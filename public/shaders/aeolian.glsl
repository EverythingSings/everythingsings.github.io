// Long wind-written threads slip sideways through layered air.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

float hash(float n) { return fract(sin(n * 91.7) * 43758.5453); }

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 p = uv * vec2(u_resolution.x / u_resolution.y, 1.0);
  float light = 0.006;
  for (int i = 0; i < 13; i++) {
    float fi = float(i);
    float y = (fi + 0.5) / 13.0;
    y += 0.055 * sin(p.x * (3.0 + hash(fi) * 4.0) + u_time * (0.04 + hash(fi + 7.0) * 0.04) + fi);
    float thread = 1.0 - smoothstep(0.003, 0.012, abs(p.y - y));
    float broken = smoothstep(0.25, 0.70, sin(p.x * (15.0 + hash(fi) * 22.0) - u_time * 0.11 + fi * 4.0) * 0.5 + 0.5);
    light += thread * broken * (0.025 + hash(fi + 2.0) * 0.025);
  }
  gl_FragColor = vec4(vec3(light), 1.0);
}
