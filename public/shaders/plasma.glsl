// Plasma Shader - Organic plasma patterns
// Classic plasma with modern layering

precision mediump float;

uniform float u_time;
uniform vec2 u_resolution;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  float aspect = u_resolution.x / u_resolution.y;
  vec2 p = uv * vec2(aspect, 1.0);

  float t = u_time * 0.2;

  // Multiple plasma layers at different scales
  float plasma = 0.0;

  // Layer 1: Large slow waves
  plasma += sin(p.x * 3.0 + t);
  plasma += sin(p.y * 2.5 - t * 0.7);
  plasma += sin((p.x + p.y) * 2.0 + t * 0.5);

  // Layer 2: Radial component
  float d = length(p - vec2(aspect * 0.5, 0.5));
  plasma += sin(d * 8.0 - t * 2.0);

  // Layer 3: Diagonal interference
  plasma += sin((p.x * 4.0 - p.y * 3.0) + t * 1.3) * 0.5;
  plasma += sin((p.x * 3.0 + p.y * 4.0) - t * 0.9) * 0.5;

  // Layer 4: Fine turbulence
  vec2 q = p * 8.0;
  plasma += sin(q.x + sin(q.y + t)) * 0.3;
  plasma += sin(q.y + sin(q.x - t * 1.1)) * 0.3;

  // Normalize to 0-1 range
  plasma = (plasma + 6.0) / 12.0;

  // Apply contrast curve
  plasma = plasma * plasma * (3.0 - 2.0 * plasma);

  // Create bands
  float bands = sin(plasma * 12.0) * 0.5 + 0.5;

  // Mix smooth and banded
  float mixed = plasma * 0.7 + bands * 0.3;

  // Map to subtle brightness
  float brightness = mixed * 0.14 + 0.02;

  gl_FragColor = vec4(vec3(brightness), 1.0);
}
