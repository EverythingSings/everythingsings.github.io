// Sedimentary contours drifting through deep time.
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
  float t = u_time * 0.035;
  float warp = noise(vec2(p.x * 1.6 + t, p.y * 1.2 - t)) * 0.34;
  warp += noise(vec2(p.x * 4.0 - t, p.y * 2.1)) * 0.11;
  float layer = p.y * 13.0 + warp * 5.0 + sin(p.x * 2.4 + t) * 0.55;
  float seam = 1.0 - smoothstep(0.04, 0.19, abs(fract(layer) - 0.5));
  float broad = 0.5 + 0.5 * sin(layer * 0.52);
  float light = 0.012 + broad * 0.022 + seam * 0.064;
  light *= 0.72 + 0.28 * smoothstep(0.9, 0.1, length(p));
  gl_FragColor = vec4(vec3(light), 1.0);
}
