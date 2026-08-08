// Accordion folds compress and release in long vertical chambers.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  float aspect = u_resolution.x / u_resolution.y;
  vec2 p = vec2(uv.x * aspect, uv.y);
  float phase = p.x * 11.0 + 0.22 * sin(uv.y * 5.0 + u_time * 0.025);
  float fold = abs(fract(phase) - 0.5);
  float ridge = 1.0 - smoothstep(0.43, 0.50, fold);
  float valley = 1.0 - smoothstep(0.0, 0.055, fold);
  float cross = 0.5 + 0.5 * sin(uv.y * 18.0 + sin(phase) * 0.7 - u_time * 0.035);
  float ends = smoothstep(0.02, 0.20, uv.y) * (1.0 - smoothstep(0.80, 0.98, uv.y));
  float light = 0.006 + (ridge * 0.035 + valley * 0.012 + cross * 0.006) * ends;
  gl_FragColor = vec4(vec3(light), 1.0);
}
