// Morphogenesis. Light reveals a living chemical relief.
precision highp float;
uniform vec2 u_resolution;
uniform sampler2D u_state;
uniform vec2 u_stateSize;
vec2 field(vec2 p) {
  vec4 v = texture2D(u_state, p);
  return vec2(dot(v.rg, vec2(256.0, 1.0)), dot(v.ba, vec2(256.0, 1.0))) * (255.0 / 65535.0);
}
float height(vec2 p) { return field(p).y; }
void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  vec2 e = 1.0 / u_stateSize;
  vec2 c = field(uv);
  float h = c.y;
  float dx = height(uv + vec2(e.x, 0)) - height(uv - vec2(e.x, 0));
  float dy = height(uv + vec2(0, e.y)) - height(uv - vec2(0, e.y));
  vec3 n = normalize(vec3(-dx * 5.0, -dy * 5.0, 0.5));
  vec3 light = normalize(vec3(-0.7, 0.9, 1.0));
  float diffuse = max(dot(n, light), 0.0);
  float specular = pow(max(dot(reflect(-light, n), vec3(0, 0, 1)), 0.0), 38.0);
  vec3 base = mix(vec3(0.022, 0.039, 0.034), vec3(0.09, 0.25, 0.21), smoothstep(0.03, 0.21, h));
  base = mix(base, vec3(0.63, 0.49, 0.23), smoothstep(0.19, 0.32, h));
  base = mix(base, vec3(0.18, 0.105, 0.05), smoothstep(0.33, 0.45, h));
  float rim = exp(-pow((h - 0.24) * 54.0, 2.0));
  vec3 color = base * (0.3 + 1.0 * diffuse) + vec3(0.8, 0.74, 0.47) * specular * 0.65;
  color += rim * vec3(0.23, 0.15, 0.06) * diffuse;
  float grain = fract(sin(dot(gl_FragCoord.xy, vec2(12.9898, 78.233))) * 43758.5453);
  color += (grain - 0.5) * 0.009;
  color *= 0.78 + 0.22 * pow(max(16.0 * uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y), 0.0), 0.22);
  gl_FragColor = vec4(pow(max(color, 0.0), vec3(0.85)), 1.0);
}
