// Thin mineral faces catch light as the viewing angle changes.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

vec2 hash2(vec2 p) {
  return fract(sin(vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)))) * 43758.5453);
}

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 p = uv * vec2(u_resolution.x / u_resolution.y, 1.0) * 8.0;
  vec2 id = floor(p);
  vec2 f = fract(p) - 0.5;
  vec2 seed = hash2(id);
  float angle = seed.x * 6.283 + 0.14 * sin(u_time * 0.035 + seed.y * 6.283);
  float c = cos(angle), s = sin(angle);
  vec2 q = mat2(c, -s, s, c) * f;
  float face = 1.0 - smoothstep(0.22, 0.48, max(abs(q.x) * 0.72, abs(q.y)));
  float edge = 1.0 - smoothstep(0.008, 0.025, abs(max(abs(q.x) * 0.72, abs(q.y)) - 0.35));
  float glint = pow(max(0.0, sin(angle + u_time * 0.045)), 8.0) * face;
  float light = 0.006 + edge * 0.022 + glint * 0.052 * step(0.22, seed.y);
  gl_FragColor = vec4(vec3(light), 1.0);
}
