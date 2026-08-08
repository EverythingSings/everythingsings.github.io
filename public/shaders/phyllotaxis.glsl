// A sparse golden-angle seed head rotates through several scales.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 p = (uv - 0.5) * vec2(u_resolution.x / u_resolution.y, 1.0);
  float r = length(p);
  float t = u_time * 0.025;
  float golden = 2.399963;
  float approximate = r * r * 420.0;
  float seed = 0.0;
  for (int j = -5; j <= 5; j++) {
    float n = max(0.0, floor(approximate) + float(j));
    float radius = sqrt(n / 420.0);
    float angle = n * golden + t;
    vec2 point = vec2(cos(angle), sin(angle)) * radius;
    seed += exp(-7200.0 * dot(p - point, p - point));
  }
  float fade = smoothstep(0.72, 0.06, r);
  float light = 0.008 + min(1.0, seed) * fade * 0.062;
  gl_FragColor = vec4(vec3(light), 1.0);
}
