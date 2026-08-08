// High windows cast slow volumetric shafts through particulate dark.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

float hash(float n) { return fract(sin(n * 127.1) * 43758.5453); }

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  float aspect = u_resolution.x / u_resolution.y;
  vec2 p = vec2(uv.x * aspect, uv.y);
  float t = u_time * 0.025;
  float light = 0.008;
  for (int i = 0; i < 7; i++) {
    float fi = float(i);
    float origin = aspect * (0.08 + fi * 0.14) + sin(t + fi) * 0.035;
    float slope = (hash(fi + 3.0) - 0.5) * 0.38;
    float center = origin + (1.0 - uv.y) * slope;
    float width = 0.025 + hash(fi + 8.0) * 0.055;
    float shaft = 1.0 - smoothstep(width, width * 2.4, abs(p.x - center));
    float dust = 0.75 + 0.25 * sin(uv.y * 19.0 + fi * 2.0 - t);
    light += shaft * dust * (0.025 + hash(fi) * 0.016);
  }
  light *= 0.72 + 0.28 * uv.y;
  gl_FragColor = vec4(vec3(light), 1.0);
}
