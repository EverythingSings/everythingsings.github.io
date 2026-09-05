// Prismatic Fold — a folded optical surface with spectral edges and traveling caustics.
precision highp float;
uniform float u_time;
uniform vec2 u_resolution;
uniform vec2 u_pointer;

vec3 spectrum(float t) {
  return 0.48 + 0.42 * cos(6.283185 * (t + vec3(0.0, 0.21, 0.43)));
}
float field(vec2 p) {
  float t = u_time * 0.055;
  float bend = 0.36 * sin(p.y * 1.6 + t) + 0.12 * sin(p.y * 3.7 - t * 0.6);
  float x = p.x + bend + u_pointer.x * 0.08;
  return x * 4.0 + 0.28 * sin(p.y * 1.1 + x * 1.4 + t);
}
void main() {
  vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution) / min(u_resolution.x, u_resolution.y);
  vec2 p = mat2(0.97, -0.24, 0.24, 0.97) * uv * 2.4;
  float f = field(p);
  float phase = fract(f);
  float fold = abs(phase * 2.0 - 1.0);
  float e = 2.4 / min(u_resolution.x, u_resolution.y);
  float slope = (field(p + vec2(0, e)) - field(p - vec2(0, e))) / (2.0 * e);
  vec3 n = normalize(vec3((phase < 0.5 ? -1.0 : 1.0) * 0.8, slope * 0.22, 0.7));
  vec3 light = normalize(vec3(-0.4 + u_pointer.x * 0.5, 0.6 + u_pointer.y * 0.4, 1.0));
  float diffuse = max(dot(n, light), 0.0);
  float edge = pow(fold, 38.0);
  float caustic = pow(0.5 + 0.5 * sin(p.y * 2.3 + fold * 4.5 - u_time * 0.075), 13.0);
  float striae = pow(0.5 + 0.5 * cos(f * 190.0 + p.y * 2.0), 14.0);
  vec3 glass = mix(vec3(0.025, 0.055, 0.085), vec3(0.14, 0.19, 0.24), diffuse);
  vec3 color = glass * (0.3 + 0.7 * smoothstep(0.0, 0.8, fold));
  color += spectrum(p.y * 0.14 + floor(f) * 0.19 + u_time * 0.006) * (edge * 0.65 + caustic * 0.4);
  color += striae * caustic * vec3(0.1, 0.13, 0.16);
  color += pow(max(dot(n, normalize(light + vec3(0, 0, 1))), 0.0), 60.0) * 0.25;
  color *= 1.0 - 0.35 * smoothstep(0.2, 1.1, length(uv));
  gl_FragColor = vec4(color, 1.0);
}
