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
    { id: 'transit', name: 'Transit' }
  ];

  const STORAGE_KEY = 'shader-preference-v2';
  const LEGACY_STORAGE_KEY = 'shader-preference';
  const ASSET_VERSION = '2026-08-08-09';
  const MAX_CACHED_PROGRAMS = 12;
  const MAX_RENDER_PIXELS = 4000000;
  const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)');
  const vertexSource = [
    'attribute vec2 a_position;',
    'void main() { gl_Position = vec4(a_position, 0.0, 1.0); }'
  ].join('\n');

  let canvas;
  let gl;
  let program;
  let geometry;
  let frame;
  let startedAt = performance.now();
  let currentIndex = 0;
  let requestSerial = 0;
  let paused = false;
  let pausedAt = 0;
  let uniforms = { time: null, resolution: null };
  const sourceCache = new Map();
  const programCache = new Map();

  const wrap = (index) => (index % SHADERS.length + SHADERS.length) % SHADERS.length;

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

  function buildProgram(fragmentSource) {
    const vertex = compile(gl.VERTEX_SHADER, vertexSource);
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
    if (status) status.textContent = `Background: ${shader.name}, ${currentIndex + 1} of ${SHADERS.length}`;
    let visibleTabStop = false;
    options.forEach((option, index) => {
      const active = index === currentIndex;
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
      gl.useProgram(program);
      gl.bindBuffer(gl.ARRAY_BUFFER, geometry);
      const position = gl.getAttribLocation(program, 'a_position');
      gl.enableVertexAttribArray(position);
      gl.vertexAttribPointer(position, 2, gl.FLOAT, false, 0, 0);
      uniforms = {
        time: gl.getUniformLocation(program, 'u_time'),
        resolution: gl.getUniformLocation(program, 'u_resolution')
      };

      currentIndex = targetIndex;
      savePreference(shader.id);
      updateControls();
      if (paused) render(performance.now());
    } catch (error) {
      console.warn(`Background "${shader.name}" unavailable:`, error);
      if (serial === requestSerial) await select(targetIndex + 1, attempts + 1);
    }
  }

  function resize() {
    if (!gl) return;
    const cssPixels = Math.max(1, window.innerWidth * window.innerHeight);
    const pixelBudgetScale = Math.sqrt(MAX_RENDER_PIXELS / cssPixels);
    const dpr = Math.min(window.devicePixelRatio || 1, 2, pixelBudgetScale);
    const width = Math.max(1, Math.round(window.innerWidth * dpr));
    const height = Math.max(1, Math.round(window.innerHeight * dpr));
    if (canvas.width !== width || canvas.height !== height) {
      canvas.width = width;
      canvas.height = height;
      gl.viewport(0, 0, width, height);
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
    return true;
  }

  function render(now) {
    if (program) {
      gl.useProgram(program);
      if (uniforms.time !== null) gl.uniform1f(uniforms.time, (now - startedAt) / 1000);
      if (uniforms.resolution !== null) gl.uniform2f(uniforms.resolution, canvas.width, canvas.height);
      gl.drawArrays(gl.TRIANGLES, 0, 6);
    }
    if (!paused) frame = requestAnimationFrame(render);
  }

  function setPanel(open, returnFocus = false) {
    const tab = document.getElementById('background-tab');
    const panel = document.getElementById('background-panel');
    if (!tab || !panel) return;
    tab.setAttribute('aria-expanded', open ? 'true' : 'false');
    panel.hidden = !open;
    document.body.classList.toggle('background-panel-open', open);
    if (open) {
      const active = panel.querySelector('.background-option.is-active');
      if (active) {
        active.focus({ preventScroll: true });
        const list = document.getElementById('background-list');
        revealActiveOption(list);
      }
    } else if (returnFocus) {
      tab.focus({ preventScroll: true });
    }
  }

  function buildControls() {
    const tab = document.getElementById('background-tab');
    const panel = document.getElementById('background-panel');
    const list = document.getElementById('background-list');
    if (!tab || !panel || !list) return;

    const count = document.getElementById('background-count');
    if (count) count.textContent = `${SHADERS.length} studies`;

    list.replaceChildren(...SHADERS.map((shader, index) => {
      const button = document.createElement('button');
      button.type = 'button';
      button.className = 'background-option';
      button.setAttribute('role', 'option');
      button.dataset.index = index.toString();
      button.dataset.name = shader.name.toLocaleLowerCase();
      button.innerHTML = `<span class="background-swatch swatch-${shader.id}" aria-hidden="true"></span><span>${shader.name}</span>`;
      button.addEventListener('click', () => select(index));
      button.addEventListener('keydown', (event) => {
        if (event.key === 'Enter' || event.key === ' ') {
          event.preventDefault();
          select(index);
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
    document.getElementById('background-motion').addEventListener('click', (event) => {
      const button = event.currentTarget;
      paused = !paused;
      button.setAttribute('aria-pressed', paused ? 'true' : 'false');
      button.textContent = paused ? 'Resume motion' : 'Pause motion';
      if (paused) {
        pausedAt = performance.now();
        cancelAnimationFrame(frame);
      } else {
        startedAt += performance.now() - pausedAt;
        frame = requestAnimationFrame(render);
      }
    });

    document.addEventListener('pointerdown', (event) => {
      if (!panel.hidden && !panel.contains(event.target) && !tab.contains(event.target)) setPanel(false);
    });
    document.addEventListener('keydown', (event) => {
      if (event.key === 'Escape' && !panel.hidden) {
        event.preventDefault();
        setPanel(false, true);
        return;
      }
      if (event.target.closest('input, textarea, select, button, a')) return;
      if (event.key === 'ArrowRight') select(currentIndex + 1);
      if (event.key === 'ArrowLeft') select(currentIndex - 1);
    });
  }

  function initialIndex() {
    const savedId = readPreference(STORAGE_KEY);
    const savedIndex = SHADERS.findIndex((shader) => shader.id === savedId);
    if (savedIndex >= 0) return savedIndex;
    const legacy = Number.parseInt(readPreference(LEGACY_STORAGE_KEY), 10);
    if (Number.isInteger(legacy) && legacy >= 0 && legacy < 11) return legacy;
    return Math.floor(Math.random() * SHADERS.length);
  }

  async function init() {
    canvas = document.getElementById('shader-canvas');
    if (!canvas || reducedMotion.matches) return;
    if (!setupGraphics()) return;

    document.documentElement.classList.add('webgl-backgrounds');
    buildControls();
    resize();
    await select(initialIndex());
    frame = requestAnimationFrame(render);
    window.addEventListener('resize', resize, { passive: true });
    canvas.addEventListener('webglcontextlost', (event) => {
      event.preventDefault();
      cancelAnimationFrame(frame);
      program = null;
      programCache.clear();
    });
    canvas.addEventListener('webglcontextrestored', async () => {
      if (!setupGraphics()) return;
      resize();
      startedAt = performance.now();
      await select(currentIndex);
      if (!paused && !reducedMotion.matches && !document.hidden) frame = requestAnimationFrame(render);
    });
    document.addEventListener('visibilitychange', () => {
      if (document.hidden) cancelAnimationFrame(frame);
      else if (!paused && !reducedMotion.matches) frame = requestAnimationFrame(render);
    });
    reducedMotion.addEventListener('change', (event) => {
      if (event.matches) cancelAnimationFrame(frame);
      else if (!paused && !document.hidden) frame = requestAnimationFrame(render);
    });
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
  else init();
})();
