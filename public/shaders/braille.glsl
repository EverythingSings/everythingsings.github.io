// Six-dot cells carry an unreadable message across the field.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 p = uv * vec2(u_resolution.x / u_resolution.y, 1.0);
  vec2 cell = vec2(0.105, 0.14);
  vec2 q = p / cell;
  q.x += u_time * 0.025;
  vec2 id = floor(q);
  vec2 f = fract(q);
  vec2 slot = floor(f * vec2(2.0, 3.0));
  vec2 center = (slot + 0.5) / vec2(2.0, 3.0);
  vec2 d = (f - center) * vec2(2.0, 3.0);
  float bit = hash(id * 7.0 + slot);
  float dotMark = exp(-95.0 * dot(d, d)) * step(0.48, bit);
  float fade = 0.70 + 0.30 * sin(id.x * 0.3 + u_time * 0.04);
  gl_FragColor = vec4(vec3(0.006 + dotMark * fade * 0.060), 1.0);
}
