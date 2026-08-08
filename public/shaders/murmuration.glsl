// Small bodies stretch into a shared turning field.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

vec2 hash2(vec2 p) {
  return fract(sin(vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)))) * 43758.5453);
}

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 p = uv * vec2(u_resolution.x / u_resolution.y, 1.0);
  float light = 0.008;
  for (int layer = 0; layer < 3; layer++) {
    float fi = float(layer);
    float scale = 22.0 + fi * 10.0;
    vec2 q = p * scale + vec2(u_time * (0.018 + fi * 0.006), 0.0);
    vec2 id = floor(q), f = fract(q) - 0.5;
    vec2 jitter = hash2(id + fi * 13.0) - 0.5;
    f -= jitter * 0.52;
    float angle = sin((id.x + id.y) * 0.12 + u_time * 0.035) * 1.7;
    float c = cos(angle), s = sin(angle);
    f = mat2(c, -s, s, c) * f;
    float bird = exp(-110.0 * (f.x * f.x * 0.38 + f.y * f.y * 3.0));
    bird *= step(0.82 + fi * 0.035, hash2(id + 4.0).x);
    light += bird * (0.060 - fi * 0.010);
  }
  gl_FragColor = vec4(vec3(light), 1.0);
}
