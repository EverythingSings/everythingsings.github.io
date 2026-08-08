// Sparse sparks rise at different depths through still air.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

float hash(vec2 p) { return fract(sin(dot(p, vec2(91.7, 237.3))) * 43758.5453); }

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 p = uv * vec2(u_resolution.x / u_resolution.y, 1.0);
  float light = 0.009;
  for (int layer = 0; layer < 3; layer++) {
    float fi = float(layer);
    float cells = 15.0 + fi * 9.0;
    vec2 q = p * cells;
    q.y -= u_time * (0.09 + fi * 0.035);
    vec2 id = floor(q);
    vec2 f = fract(q) - 0.5;
    vec2 jitter = vec2(hash(id), hash(id + 7.7)) - 0.5;
    f -= jitter * 0.55;
    float exists = step(0.91 + fi * 0.015, hash(id + fi * 19.0));
    float spark = exp(-95.0 * dot(f, f)) * exists;
    float breathe = 0.55 + 0.45 * sin(u_time * 0.8 + hash(id) * 6.2831);
    light += spark * breathe * (0.075 - fi * 0.014);
  }
  gl_FragColor = vec4(vec3(light), 1.0);
}
