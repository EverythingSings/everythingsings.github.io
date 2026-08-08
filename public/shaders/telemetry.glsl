// Several instruments write simultaneous traces across the screen.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  float light = 0.006;
  for (int i = 0; i < 8; i++) {
    float fi = float(i);
    float baseline = (fi + 0.65) / 8.8;
    float phase = uv.x * (10.0 + fi * 1.7) - u_time * (0.10 + fi * 0.008);
    float signal = baseline + 0.018 * sin(phase) + 0.010 * sin(phase * 2.7 + fi);
    float event = exp(-220.0 * pow(fract(uv.x * 2.0 - u_time * 0.018 + fi * 0.17) - 0.5, 2.0));
    signal += event * 0.045 * sin(phase * 5.0);
    float trace = 1.0 - smoothstep(0.002, 0.0065, abs(uv.y - signal));
    light += trace * (0.024 + event * 0.022);
  }
  gl_FragColor = vec4(vec3(light), 1.0);
}
