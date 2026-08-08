// Marks accumulate in groups of five across an endless dark ledger.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 p = uv * vec2(u_resolution.x / u_resolution.y, 1.0);
  vec2 q = p * vec2(16.0, 14.0);
  q.x += u_time * 0.018;
  vec2 id = floor(q);
  vec2 f = fract(q);
  float present = step(0.33, hash(floor(id / vec2(5.0, 1.0))));
  float vertical = (1.0 - smoothstep(0.06, 0.12, abs(f.x - 0.5)))
                 * smoothstep(0.10, 0.20, f.y) * (1.0 - smoothstep(0.80, 0.90, f.y));
  float groupPos = mod(id.x, 5.0);
  vertical *= step(groupPos, 3.5);
  vec2 diagonal = vec2(mod(q.x, 5.0) / 5.0, f.y);
  float slash = 1.0 - smoothstep(0.025, 0.055, abs(diagonal.y - (0.16 + diagonal.x * 0.68)));
  slash *= step(3.5, groupPos);
  float ruled = (1.0 - smoothstep(0.488, 0.5, abs(fract(uv.y * 14.0) - 0.5))) * 0.12;
  float ink = 0.007 + ruled * 0.025 + present * max(vertical, slash) * 0.065;
  gl_FragColor = vec4(vec3(ink), 1.0);
}
