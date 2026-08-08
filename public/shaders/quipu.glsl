// Hanging cords and migrating knots form a record no one can read.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

float hash(vec2 p) { return fract(sin(dot(p, vec2(71.3, 219.7))) * 43758.5453); }

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  float columns = 28.0;
  float id = floor(uv.x * columns);
  float localX = fract(uv.x * columns) - 0.5;
  float sway = sin(uv.y * 8.0 + u_time * 0.035 + id) * 0.07;
  float cord = 1.0 - smoothstep(0.025, 0.07, abs(localX - sway));
  float knotRow = floor((uv.y + u_time * 0.008 * (0.4 + hash(vec2(id, 1.0)))) * 12.0);
  float knotY = fract((uv.y + u_time * 0.008) * 12.0) - 0.5;
  float hasKnot = step(0.72, hash(vec2(id, knotRow)));
  float knot = exp(-75.0 * (pow(localX - sway, 2.0) + knotY * knotY)) * hasKnot;
  float lengthGate = step(hash(vec2(id, 8.0)) * 0.4, uv.y);
  float light = 0.008 + cord * lengthGate * 0.024 + knot * 0.055;
  gl_FragColor = vec4(vec3(light), 1.0);
}
