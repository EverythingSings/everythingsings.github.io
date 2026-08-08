// Overlapping wave lenses cast slow monochrome caustics.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 p = (uv - 0.5) * vec2(u_resolution.x / u_resolution.y, 1.0) * 3.0;
  float t = u_time * 0.055;
  float field = 0.0;
  vec2 q = p;
  for (int i = 0; i < 5; i++) {
    float fi = float(i);
    q += 0.18 * vec2(sin(q.y * (1.3 + fi * 0.1) + t + fi), cos(q.x * (1.5 + fi * 0.08) - t + fi));
    field += sin(q.x * (2.1 + fi * 0.17) + cos(q.y * 1.7 - t)) * 0.2;
  }
  float lens = pow(0.5 + 0.5 * sin(field * 4.2 + p.y * 1.4), 9.0);
  float light = 0.009 + lens * 0.067;
  gl_FragColor = vec4(vec3(light), 1.0);
}
