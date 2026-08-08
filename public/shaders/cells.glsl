// Soft biological cells: divisions form, press together, and subside.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

vec2 hash2(vec2 p) {
  return fract(sin(vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)))) * 43758.5453);
}

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 p = (uv - 0.5) * vec2(u_resolution.x / u_resolution.y, 1.0) * 5.2;
  vec2 cell = floor(p), local = fract(p);
  float nearest = 8.0, second = 8.0;
  float t = u_time * 0.12;
  for (int y = -1; y <= 1; y++) {
    for (int x = -1; x <= 1; x++) {
      vec2 neighbor = vec2(float(x), float(y));
      vec2 seed = hash2(cell + neighbor);
      seed = 0.5 + 0.34 * sin(t + 6.2831 * seed);
      float d = length(neighbor + seed - local);
      if (d < nearest) { second = nearest; nearest = d; }
      else if (d < second) { second = d; }
    }
  }
  float membrane = 1.0 - smoothstep(0.015, 0.10, second - nearest);
  float nucleus = exp(-12.0 * nearest * nearest) * (0.5 + 0.5 * sin(t * 0.7));
  float light = 0.011 + membrane * 0.052 + nucleus * 0.018;
  gl_FragColor = vec4(vec3(light), 1.0);
}
