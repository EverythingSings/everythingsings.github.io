// A drifting graph: stars connect only to their nearest local field.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

vec2 hash2(vec2 p) {
  return fract(sin(vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)))) * 43758.5453);
}
float segment(vec2 p, vec2 a, vec2 b) {
  vec2 pa = p - a, ba = b - a;
  float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
  return length(pa - ba * h);
}

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 p = (uv - 0.5) * vec2(u_resolution.x / u_resolution.y, 1.0) * 5.4;
  p += vec2(u_time * 0.018, -u_time * 0.011);
  vec2 id = floor(p), f = fract(p);
  vec2 center = hash2(id) * 0.66 + 0.17;
  float point = exp(-170.0 * dot(f - center, f - center));
  float threads = 0.0;
  for (int i = 0; i < 3; i++) {
    vec2 offset = i == 0 ? vec2(1.0, 0.0) : (i == 1 ? vec2(0.0, 1.0) : vec2(1.0, 1.0));
    vec2 other = offset + hash2(id + offset) * 0.66 + 0.17;
    float distanceGate = smoothstep(1.18, 0.62, length(other - center));
    threads += (1.0 - smoothstep(0.008, 0.018, segment(f, center, other))) * distanceGate;
  }
  float light = 0.008 + point * 0.085 + min(1.0, threads) * 0.017;
  gl_FragColor = vec4(vec3(light), 1.0);
}
