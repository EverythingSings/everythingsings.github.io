// Tiny directional marks turn together through a continuous field.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 p = uv * vec2(u_resolution.x / u_resolution.y, 1.0);
  vec2 q = p * 19.0;
  vec2 id = floor(q);
  vec2 f = fract(q) - 0.5;
  vec2 center = (id + 0.5) / 19.0;
  float angle = atan(center.y - 0.5, center.x - 0.65) + 1.5708;
  angle += 0.75 * sin(center.x * 4.0 + center.y * 5.0 + u_time * 0.035);
  float c = cos(angle), s = sin(angle);
  f = mat2(c, -s, s, c) * f;
  float shaft = (1.0 - smoothstep(0.035, 0.09, abs(f.y)))
              * (1.0 - smoothstep(0.08, 0.32, abs(f.x)));
  float headA = 1.0 - smoothstep(0.025, 0.070, abs(f.y - (0.28 - f.x) * 0.45));
  float headB = 1.0 - smoothstep(0.025, 0.070, abs(f.y + (0.28 - f.x) * 0.45));
  float head = max(headA, headB) * smoothstep(0.08, 0.24, f.x);
  float light = 0.006 + max(shaft, head) * 0.052;
  gl_FragColor = vec4(vec3(light), 1.0);
}
