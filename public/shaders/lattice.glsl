// A perspective lattice that folds instead of scrolling.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 p = (uv - 0.5) * vec2(u_resolution.x / u_resolution.y, 1.0);
  float t = u_time * 0.06;
  float r = length(p);
  float twist = sin(r * 7.0 - t) * 0.24;
  float c = cos(twist), s = sin(twist);
  p = mat2(c, -s, s, c) * p;
  p += 0.035 * vec2(sin(p.y * 8.0 + t), cos(p.x * 7.0 - t));
  vec2 grid = abs(fract(p * 8.0 + 0.5) - 0.5);
  float line = 1.0 - smoothstep(0.025, 0.075, min(grid.x, grid.y));
  float nodes = 1.0 - smoothstep(0.05, 0.23, length(fract(p * 4.0) - 0.5));
  float pulse = 0.5 + 0.5 * sin(r * 18.0 - t * 3.0);
  float light = 0.010 + line * 0.038 + nodes * pulse * 0.026;
  light *= 0.65 + 0.35 * smoothstep(0.9, 0.05, r);
  gl_FragColor = vec4(vec3(light), 1.0);
}
