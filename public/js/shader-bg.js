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
  function showIndicator() {
    let indicator = document.getElementById('shader-indicator');

    if (!indicator) {
      indicator = document.createElement('div');
      indicator.id = 'shader-indicator';
      document.body.appendChild(indicator);
    }

    indicator.textContent = (currentShader + 1).toString();
    indicator.classList.add('visible');

    clearTimeout(indicatorTimeout);
    indicatorTimeout = setTimeout(() => {
      indicator.classList.remove('visible');
    }, 2000);
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

    render();
  }

  // Start when DOM is ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
