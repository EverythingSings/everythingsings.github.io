// Five strands exchange depth as they cross a vertical loom.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 p = (uv - 0.5) * vec2(u_resolution.x / u_resolution.y, 1.0);
  float t = u_time * 0.04;
  float light = 0.008;
  for (int i = 0; i < 5; i++) {
    float fi = float(i);
    float center = (fi - 2.0) * 0.15;
    float path = center + sin(p.y * (17.0 + fi * 0.3) + t + fi * 1.25) * 0.065;
    float strand = 1.0 - smoothstep(0.004, 0.013, abs(p.x - path));
    float over = 0.45 + 0.55 * sin(p.y * 24.0 + fi * 1.7 + t);
    light += strand * (0.016 + over * 0.018);
  }
  gl_FragColor = vec4(vec3(light), 1.0);
}
