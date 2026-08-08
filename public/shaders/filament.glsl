// Fine gravitational filaments curve around an absent center.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

float line(float value, float width) {
  return 1.0 - smoothstep(width, width * 2.2, abs(value));
}

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 p = (uv - 0.5) * vec2(u_resolution.x / u_resolution.y, 1.0);
  float t = u_time * 0.025;
  float r = length(p) + 0.001;
  float a = atan(p.y, p.x);
  float light = 0.009;
  for (int i = 0; i < 5; i++) {
    float fi = float(i);
    float spiral = sin(a * (2.0 + mod(fi, 2.0)) + log(r) * (3.2 + fi * 0.17) + t * (1.0 + fi * 0.1) + fi);
    float filament = line(spiral, 0.025 + fi * 0.004);
    light += filament * (0.025 - fi * 0.0025) * smoothstep(0.02, 0.22, r);
  }
  light *= 0.7 + 0.3 * smoothstep(0.95, 0.12, r);
  gl_FragColor = vec4(vec3(light), 1.0);
}
