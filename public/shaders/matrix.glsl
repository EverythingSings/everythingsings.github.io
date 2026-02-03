// Matrix Shader - Digital rain / falling patterns
// Vertical streams with varying speeds

precision mediump float;

uniform float u_time;
uniform vec2 u_resolution;

float hash(float n) {
  return fract(sin(n) * 43758.5453);
}

float hash2(vec2 p) {
  return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

// Create a single column of falling elements
float column(float x, float colId, float t) {
  // Each column has unique properties
  float speed = 0.3 + hash(colId * 127.1) * 0.7;
  float offset = hash(colId * 43.7) * 100.0;
  float density = 0.3 + hash(colId * 91.3) * 0.5;

  // Vertical position with time
  float y = fract(t * speed + offset);

  return y;
}

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  float aspect = u_resolution.x / u_resolution.y;

  float t = u_time * 0.15;

  // Grid resolution (number of columns)
  float cols = 40.0 * aspect;
  float rows = 60.0;

  // Get column index
  float colId = floor(uv.x * cols);
  float colX = fract(uv.x * cols);

  float brightness = 0.0;

  // Multiple falling streams per column
  for (int i = 0; i < 4; i++) {
    float streamId = colId + float(i) * 100.0;

    // Stream properties
    float speed = 0.2 + hash(streamId * 13.7) * 0.5;
    float phase = hash(streamId * 73.1) * 10.0;
    float length = 0.1 + hash(streamId * 31.3) * 0.3;

    // Head position (falling down = 1 -> 0)
    float headY = 1.0 - fract(t * speed + phase);

    // Distance from head
    float dist = uv.y - headY;

    // Trail effect (brighter at head, fading behind)
    if (dist > 0.0 && dist < length) {
      float trail = 1.0 - dist / length;
      trail = pow(trail, 2.0);

      // Flickering/glitching effect
      float flicker = hash2(vec2(colId, floor(t * 10.0 + float(i))));
      trail *= 0.5 + flicker * 0.5;

      // Brighter head
      float head = exp(-dist * 50.0);
      trail += head * 0.5;

      // Column centering (fade at edges of column)
      float center = 1.0 - abs(colX - 0.5) * 2.0;
      center = pow(center, 0.5);

      brightness += trail * center * 0.3;
    }
  }

  // Add subtle background grid glow
  float gridX = abs(fract(uv.x * cols) - 0.5) * 2.0;
  float gridY = abs(fract(uv.y * rows) - 0.5) * 2.0;
  float grid = (1.0 - gridX) * (1.0 - gridY);
  grid = pow(grid, 8.0) * 0.05;

  // Random character-like dots
  vec2 cell = floor(vec2(uv.x * cols, uv.y * rows));
  float dot = hash2(cell + floor(t * 2.0));
  dot = step(0.97, dot) * 0.1;

  brightness += grid + dot;

  // Map to subtle range
  brightness = brightness * 0.8 + 0.02;
  brightness = clamp(brightness, 0.0, 0.2);

  gl_FragColor = vec4(vec3(brightness), 1.0);
}
