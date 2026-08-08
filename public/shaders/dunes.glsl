// Wind-drawn dune ridges moving almost imperceptibly.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float noise(vec2 p) {
  vec2 i = floor(p), f = fract(p);
  f = f * f * (3.0 - 2.0 * f);
  return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
             mix(hash(i + vec2(0.0, 1.0)), hash(i + 1.0), f.x), f.y);
}

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 p = (uv - 0.5) * vec2(u_resolution.x / u_resolution.y, 1.0);
  float t = u_time * 0.025;
  float perspective = 1.0 / max(0.18, uv.y + 0.14);
  float bend = noise(vec2(p.x * 1.3 + t, uv.y * 2.0)) * 0.7;
  float ridgeCoord = perspective * 1.4 + p.x * 0.28 + bend;
  float ridge = pow(0.5 + 0.5 * sin(ridgeCoord * 7.0), 12.0);
  float wind = noise(vec2(p.x * 12.0 - t, uv.y * 8.0)) * 0.018;
  float light = 0.011 + ridge * 0.058 * smoothstep(0.02, 0.65, uv.y) + wind;
  gl_FragColor = vec4(vec3(light), 1.0);
}
