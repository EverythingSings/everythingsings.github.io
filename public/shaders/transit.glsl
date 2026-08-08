// Routes bend between quiet stations on an unlabeled night map.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  float aspect = u_resolution.x / u_resolution.y;
  vec2 p = vec2(uv.x * aspect, uv.y);
  float light = 0.006;
  for (int i = 0; i < 6; i++) {
    float fi = float(i);
    float baseline = 0.12 + fi * 0.15;
    float routeY = baseline + 0.08 * sin(p.x * (1.5 + fi * 0.18) + fi * 1.7 + u_time * 0.018);
    float route = 1.0 - smoothstep(0.0025, 0.008, abs(p.y - routeY));
    float stationX = (fi * 0.19 + 0.22 + u_time * 0.006) - floor((fi * 0.19 + 0.22 + u_time * 0.006) / aspect) * aspect;
    float stationY = baseline + 0.08 * sin(stationX * (1.5 + fi * 0.18) + fi * 1.7 + u_time * 0.018);
    float station = 1.0 - smoothstep(0.010, 0.020, abs(length(p - vec2(stationX, stationY)) - 0.026));
    light += route * 0.027 + station * 0.052;
  }
  gl_FragColor = vec4(vec3(light), 1.0);
}
