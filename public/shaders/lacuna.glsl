// Lacuna — a slowly breathing, fluted porcelain body around an absent center.
// The light and the viewing angle follow the pointer independently of the compositor.
precision highp float;
uniform float u_time;
uniform vec2 u_resolution;
uniform vec2 u_pointer;
uniform float u_impulse;

mat2 turn(float a) { float c = cos(a), s = sin(a); return mat2(c, -s, s, c); }
vec3 local(vec3 p) {
  p.xz = turn(0.48 + 0.13 * sin(u_time * 0.08) + u_pointer.x * 0.24) * p.xz;
  p.yz = turn(-0.38 + u_pointer.y * 0.2) * p.yz;
  return p;
}
float surface(vec3 world) {
  vec3 p = local(world);
  float a = atan(p.y, p.x);
  float major = 0.71 + 0.046 * sin(a * 3.0 + u_time * 0.11);
  vec2 q = vec2(length(p.xy) - major, p.z);
  float minor = 0.235 + 0.025 * sin(a * 5.0 - u_time * 0.08) + 0.012 * u_impulse;
  float flutes = 0.006 * cos(a * 76.0 + atan(q.y, q.x) * 2.0);
  return length(q) - minor - flutes;
}
vec3 normalAt(vec3 p) {
  vec2 e = vec2(0.0015, 0.0);
  return normalize(vec3(surface(p + e.xyy) - surface(p - e.xyy), surface(p + e.yxy) - surface(p - e.yxy), surface(p + e.yyx) - surface(p - e.yyx)));
}
void main() {
  vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution) / min(u_resolution.x, u_resolution.y);
  vec3 ro = vec3(0.0, 0.0, 3.5);
  vec3 rd = normalize(vec3(uv, -1.55));
  float travel = 0.0;
  float distanceToBody = 1.0;
  for (int i = 0; i < 76; i++) {
    distanceToBody = surface(ro + rd * travel);
    if (distanceToBody < 0.0009 || travel > 5.5) break;
    travel += distanceToBody * 0.72;
  }
  vec3 color = vec3(0.011, 0.014, 0.021) + 0.018 * exp(-2.8 * dot(uv, uv)) * vec3(0.55, 0.64, 0.9);
  if (distanceToBody < 0.003 && travel < 5.5) {
    vec3 p = ro + rd * travel;
    vec3 n = normalAt(p);
    vec3 light = normalize(vec3(-0.65 + u_pointer.x * 0.4, 0.9 + u_pointer.y * 0.3, 1.4));
    float diffuse = max(dot(n, light), 0.0);
    float rim = pow(1.0 - max(dot(n, -rd), 0.0), 3.0);
    float ao = clamp(surface(p + n * 0.12) / 0.12, 0.25, 1.0);
    vec3 q = local(p);
    float a = atan(q.y, q.x);
    float grain = 0.94 + 0.06 * sin(a * 76.0 + atan(q.z, length(q.xy) - 0.71) * 2.0);
    vec3 porcelain = mix(vec3(0.38, 0.48, 0.55), vec3(0.91, 0.87, 0.76), diffuse);
    color = porcelain * (0.08 + diffuse * 0.84) * ao * grain;
    color += pow(max(dot(n, normalize(light - rd)), 0.0), 65.0) * vec3(0.62, 0.64, 0.59);
    color += rim * vec3(0.17, 0.3, 0.41);
  }
  color *= 1.0 - 0.26 * smoothstep(0.35, 1.05, length(uv));
  gl_FragColor = vec4(color, 1.0);
}
