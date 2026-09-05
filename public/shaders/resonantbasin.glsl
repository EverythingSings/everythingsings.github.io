// Resonant Basin. Persistent wave height refracts a submerged mosaic.
precision highp float;
uniform vec2 u_resolution;
uniform sampler2D u_state;
uniform vec2 u_stateSize;
float height(vec2 p) {
  vec4 v = texture2D(u_state, p);
  return (dot(v.rg, vec2(256.0, 1.0)) * 255.0 - 32768.0) * (2.0 / 65535.0);
}
void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  vec2 e = 1.0 / u_stateSize;
  float h = height(uv);
  float l = height(uv - vec2(e.x, 0)), r = height(uv + vec2(e.x, 0));
  float b = height(uv - vec2(0, e.y)), t = height(uv + vec2(0, e.y));
  vec2 slope = vec2(r - l, t - b) * 22.0;
  float curvature = (l + r + b + t - 4.0 * h) * 250.0;
  vec3 n = normalize(vec3(-slope, 1.0));
  vec2 p = (uv - 0.5 + slope * 0.045) * u_resolution / min(u_resolution.x, u_resolution.y);
  vec2 tile = p * 13.0;
  vec2 f = fract(tile);
  vec2 edge = min(f, 1.0 - f);
  float grout = 1.0 - smoothstep(0.018, 0.045, min(edge.x, edge.y));
  float variation = fract(sin(dot(floor(tile), vec2(127.1, 311.7))) * 43758.5453);
  vec3 color = mix(vec3(0.025, 0.14, 0.17), vec3(0.16, 0.36, 0.34), variation);
  float circle = abs(length(p + vec2(0.12, 0.02)) - 0.30);
  color = mix(color, vec3(0.57, 0.39, 0.13), 1.0 - smoothstep(0.011, 0.018, circle));
  color *= 1.0 - grout * 0.58;
  color *= 0.65 + 0.35 * max(dot(n, normalize(vec3(-0.4, 0.6, 1.0))), 0.0);
  float caustic = clamp(-curvature * 0.3, -0.3, 1.8);
  color += vec3(0.25, 0.43, 0.34) * max(caustic, 0.0);
  color += vec3(0.08, 0.22, 0.19) * pow(min(length(slope), 1.0), 0.7);
  color *= 1.0 + min(caustic, 0.0);
  vec3 reflection = reflect(vec3(0, 0, -1), n);
  float windowLight = pow(max(dot(reflection, normalize(vec3(-0.25, 0.45, 1.0))), 0.0), 85.0);
  color += vec3(0.85, 0.84, 0.63) * windowLight * 0.6;
  color *= 0.8 + 0.2 * exp(-dot(p, p) * 1.4);
  gl_FragColor = vec4(pow(max(color, 0.0), vec3(0.85)), 1.0);
}
