// Layered seismograph traces carry rare disturbances across the page.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

float hash(float n) { return fract(sin(n * 127.1) * 43758.5453); }

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  float rows = 15.0;
  float row = floor(uv.y * rows);
  float localY = fract(uv.y * rows) - 0.5;
  float travel = fract(uv.x * 0.72 - u_time * (0.018 + hash(row) * 0.012) + hash(row + 9.0));
  float packet = exp(-90.0 * pow(travel - 0.5, 2.0));
  float wave = sin(travel * 95.0 + row * 2.7) * packet * (0.09 + hash(row + 2.0) * 0.12);
  wave += sin(uv.x * 9.0 + row) * 0.015;
  float trace = 1.0 - smoothstep(0.018, 0.05, abs(localY - wave));
  float baseline = 1.0 - smoothstep(0.008, 0.025, abs(localY));
  float light = 0.008 + trace * 0.052 + baseline * 0.012 * (1.0 - packet);
  gl_FragColor = vec4(vec3(light), 1.0);
}
