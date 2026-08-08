// Hairline fractures drift apart and find one another again.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

vec2 hash2(vec2 p) {
  return fract(sin(vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)))) * 43758.5453);
}

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 p = (uv - 0.5) * vec2(u_resolution.x / u_resolution.y, 1.0) * 3.6;
  vec2 id = floor(p), f = fract(p);
  float nearest = 8.0, second = 8.0;
  float t = u_time * 0.045;
  for (int y = -1; y <= 1; y++) {
    for (int x = -1; x <= 1; x++) {
      vec2 n = vec2(float(x), float(y));
      vec2 seed = hash2(id + n);
      seed += 0.055 * sin(t + seed * 6.2831);
      float d = length(n + seed - f);
      if (d < nearest) { second = nearest; nearest = d; }
      else if (d < second) { second = d; }
    }
  }
  float crack = 1.0 - smoothstep(0.008, 0.035, second - nearest);
  float flare = 1.0 - smoothstep(0.0, 0.15, abs(sin((nearest + second) * 13.0 - t)));
  float light = 0.008 + crack * (0.046 + flare * 0.025);
  gl_FragColor = vec4(vec3(light), 1.0);
}
