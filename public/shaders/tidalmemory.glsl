// Tidal Memory — copper sediment terraces, cut by a wandering inlet.
// Height-field lighting is computed from the same terrain that generates the contours.
precision highp float;
uniform float u_time;
uniform vec2 u_resolution;
uniform vec2 u_pointer;

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123); }
float noise(vec2 p) {
  vec2 i = floor(p), f = fract(p);
  vec2 u = f * f * (3.0 - 2.0 * f);
  return mix(mix(hash(i), hash(i + vec2(1, 0)), u.x), mix(hash(i + vec2(0, 1)), hash(i + 1.0), u.x), u.y);
}
float terrain(vec2 p) {
  float t = u_time * 0.017;
  float n = 0.0, amplitude = 0.48;
  mat2 r = mat2(0.8, -0.6, 0.6, 0.8);
  for (int i = 0; i < 5; i++) {
    n += amplitude * noise(p + vec2(t, -t * 0.6));
    p = r * p * 2.03 + 3.17;
    amplitude *= 0.48;
  }
  return n;
}
float heightAt(vec2 p) {
  p += 0.32 * vec2(sin(p.y * 0.8), cos(p.x * 0.6));
  float inlet = p.x + 0.58 * sin(p.y * 0.8 + u_time * 0.021) + 0.18 * sin(p.y * 2.0);
  return terrain(p) + 0.14 * abs(inlet) - 0.34 * exp(-inlet * inlet * 1.7);
}
void main() {
  vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution) / min(u_resolution.x, u_resolution.y);
  vec2 p = mat2(0.91, -0.42, 0.42, 0.91) * uv * 3.7 + vec2(0.15, 0.7);
  float h = heightAt(p);
  float e = 3.7 / min(u_resolution.x, u_resolution.y);
  vec2 gradient = vec2(heightAt(p + vec2(e, 0)) - heightAt(p - vec2(e, 0)), heightAt(p + vec2(0, e)) - heightAt(p - vec2(0, e))) / (2.0 * e);
  vec3 normal = normalize(vec3(-gradient * 0.65, 1.0));
  vec3 light = normalize(vec3(-0.65 + u_pointer.x * 0.45, 0.65 + u_pointer.y * 0.4, 0.65));
  float diffuse = max(dot(normal, light), 0.0);
  float contourPhase = h * 38.0;
  float edgeDistance = abs(fract(contourPhase) - 0.5);
  float lineWidth = clamp(length(gradient) * e * 38.0, 0.018, 0.24);
  float contour = 1.0 - smoothstep(0.025, 0.025 + lineWidth, edgeDistance);
  vec3 land = mix(vec3(0.13, 0.16, 0.16), vec3(0.63, 0.43, 0.26), smoothstep(0.25, 0.8, h));
  vec3 water = vec3(0.025, 0.10, 0.13);
  vec3 color = mix(water, land, smoothstep(0.22, 0.27, h));
  color *= 0.35 + 0.78 * diffuse;
  color += contour * vec3(0.18, 0.145, 0.095) * smoothstep(0.22, 0.27, h);
  float shore = exp(-abs(h - 0.25) * 100.0);
  color += shore * vec3(0.31, 0.36, 0.30);
  color *= 1.0 - 0.38 * smoothstep(0.2, 1.15, length(uv));
  gl_FragColor = vec4(color, 1.0);
}
