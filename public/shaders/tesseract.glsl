// Nested frames shear through one another like a 4D shadow.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

float boxLine(vec2 p, vec2 size, float width) {
  vec2 d = abs(p) - size;
  float outside = length(max(d, 0.0));
  float inside = min(max(d.x, d.y), 0.0);
  return 1.0 - smoothstep(width, width * 2.2, abs(outside + inside));
}

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 p = (uv - 0.5) * vec2(u_resolution.x / u_resolution.y, 1.0);
  float t = u_time * 0.04;
  float light = 0.008;
  for (int i = 0; i < 6; i++) {
    float fi = float(i);
    float angle = t * (0.7 + fi * 0.08) + fi * 0.19;
    float c = cos(angle), s = sin(angle);
    vec2 q = mat2(c, -s, s, c) * p;
    q += 0.035 * vec2(sin(t + fi), cos(t * 0.8 + fi));
    float size = 0.12 + fi * 0.072;
    light += boxLine(q, vec2(size, size * (0.78 + fi * 0.025)), 0.0045) * (0.018 + fi * 0.002);
  }
  gl_FragColor = vec4(vec3(light), 1.0);
}
