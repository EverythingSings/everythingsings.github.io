// Granular time narrows through a shifting waist and gathers below.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 p = (uv - 0.5) * vec2(u_resolution.x / u_resolution.y, 1.0);
  float body = abs(p.x) - (0.05 + abs(p.y) * 0.42);
  float glass = 1.0 - smoothstep(0.006, 0.016, abs(body));
  vec2 q = p * 42.0;
  q.y += u_time * 0.20;
  vec2 id = floor(q);
  vec2 f = fract(q) - 0.5;
  float grain = exp(-120.0 * dot(f, f)) * step(0.80, hash(id));
  float inside = 1.0 - smoothstep(0.0, 0.025, body);
  float stream = exp(-180.0 * p.x * p.x) * smoothstep(-0.38, -0.02, p.y) * (1.0 - smoothstep(0.02, 0.42, p.y));
  float pile = smoothstep(-0.48, -0.25, p.y) * (1.0 - smoothstep(0.0, 0.25, abs(p.x) + p.y * 0.55 + 0.10));
  float active = max(stream, pile);
  float light = 0.006 + glass * 0.035 + grain * inside * active * 0.075;
  gl_FragColor = vec4(vec3(light), 1.0);
}
