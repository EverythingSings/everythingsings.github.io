// A projected grid bends as if laid across a breathing sphere.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 p = (uv - 0.5) * vec2(u_resolution.x / u_resolution.y, 1.0);
  float t = u_time * 0.025;
  float r = length(p);
  float bend = 0.10 * sin(r * 5.0 - t) + 0.035 * sin(p.y * 7.0 + t);
  vec2 q = p;
  q.x += bend * p.y;
  q.y += bend * p.x;
  vec2 grid = abs(fract(q * vec2(13.0, 11.0)) - 0.5);
  float minor = (1.0 - smoothstep(0.465, 0.492, max(grid.x, grid.y)));
  vec2 majorGrid = abs(fract(q * vec2(3.25, 2.75)) - 0.5);
  float major = 1.0 - smoothstep(0.480, 0.498, max(majorGrid.x, majorGrid.y));
  float vignette = 1.0 - smoothstep(0.35, 1.15, r);
  float ink = 0.007 + (minor * 0.020 + major * 0.032) * (0.55 + 0.45 * vignette);
  gl_FragColor = vec4(vec3(ink), 1.0);
}
