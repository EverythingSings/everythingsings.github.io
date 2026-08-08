// Two slow wavefronts create interference without flicker.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 p = (uv - 0.5) * vec2(u_resolution.x / u_resolution.y, 1.0);
  float t = u_time * 0.035;
  vec2 a = vec2(-0.42 + 0.05 * sin(t), 0.08 * cos(t * 0.8));
  vec2 b = vec2(0.42 + 0.05 * cos(t * 0.9), -0.08 * sin(t));
  float wa = sin(length(p - a) * 44.0 - t * 2.0);
  float wb = sin(length(p - b) * 43.3 + t * 1.7);
  float interference = abs(wa + wb) * 0.5;
  float fine = pow(interference, 5.0);
  float envelope = smoothstep(1.0, 0.18, length(p));
  float light = 0.009 + fine * 0.055 * (0.45 + 0.55 * envelope);
  gl_FragColor = vec4(vec3(light), 1.0);
}
