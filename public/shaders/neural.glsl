// A breathing graph of local signals rather than a single pulse test.
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
  vec2 p = (uv - 0.5) * vec2(u_resolution.x / u_resolution.y, 1.0) * 5.0;
  vec2 id = floor(p), f = fract(p);
  float t = u_time * 0.08;
  vec2 seed = hash2(id);
  vec2 center = 0.5 + 0.28 * sin(seed * 6.2831 + t + id.yx);
  float node = exp(-130.0 * dot(f - center, f - center));
  float links = 0.0;
  for (int i = 0; i < 4; i++) {
    vec2 offset = i == 0 ? vec2(1.0, 0.0) : (i == 1 ? vec2(0.0, 1.0) : (i == 2 ? vec2(-1.0, 0.0) : vec2(0.0, -1.0)));
    vec2 otherSeed = hash2(id + offset);
    vec2 other = offset + 0.5 + 0.28 * sin(otherSeed * 6.2831 + t + (id + offset).yx);
    float gate = smoothstep(1.18, 0.55, length(other - center));
    float wire = 1.0 - smoothstep(0.008, 0.024, segment(f, center, other));
    float signal = 0.55 + 0.45 * sin(t * 3.0 + length(f - center) * 18.0 + seed.x * 6.2831);
    links += wire * gate * signal;
  }
  float light = 0.008 + node * 0.072 + min(1.0, links) * 0.026;
  gl_FragColor = vec4(vec3(light), 1.0);
}
