// Fine elliptical paths turn around several wandering centers.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 p = (uv - 0.5) * vec2(u_resolution.x / u_resolution.y, 1.0);
  float light = 0.007;
  for (int i = 0; i < 8; i++) {
    float fi = float(i);
    float angle = fi * 0.61 + u_time * (0.008 + fi * 0.0007);
    float c = cos(angle), s = sin(angle);
    vec2 center = 0.08 * vec2(sin(fi * 2.3 + u_time * 0.017), cos(fi * 1.7));
    vec2 q = mat2(c, -s, s, c) * (p - center);
    float radius = 0.20 + fi * 0.075;
    float ellipse = length(q * vec2(1.0, 1.35 + 0.08 * sin(fi)));
    float ring = 1.0 - smoothstep(0.0025, 0.008, abs(ellipse - radius));
    float phase = atan(q.y, q.x) + u_time * (0.11 + fi * 0.007);
    float body = exp(-700.0 * pow(abs(ellipse - radius), 2.0))
               * exp(-90.0 * pow(sin(phase * 0.5), 2.0));
    light += ring * 0.022 + body * 0.075;
  }
  gl_FragColor = vec4(vec3(light), 1.0);
}
