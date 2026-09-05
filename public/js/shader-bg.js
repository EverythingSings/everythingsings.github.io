/**
 * EverythingSings background gallery.
 * Progressive enhancement: the page remains complete if WebGL or JavaScript fails.
 */
(function () {
  'use strict';

  const SHADERS = [
    { id: 'flow', name: 'Flow' },
    { id: 'fbm', name: 'Cloud Field' },
    { id: 'voronoi', name: 'Voronoi' },
    { id: 'waves', name: 'Waves' },
    { id: 'neural', name: 'Neural' },
    { id: 'plasma', name: 'Plasma' },
    { id: 'aurora', name: 'Aurora' },
    { id: 'ripple', name: 'Ripple' },
    { id: 'spiral', name: 'Spiral' },
    { id: 'matrix', name: 'Matrix' },
    { id: 'smoke', name: 'Smoke' },
    { id: 'strata', name: 'Strata' },
    { id: 'eclipse', name: 'Eclipse' },
    { id: 'lattice', name: 'Lattice' },
    { id: 'rain', name: 'Night Rain' },
    { id: 'cells', name: 'Cells' },
    { id: 'moire', name: 'Moire' },
    { id: 'embers', name: 'Embers' },
    { id: 'dunes', name: 'Dunes' },
    { id: 'filament', name: 'Filament' },
    { id: 'halftone', name: 'Halftone' },
    { id: 'topography', name: 'Topography' },
    { id: 'rorschach', name: 'Rorschach' },
    { id: 'constellation', name: 'Constellation' },
    { id: 'caustics', name: 'Caustics' },
    { id: 'scan', name: 'Slow Scan' },
    { id: 'iris', name: 'Iris' },
    { id: 'paper', name: 'Paper Grain' },
    { id: 'kintsugi', name: 'Kintsugi' },
    { id: 'tesseract', name: 'Tesseract' },
    { id: 'pulse', name: 'Deep Pulse' },
    { id: 'magnetosphere', name: 'Magnetosphere' },
    { id: 'seismic', name: 'Seismic' },
    { id: 'weaver', name: 'Weaver' },
    { id: 'cathedral', name: 'Cathedral' },
    { id: 'driftice', name: 'Drift Ice' },
    { id: 'phyllotaxis', name: 'Phyllotaxis' },
    { id: 'ferrofluid', name: 'Ferrofluid' },
    { id: 'braid', name: 'Five Strands' },
    { id: 'barcode', name: 'Barcode' },
    { id: 'tidepool', name: 'Tidepool' },
    { id: 'quipu', name: 'Quipu' },
    { id: 'circuit', name: 'Circuit' },
    { id: 'sundial', name: 'Sundial' },
    { id: 'murmuration', name: 'Murmuration' },
    { id: 'lumen', name: 'Lumen' },
    { id: 'isobars', name: 'Isobars' },
    { id: 'morse', name: 'Morse' },
    { id: 'orbital', name: 'Orbital' },
    { id: 'pollen', name: 'Pollen' },
    { id: 'mercator', name: 'Soft Mercator' },
    { id: 'gravitywell', name: 'Gravity Well' },
    { id: 'tally', name: 'Tally' },
    { id: 'aeolian', name: 'Aeolian' },
    { id: 'sandglass', name: 'Sandglass' },
    { id: 'mica', name: 'Mica' },
    { id: 'chladni', name: 'Chladni' },
    { id: 'radar', name: 'Radar' },
    { id: 'spectrogram', name: 'Spectrogram' },
    { id: 'vectorfield', name: 'Vector Field' },
    { id: 'catenary', name: 'Catenary' },
    { id: 'braille', name: 'Braille' },
    { id: 'suture', name: 'Suture' },
    { id: 'clockwork', name: 'Clockwork' },
    { id: 'chromatogram', name: 'Chromatogram' },
    { id: 'anemometer', name: 'Anemometer' },
    { id: 'rosette', name: 'Rosette' },
    { id: 'telemetry', name: 'Telemetry' },
    { id: 'perforation', name: 'Perforation' },
    { id: 'bellows', name: 'Bellows' },
    { id: 'transit', name: 'Transit' },
    { id: 'lacuna', name: 'Lacuna', featured: true, fullRange: true, renderPixels: 1100000 },
    { id: 'silkcurrent', name: 'Silk Current', featured: true, fullRange: true, renderPixels: 2200000 },
    { id: 'tidalmemory', name: 'Tidal Memory', featured: true, fullRange: true, renderPixels: 1400000 },
    { id: 'orbitalloom', name: 'Orbital Loom', featured: true, fullRange: true, renderPixels: 1100000 },
    { id: 'prismaticfold', name: 'Prismatic Fold', featured: true, fullRange: true, renderPixels: 2000000 },
    { id: 'noctiluca', name: 'Noctiluca', featured: true, fullRange: true, renderPixels: 1800000 },
    { id: 'aperturechoir', name: 'Aperture Choir', featured: true, fullRange: true, renderPixels: 2000000 },
    { id: 'palimpsest', name: 'Palimpsest', featured: true, fullRange: true, renderPixels: 2200000 }
  ];

  const STORAGE_KEY = 'shader-preference-v2';
  const LEGACY_STORAGE_KEY = 'shader-preference';
  const ASSET_VERSION = '2026-09-05-01';
  const MAX_CACHED_PROGRAMS = 12;
  const MAX_RENDER_PIXELS = 4000000;
  const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)');
  const vertexSource = [
    'attribute vec2 a_position;',
    'void main() { gl_Position = vec4(a_position, 0.0, 1.0); }'
  ].join('\n');
  const compositorVertexSource = [
    'attribute vec2 a_position;',
    'varying vec2 v_uv;',
    'void main() {',
    '  v_uv = a_position * 0.5 + 0.5;',
    '  gl_Position = vec4(a_position, 0.0, 1.0);',
    '}'
  ].join('\n');
  const compositorSource = [
    'precision mediump float;',
    'uniform sampler2D u_scene;',
    'uniform vec4 u_motion;',
    'uniform vec4 u_profile;',
    'uniform float u_impulse;',
    'varying vec2 v_uv;',
    'void main() {',
    '  vec2 center = v_uv - 0.5;',
    '  float angle = (u_motion.x * u_motion.w - u_motion.y * u_motion.z) * u_profile.y;',
    '  float c = cos(angle);',
    '  float s = sin(angle);',
    '  center = mat2(c, -s, s, c) * center;',
    '  float wave = sin(length(center) * 18.0 - u_impulse * 2.0);',
    '  center *= 0.955 + u_impulse * u_profile.z * wave;',
    '  vec2 uv = 0.5 + center - u_motion.xy * u_profile.x;',
    '  uv += u_motion.zw * u_profile.z * (0.12 + length(center));',
    '  uv = clamp(uv, vec2(0.006), vec2(0.994));',
    '  vec2 split = u_motion.zw * u_profile.w;',
    '  float red = texture2D(u_scene, clamp(uv + split, 0.006, 0.994)).r;',
    '  vec4 base = texture2D(u_scene, uv);',
    '  float blue = texture2D(u_scene, clamp(uv - split, 0.006, 0.994)).b;',
    '  gl_FragColor = vec4(red, base.g, blue, 1.0);',
    '}'
  ].join('\n');

  let canvas;
  let gl;
  let program;
  let geometry;
  let sceneTexture;
  let sceneFramebuffer;
  let compositorProgram;
  let compositorUniforms;
  let frame;
  let startedAt = performance.now();
  let currentIndex = 0;
  let requestSerial = 0;
  let paused = false;
  let pausedAt = 0;
  let uniforms = { time: null, resolution: null, pointer: null, impulse: null };
  let activeProfile;
  let lastFrameAt = performance.now();
  let sensorEnabled = false;
  let sensorListening = false;
  let sensorNeutral = null;
  let viewerOpen = false;
  let viewerScrollY = 0;
  const pageTitle = document.title;
  const motion = {
    target: [0, 0],
    position: [0, 0],
    velocity: [0, 0],
    impulse: 0
  };
  const sourceCache = new Map();
  const programCache = new Map();

  const wrap = (index) => (index % SHADERS.length + SHADERS.length) % SHADERS.length;
  const clamp = (value, low, high) => Math.max(low, Math.min(high, value));

  function generatedProfile(id) {
    let hash = 2166136261;
    for (let i = 0; i < id.length; i += 1) {
      hash ^= id.charCodeAt(i);
      hash = Math.imul(hash, 16777619);
    }
    const sample = (shift) => ((hash >>> shift) & 255) / 255;
    return {
      mass: 0.72 + sample(0) * 1.65,
      stiffness: 10.0 + sample(8) * 12.0,
      damping: 4.4 + sample(16) * 3.8,
      travel: 0.009 + sample(4) * 0.014,
      rotation: 0.035 + sample(12) * 0.075,
      warp: 0.003 + sample(20) * 0.008,
      chroma: 0.0002 + sample(24) * 0.0009
    };
  }

  function readPreference(key) {
    try {
      return localStorage.getItem(key);
    } catch (error) {
      console.warn('Background preference storage unavailable:', error);
      return null;
    }
  }

  function savePreference(id) {
    try {
      localStorage.setItem(STORAGE_KEY, id);
    } catch (error) {
      console.warn('Background preference could not be saved:', error);
    }
  }

  function compile(type, source) {
    const shader = gl.createShader(type);
    gl.shaderSource(shader, source);
    gl.compileShader(shader);
    if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
      console.error('Background shader compile error:', gl.getShaderInfoLog(shader));
      gl.deleteShader(shader);
      return null;
    }
    return shader;
  }

  function buildProgram(fragmentSource, customVertexSource = vertexSource) {
    const vertex = compile(gl.VERTEX_SHADER, customVertexSource);
    const fragment = compile(gl.FRAGMENT_SHADER, fragmentSource);
    if (!vertex || !fragment) {
      if (vertex) gl.deleteShader(vertex);
      if (fragment) gl.deleteShader(fragment);
      return null;
    }

    const nextProgram = gl.createProgram();
    gl.attachShader(nextProgram, vertex);
    gl.attachShader(nextProgram, fragment);
    gl.linkProgram(nextProgram);
    gl.deleteShader(vertex);
    gl.deleteShader(fragment);

    if (!gl.getProgramParameter(nextProgram, gl.LINK_STATUS)) {
      console.error('Background shader link error:', gl.getProgramInfoLog(nextProgram));
      gl.deleteProgram(nextProgram);
      return null;
    }
    return nextProgram;
  }

  function bindGeometry(targetProgram) {
    gl.useProgram(targetProgram);
    gl.bindBuffer(gl.ARRAY_BUFFER, geometry);
    const position = gl.getAttribLocation(targetProgram, 'a_position');
    if (position < 0) return false;
    gl.enableVertexAttribArray(position);
    gl.vertexAttribPointer(position, 2, gl.FLOAT, false, 0, 0);
    return true;
  }

  function destroyRenderTarget() {
    if (sceneFramebuffer) gl.deleteFramebuffer(sceneFramebuffer);
    if (sceneTexture) gl.deleteTexture(sceneTexture);
    sceneFramebuffer = null;
    sceneTexture = null;
  }

  function createRenderTarget(width, height) {
    destroyRenderTarget();
    sceneTexture = gl.createTexture();
    gl.bindTexture(gl.TEXTURE_2D, sceneTexture);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, width, height, 0, gl.RGBA, gl.UNSIGNED_BYTE, null);

    sceneFramebuffer = gl.createFramebuffer();
    gl.bindFramebuffer(gl.FRAMEBUFFER, sceneFramebuffer);
    gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, sceneTexture, 0);
    const complete = gl.checkFramebufferStatus(gl.FRAMEBUFFER) === gl.FRAMEBUFFER_COMPLETE;
    gl.bindFramebuffer(gl.FRAMEBUFFER, null);
    if (!complete) {
      console.warn('Background motion compositor unavailable: incomplete framebuffer.');
      destroyRenderTarget();
    }
    return complete;
  }

  function setupCompositor() {
    compositorProgram = buildProgram(compositorSource, compositorVertexSource);
    if (!compositorProgram) return false;
    compositorUniforms = {
      scene: gl.getUniformLocation(compositorProgram, 'u_scene'),
      motion: gl.getUniformLocation(compositorProgram, 'u_motion'),
      profile: gl.getUniformLocation(compositorProgram, 'u_profile'),
      impulse: gl.getUniformLocation(compositorProgram, 'u_impulse')
    };
    return true;
  }

  function rememberProgram(id, nextProgram) {
    programCache.delete(id);
    programCache.set(id, nextProgram);
    while (programCache.size > MAX_CACHED_PROGRAMS) {
      const oldestId = programCache.keys().next().value;
      const oldestProgram = programCache.get(oldestId);
      programCache.delete(oldestId);
      if (oldestProgram !== program) gl.deleteProgram(oldestProgram);
    }
  }

  async function sourceFor(shader) {
    if (sourceCache.has(shader.id)) return sourceCache.get(shader.id);
    const response = await fetch(`/shaders/${shader.id}.glsl?v=${ASSET_VERSION}`);
    if (!response.ok) throw new Error(`${response.status} loading ${shader.id}`);
    const source = await response.text();
    sourceCache.set(shader.id, source);
    return source;
  }

  function updateControls() {
    const shader = SHADERS[currentIndex];
    const name = document.getElementById('background-current');
    const status = document.getElementById('background-status');
    const options = document.querySelectorAll('.background-option');
    if (name) name.textContent = shader.name;
    if (status) status.textContent = `${viewerOpen ? 'Study' : 'Background'}: ${shader.name}, ${currentIndex + 1} of ${SHADERS.length}`;
    let visibleTabStop = false;
    options.forEach((option) => {
      const active = Number(option.dataset.index) === currentIndex;
      option.classList.toggle('is-active', active);
      option.setAttribute('aria-selected', active ? 'true' : 'false');
      const activeAndVisible = active && !option.hidden;
      option.tabIndex = activeAndVisible ? 0 : -1;
      if (activeAndVisible) visibleTabStop = true;
    });
    if (!visibleTabStop) {
      const firstVisible = Array.from(options).find((option) => !option.hidden);
      if (firstVisible) firstVisible.tabIndex = 0;
    }
    updateViewer();
    if (viewerOpen) writeViewerUrl();
  }

  function studyUrl() {
    const url = new URL(window.location.href);
    url.searchParams.set('study', SHADERS[currentIndex].id);
    url.searchParams.set('view', 'art');
    return url;
  }

  function writeViewerUrl(push = false) {
    const url = viewerOpen ? studyUrl() : new URL(window.location.href);
    if (!viewerOpen) {
      url.searchParams.delete('study');
      url.searchParams.delete('view');
    }
    if (url.href === window.location.href) return;
    try {
      if (push) history.pushState(null, '', url);
      else history.replaceState(history.state, '', url);
    } catch (error) {
      // Viewing still works in embeds that disallow history changes.
    }
  }

  function updateViewer() {
    const title = document.getElementById('art-title');
    if (!title) return;
    const shader = SHADERS[currentIndex];
    title.textContent = shader.name;
    document.getElementById('art-position').textContent =
      `Study ${String(currentIndex + 1).padStart(2, '0')} / ${SHADERS.length}`;
    document.getElementById('art-share-fallback').hidden = true;
    document.getElementById('art-notice').textContent = '';
    document.querySelector('.background-panel-heading span:first-child').textContent = viewerOpen ? 'Studies' : 'Backgrounds';
    const filter = document.getElementById('background-filter');
    const filterLabel = viewerOpen ? 'Find a study' : 'Find a background';
    filter.placeholder = filterLabel;
    filter.setAttribute('aria-label', filterLabel);
    document.getElementById('background-panel').setAttribute('aria-label', viewerOpen ? 'Choose a study' : 'Choose a background');
    document.getElementById('background-status').textContent =
      `${viewerOpen ? 'Study' : 'Background'}: ${shader.name}, ${currentIndex + 1} of ${SHADERS.length}`;
    document.title = viewerOpen ? `${shader.name} | EverythingSings` : pageTitle;
  }

  function setViewer(open, updateUrl = true) {
    const viewer = document.getElementById('art-viewer');
    if (!viewer || (open && (!program || reducedMotion.matches))) return;
    if (open === viewerOpen) return;
    setPanel(false);
    if (open) viewerScrollY = window.scrollY;
    viewerOpen = open;
    viewer.hidden = !open;
    document.body.classList.toggle('art-viewing', open);
    document.querySelectorAll('main, body > footer').forEach((element) => {
      element.inert = open;
      if (open) element.setAttribute('aria-hidden', 'true');
      else element.removeAttribute('aria-hidden');
    });
    updateViewer();
    if (updateUrl) writeViewerUrl(open);
    if (open) viewer.focus({ preventScroll: true });
    else {
      window.scrollTo(0, viewerScrollY);
      requestAnimationFrame(() => {
        if (!viewerOpen) document.getElementById('art-enter').focus({ preventScroll: true });
      });
    }
  }

  function setPaused(next) {
    if (paused === next) return;
    paused = next;
    document.querySelectorAll('#background-motion, #art-motion').forEach((button) => {
      button.setAttribute('aria-pressed', paused ? 'true' : 'false');
      button.textContent = button.id === 'art-motion'
        ? (paused ? 'Play' : 'Pause') : (paused ? 'Resume motion' : 'Pause motion');
    });
    if (paused) {
      pausedAt = performance.now();
      cancelAnimationFrame(frame);
      stopSensorListeners();
    } else {
      startedAt += performance.now() - pausedAt;
      startSensorListeners();
      lastFrameAt = performance.now();
      if (!document.hidden && !reducedMotion.matches) frame = requestAnimationFrame(render);
    }
  }

  function buildViewer() {
    const entry = document.getElementById('art-enter');
    if (!entry) return;
    entry.closest('.art-entry').hidden = false;
    entry.addEventListener('click', () => setViewer(true));
    document.getElementById('art-exit').addEventListener('click', () => setViewer(false));
    document.getElementById('art-choose').addEventListener('click', () => {
      setPanel(document.getElementById('background-panel').hidden);
    });
    document.getElementById('art-prev').addEventListener('click', () => select(currentIndex - 1));
    document.getElementById('art-next').addEventListener('click', () => select(currentIndex + 1));
    document.getElementById('art-motion').addEventListener('click', () => setPaused(!paused));
    document.getElementById('art-share').addEventListener('click', async () => {
      const url = studyUrl().href;
      try {
        await navigator.clipboard.writeText(url);
        if (!viewerOpen || studyUrl().href !== url) return;
        document.getElementById('art-notice').textContent = 'Link copied';
      } catch (error) {
        if (!viewerOpen || studyUrl().href !== url) return;
        document.getElementById('art-share-fallback').hidden = false;
        const input = document.getElementById('art-share-url');
        input.value = url;
        input.focus();
        input.select();
      }
    });
    window.addEventListener('popstate', () => {
      const index = initialIndex();
      setViewer(new URL(window.location.href).searchParams.get('view') === 'art', false);
      select(index);
    });
    if (new URL(window.location.href).searchParams.get('view') === 'art') setViewer(true, false);
  }

  async function select(index, attempts = 0) {
    if (!gl || attempts >= SHADERS.length) return;
    const targetIndex = wrap(index);
    const serial = ++requestSerial;
    const shader = SHADERS[targetIndex];

    try {
      const source = await sourceFor(shader);
      if (serial !== requestSerial) return;
      let nextProgram = programCache.get(shader.id);
      if (!nextProgram) {
        nextProgram = buildProgram(source);
      }
      if (!nextProgram) {
        await select(targetIndex + 1, attempts + 1);
        return;
      }
      program = nextProgram;
      rememberProgram(shader.id, nextProgram);
      bindGeometry(program);
      uniforms = {
        time: gl.getUniformLocation(program, 'u_time'),
        resolution: gl.getUniformLocation(program, 'u_resolution'),
        pointer: gl.getUniformLocation(program, 'u_pointer'),
        impulse: gl.getUniformLocation(program, 'u_impulse')
      };

      currentIndex = targetIndex;
      activeProfile = generatedProfile(shader.id);
      canvas.style.setProperty('--study-background-exposure', shader.fullRange ? '0.16' : '1');
      canvas.style.setProperty('--study-view-exposure', shader.fullRange ? '1' : '4');
      savePreference(shader.id);
      updateControls();
      resize();
      if (paused || reducedMotion.matches) render(paused ? pausedAt : performance.now());
    } catch (error) {
      console.warn(`Background "${shader.name}" unavailable:`, error);
      if (serial === requestSerial) await select(targetIndex + 1, attempts + 1);
    }
  }

  function resize() {
    if (!gl) return;
    const cssPixels = Math.max(1, window.innerWidth * window.innerHeight);
    const pixelBudget = SHADERS[currentIndex].renderPixels || MAX_RENDER_PIXELS;
    const pixelBudgetScale = Math.sqrt(pixelBudget / cssPixels);
    const dpr = Math.min(window.devicePixelRatio || 1, 2, pixelBudgetScale);
    const width = Math.max(1, Math.round(window.innerWidth * dpr));
    const height = Math.max(1, Math.round(window.innerHeight * dpr));
    if (canvas.width !== width || canvas.height !== height || !sceneFramebuffer) {
      canvas.width = width;
      canvas.height = height;
      gl.viewport(0, 0, width, height);
      createRenderTarget(width, height);
      if (program && paused) render(pausedAt);
    }
  }

  function revealActiveOption(list) {
    const active = list.querySelector('.background-option.is-active:not([hidden])');
    if (!active) return;
    const itemTop = active.offsetTop - list.offsetTop;
    const centered = itemTop - (list.clientHeight - active.offsetHeight) / 2;
    list.scrollTop = Math.max(0, centered);
  }

  function setupGraphics() {
    gl = canvas.getContext('webgl', { alpha: false, antialias: false, powerPreference: 'low-power' });
    if (!gl) return false;
    geometry = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, geometry);
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([-1, -1, 1, -1, -1, 1, -1, 1, 1, -1, 1, 1]), gl.STATIC_DRAW);
    return setupCompositor();
  }

  function updateMotion(now) {
    const dt = clamp((now - lastFrameAt) / 1000, 1 / 120, 1 / 20);
    lastFrameAt = now;
    const profile = activeProfile || generatedProfile('flow');
    const spring = profile.stiffness / profile.mass;
    const drag = Math.exp(-profile.damping * dt / profile.mass);

    for (let axis = 0; axis < 2; axis += 1) {
      const acceleration = (motion.target[axis] - motion.position[axis]) * spring;
      motion.velocity[axis] = (motion.velocity[axis] + acceleration * dt) * drag;
      motion.position[axis] = clamp(motion.position[axis] + motion.velocity[axis] * dt, -1.25, 1.25);
    }
    motion.impulse *= Math.exp(-5.5 * dt);
  }

  function screenAngle() {
    if (screen.orientation && Number.isFinite(screen.orientation.angle)) return screen.orientation.angle;
    return Number.isFinite(window.orientation) ? window.orientation : 0;
  }

  function orientToScreen(x, y) {
    const angle = ((screenAngle() % 360) + 360) % 360;
    if (angle === 90) return [-y, x];
    if (angle === 180) return [-x, -y];
    if (angle === 270) return [y, -x];
    return [x, y];
  }

  function handleOrientation(event) {
    if (document.hidden || !sensorEnabled || !Number.isFinite(event.beta) || !Number.isFinite(event.gamma)) return;
    if (!sensorNeutral) sensorNeutral = { beta: event.beta, gamma: event.gamma };
    const deltaGamma = clamp((event.gamma - sensorNeutral.gamma) / 28, -1, 1);
    const deltaBeta = clamp((event.beta - sensorNeutral.beta) / 28, -1, 1);
    const oriented = orientToScreen(deltaGamma, -deltaBeta);
    motion.target[0] = oriented[0];
    motion.target[1] = oriented[1];
  }

  function handleDeviceMotion(event) {
    if (document.hidden || !sensorEnabled) return;
    const acceleration = event.acceleration;
    if (!acceleration) return;
    const x = Number.isFinite(acceleration.x) ? acceleration.x : 0;
    const y = Number.isFinite(acceleration.y) ? acceleration.y : 0;
    const z = Number.isFinite(acceleration.z) ? acceleration.z : 0;
    const magnitude = Math.sqrt(x * x + y * y + z * z);
    motion.impulse = Math.max(motion.impulse, clamp((magnitude - 2.2) / 8.5, 0, 1));
  }

  function startSensorListeners() {
    if (!sensorEnabled || sensorListening || document.hidden || paused || reducedMotion.matches) return;
    window.addEventListener('deviceorientation', handleOrientation, { passive: true });
    window.addEventListener('devicemotion', handleDeviceMotion, { passive: true });
    sensorListening = true;
  }

  function stopSensorListeners() {
    if (!sensorListening) return;
    window.removeEventListener('deviceorientation', handleOrientation);
    window.removeEventListener('devicemotion', handleDeviceMotion);
    sensorListening = false;
  }

  function setInputStatus(message) {
    const status = document.getElementById('background-input-status');
    if (status) status.textContent = message;
  }

  function setTiltButton(active, label, disabled = false) {
    const button = document.getElementById('background-tilt');
    if (!button) return;
    button.setAttribute('aria-pressed', active ? 'true' : 'false');
    button.textContent = label;
    button.disabled = disabled;
  }

  async function requestMotionPermission() {
    const requests = [];
    if (typeof DeviceOrientationEvent !== 'undefined'
      && typeof DeviceOrientationEvent.requestPermission === 'function') {
      requests.push(DeviceOrientationEvent.requestPermission());
    }
    if (typeof DeviceMotionEvent !== 'undefined'
      && typeof DeviceMotionEvent.requestPermission === 'function') {
      requests.push(DeviceMotionEvent.requestPermission());
    }
    if (requests.length === 0) return true;
    const permissions = await Promise.all(requests);
    return permissions.every((permission) => permission === 'granted');
  }

  async function toggleTilt() {
    if (sensorEnabled) {
      sensorEnabled = false;
      sensorNeutral = null;
      stopSensorListeners();
      motion.target[0] = 0;
      motion.target[1] = 0;
      setTiltButton(false, 'Enable tilt');
      setInputStatus('Pointer-responsive - sensors stay local');
      return;
    }

    setTiltButton(false, 'Requesting...', true);
    try {
      if (!await requestMotionPermission()) throw new Error('permission denied');
      sensorEnabled = true;
      sensorNeutral = null;
      startSensorListeners();
      setTiltButton(true, 'Tilt active');
      setInputStatus('Tilt-responsive - sensors stay local');
    } catch (error) {
      console.warn('Background tilt input unavailable:', error);
      setTiltButton(false, 'Enable tilt');
      setInputStatus('Tilt permission unavailable - pointer-responsive');
    }
  }

  function setupMotionInput() {
    const tilt = document.getElementById('background-tilt');
    const hasOrientation = typeof DeviceOrientationEvent !== 'undefined' && navigator.maxTouchPoints > 0;
    if (tilt && hasOrientation) {
      tilt.hidden = false;
      tilt.addEventListener('click', toggleTilt);
      setInputStatus('Pointer-responsive - tilt available');
    } else {
      setInputStatus('Pointer-responsive');
    }

    window.addEventListener('pointermove', (event) => {
      if (sensorEnabled || document.hidden) return;
      motion.target[0] = clamp((event.clientX / Math.max(1, window.innerWidth) - 0.5) * 1.6, -0.8, 0.8);
      motion.target[1] = clamp((0.5 - event.clientY / Math.max(1, window.innerHeight)) * 1.6, -0.8, 0.8);
    }, { passive: true });
    document.documentElement.addEventListener('pointerleave', () => {
      if (sensorEnabled) return;
      motion.target[0] = 0;
      motion.target[1] = 0;
    }, { passive: true });
    window.addEventListener('pointerdown', (event) => {
      if (sensorEnabled || (event.target instanceof Element && event.target.closest('button, input, a'))) return;
      motion.impulse = Math.max(motion.impulse, 0.32);
    }, { passive: true });
  }

  function render(now) {
    if (program) {
      updateMotion(now);
      const compositing = Boolean(sceneFramebuffer && sceneTexture && compositorProgram && compositorUniforms);
      gl.bindFramebuffer(gl.FRAMEBUFFER, compositing ? sceneFramebuffer : null);
      gl.viewport(0, 0, canvas.width, canvas.height);
      bindGeometry(program);
      if (uniforms.time !== null) gl.uniform1f(uniforms.time, (now - startedAt) / 1000);
      if (uniforms.resolution !== null) gl.uniform2f(uniforms.resolution, canvas.width, canvas.height);
      if (uniforms.pointer !== null) gl.uniform2f(uniforms.pointer, motion.position[0], motion.position[1]);
      if (uniforms.impulse !== null) gl.uniform1f(uniforms.impulse, motion.impulse);
      gl.drawArrays(gl.TRIANGLES, 0, 6);

      if (compositing) {
        gl.bindFramebuffer(gl.FRAMEBUFFER, null);
        bindGeometry(compositorProgram);
        gl.activeTexture(gl.TEXTURE0);
        gl.bindTexture(gl.TEXTURE_2D, sceneTexture);
        gl.uniform1i(compositorUniforms.scene, 0);
        gl.uniform4f(
          compositorUniforms.motion,
          motion.position[0], motion.position[1], motion.velocity[0], motion.velocity[1]
        );
        gl.uniform4f(
          compositorUniforms.profile,
          activeProfile.travel, activeProfile.rotation, activeProfile.warp, activeProfile.chroma
        );
        gl.uniform1f(compositorUniforms.impulse, motion.impulse);
        gl.drawArrays(gl.TRIANGLES, 0, 6);
      }
    }
    if (!paused && !document.hidden && !reducedMotion.matches) frame = requestAnimationFrame(render);
  }

  function setPanel(open, returnFocus = false) {
    const tab = document.getElementById('background-tab');
    const panel = document.getElementById('background-panel');
    if (!tab || !panel) return;
    tab.setAttribute('aria-expanded', open ? 'true' : 'false');
    const choose = document.getElementById('art-choose');
    if (choose) choose.setAttribute('aria-expanded', open ? 'true' : 'false');
    panel.hidden = !open;
    document.body.classList.toggle('background-panel-open', open);
    if (open) {
      const active = panel.querySelector('.background-option.is-active:not([hidden])')
        || panel.querySelector('.background-option:not([hidden])')
        || document.getElementById('background-filter');
      if (active) {
        active.focus({ preventScroll: true });
        const list = document.getElementById('background-list');
        revealActiveOption(list);
      }
    } else if (returnFocus) {
      (viewerOpen ? choose : tab).focus({ preventScroll: true });
    }
  }

  function buildControls() {
    const tab = document.getElementById('background-tab');
    const panel = document.getElementById('background-panel');
    const list = document.getElementById('background-list');
    if (!tab || !panel || !list) return;

    const count = document.getElementById('background-count');
    if (count) count.textContent = `${SHADERS.length} studies`;

    const galleryOrder = SHADERS.map((shader, index) => ({ shader, index }))
      .sort((a, b) => Number(Boolean(b.shader.featured)) - Number(Boolean(a.shader.featured)));
    list.replaceChildren(...galleryOrder.map(({ shader, index }) => {
      const button = document.createElement('button');
      button.type = 'button';
      button.className = 'background-option';
      button.setAttribute('role', 'option');
      button.dataset.index = index.toString();
      button.dataset.name = shader.name.toLocaleLowerCase();
      if (shader.featured) button.dataset.new = 'true';
      button.innerHTML = `<span class="background-swatch swatch-${shader.id}" aria-hidden="true"></span><span>${shader.name}</span>`;
      const chooseStudy = async () => {
        await select(index);
        if (viewerOpen) setPanel(false, true);
      };
      button.addEventListener('click', chooseStudy);
      button.addEventListener('keydown', (event) => {
        if (event.key === 'Enter' || event.key === ' ') {
          event.preventDefault();
          chooseStudy();
          return;
        }
        if (!['ArrowDown', 'ArrowRight', 'ArrowUp', 'ArrowLeft', 'Home', 'End'].includes(event.key)) return;
        event.preventDefault();
        const visible = Array.from(list.children).filter((option) => !option.hidden);
        const visibleIndex = visible.indexOf(button);
        let next = visibleIndex;
        if (event.key === 'ArrowDown' || event.key === 'ArrowRight') next = (visibleIndex + 1) % visible.length;
        if (event.key === 'ArrowUp' || event.key === 'ArrowLeft') next = (visibleIndex - 1 + visible.length) % visible.length;
        if (event.key === 'Home') next = 0;
        if (event.key === 'End') next = visible.length - 1;
        visible[next].focus();
      });
      return button;
    }));

    const filter = document.getElementById('background-filter');
    const empty = document.getElementById('background-empty');
    filter.addEventListener('input', () => {
      const query = filter.value.trim().toLocaleLowerCase();
      let visibleCount = 0;
      const visibleOptions = [];
      Array.from(list.children).forEach((option) => {
        option.hidden = query !== '' && !option.dataset.name.includes(query);
        if (!option.hidden) {
          visibleCount += 1;
          visibleOptions.push(option);
        }
      });
      count.textContent = query ? `${visibleCount} of ${SHADERS.length}` : `${SHADERS.length} studies`;
      empty.hidden = visibleCount !== 0;
      if (query === '') {
        updateControls();
        revealActiveOption(list);
      } else {
        const focusTarget = visibleOptions.find((option) => option.classList.contains('is-active'))
          || visibleOptions[0];
        visibleOptions.forEach((option) => { option.tabIndex = option === focusTarget ? 0 : -1; });
      }
    });
    filter.addEventListener('keydown', (event) => {
      if (event.key !== 'ArrowDown') return;
      const target = Array.from(list.children)
        .find((option) => !option.hidden && option.tabIndex === 0);
      if (!target) return;
      event.preventDefault();
      target.focus();
    });

    tab.addEventListener('click', () => setPanel(tab.getAttribute('aria-expanded') !== 'true'));
    tab.addEventListener('keydown', (event) => {
      if (event.key !== 'Enter' && event.key !== ' ') return;
      event.preventDefault();
      setPanel(tab.getAttribute('aria-expanded') !== 'true');
    });
    document.getElementById('background-prev').addEventListener('click', () => select(currentIndex - 1));
    document.getElementById('background-next').addEventListener('click', () => select(currentIndex + 1));
    document.getElementById('background-shuffle').addEventListener('click', () => {
      const offset = 1 + Math.floor(Math.random() * (SHADERS.length - 1));
      select(currentIndex + offset);
    });
    setupMotionInput();
    document.getElementById('background-motion').addEventListener('click', () => setPaused(!paused));

    document.addEventListener('pointerdown', (event) => {
      if (!panel.hidden && !panel.contains(event.target) && !tab.contains(event.target)
        && !event.target.closest('#art-choose')) setPanel(false);
    });
    document.addEventListener('keydown', (event) => {
      if (event.key === 'Escape' && !panel.hidden) {
        event.preventDefault();
        setPanel(false, true);
        return;
      }
      if (viewerOpen && event.key === 'Escape') {
        event.preventDefault();
        setViewer(false);
        return;
      }
      if (viewerOpen && panel.hidden && !event.target.closest('input, textarea, select')) {
        if (event.key === 'ArrowRight' || event.key === 'ArrowLeft') {
          event.preventDefault();
          select(currentIndex + (event.key === 'ArrowRight' ? 1 : -1));
          return;
        }
        if (event.key === ' ' && !event.target.closest('button, a')) {
          event.preventDefault();
          setPaused(!paused);
          return;
        }
      }
      if (event.target.closest('input, textarea, select, button, a')) return;
      if (event.key === 'ArrowRight') select(currentIndex + 1);
      if (event.key === 'ArrowLeft') select(currentIndex - 1);
    });
  }

  function initialIndex() {
    const sharedId = new URL(window.location.href).searchParams.get('study');
    const sharedIndex = SHADERS.findIndex((shader) => shader.id === sharedId);
    if (sharedIndex >= 0) return sharedIndex;
    const savedId = readPreference(STORAGE_KEY);
    const savedIndex = SHADERS.findIndex((shader) => shader.id === savedId);
    if (savedIndex >= 0) return savedIndex;
    const legacy = Number.parseInt(readPreference(LEGACY_STORAGE_KEY), 10);
    if (Number.isInteger(legacy) && legacy >= 0 && legacy < 11) return legacy;
    const featured = SHADERS.map((shader, index) => shader.featured ? index : -1).filter((index) => index >= 0);
    return featured.length ? featured[Math.floor(Math.random() * featured.length)] : Math.floor(Math.random() * SHADERS.length);
  }

  async function init() {
    canvas = document.getElementById('shader-canvas');
    if (!canvas || reducedMotion.matches) return;
    if (!setupGraphics()) return;

    document.documentElement.classList.add('webgl-backgrounds');
    buildControls();
    resize();
    await select(initialIndex());
    if (!program) {
      document.documentElement.classList.remove('webgl-backgrounds');
      return;
    }
    buildViewer();
    frame = requestAnimationFrame(render);
    window.addEventListener('resize', resize, { passive: true });
    canvas.addEventListener('webglcontextlost', (event) => {
      event.preventDefault();
      setViewer(false);
      document.documentElement.classList.remove('webgl-backgrounds');
      cancelAnimationFrame(frame);
      program = null;
      compositorProgram = null;
      compositorUniforms = null;
      sceneTexture = null;
      sceneFramebuffer = null;
      programCache.clear();
    });
    canvas.addEventListener('webglcontextrestored', async () => {
      if (!setupGraphics()) return;
      resize();
      startedAt = performance.now();
      await select(currentIndex);
      document.documentElement.classList.toggle('webgl-backgrounds', Boolean(program) && !reducedMotion.matches);
      if (!paused && !reducedMotion.matches && !document.hidden) frame = requestAnimationFrame(render);
    });
    document.addEventListener('visibilitychange', () => {
      if (document.hidden) {
        cancelAnimationFrame(frame);
        stopSensorListeners();
      } else {
        startSensorListeners();
        lastFrameAt = performance.now();
        if (!paused && !reducedMotion.matches) frame = requestAnimationFrame(render);
      }
    });
    reducedMotion.addEventListener('change', (event) => {
      if (event.matches) {
        setViewer(false);
        document.documentElement.classList.remove('webgl-backgrounds');
        cancelAnimationFrame(frame);
        stopSensorListeners();
      } else {
        document.documentElement.classList.add('webgl-backgrounds');
        if (!paused && !document.hidden) {
          startSensorListeners();
          lastFrameAt = performance.now();
          frame = requestAnimationFrame(render);
        }
      }
    });
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
  else init();
})();
