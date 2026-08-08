// Frequency bins breathe in a slowly scrolling monochrome record.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  float columns = 84.0;
  float x = uv.x * columns + u_time * 1.1;
  float id = floor(x);
  float stripe = 1.0 - smoothstep(0.20, 0.48, abs(fract(x) - 0.5));
  float energy = hash(vec2(id, floor(uv.y * 11.0)));
  float envelope = 0.30 + 0.70 * pow(1.0 - uv.y, 1.6);
  float harmonics = 0.5 + 0.5 * sin(uv.y * 90.0 + sin(id * 0.17) * 3.0);
  float pulse = smoothstep(0.62, 0.95, energy * envelope + harmonics * 0.22);
  float floorLine = 1.0 - smoothstep(0.004, 0.012, abs(uv.y - 0.16 - 0.025 * sin(id * 0.08)));
  float light = 0.006 + stripe * pulse * 0.052 + floorLine * 0.022;
  gl_FragColor = vec4(vec3(light), 1.0);
}
