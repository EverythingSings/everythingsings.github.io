// A long vertical code mutates one quiet band at a time.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

float hash(float n) { return fract(sin(n * 127.1) * 43758.5453); }

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  float columns = 170.0;
  float column = floor(uv.x * columns);
  float cell = fract(uv.x * columns);
  float width = 0.12 + hash(column * 1.7) * 0.3;
  float bar = 1.0 - smoothstep(width, width + 0.08, abs(cell - 0.5));
  float band = floor(uv.y * 9.0);
  float shift = floor(u_time * 0.09 + band * 3.0);
  float gate = step(0.38, hash(column + band * 41.0 + shift));
  float fade = 0.6 + 0.4 * sin(uv.y * 3.1416);
  float light = 0.008 + bar * gate * fade * 0.032;
  gl_FragColor = vec4(vec3(light), 1.0);
}
