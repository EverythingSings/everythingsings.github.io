// Offset toothed wheels turn with linked but unequal periods.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 p = (uv - 0.5) * vec2(u_resolution.x / u_resolution.y, 1.0);
  float light = 0.006;
  for (int i = 0; i < 7; i++) {
    float fi = float(i);
    vec2 c = vec2(sin(fi * 2.17), cos(fi * 1.63)) * vec2(0.55, 0.34);
    vec2 d = p - c;
    float a = atan(d.y, d.x);
    float teeth = 0.018 * sin(a * (8.0 + mod(fi, 4.0)) + u_time * (0.08 - fi * 0.012));
    float radius = 0.13 + mod(fi, 3.0) * 0.035 + teeth;
    float ring = 1.0 - smoothstep(0.003, 0.010, abs(length(d) - radius));
    float hub = 1.0 - smoothstep(0.003, 0.009, abs(length(d) - 0.030));
    light += ring * 0.032 + hub * 0.025;
  }
  gl_FragColor = vec4(vec3(light), 1.0);
}
