// A slow sweep discloses contacts in concentric darkness.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 p = (uv - 0.5) * vec2(u_resolution.x / u_resolution.y, 1.0);
  float r = length(p);
  float angle = atan(p.y, p.x);
  float sweepAngle = mod(u_time * 0.12, 6.2831853) - 3.14159265;
  float delta = abs(atan(sin(angle - sweepAngle), cos(angle - sweepAngle)));
  float sweep = exp(-10.0 * delta) * (1.0 - smoothstep(0.65, 0.82, r));
  float rings = 1.0 - smoothstep(0.004, 0.012, abs(fract(r * 8.0) - 0.5));
  float spokes = 1.0 - smoothstep(0.005, 0.018, abs(sin(angle * 4.0)) * r);
  float contacts = 0.0;
  for (int i = 0; i < 7; i++) {
    float fi = float(i);
    vec2 c = (vec2(hash(vec2(fi, 1.0)), hash(vec2(fi, 2.0))) - 0.5) * vec2(1.25, 0.82);
    float dotMark = exp(-900.0 * dot(p - c, p - c));
    float reveal = exp(-7.0 * abs(atan(sin(atan(c.y, c.x) - sweepAngle), cos(atan(c.y, c.x) - sweepAngle))));
    contacts += dotMark * reveal;
  }
  float light = 0.006 + rings * 0.024 + spokes * 0.014 + sweep * 0.046 + contacts * 0.16;
  gl_FragColor = vec4(vec3(light), 1.0);
}
