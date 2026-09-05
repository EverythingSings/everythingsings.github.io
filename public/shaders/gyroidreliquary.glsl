// Gyroid Reliquary. A rotating cut exposes a continuous porous surface.
precision highp float;
uniform float u_time;
uniform vec2 u_resolution;
uniform vec2 u_pointer;
mat2 rot(float a) { float c = cos(a), s = sin(a); return mat2(c, -s, s, c); }
vec3 local(vec3 p) { p.xz = rot(u_time * 0.055 + u_pointer.x * 0.5) * p.xz; p.yz = rot(0.32 + u_pointer.y * 0.25) * p.yz; return p; }
float shape(vec3 p) {
  p = local(p);
  vec3 q = p * 6.2;
  float g = dot(sin(q), cos(q.yzx));
  float membrane = (abs(g) - 0.28) / 11.2;
  float shell = length(p) - 1.13;
  float cut = dot(p, normalize(vec3(0.6, 0.8, 0.3))) - 0.83;
  return max(max(membrane, shell), cut);
}
vec3 normal(vec3 p) {
  vec2 e = vec2(0.0015, -0.0015);
  return normalize(e.xyy * shape(p + e.xyy) + e.yyx * shape(p + e.yyx) + e.yxy * shape(p + e.yxy) + e.xxx * shape(p + e.xxx));
}
float shadow(vec3 ro, vec3 rd) {
  float shade = 1.0, t = 0.015;
  for (int i = 0; i < 25; i++) {
    float h = shape(ro + rd * t);
    shade = min(shade, 12.0 * h / t);
    t += clamp(h, 0.012, 0.12);
    if (shade < 0.015 || t > 2.4) break;
  }
  return clamp(shade, 0.0, 1.0);
}
void main() {
  vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution) / min(u_resolution.x, u_resolution.y);
  vec3 ro = vec3(0.0, 0.1, 3.5);
  vec3 rd = normalize(vec3(uv * 2.9, -3.2));
  float t = 1.9, d = 1.0;
  for (int i = 0; i < 112; i++) {
    d = shape(ro + rd * t);
    if (d < 0.0012 || t > 5.2) break;
    t += d * 0.78;
  }
  vec3 color = mix(vec3(0.075, 0.1, 0.115), vec3(0.015, 0.021, 0.035), smoothstep(0.0, 0.9, length(uv)));
  color += vec3(0.08, 0.045, 0.028) * exp(-dot(uv - vec2(-0.3, 0.1), uv - vec2(-0.3, 0.1)) * 4.0);
  if (d < 0.0012) {
    vec3 p = ro + rd * t, n = normal(p), q = local(p);
    vec3 light = normalize(vec3(-1.6, 2.0, 2.0));
    float ao = 1.0;
    for (int i = 1; i <= 5; i++) { float h = float(i) * 0.035; ao -= max(h - shape(p + n * h), 0.0) * 1.4; }
    ao = clamp(ao, 0.12, 1.0);
    float diff = max(dot(n, light), 0.0) * shadow(p + n * 0.005, light);
    float patina = smoothstep(-0.4, 0.5, sin(q.x * 7.0 + q.y * 3.0) * sin(q.z * 9.0 - q.y * 4.0));
    vec3 metal = mix(vec3(0.56, 0.27, 0.09), vec3(0.045, 0.26, 0.23), patina);
    color = metal * (0.17 * ao + 0.85 * diff);
    float spec = pow(max(dot(n, normalize(light - rd)), 0.0), 65.0);
    color += mix(vec3(0.9, 0.64, 0.3), vec3(0.45, 0.67, 0.57), patina) * spec * diff * 1.2;
    float rim = pow(1.0 - max(dot(n, -rd), 0.0), 3.0);
    color += vec3(0.09, 0.2, 0.28) * rim * ao;
    color = mix(color, vec3(0.025, 0.04, 0.055), smoothstep(2.6, 4.5, t) * 0.35);
  }
  gl_FragColor = vec4(pow(max(color, 0.0), vec3(0.8)), 1.0);
}
