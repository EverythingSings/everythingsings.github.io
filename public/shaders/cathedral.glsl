// Repeating arches recede like an impossible monochrome nave.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

float archLine(vec2 p, float radius) {
  float side = 1.0 - smoothstep(0.012, 0.032, abs(abs(p.x) - radius));
  side *= 1.0 - smoothstep(-0.08, 0.0, p.y);
  float curve = 1.0 - smoothstep(0.012, 0.032, abs(length(vec2(p.x, max(p.y, 0.0))) - radius));
  curve *= smoothstep(-0.02, 0.05, p.y);
  return max(side, curve);
}

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 p = (uv - 0.5) * vec2(u_resolution.x / u_resolution.y, 1.0);
  float t = u_time * 0.018;
  float light = 0.008;
  for (int i = 0; i < 6; i++) {
    float fi = float(i);
    float depth = 0.16 + fi * 0.105;
    vec2 q = p;
    q.y += 0.14 - fi * 0.018;
    q.x += sin(t + fi * 0.5) * 0.012;
    light += archLine(q, depth) * (0.034 - fi * 0.0032);
  }
  float floorLine = 1.0 - smoothstep(0.006, 0.018, abs(p.y + 0.31));
  light += floorLine * 0.018;
  gl_FragColor = vec4(vec3(light), 1.0);
}
