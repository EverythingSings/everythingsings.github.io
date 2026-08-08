// Nodal lines migrate across an imagined vibrating plate.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 p = (uv - 0.5) * vec2(u_resolution.x / u_resolution.y, 1.0);
  p *= 3.14159265;
  float t = u_time * 0.018;
  float m = 3.0 + 0.16 * sin(t);
  float n = 5.0 + 0.20 * cos(t * 0.73);
  float mode = sin(m * p.x) * sin(n * p.y) - sin(n * p.x) * sin(m * p.y);
  float node = 1.0 - smoothstep(0.018, 0.075, abs(mode));
  float echo = 1.0 - smoothstep(0.07, 0.15, abs(abs(mode) - 0.24));
  float edge = smoothstep(1.7, 3.1, length(p));
  float light = 0.007 + node * 0.052 + echo * 0.012;
  light *= 1.0 - edge * 0.34;
  gl_FragColor = vec4(vec3(light), 1.0);
}
