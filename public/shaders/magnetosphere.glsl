// Dipole field contours bend between two quiet poles.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 p = (uv - 0.5) * vec2(u_resolution.x / u_resolution.y, 1.0);
  float t = u_time * 0.025;
  float angle = t * 0.35;
  float c = cos(angle), s = sin(angle);
  p = mat2(c, -s, s, c) * p;
  float r = length(p) + 0.025;
  float a = atan(p.y, p.x);
  float field = r / max(0.035, pow(abs(sin(a)), 2.0));
  float contours = 1.0 - smoothstep(0.025, 0.08, abs(fract(field * 6.0) - 0.5));
  float axis = exp(-28.0 * abs(p.y)) * smoothstep(0.55, 0.05, abs(p.x));
  float poles = exp(-90.0 * dot(p - vec2(0.22, 0.0), p - vec2(0.22, 0.0)));
  poles += exp(-90.0 * dot(p + vec2(0.22, 0.0), p + vec2(0.22, 0.0)));
  float fade = smoothstep(0.95, 0.12, r);
  float light = 0.008 + contours * fade * 0.039 + axis * 0.012 + poles * 0.052;
  gl_FragColor = vec4(vec3(light), 1.0);
}
