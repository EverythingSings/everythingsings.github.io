// Flow Field Shader - Organic, ever-shifting patterns
// Curl noise creates fluid-like movement

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

// Curl noise for fluid motion
vec2 curl(vec2 p, float t) {
  float eps = 0.01;
  float n1 = noise(p + vec2(eps, 0.0) + t);
  float n2 = noise(p - vec2(eps, 0.0) + t);
  float n3 = noise(p + vec2(0.0, eps) + t);
  float n4 = noise(p - vec2(0.0, eps) + t);
  return vec2((n3 - n4), -(n1 - n2)) / (2.0 * eps);
}

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  float aspect = u_resolution.x / u_resolution.y;
  vec2 p = vec2(uv.x * aspect, uv.y) * 4.0;

  float t = u_time * 0.1;

  // Advect position through curl field
  vec2 pos = p;
  for (int i = 0; i < 3; i++) {
    pos += curl(pos * 0.5, t * float(i + 1) * 0.3) * 0.15;
  }

  // Layer multiple noise octaves
  float n = 0.0;
  float amp = 0.5;
  float freq = 1.0;
  for (int i = 0; i < 5; i++) {
    n += amp * noise(pos * freq + t);
    freq *= 2.0;
    amp *= 0.5;
  }

  // Create flowing bands
  float bands = sin(n * 8.0 + t * 2.0) * 0.5 + 0.5;
  bands = pow(bands, 2.0);

  // Final composition
  float brightness = n * 0.12 + bands * 0.06 + 0.02;

  gl_FragColor = vec4(vec3(brightness), 1.0);
}
