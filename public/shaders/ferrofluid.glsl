// Magnetic lobes form ridges and thorn-like crests.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 p = (uv - 0.5) * vec2(u_resolution.x / u_resolution.y, 1.0);
  float t = u_time * 0.04;
  vec2 a = vec2(0.22 * sin(t), 0.18 * cos(t * 0.8));
  vec2 b = vec2(-0.27 * cos(t * 0.7), 0.16 * sin(t * 1.1));
  vec2 c = vec2(0.08 * cos(t * 1.3), -0.26 * sin(t * 0.6));
  float field = 0.07 / (length(p - a) + 0.045);
  field += 0.06 / (length(p - b) + 0.05);
  field += 0.05 / (length(p - c) + 0.055);
  float angle = atan(p.y, p.x);
  field += sin(angle * 17.0 + length(p) * 28.0 - t) * 0.055;
  float ridge = 1.0 - smoothstep(0.025, 0.075, abs(fract(field * 6.0) - 0.5));
  float mass = smoothstep(0.62, 1.2, field);
  float light = 0.008 + ridge * 0.027 + mass * 0.012;
  gl_FragColor = vec4(vec3(light), 1.0);
}
