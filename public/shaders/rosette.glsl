// Nested petal rings open and close around a drifting center.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 p = (uv - 0.5) * vec2(u_resolution.x / u_resolution.y, 1.0);
  p -= 0.08 * vec2(sin(u_time * 0.021), cos(u_time * 0.017));
  float r = length(p);
  float a = atan(p.y, p.x);
  float light = 0.006;
  for (int i = 0; i < 7; i++) {
    float fi = float(i);
    float petals = 5.0 + mod(fi, 4.0) * 2.0;
    float radius = 0.12 + fi * 0.075 + 0.024 * cos(a * petals + u_time * (0.025 + fi * 0.003));
    float line = 1.0 - smoothstep(0.0025, 0.008, abs(r - radius));
    light += line * (0.026 + 0.004 * sin(fi));
  }
  gl_FragColor = vec4(vec3(light), 1.0);
}
