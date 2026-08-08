// Slow orbital bodies and a restrained corona.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

float hash(vec2 p) { return fract(sin(dot(p, vec2(41.3, 289.1))) * 45758.5453); }

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 p = (uv - 0.5) * vec2(u_resolution.x / u_resolution.y, 1.0);
  float t = u_time * 0.045;
  vec2 center = vec2(0.12 * sin(t), 0.06 * cos(t * 0.7));
  float d = length(p - center);
  float angle = atan(p.y - center.y, p.x - center.x);
  float coronaNoise = hash(vec2(floor(angle * 58.0), floor(t * 2.0)));
  float corona = exp(-38.0 * abs(d - 0.215)) * (0.6 + 0.4 * coronaNoise);
  float halo = 0.022 / max(0.018, abs(d - 0.215));
  float body = 1.0 - smoothstep(0.205, 0.218, d);
  float stars = step(0.9975, hash(floor((p + t * 0.015) * 190.0))) * (1.0 - body);
  float light = 0.008 + min(0.12, halo * 0.012) + corona * 0.11 + stars * 0.08;
  light *= 1.0 - body * 0.93;
  gl_FragColor = vec4(vec3(light), 1.0);
}
