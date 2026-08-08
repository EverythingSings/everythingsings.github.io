// Long exposure scan lines break into quiet horizontal signals.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

float hash(vec2 p) { return fract(sin(dot(p, vec2(21.17, 97.31))) * 43758.5453); }

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 p = uv * vec2(u_resolution.x / u_resolution.y, 1.0);
  float rows = 96.0;
  float row = floor(p.y * rows);
  float lineY = abs(fract(p.y * rows) - 0.5);
  float speed = 0.012 + hash(vec2(row, 4.0)) * 0.035;
  float x = fract(p.x * (1.2 + hash(vec2(row, 2.0)) * 3.5) + u_time * speed);
  float gate = smoothstep(0.02, 0.12, x) * smoothstep(0.98, 0.78, x);
  float line = smoothstep(0.14, 0.02, lineY) * gate * step(0.62, hash(vec2(row, floor(u_time * 0.16))));
  float broad = exp(-80.0 * pow(fract(p.y * 6.0 - u_time * 0.01) - 0.5, 2.0));
  float light = 0.008 + line * 0.045 + broad * 0.013;
  gl_FragColor = vec4(vec3(light), 1.0);
}
