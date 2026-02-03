// Ripple Shader - Water ripple interference patterns
// Concentric waves from multiple sources creating interference

precision mediump float;

uniform float u_time;
uniform vec2 u_resolution;

float hash(vec2 p) {
  return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

// Single ripple from a point
float ripple(vec2 uv, vec2 center, float t, float speed, float freq) {
  float d = length(uv - center);
  float wave = sin(d * freq - t * speed);
  // Attenuate with distance
  float atten = 1.0 / (1.0 + d * 2.0);
  return wave * atten;
}

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  float aspect = u_resolution.x / u_resolution.y;
  vec2 p = vec2(uv.x * aspect, uv.y);

  float t = u_time * 0.5;

  // Multiple ripple sources with slow movement
  float waves = 0.0;

  // Source 1: Center-left, slow drift
  vec2 c1 = vec2(aspect * 0.3 + sin(t * 0.2) * 0.1, 0.5 + cos(t * 0.15) * 0.1);
  waves += ripple(p, c1, t, 3.0, 20.0);

  // Source 2: Center-right
  vec2 c2 = vec2(aspect * 0.7 + cos(t * 0.18) * 0.1, 0.4 + sin(t * 0.22) * 0.1);
  waves += ripple(p, c2, t * 1.1, 2.8, 18.0);

  // Source 3: Top center
  vec2 c3 = vec2(aspect * 0.5 + sin(t * 0.12) * 0.15, 0.8 + cos(t * 0.1) * 0.05);
  waves += ripple(p, c3, t * 0.9, 3.2, 22.0);

  // Source 4: Bottom area
  vec2 c4 = vec2(aspect * 0.4 + cos(t * 0.14) * 0.12, 0.2 + sin(t * 0.16) * 0.08);
  waves += ripple(p, c4, t * 1.05, 2.6, 16.0);

  // Source 5: Wandering source
  vec2 c5 = vec2(
    aspect * 0.5 + sin(t * 0.25) * aspect * 0.3,
    0.5 + cos(t * 0.2) * 0.3
  );
  waves += ripple(p, c5, t * 0.95, 3.5, 24.0) * 0.7;

  // Normalize and apply contrast
  waves = waves * 0.2;
  waves = waves * 0.5 + 0.5; // Map to 0-1

  // Add subtle caustic-like highlights
  float caustic = waves * waves;

  // Edge darkening (vignette)
  vec2 center = vec2(aspect * 0.5, 0.5);
  float vignette = 1.0 - length(p - center) * 0.5;
  vignette = clamp(vignette, 0.0, 1.0);

  // Final composition
  float brightness = (waves * 0.08 + caustic * 0.04) * vignette + 0.02;

  gl_FragColor = vec4(vec3(brightness), 1.0);
}
