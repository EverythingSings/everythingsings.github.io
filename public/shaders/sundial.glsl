// Long shadows rotate around several displaced gnomons.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

float ray(vec2 p, float angle, float width) {
  vec2 direction = vec2(cos(angle), sin(angle));
  float along = dot(p, direction);
  float across = abs(p.x * direction.y - p.y * direction.x);
  return smoothstep(0.0, 0.05, along) * (1.0 - smoothstep(width, width * 2.2, across));
}

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 p = (uv - 0.5) * vec2(u_resolution.x / u_resolution.y, 1.0);
  float t = u_time * 0.018;
  float light = 0.008;
  light += ray(p - vec2(-0.28, 0.15), t + 0.4, 0.008) * 0.046;
  light += ray(p - vec2(0.22, -0.18), t * 0.82 + 2.1, 0.006) * 0.035;
  light += ray(p - vec2(0.38, 0.24), -t * 0.65 - 1.2, 0.005) * 0.03;
  float gnomon = exp(-160.0 * dot(p + vec2(0.28, -0.15), p + vec2(0.28, -0.15)));
  light += gnomon * 0.065;
  gl_FragColor = vec4(vec3(light), 1.0);
}
