// Broken sonar rings cross a deep field from an off-center source.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

float hash(float n) { return fract(sin(n * 127.1) * 43758.5453); }

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 p = (uv - 0.5) * vec2(u_resolution.x / u_resolution.y, 1.0);
  vec2 source = vec2(-0.32, 0.17);
  float r = length(p - source);
  float a = atan(p.y - source.y, p.x - source.x);
  float phase = r * 10.0 - u_time * 0.18;
  float ringId = floor(phase);
  float ring = 1.0 - smoothstep(0.035, 0.12, abs(fract(phase) - 0.5));
  float arcGate = smoothstep(0.18, 0.4, 0.5 + 0.5 * sin(a * (2.0 + mod(ringId, 4.0)) + hash(ringId) * 6.2831));
  float sourceGlow = exp(-18.0 * r);
  float light = 0.008 + ring * arcGate * 0.032 + sourceGlow * 0.03;
  gl_FragColor = vec4(vec3(light), 1.0);
}
