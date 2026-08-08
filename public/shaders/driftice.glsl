// Flat ice plates drift with dark water opening between them.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

vec2 hash2(vec2 p) {
  return fract(sin(vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)))) * 43758.5453);
}

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 p = (uv - 0.5) * vec2(u_resolution.x / u_resolution.y, 1.0) * 4.2;
  p += vec2(u_time * 0.012, sin(u_time * 0.025) * 0.08);
  vec2 id = floor(p), f = fract(p);
  float nearest = 8.0, second = 8.0;
  float shade = 0.0;
  for (int y = -1; y <= 1; y++) {
    for (int x = -1; x <= 1; x++) {
      vec2 n = vec2(float(x), float(y));
      vec2 seed = hash2(id + n);
      float d = length(n + seed - f);
      if (d < nearest) {
        second = nearest;
        nearest = d;
        shade = hash2(id + n + 13.0).x;
      } else if (d < second) second = d;
    }
  }
  float channel = smoothstep(0.025, 0.11, second - nearest);
  float plate = (0.018 + shade * 0.018) * channel;
  float edge = (1.0 - smoothstep(0.01, 0.055, second - nearest)) * 0.035;
  float light = 0.007 + plate + edge;
  gl_FragColor = vec4(vec3(light), 1.0);
}
