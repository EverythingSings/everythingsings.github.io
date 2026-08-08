// A rectilinear field falls inward without ever reaching the center.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 p = (uv - 0.5) * vec2(u_resolution.x / u_resolution.y, 1.0);
  vec2 center = 0.10 * vec2(sin(u_time * 0.031), cos(u_time * 0.024));
  vec2 d = p - center;
  float r = length(d);
  float pull = 0.15 / (0.18 + r);
  vec2 q = p + normalize(d + 0.0001) * pull;
  q += 0.012 * sin(vec2(q.y, q.x) * 9.0 + u_time * 0.04);
  vec2 g = abs(fract(q * 12.0) - 0.5);
  float grid = 1.0 - smoothstep(0.475, 0.495, max(g.x, g.y));
  float horizon = 1.0 - smoothstep(0.008, 0.025, abs(r - 0.16 - 0.008 * sin(u_time * 0.10)));
  float shade = 1.0 - smoothstep(0.0, 0.30, r);
  float light = 0.007 + grid * 0.028 * (0.65 + 0.35 * r) + horizon * 0.060 + shade * 0.010;
  gl_FragColor = vec4(vec3(light), 1.0);
}
