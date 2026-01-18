// Waves Shader - Interference patterns
// Multiple wave sources creating moire-like effects

precision mediump float;

uniform float u_time;
uniform vec2 u_resolution;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  float aspect = u_resolution.x / u_resolution.y;
  vec2 p = (uv - 0.5) * vec2(aspect, 1.0);

  float t = u_time * 0.15;

  // Multiple wave sources
  vec2 c1 = vec2(sin(t * 0.7) * 0.3, cos(t * 0.5) * 0.3);
  vec2 c2 = vec2(cos(t * 0.6) * 0.4, sin(t * 0.8) * 0.2);
  vec2 c3 = vec2(sin(t * 0.4 + 2.0) * 0.2, cos(t * 0.9) * 0.4);
  vec2 c4 = vec2(cos(t * 0.5 + 1.0) * 0.35, sin(t * 0.6 + 3.0) * 0.35);

  // Circular waves from each source
  float d1 = length(p - c1);
  float d2 = length(p - c2);
  float d3 = length(p - c3);
  float d4 = length(p - c4);

  // Wave frequencies
  float w1 = sin(d1 * 25.0 - t * 3.0);
  float w2 = sin(d2 * 30.0 - t * 2.5);
  float w3 = sin(d3 * 20.0 - t * 3.5);
  float w4 = sin(d4 * 35.0 - t * 2.0);

  // Combine waves with interference
  float waves = (w1 + w2 + w3 + w4) * 0.25;

  // Add envelope for fade at edges
  float envelope = 1.0 - smoothstep(0.3, 0.8, length(p));

  // Secondary fine detail
  float fine = sin(p.x * 50.0 + waves * 5.0) * sin(p.y * 50.0 + waves * 5.0);

  // Compose
  float brightness = waves * 0.08 * envelope + fine * 0.02 + 0.05;
  brightness = clamp(brightness, 0.01, 0.2);

  gl_FragColor = vec4(vec3(brightness), 1.0);
}
