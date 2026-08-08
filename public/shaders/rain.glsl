// Fine slanting rain catching intermittent distant light.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

float hash(vec2 p) { return fract(sin(dot(p, vec2(17.13, 73.71))) * 43758.5453); }

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 p = uv * vec2(u_resolution.x / u_resolution.y, 1.0);
  float t = u_time * 0.32;
  float light = 0.012;
  for (int i = 0; i < 3; i++) {
    float fi = float(i);
    float scale = 34.0 + fi * 19.0;
    vec2 q = p * scale;
    q.x += q.y * (0.22 + fi * 0.04);
    float lane = floor(q.x);
    float speed = 1.2 + hash(vec2(lane, fi)) * 2.1;
    float y = fract(q.y + t * speed + hash(vec2(lane, fi + 4.0)));
    float x = abs(fract(q.x) - 0.5);
    float drop = smoothstep(0.07, 0.0, x) * smoothstep(0.55, 0.18, y) * smoothstep(0.0, 0.08, y);
    light += drop * (0.045 - fi * 0.009);
  }
  float distant = exp(-12.0 * length(p - vec2(0.78, 0.68))) * (0.04 + 0.015 * sin(t));
  gl_FragColor = vec4(vec3(light + distant), 1.0);
}
