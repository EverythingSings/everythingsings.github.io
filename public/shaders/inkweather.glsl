// Ink Weather. Two pigments are advected by a pressure-projected flow.
precision highp float;
uniform vec2 u_resolution;
uniform sampler2D u_state;
uniform vec2 u_stateSize;
vec2 field(vec2 p) {
  vec4 v = texture2D(u_state, p);
  return vec2(dot(v.rg, vec2(256.0, 1.0)), dot(v.ba, vec2(256.0, 1.0))) * (255.0 / 65535.0);
}
void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  vec2 c = field(uv), e = 1.0 / u_stateSize;
  float h = c.x;
  vec2 gradient = vec2(field(uv + vec2(e.x, 0)).x - field(uv - vec2(e.x, 0)).x, field(uv + vec2(0, e.y)).x - field(uv - vec2(0, e.y)).x);
  vec3 paper = vec3(0.88, 0.84, 0.73);
  vec3 ink = mix(vec3(0.025, 0.045, 0.066), vec3(0.06, 0.17, 0.2), c.y);
  vec3 color = mix(paper, ink, smoothstep(0.20, 0.57, h));
  float gold = smoothstep(0.64, 0.71, h) * (1.0 - smoothstep(0.76, 0.83, h));
  color = mix(color, mix(vec3(0.55, 0.23, 0.095), vec3(0.84, 0.65, 0.31), c.y), gold);
  float contour = pow(0.5 + 0.5 * sin(h * 190.0), 20.0) * smoothstep(0.008, 0.05, length(gradient));
  color *= 1.0 - 0.13 * contour;
  color += vec3(0.12, 0.10, 0.07) * clamp(dot(gradient, vec2(-1, 1)) * 6.0, -0.5, 0.5);
  float grain = fract(sin(dot(gl_FragCoord.xy, vec2(12.9898, 78.233))) * 43758.5453);
  color += (grain - 0.5) * 0.016;
  gl_FragColor = vec4(max(color, 0.0), 1.0);
}
