// Dark solvent draws narrow traces into soft vertical tails.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

float hash(float n) { return fract(sin(n * 127.1) * 43758.5453); }

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  float aspect = u_resolution.x / u_resolution.y;
  float light = 0.006;
  for (int i = 0; i < 19; i++) {
    float fi = float(i);
    float x = (fi + 0.5) / 19.0 * aspect;
    float center = 0.22 + hash(fi) * 0.60 + 0.035 * sin(u_time * 0.022 + fi);
    float width = 0.006 + hash(fi + 3.0) * 0.018;
    float column = exp(-pow((uv.x * aspect - x) / width, 2.0));
    float spot = exp(-pow((uv.y - center) / (0.045 + hash(fi + 8.0) * 0.08), 2.0));
    float tail = exp(-max(0.0, center - uv.y) * (7.0 + hash(fi + 2.0) * 9.0));
    light += column * (spot * 0.040 + tail * 0.014) * step(0.18, hash(fi + 5.0));
  }
  gl_FragColor = vec4(vec3(light), 1.0);
}
