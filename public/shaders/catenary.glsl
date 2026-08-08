// Suspended lines find their own slow equilibrium between anchors.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 p = (uv - 0.5) * vec2(u_resolution.x / u_resolution.y, 1.0);
  float light = 0.006;
  for (int i = 0; i < 11; i++) {
    float fi = float(i);
    float span = 0.52 + 0.07 * sin(fi * 1.9);
    float base = -0.46 + fi * 0.092;
    float sag = 0.10 + 0.055 * sin(fi * 2.3 + u_time * 0.025);
    float x = p.x + 0.09 * sin(fi * 1.3 + u_time * 0.018);
    float curve = base + sag * (1.0 - (x * x) / (span * span));
    float within = 1.0 - smoothstep(span, span + 0.025, abs(x));
    float line = 1.0 - smoothstep(0.0025, 0.008, abs(p.y - curve));
    float anchor = exp(-500.0 * pow(abs(x) - span, 2.0) - 500.0 * pow(p.y - base, 2.0));
    light += line * within * 0.030 + anchor * 0.055;
  }
  gl_FragColor = vec4(vec3(light), 1.0);
}
