// A slow mechanical iris, more botanical than optical.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 p = (uv - 0.5) * vec2(u_resolution.x / u_resolution.y, 1.0);
  float r = length(p);
  float a = atan(p.y, p.x);
  float t = u_time * 0.035;
  float petals = 0.5 + 0.5 * cos(a * 12.0 + sin(r * 8.0 - t) * 0.7);
  float aperture = 0.26 + 0.055 * petals + 0.018 * sin(t * 2.0);
  float rim = 1.0 - smoothstep(0.012, 0.036, abs(r - aperture));
  float outer = 1.0 - smoothstep(0.012, 0.03, abs(r - 0.43 - petals * 0.035));
  float veins = pow(0.5 + 0.5 * cos(a * 12.0 + r * 22.0 - t), 16.0) * smoothstep(0.18, 0.48, r);
  float glow = exp(-14.0 * abs(r - aperture));
  float light = 0.008 + rim * 0.068 + outer * 0.032 + veins * 0.025 + glow * 0.012;
  gl_FragColor = vec4(vec3(light), 1.0);
}
