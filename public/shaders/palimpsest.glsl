// Palimpsest — a breathing interference engraving on warm mineral paper.
precision highp float;
uniform float u_time;
uniform vec2 u_resolution;
uniform vec2 u_pointer;

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
void main() {
  vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution) / min(u_resolution.x, u_resolution.y);
  vec2 p = uv * 2.2;
  float t = u_time * 0.037;
  vec2 a = vec2(-0.32 + 0.08 * sin(t), 0.14 + u_pointer.y * 0.06);
  vec2 b = vec2(0.3 + u_pointer.x * 0.06, -0.16 + 0.08 * cos(t * 0.7));
  vec2 qa = p - a, qb = p - b;
  float angleA = atan(qa.y, qa.x), angleB = atan(qb.y, qb.x);
  float ra = length(qa) + 0.09 * sin(angleA * 3.0 + t);
  float rb = length(qb) + 0.08 * sin(angleB * 4.0 - t * 0.8);
  float warp = 0.13 * sin(p.y * 3.0 + t) * sin(p.x * 2.0 - t);
  float phaseA = (ra + warp) * 39.0;
  float phaseB = (rb - warp) * 42.0;
  float width = clamp(100.0 / min(u_resolution.x, u_resolution.y), 0.05, 0.3);
  float lineA = 1.0 - smoothstep(0.04, 0.04 + width, abs(fract(phaseA) - 0.5));
  float lineB = 1.0 - smoothstep(0.035, 0.035 + width, abs(fract(phaseB) - 0.5));
  float body = 1.0 - smoothstep(0.60, 1.18, length(p * vec2(0.8, 1.0)));
  float overlap = lineA * lineB;
  vec3 paper = vec3(0.75, 0.72, 0.64);
  float grain = hash(floor(gl_FragCoord.xy * 0.75));
  paper += (grain - 0.5) * 0.045;
  vec3 ink = vec3(0.06, 0.085, 0.09);
  float etched = clamp(lineA * 0.54 + lineB * 0.4 + overlap * 0.27, 0.0, 1.0) * body;
  vec3 color = mix(paper, ink, etched);
  float plateEdge = exp(-abs(length(p * vec2(0.8, 1.0)) - 1.15) * 100.0);
  color -= plateEdge * 0.12;
  color *= 0.83 + 0.17 * exp(-length(uv) * 1.2);
  gl_FragColor = vec4(color, 1.0);
}
