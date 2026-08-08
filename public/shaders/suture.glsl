// Alternating stitches hold a wandering seam in tension.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  float seam = 0.5 + 0.09 * sin(uv.y * 7.0 + u_time * 0.035) + 0.035 * sin(uv.y * 21.0 - u_time * 0.052);
  float core = 1.0 - smoothstep(0.0015, 0.0055, abs(uv.x - seam));
  float row = fract(uv.y * 24.0 + u_time * 0.018);
  float side = step(0.5, mod(floor(uv.y * 24.0), 2.0)) * 2.0 - 1.0;
  float stitchX = seam + side * (row - 0.5) * 0.10;
  float stitch = (1.0 - smoothstep(0.003, 0.009, abs(uv.x - stitchX)))
               * smoothstep(0.08, 0.20, row) * (1.0 - smoothstep(0.80, 0.92, row));
  float puncture = exp(-1800.0 * pow(uv.x - seam - side * 0.05, 2.0))
                 * exp(-500.0 * pow(row - 0.5, 2.0));
  float light = 0.006 + core * 0.028 + stitch * 0.050 + puncture * 0.065;
  gl_FragColor = vec4(vec3(light), 1.0);
}
