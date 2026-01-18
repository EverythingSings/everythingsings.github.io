// Fractal Brownian Motion Shader - Layered complexity
// Domain warping creates organic, smoke-like forms

precision mediump float;

uniform float u_time;
uniform vec2 u_resolution;

float hash(vec2 p) {
  return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  vec2 u = f * f * f * (f * (f * 6.0 - 15.0) + 10.0); // Quintic interpolation

  return mix(
    mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x),
    mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x),
    u.y
  );
}

// FBM with rotation per octave
float fbm(vec2 p) {
  float value = 0.0;
  float amplitude = 0.5;
  float frequency = 1.0;
  mat2 rot = mat2(0.8, 0.6, -0.6, 0.8); // Rotation matrix

  for (int i = 0; i < 6; i++) {
    value += amplitude * noise(p * frequency);
    p = rot * p;
    frequency *= 2.0;
    amplitude *= 0.5;
  }

  return value;
}

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  float aspect = u_resolution.x / u_resolution.y;
  vec2 p = vec2(uv.x * aspect, uv.y) * 3.0;

  float t = u_time * 0.05;

  // Triple domain warping for organic shapes
  vec2 q = vec2(fbm(p + t), fbm(p + vec2(5.2, 1.3)));
  vec2 r = vec2(
    fbm(p + q * 4.0 + vec2(1.7, 9.2) + t * 0.15),
    fbm(p + q * 4.0 + vec2(8.3, 2.8) + t * 0.12)
  );
  vec2 s = vec2(
    fbm(p + r * 2.0 + vec2(3.1, 4.7) - t * 0.1),
    fbm(p + r * 2.0 + vec2(7.9, 1.4) - t * 0.08)
  );

  float f = fbm(p + s * 2.0);

  // Create depth with multiple layers
  float detail = fbm(p * 8.0 + f * 2.0);

  // Map to monochrome with subtle variation
  float brightness = f * 0.15 + detail * 0.03 + 0.02;

  // Add subtle vignette
  float vignette = 1.0 - length(uv - 0.5) * 0.3;
  brightness *= vignette;

  gl_FragColor = vec4(vec3(brightness), 1.0);
}
