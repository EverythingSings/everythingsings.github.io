// A punched sheet flexes under a slow passing pressure wave.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 p = uv * vec2(u_resolution.x / u_resolution.y, 1.0) * 21.0;
  p.y += mod(floor(p.x), 2.0) * 0.5;
  vec2 id = floor(p);
  vec2 f = fract(p) - 0.5;
  float wave = 0.05 * sin(id.x * 0.28 + id.y * 0.21 - u_time * 0.055);
  float r = length(f) + wave;
  float rim = 1.0 - smoothstep(0.018, 0.055, abs(r - 0.17));
  float shadow = (1.0 - smoothstep(0.12, 0.25, r)) * smoothstep(-0.22, 0.05, f.y);
  float sheen = 0.004 * (0.5 + 0.5 * sin(uv.x * 4.0 + u_time * 0.025));
  gl_FragColor = vec4(vec3(0.006 + sheen + rim * 0.040 + shadow * 0.012), 1.0);
}
