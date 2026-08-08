// A field of dot-dash transmissions drifts at several quiet rates.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 p = uv * vec2(u_resolution.x / u_resolution.y, 1.0);
  vec2 q = p * vec2(18.0, 29.0);
  vec2 id = floor(q);
  vec2 f = fract(q) - 0.5;
  float speed = 0.09 + hash(vec2(id.y, 4.0)) * 0.16;
  f.x = fract(f.x + 0.5 + u_time * speed + hash(vec2(id.y, 2.0)) * 8.0) - 0.5;
  float dash = step(0.52, hash(id));
  float width = mix(0.10, 0.33, dash);
  float mark = (1.0 - smoothstep(width, width + 0.08, abs(f.x)))
             * (1.0 - smoothstep(0.055, 0.13, abs(f.y)));
  mark *= step(0.32, hash(id + 9.0));
  float scan = 0.004 * (0.5 + 0.5 * sin(uv.y * 700.0));
  gl_FragColor = vec4(vec3(0.007 + scan + mark * 0.070), 1.0);
}
