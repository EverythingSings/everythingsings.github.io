// A breathing print-screen field, offset like imperfect registration.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

float dots(vec2 p, float size, float phase) {
  vec2 id = floor(p);
  vec2 f = fract(p) - 0.5;
  float radius = size * (0.72 + 0.28 * sin(id.x * 0.7 + id.y * 0.9 + phase));
  return 1.0 - smoothstep(radius, radius + 0.045, length(f));
}

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 p = (uv - 0.5) * vec2(u_resolution.x / u_resolution.y, 1.0);
  float t = u_time * 0.055;
  float angle = 0.12 * sin(t);
  float c = cos(angle), s = sin(angle);
  vec2 q = mat2(c, -s, s, c) * p * 24.0;
  float field = 0.5 + 0.5 * sin(length(p - vec2(0.18 * sin(t), 0.0)) * 12.0 - t);
  float screen = dots(q, 0.08 + field * 0.16, t);
  float ghost = dots(q * 0.503 + vec2(0.16, -0.11), 0.10, -t) * 0.45;
  float light = 0.009 + screen * 0.048 + ghost * 0.026;
  gl_FragColor = vec4(vec3(light), 1.0);
}
