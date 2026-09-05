// Orbital Loom — three independently rotating, engraved metal hoops.
precision highp float;
uniform float u_time;
uniform vec2 u_resolution;
uniform vec2 u_pointer;

mat2 turn(float a) { float c = cos(a), s = sin(a); return mat2(c, -s, s, c); }
vec3 ringSpace(vec3 p, float k) {
  p.xz = turn(0.45 + u_pointer.x * 0.25) * p.xz;
  p.yz = turn(-0.3 + u_pointer.y * 0.2) * p.yz;
  p.xy = turn(k * 1.0472) * p.xy;
  p.xz = turn(k * 0.73 + 0.45 * sin(u_time * 0.07 + k * 1.6)) * p.xz;
  return p;
}
vec2 map(vec3 p) {
  vec2 hit = vec2(10.0, 0.0);
  for (int i = 0; i < 3; i++) {
    float k = float(i);
    vec3 q = ringSpace(p, k);
    vec2 crossSection = vec2(length(q.xy) - (0.82 - k * 0.11), q.z);
    vec2 box = abs(crossSection) - vec2(0.045, 0.06);
    float d = length(max(box, 0.0)) + min(max(box.x, box.y), 0.0) - 0.025;
    if (d < hit.x) hit = vec2(d, k);
  }
  return hit;
}
vec3 normalAt(vec3 p) {
  vec2 e = vec2(0.0015, 0.0);
  return normalize(vec3(map(p + e.xyy).x - map(p - e.xyy).x, map(p + e.yxy).x - map(p - e.yxy).x, map(p + e.yyx).x - map(p - e.yyx).x));
}
void main() {
  vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution) / min(u_resolution.x, u_resolution.y);
  vec3 ro = vec3(0, 0, 3.4), rd = normalize(vec3(uv, -1.6));
  float travel = 0.0;
  vec2 hit = vec2(1.0, 0.0);
  for (int i = 0; i < 80; i++) {
    hit = map(ro + rd * travel);
    if (hit.x < 0.0008 || travel > 5.0) break;
    travel += hit.x * 0.8;
  }
  vec3 color = vec3(0.013, 0.018, 0.025) + vec3(0.02, 0.027, 0.031) * exp(-length(uv) * 3.0);
  if (travel < 5.0 && hit.x < 0.003) {
    vec3 p = ro + rd * travel;
    vec3 n = normalAt(p);
    vec3 light = normalize(vec3(-0.6, 0.8, 1.2));
    vec3 q = ringSpace(p, hit.y);
    float a = atan(q.y, q.x);
    float engraving = smoothstep(0.87, 0.96, cos(a * 160.0));
    vec3 metal = mix(vec3(0.34, 0.47, 0.5), vec3(0.74, 0.48, 0.29), hit.y * 0.5);
    float diffuse = max(dot(n, light), 0.0);
    float rim = pow(1.0 - max(dot(n, -rd), 0.0), 3.0);
    color = metal * (0.16 + diffuse * 0.7) * (1.0 - engraving * 0.5);
    color += vec3(0.8, 0.83, 0.78) * pow(max(dot(n, normalize(light - rd)), 0.0), 80.0);
    color += rim * vec3(0.12, 0.24, 0.32);
  }
  gl_FragColor = vec4(color, 1.0);
}
