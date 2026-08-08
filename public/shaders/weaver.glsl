// Threads pass over and under in a breathing woven field.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 p = uv * vec2(u_resolution.x / u_resolution.y, 1.0) * 42.0;
  float t = u_time * 0.035;
  p.x += sin(p.y * 0.17 + t) * 0.42;
  p.y += sin(p.x * 0.13 - t) * 0.36;
  vec2 f = fract(p) - 0.5;
  vec2 id = floor(p);
  float warp = 1.0 - smoothstep(0.08, 0.19, abs(f.x));
  float weft = 1.0 - smoothstep(0.08, 0.19, abs(f.y));
  float over = step(0.5, mod(id.x + id.y, 2.0));
  float thread = mix(max(warp * 0.55, weft), max(warp, weft * 0.55), over);
  float sheen = 0.7 + 0.3 * sin((f.x + f.y) * 3.1416);
  float light = 0.008 + thread * sheen * 0.026;
  gl_FragColor = vec4(vec3(light), 1.0);
}
