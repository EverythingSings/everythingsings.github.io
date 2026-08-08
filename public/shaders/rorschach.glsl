// Mirrored ink blooms open and close around the center seam.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

float hash(vec2 p) { return fract(sin(dot(p, vec2(113.5, 271.9))) * 43758.5453); }
float noise(vec2 p) {
  vec2 i = floor(p), f = fract(p);
  f = f * f * (3.0 - 2.0 * f);
  return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
             mix(hash(i + vec2(0.0, 1.0)), hash(i + 1.0), f.x), f.y);
}

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 p = (uv - 0.5) * vec2(u_resolution.x / u_resolution.y, 1.0);
  p.x = abs(p.x);
  float t = u_time * 0.035;
  float ink = noise(p * 2.1 + vec2(t, -t * 0.4));
  ink += noise(p * 5.3 + vec2(-t * 0.6, t)) * 0.48;
  ink += noise(p * 11.0 - t * 0.3) * 0.2;
  float threshold = 0.70 + 0.07 * sin(p.y * 4.0 + t);
  float bloom = smoothstep(threshold, threshold + 0.11, ink);
  float contour = 1.0 - smoothstep(0.025, 0.075, abs(ink - threshold));
  float innerContour = 1.0 - smoothstep(0.025, 0.07, abs(ink - threshold - 0.16));
  float edge = smoothstep(0.0, 0.018, p.x);
  float light = 0.009 + bloom * 0.018 + contour * 0.052 + innerContour * 0.025;
  light += (1.0 - edge) * 0.018 * contour;
  gl_FragColor = vec4(vec3(light), 1.0);
}
