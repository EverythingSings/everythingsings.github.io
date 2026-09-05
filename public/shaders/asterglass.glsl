// Aster Glass. Entry/exit refraction, spectral dispersion and Fresnel reflection.
precision highp float;
uniform float u_time;
uniform vec2 u_resolution;
uniform vec2 u_pointer;
const vec3 RADII = vec3(0.82, 1.02, 0.64);
mat2 rot(float a) { float c = cos(a), s = sin(a); return mat2(c, -s, s, c); }
vec3 local(vec3 p) { p.xz = rot(0.2 + u_time * 0.08 + u_pointer.x * 0.4) * p.xz; p.xy = rot(0.18 + u_pointer.y * 0.2) * p.xy; return p; }
vec3 world(vec3 p) { p.xy = rot(-0.18 - u_pointer.y * 0.2) * p.xy; p.xz = rot(-0.2 - u_time * 0.08 - u_pointer.x * 0.4) * p.xz; return p; }
vec2 intersect(vec3 ro, vec3 rd) {
  vec3 o = local(ro) / RADII, d = local(rd) / RADII;
  float a = dot(d, d), b = dot(o, d), c = dot(o, o) - 1.0;
  float disc = b * b - a * c;
  if (disc < 0.0) return vec2(-1);
  return (-b + vec2(-1, 1) * sqrt(disc)) / a;
}
vec3 normal(vec3 p) { return normalize(world(local(p) / (RADII * RADII))); }
vec3 room(vec3 ro, vec3 rd) {
  float t = (-3.6 - ro.z) / min(rd.z, -0.0001);
  vec2 p = (ro + rd * t).xy;
  float a = atan(p.y + 0.15, p.x), r = length(p + vec2(0, 0.15));
  float petals = cos(a * 12.0 + 0.18 * sin(r * 4.0) + u_time * 0.03);
  float rings = sin(r * 15.0 - u_time * 0.07);
  vec3 color = mix(vec3(0.055, 0.09, 0.11), vec3(0.77, 0.60, 0.34), smoothstep(-0.2, 0.5, petals * rings));
  color = mix(color, vec3(0.92, 0.86, 0.68), pow(0.5 + 0.5 * cos(a * 24.0 + r * 18.0), 28.0) * 0.6);
  color *= 0.4 + 0.6 * exp(-r * r * 0.055);
  if (rd.z > -0.05) {
    color = vec3(0.015, 0.025, 0.034);
    color += vec3(2.0, 1.8, 1.4) * exp(-pow((rd.x + 0.55) * 12.0, 2.0) - pow((rd.y - 0.5) * 2.0, 2.0));
    color += vec3(0.55, 0.9, 1.15) * exp(-pow((rd.x - 0.5) * 18.0, 2.0) - pow((rd.y + 0.1) * 3.0, 2.0));
  }
  return color;
}
vec3 transmitted(vec3 p, vec3 rd, vec3 n, float ior) {
  vec3 inside = refract(rd, n, 1.0 / ior);
  vec3 entry = p + inside * 0.003;
  float distance = intersect(entry, inside).y;
  vec3 exitPoint = entry + inside * distance;
  vec3 outgoing = refract(inside, -normal(exitPoint), ior);
  if (dot(outgoing, outgoing) < 0.01) outgoing = reflect(inside, normal(exitPoint));
  return room(exitPoint, outgoing) * exp(-vec3(0.055, 0.022, 0.009) * distance);
}
vec3 render(vec2 frag) {
  vec2 uv = (frag - 0.5 * u_resolution) / min(u_resolution.x, u_resolution.y);
  vec3 ro = vec3(0, 0, 3.6), rd = normalize(vec3(uv * 2.6, -3.4));
  vec3 color = room(ro, rd) * 0.36;
  vec2 hit = intersect(ro, rd);
  if (hit.x > 0.0) {
    vec3 p = ro + rd * hit.x, n = normal(p);
    vec3 transmission = vec3(transmitted(p, rd, n, 1.493).r, transmitted(p, rd, n, 1.500).g, transmitted(p, rd, n, 1.507).b);
    float fresnel = 0.04 + 0.96 * pow(1.0 - max(dot(-rd, n), 0.0), 5.0);
    color = mix(transmission, room(p, reflect(rd, n)), fresnel);
    color += vec3(0.12, 0.19, 0.21) * pow(1.0 - max(dot(-rd, n), 0.0), 8.0);
  }
  color = color / (1.0 + color * 0.2);
  return color;
}
void main() {
  vec3 color = vec3(0);
  for (int y = 0; y < 2; y++) for (int x = 0; x < 2; x++) {
    color += render(gl_FragCoord.xy + vec2(float(x), float(y)) * 0.5 - 0.25);
  }
  gl_FragColor = vec4(pow(max(color * 0.25, 0.0), vec3(0.85)), 1.0);
}
