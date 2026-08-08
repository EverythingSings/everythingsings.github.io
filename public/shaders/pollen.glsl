// Soft grains rise through a barely moving depth field.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

vec2 hash2(vec2 p) {
  return fract(sin(vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)))) * 43758.5453);
}

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 p = uv * vec2(u_resolution.x / u_resolution.y, 1.0);
  float light = 0.006;
  for (int layer = 0; layer < 4; layer++) {
    float fi = float(layer);
    float scale = 7.0 + fi * 4.5;
    vec2 q = p * scale;
    q.y += u_time * (0.022 + fi * 0.010);
    vec2 id = floor(q);
    vec2 f = fract(q) - 0.5;
    vec2 seed = hash2(id + fi * 17.0);
    f -= (seed - 0.5) * 0.65;
    f.x += sin(u_time * 0.08 + id.y + seed.x * 6.28) * 0.10;
    float grain = exp(-90.0 * dot(f, f));
    grain *= step(0.66 + fi * 0.045, seed.y);
    light += grain * (0.042 - fi * 0.006);
  }
  gl_FragColor = vec4(vec3(light), 1.0);
}
