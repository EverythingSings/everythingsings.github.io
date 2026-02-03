// Spiral Shader - Galaxy-like rotation pattern
// Logarithmic spirals with organic distortion

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

float fbm(vec2 p) {
  float value = 0.0;
  float amplitude = 0.5;

  for (int i = 0; i < 4; i++) {
    value += amplitude * noise(p);
    p *= 2.0;
    amplitude *= 0.5;
  }
  return value;
}

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  float aspect = u_resolution.x / u_resolution.y;

  // Center the coordinate system
  vec2 p = vec2(uv.x * aspect, uv.y) - vec2(aspect * 0.5, 0.5);

  float t = u_time * 0.05;

  // Convert to polar coordinates
  float r = length(p);
  float theta = atan(p.y, p.x);

  // Add noise distortion to angle
  float distortion = fbm(p * 3.0 + t) * 0.5;
  theta += distortion;

  // Create spiral arms (logarithmic spiral: r = a * e^(b*theta))
  float arms = 0.0;

  // Multiple spiral arms with different tightness
  for (int i = 0; i < 3; i++) {
    float offset = float(i) * 2.094; // 2*PI/3 for 3-fold symmetry
    float spiral = theta + offset + t * 2.0 - log(r + 0.1) * 3.0;
    float arm = sin(spiral * 2.0) * 0.5 + 0.5;
    arm = pow(arm, 3.0); // Sharpen the arms
    arm *= smoothstep(0.8, 0.0, r); // Fade at edges
    arm *= smoothstep(0.0, 0.1, r); // Fade at center
    arms += arm;
  }

  // Add central glow
  float core = exp(-r * 8.0) * 0.5;

  // Add dust/star field effect
  float stars = fbm(p * 20.0 + t * 0.5);
  stars = pow(stars, 3.0) * 0.3;
  stars *= smoothstep(0.6, 0.0, r);

  // Rotation trails
  float trails = sin(theta * 8.0 - r * 10.0 + t * 3.0) * 0.5 + 0.5;
  trails *= exp(-r * 4.0);
  trails *= 0.2;

  // Combine elements
  float galaxy = arms * 0.4 + core + stars + trails;

  // Map to subtle brightness
  float brightness = galaxy * 0.12 + 0.02;

  gl_FragColor = vec4(vec3(brightness), 1.0);
}
