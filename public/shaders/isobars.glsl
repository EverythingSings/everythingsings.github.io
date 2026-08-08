// Pressure bands migrate across a low-contrast weather map.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

float field(vec2 p) {
  float t = u_time * 0.025;
  float a = sin(p.x * 2.2 + t) * cos(p.y * 1.7 - t * 0.6);
  float b = sin(length(p - vec2(0.9, -0.3)) * 3.4 - t * 0.7);
  float c = cos(length(p + vec2(1.1, 0.5)) * 2.7 + t * 0.4);
  return a * 0.46 + b * 0.32 + c * 0.22;
}

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 p = (uv - 0.5) * vec2(u_resolution.x / u_resolution.y, 1.0) * 3.1;
  float f = field(p);
  float bands = 1.0 - smoothstep(0.035, 0.085, abs(fract(f * 5.0) - 0.5));
  float major = 1.0 - smoothstep(0.025, 0.060, abs(fract(f * 1.25) - 0.5));
  float ink = 0.008 + bands * 0.030 + major * 0.030;
  gl_FragColor = vec4(vec3(ink), 1.0);
}
