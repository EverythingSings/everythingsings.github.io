// Voronoi Shader - Emergent cellular structures
// Layered voronoi with edge glow

precision mediump float;

uniform float u_time;
uniform vec2 u_resolution;

vec2 hash2(vec2 p) {
  p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
  return fract(sin(p) * 43758.5453);
}

// Voronoi with smooth edges
vec3 voronoi(vec2 p, float t) {
  vec2 n = floor(p);
  vec2 f = fract(p);

  float minDist = 8.0;
  float secondDist = 8.0;
  vec2 minPoint = vec2(0.0);

  for (int j = -1; j <= 1; j++) {
    for (int i = -1; i <= 1; i++) {
      vec2 neighbor = vec2(float(i), float(j));
      vec2 point = hash2(n + neighbor);

      // Organic movement
      point = 0.5 + 0.4 * sin(t + 6.2831 * point + point.yx * 3.0);

      vec2 diff = neighbor + point - f;
      float dist = length(diff);

      if (dist < minDist) {
        secondDist = minDist;
        minDist = dist;
        minPoint = point;
      } else if (dist < secondDist) {
        secondDist = dist;
      }
    }
  }

  float edge = secondDist - minDist;
  return vec3(minDist, secondDist, edge);
}

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  float aspect = u_resolution.x / u_resolution.y;
  vec2 p = vec2(uv.x * aspect, uv.y);

  float t = u_time * 0.08;

  // Layer multiple scales
  vec3 v1 = voronoi(p * 4.0, t);
  vec3 v2 = voronoi(p * 8.0 + 10.0, t * 1.3);
  vec3 v3 = voronoi(p * 16.0 + 20.0, t * 0.7);

  // Cell shading
  float cell = v1.x * 0.6 + v2.x * 0.3 + v3.x * 0.1;

  // Edge glow - brighter at cell boundaries
  float edge1 = 1.0 - smoothstep(0.0, 0.1, v1.z);
  float edge2 = 1.0 - smoothstep(0.0, 0.05, v2.z);

  float edges = edge1 * 0.7 + edge2 * 0.3;

  // Combine
  float brightness = cell * 0.08 + edges * 0.1 + 0.02;

  gl_FragColor = vec4(vec3(brightness), 1.0);
}
