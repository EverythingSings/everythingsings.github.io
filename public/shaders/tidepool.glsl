// Neighboring pools send rings into one another across a shallow plane.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

vec2 hash2(vec2 p) {
  return fract(sin(vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)))) * 43758.5453);
}

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 p = (uv - 0.5) * vec2(u_resolution.x / u_resolution.y, 1.0) * 3.2;
  vec2 id = floor(p), f = fract(p);
  float light = 0.008;
  float t = u_time * 0.055;
  for (int y = -1; y <= 1; y++) {
    for (int x = -1; x <= 1; x++) {
      vec2 n = vec2(float(x), float(y));
      vec2 seed = n + hash2(id + n);
      float d = length(f - seed);
      float phase = d * 13.0 - t - hash2(id + n + 8.0).x * 6.2831;
      float ring = pow(0.5 + 0.5 * sin(phase), 16.0);
      light += ring * exp(-2.2 * d) * 0.028;
    }
  }
  gl_FragColor = vec4(vec3(light), 1.0);
}
