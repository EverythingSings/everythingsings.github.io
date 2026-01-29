/**
 * Shader Background Manager
 *
 * Manages WebGL shader backgrounds with six toggleable generative patterns.
 * Respects prefers-reduced-motion and persists user preference.
 */
(function() {
  'use strict';

  // Exit early if reduced motion is preferred
  if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
    return;
  }

  const SHADER_NAMES = ['flow', 'fbm', 'voronoi', 'waves', 'neural', 'plasma'];
  const SHADER_COUNT = SHADER_NAMES.length;
  const STORAGE_KEY = 'shader-preference';

  let canvas, gl, program, startTime;
  let currentShader = 0;
  let indicatorTimeout = null;
  let shaderSources = {};

  // Vertex shader (shared by all fragment shaders)
  const vertexShaderSource = `
    attribute vec2 a_position;
    void main() {
      gl_Position = vec4(a_position, 0.0, 1.0);
    }
  `;

  // Load shader source from file (with cache bust)
  async function loadShaderSource(name) {
    const cacheBust = Date.now();
    const response = await fetch(`/shaders/${name}.glsl?v=${cacheBust}`);
    return response.text();
  }

  // Compile a shader
  function compileShader(type, source) {
    const shader = gl.createShader(type);
    gl.shaderSource(shader, source);
    gl.compileShader(shader);

    if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
      console.error('Shader compile error:', gl.getShaderInfoLog(shader));
      gl.deleteShader(shader);
      return null;
    }
    return shader;
  }

  // Create shader program
  function createProgram(fragmentSource) {
    const vertexShader = compileShader(gl.VERTEX_SHADER, vertexShaderSource);
    const fragmentShader = compileShader(gl.FRAGMENT_SHADER, fragmentSource);

    if (!vertexShader || !fragmentShader) return null;

    const prog = gl.createProgram();
    gl.attachShader(prog, vertexShader);
    gl.attachShader(prog, fragmentShader);
    gl.linkProgram(prog);

    if (!gl.getProgramParameter(prog, gl.LINK_STATUS)) {
      console.error('Program link error:', gl.getProgramInfoLog(prog));
      gl.deleteProgram(prog);
      return null;
    }

    // Clean up individual shaders after linking
    gl.deleteShader(vertexShader);
    gl.deleteShader(fragmentShader);

    return prog;
  }

  // Set up fullscreen quad geometry
  function setupGeometry() {
    const buffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([
      -1, -1, 1, -1, -1, 1,
      -1, 1, 1, -1, 1, 1
    ]), gl.STATIC_DRAW);
  }

  // Switch to a specific shader (with retry limit to prevent infinite loops)
  async function switchShader(index, retryCount = 0) {
    // Prevent infinite loop if all shaders fail
    if (retryCount >= SHADER_COUNT) {
      console.error('All shaders failed to compile');
      return;
    }

    // Wrap around
    index = ((index % SHADER_COUNT) + SHADER_COUNT) % SHADER_COUNT;

    const name = SHADER_NAMES[index];

    if (!shaderSources[name]) {
      shaderSources[name] = await loadShaderSource(name);
    }

    // Create new program BEFORE deleting old one
    const newProgram = createProgram(shaderSources[name]);
    if (!newProgram) {
      // Shader failed - skip to next shader automatically
      console.warn(`Shader "${name}" failed to compile, skipping...`);
      switchShader(index + 1, retryCount + 1);
      return;
    }

    // Only delete old program after new one succeeds
    if (program) {
      gl.deleteProgram(program);
    }

    program = newProgram;
    gl.useProgram(program);

    // Set up position attribute
    const positionLoc = gl.getAttribLocation(program, 'a_position');
    gl.enableVertexAttribArray(positionLoc);
    gl.vertexAttribPointer(positionLoc, 2, gl.FLOAT, false, 0, 0);

    currentShader = index;
    localStorage.setItem(STORAGE_KEY, index.toString());
    showIndicator();
  }

  // Show shader indicator
  // duration: milliseconds to show (0 = use default, -1 = persistent)
  function showIndicator(duration = 0) {
    let indicator = document.getElementById('shader-indicator');

    if (!indicator) {
      indicator = document.createElement('div');
      indicator.id = 'shader-indicator';
      indicator.setAttribute('role', 'button');
      indicator.setAttribute('aria-label', 'Change shader background (tap to cycle)');
      indicator.setAttribute('tabindex', '0');
      document.body.appendChild(indicator);

      // Click/tap to cycle shaders
      indicator.addEventListener('click', function(e) {
        e.preventDefault();
        switchShader(currentShader + 1);
      });

      // Keyboard support for accessibility
      indicator.addEventListener('keydown', function(e) {
        if (e.key === 'Enter' || e.key === ' ') {
          e.preventDefault();
          switchShader(currentShader + 1);
        }
      });
    }

    indicator.textContent = (currentShader + 1).toString();
    indicator.classList.add('visible');

    clearTimeout(indicatorTimeout);
    if (duration !== -1) {
      const hideDelay = duration > 0 ? duration : 2000;
      indicatorTimeout = setTimeout(() => {
        indicator.classList.remove('visible');
      }, hideDelay);
    }
  }

  // Handle resize
  function resize() {
    const dpr = Math.min(window.devicePixelRatio || 1, 2); // Cap at 2x for performance
    const width = window.innerWidth;
    const height = window.innerHeight;

    canvas.width = width * dpr;
    canvas.height = height * dpr;
    canvas.style.width = width + 'px';
    canvas.style.height = height + 'px';

    gl.viewport(0, 0, canvas.width, canvas.height);
  }

  // Animation loop
  function render() {
    if (!program) {
      requestAnimationFrame(render);
      return;
    }

    const time = (performance.now() - startTime) / 1000;

    // Set uniforms
    const timeLoc = gl.getUniformLocation(program, 'u_time');
    const resLoc = gl.getUniformLocation(program, 'u_resolution');

    if (timeLoc) gl.uniform1f(timeLoc, time);
    if (resLoc) gl.uniform2f(resLoc, canvas.width, canvas.height);

    gl.drawArrays(gl.TRIANGLES, 0, 6);
    requestAnimationFrame(render);
  }

  // Touch swipe support for mobile
  let touchStartX = 0;
  let touchStartY = 0;
  const SWIPE_THRESHOLD = 50;

  function handleTouchStart(e) {
    touchStartX = e.touches[0].clientX;
    touchStartY = e.touches[0].clientY;
  }

  function handleTouchEnd(e) {
    if (!touchStartX || !touchStartY) return;

    const touchEndX = e.changedTouches[0].clientX;
    const touchEndY = e.changedTouches[0].clientY;

    const deltaX = touchEndX - touchStartX;
    const deltaY = touchEndY - touchStartY;

    // Only trigger if horizontal swipe is dominant and exceeds threshold
    if (Math.abs(deltaX) > Math.abs(deltaY) && Math.abs(deltaX) > SWIPE_THRESHOLD) {
      if (deltaX > 0) {
        // Swipe right - previous shader
        switchShader(currentShader - 1);
      } else {
        // Swipe left - next shader
        switchShader(currentShader + 1);
      }
    }

    touchStartX = 0;
    touchStartY = 0;
  }

  // Handle keyboard input
  function handleKeydown(e) {
    if (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA') {
      return;
    }

    switch (e.key) {
      case '1':
        switchShader(0);
        break;
      case '2':
        switchShader(1);
        break;
      case '3':
        switchShader(2);
        break;
      case '4':
        switchShader(3);
        break;
      case '5':
        switchShader(4);
        break;
      case '6':
        switchShader(5);
        break;
      case ' ':
        e.preventDefault();
        switchShader(currentShader + 1);
        break;
      case 'ArrowRight':
        e.preventDefault();
        switchShader(currentShader + 1);
        break;
      case 'ArrowLeft':
        e.preventDefault();
        switchShader(currentShader - 1);
        break;
    }
  }

  // Initialize
  async function init() {
    canvas = document.getElementById('shader-canvas');
    if (!canvas) return;

    gl = canvas.getContext('webgl', { alpha: false, antialias: false });
    if (!gl) {
      console.warn('WebGL not supported');
      return;
    }

    setupGeometry();
    resize();

    // Load saved preference or default to 0
    const saved = localStorage.getItem(STORAGE_KEY);
    let initialShader = saved !== null ? parseInt(saved, 10) : 0;
    if (isNaN(initialShader) || initialShader < 0 || initialShader >= SHADER_COUNT) {
      initialShader = 0;
    }

    startTime = performance.now();
    await switchShader(initialShader);

    window.addEventListener('resize', resize);
    window.addEventListener('keydown', handleKeydown);

    // Touch swipe support
    document.addEventListener('touchstart', handleTouchStart, { passive: true });
    document.addEventListener('touchend', handleTouchEnd, { passive: true });

    // Show indicator longer on first load for touch device discoverability
    const isTouchDevice = window.matchMedia('(hover: none) and (pointer: coarse)').matches;
    if (isTouchDevice) {
      // Override the initial indicator with longer duration (4 seconds)
      setTimeout(() => showIndicator(4000), 200);
    }

    render();
  }

  // Start when DOM is ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
