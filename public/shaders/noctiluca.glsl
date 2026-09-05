// Noctiluca — translucent colonies breathing out of phase in deep water.
precision highp float;
uniform float u_time;
uniform vec2 u_resolution;
uniform vec2 u_pointer;
uniform float u_impulse;

vec2 hash2(vec2 p) { return fract(sin(vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)))) * 43758.5453); }
void main() {
  vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution) / min(u_resolution.x, u_resolution.y);
  vec2 p = uv * 3.3 + vec2(0.3, u_time * 0.017);
  p += u_pointer * 0.16;
  p += 0.12 * vec2(sin(p.y * 1.5 + u_time * 0.08), cos(p.x * 1.2 - u_time * 0.04));
  vec2 cell = floor(p);
  vec3 color = vec3(0.005, 0.014, 0.022);
  for (int y = -1; y <= 1; y++) {
    for (int x = -1; x <= 1; x++) {
      vec2 id = cell + vec2(float(x), float(y));
      vec2 seed = hash2(id);
      vec2 center = id + 0.5 + 0.23 * sin(seed * 6.283185 + u_time * 0.04);
      vec2 q = p - center;
      q.x *= 0.8 + seed.y * 0.4;
      float angle = atan(q.y, q.x);
      float radius = 0.22 + 0.16 * seed.x;
      radius += 0.025 * sin(angle * (4.0 + floor(seed.y * 4.0)) + u_time * 0.17 + seed.x * 9.0);
      radius *= 1.0 + 0.04 * sin(u_time * 0.2 + seed.y * 15.0) + u_impulse * 0.05;
      float r = length(q);
      float membrane = exp(-abs(r - radius) * 100.0);
      float halo = exp(-abs(r - radius) * 15.0);
      float interior = 1.0 - smoothstep(radius * 0.4, radius, r);
      float filaments = pow(0.5 + 0.5 * cos(angle * 36.0 + r * 48.0 - u_time * 0.1 + seed.x * 6.0), 14.0);
      float tide = 0.3 + 0.7 * pow(0.5 + 0.5 * sin(angle * 1.8 - u_time * 0.18 + seed.y * 5.0), 3.0);
      vec3 tint = mix(vec3(0.12, 0.65, 0.67), vec3(0.47, 0.3, 0.7), seed.y);
      color += tint * (membrane * (0.18 + 0.72 * tide) + halo * 0.055);
      color += tint * interior * (0.055 + filaments * 0.27) * tide;
      color += vec3(0.48, 0.75, 0.62) * exp(-r * r * 380.0) * (0.45 + 0.4 * sin(seed.x * 6.0 + u_time * 0.14));
    }
  }
  color *= 1.0 - 0.45 * smoothstep(0.15, 1.05, length(uv));
  gl_FragColor = vec4(color, 1.0);
}
