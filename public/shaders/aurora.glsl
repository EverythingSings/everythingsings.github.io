// Aurora Shader - Northern lights style vertical waves
// Ethereal bands of light with slow vertical movement

precision mediump float;

uniform float u_time;
uniform vec2 u_resolution;

float hash(vec2 p) {
  return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  vec2 u = f * f * (3.0 - 2.0 * f);

  return mix(
    mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x),
    mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x),
    u.y
  );
}

// Fractal Brownian Motion
float fbm(vec2 p) {
  float value = 0.0;
  float amplitude = 0.5;
  float frequency = 1.0;

  for (int i = 0; i < 5; i++) {
    value += amplitude * noise(p * frequency);
    frequency *= 2.0;
    amplitude *= 0.5;
  }
  return value;
}

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  float aspect = u_resolution.x / u_resolution.y;

  float t = u_time * 0.08;

  // Create vertical aurora bands
  float x = uv.x * aspect;

  // Multiple layered curtains
  float aurora = 0.0;

  // Layer 1: Slow wide curtains
  float wave1 = sin(x * 2.0 + t + fbm(vec2(x * 0.5, t * 0.3)) * 2.0);
  wave1 = wave1 * 0.5 + 0.5;
  wave1 *= smoothstep(0.2, 0.8, uv.y); // Fade at bottom
  wave1 *= smoothstep(1.0, 0.6, uv.y); // Fade at top

  // Layer 2: Medium curtains with more movement
  float wave2 = sin(x * 4.0 - t * 1.3 + fbm(vec2(x, t * 0.5)) * 3.0);
  wave2 = wave2 * 0.5 + 0.5;
  wave2 *= smoothstep(0.1, 0.7, uv.y);
  wave2 *= smoothstep(1.0, 0.5, uv.y);

  // Layer 3: Fine rippling detail
  float wave3 = sin(x * 8.0 + t * 0.7 + fbm(vec2(x * 2.0, t * 0.8)) * 2.0);
  wave3 = wave3 * 0.5 + 0.5;
  wave3 *= smoothstep(0.3, 0.9, uv.y);
  wave3 *= smoothstep(1.0, 0.7, uv.y);

  // Combine layers
  aurora = wave1 * 0.5 + wave2 * 0.35 + wave3 * 0.15;

  // Add vertical shimmer
  float shimmer = noise(vec2(x * 10.0, uv.y * 20.0 + t * 2.0));
  aurora += shimmer * 0.1 * smoothstep(0.3, 0.7, uv.y);

  // Height-based intensity (brighter in upper portion)
  aurora *= smoothstep(0.0, 0.4, uv.y);

  // Map to subtle brightness
  float brightness = aurora * 0.12 + 0.02;

  gl_FragColor = vec4(vec3(brightness), 1.0);
}
