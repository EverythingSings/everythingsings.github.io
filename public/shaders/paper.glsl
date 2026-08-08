// Fibrous paper under raking light; nearly still, never frozen.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

float hash(vec2 p) { return fract(sin(dot(p, vec2(27.17, 113.91))) * 43758.5453); }

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 px = gl_FragCoord.xy;
  float grain = hash(floor(px * 0.72) + floor(u_time * 0.12));
  float fiberA = pow(0.5 + 0.5 * sin(uv.x * 520.0 + sin(uv.y * 31.0) * 4.0), 20.0);
  float fiberB = pow(0.5 + 0.5 * sin((uv.x + uv.y * 0.13) * 240.0 - u_time * 0.018), 32.0);
  float cloudy = 0.5 + 0.5 * sin(uv.x * 5.0 + sin(uv.y * 4.0));
  float light = 0.012 + grain * 0.018 + fiberA * 0.025 + fiberB * 0.016 + cloudy * 0.008;
  gl_FragColor = vec4(vec3(light), 1.0);
}
