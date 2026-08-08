// Contour lines reveal a landscape that never resolves into terrain.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float noise(vec2 p) {
  vec2 i = floor(p), f = fract(p);
  f = f * f * (3.0 - 2.0 * f);
  return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
             mix(hash(i + vec2(0.0, 1.0)), hash(i + 1.0), f.x), f.y);
}
float fbm(vec2 p) {
  float value = 0.0, amplitude = 0.5;
  for (int i = 0; i < 5; i++) {
    value += noise(p) * amplitude;
    p = mat2(1.6, 1.2, -1.2, 1.6) * p + 0.17;
    amplitude *= 0.5;
  }
  return value;
}

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 p = (uv - 0.5) * vec2(u_resolution.x / u_resolution.y, 1.0) * 2.4;
  float field = fbm(p + vec2(u_time * 0.012, -u_time * 0.008));
  float contour = abs(fract(field * 13.0) - 0.5);
  float line = 1.0 - smoothstep(0.035, 0.09, contour);
  float major = 1.0 - smoothstep(0.025, 0.07, abs(fract(field * 3.25) - 0.5));
  float light = 0.008 + line * 0.032 + major * 0.019;
  gl_FragColor = vec4(vec3(light), 1.0);
}
