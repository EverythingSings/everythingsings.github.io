// Smoke Shader - Wispy tendrils rising
// Turbulent advection with upward drift

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

// Fractal Brownian Motion with rotation
float fbm(vec2 p) {
  float value = 0.0;
  float amplitude = 0.5;
  mat2 rot = mat2(0.8, 0.6, -0.6, 0.8); // Rotation matrix

  for (int i = 0; i < 6; i++) {
    value += amplitude * noise(p);
    p = rot * p * 2.0;
    amplitude *= 0.5;
  }
  return value;
}

// Turbulence function
float turbulence(vec2 p) {
  float value = 0.0;
  float amplitude = 0.5;

  for (int i = 0; i < 5; i++) {
    value += amplitude * abs(noise(p) * 2.0 - 1.0);
    p *= 2.0;
    amplitude *= 0.5;
  }
  return value;
}

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  float aspect = u_resolution.x / u_resolution.y;
  vec2 p = vec2(uv.x * aspect, uv.y);

  float t = u_time * 0.1;

  // Base upward drift
  vec2 drift = vec2(0.0, t * 0.5);

  // Multiple smoke layers with different behaviors
  float smoke = 0.0;

  // Layer 1: Large slow billows
  vec2 p1 = p * 2.0 - drift * 0.3;
  p1.x += sin(p1.y * 2.0 + t) * 0.2; // Gentle sway
  float layer1 = fbm(p1);
  layer1 = smoothstep(0.3, 0.7, layer1);

  // Layer 2: Medium turbulent wisps
  vec2 p2 = p * 4.0 - drift * 0.6;
  p2.x += fbm(p2 * 0.5 + t) * 0.3; // Turbulent sway
  float layer2 = turbulence(p2 + t * 0.5);
  layer2 = smoothstep(0.4, 0.8, layer2);

  // Layer 3: Fine detail
  vec2 p3 = p * 8.0 - drift;
  p3 += vec2(fbm(p3 * 0.3), fbm(p3 * 0.3 + 100.0)) * 0.5;
  float layer3 = fbm(p3);
  layer3 = pow(layer3, 2.0);

  // Combine layers
  smoke = layer1 * 0.5 + layer2 * 0.3 + layer3 * 0.2;

  // Source at bottom (smoke rises from below)
  float source = smoothstep(0.0, 0.4, uv.y);
  float dissipate = smoothstep(1.0, 0.5, uv.y);
  smoke *= source * dissipate;

  // Add some wispy tendrils
  float tendrils = fbm(p * 3.0 + vec2(t * 0.2, -t * 0.8));
  tendrils = pow(tendrils, 3.0);
  tendrils *= smoothstep(0.0, 0.3, uv.y) * smoothstep(1.0, 0.4, uv.y);

  smoke += tendrils * 0.3;

  // Volumetric feel - darken edges
  float edge = 1.0 - abs(uv.x - 0.5) * 1.5;
  edge = clamp(edge, 0.0, 1.0);
  smoke *= edge;

  // Map to subtle brightness
  float brightness = smoke * 0.12 + 0.02;

  gl_FragColor = vec4(vec3(brightness), 1.0);
}
