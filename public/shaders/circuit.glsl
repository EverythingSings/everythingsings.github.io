// Orthogonal traces reroute one junction at a time.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 p = uv * vec2(u_resolution.x / u_resolution.y, 1.0) * 22.0;
  vec2 id = floor(p), f = fract(p) - 0.5;
  float epoch = floor(u_time * 0.07);
  float direction = step(0.5, hash(id + epoch));
  float horizontal = (1.0 - smoothstep(0.035, 0.095, abs(f.y))) * step(-0.46, f.x);
  float vertical = (1.0 - smoothstep(0.035, 0.095, abs(f.x))) * step(-0.46, f.y);
  float trace = mix(horizontal, vertical, direction);
  float junction = exp(-110.0 * dot(f, f)) * step(0.76, hash(id + 9.0));
  float pulse = 0.65 + 0.35 * sin(u_time * 0.22 + id.x + id.y);
  float light = 0.008 + trace * pulse * 0.032 + junction * 0.055;
  gl_FragColor = vec4(vec3(light), 1.0);
}
