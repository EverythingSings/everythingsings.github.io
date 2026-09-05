// Silk Current — bundles of fine filaments turn through a continuous, sheared flow.
precision highp float;
uniform float u_time;
uniform vec2 u_resolution;
uniform vec2 u_pointer;
uniform float u_impulse;

mat2 turn(float a) { float c = cos(a), s = sin(a); return mat2(c, -s, s, c); }
void main() {
  vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution) / min(u_resolution.x, u_resolution.y);
  vec2 p = turn(-0.38) * uv;
  float t = u_time * 0.07;
  p.x += 0.06 * u_pointer.x;
  p.y += 0.04 * u_pointer.y;
  vec3 color = vec3(0.009, 0.016, 0.024);
  for (int i = 0; i < 4; i++) {
    float k = float(i);
    vec2 q = p + vec2(0.0, (k - 1.5) * 0.16);
    float bend = 0.24 * sin(q.x * 2.5 + t + k * 0.62);
    bend += 0.11 * sin(q.x * 5.1 - t * 0.73 + k * 0.38);
    float field = q.y - bend;
    float envelope = exp(-pow(field / (0.11 + 0.025 * sin(q.x * 2.0 - t + k)), 4.0));
    float folded = field * (110.0 + 15.0 * sin(q.x * 1.6 + t)) + 0.6 * sin(q.x * 3.0 + k);
    float filament = pow(0.5 + 0.5 * cos(folded * 6.283185), 12.0);
    float nyquist = clamp(min(u_resolution.x, u_resolution.y) / 850.0, 0.3, 1.0);
    filament = mix(0.16, filament, nyquist);
    float sheen = pow(0.5 + 0.5 * sin(q.x * 2.3 - t * 0.5 + k * 1.2), 5.0);
    vec3 cool = vec3(0.13, 0.37, 0.44);
    vec3 warm = vec3(0.75, 0.47, 0.32);
    vec3 dye = mix(cool, warm, 0.5 + 0.5 * sin(q.x * 0.85 + k * 1.7 + t * 0.25));
    color += envelope * (0.035 + filament * (0.42 + 0.48 * sheen)) * dye;
    color += envelope * pow(filament, 2.0) * pow(sheen, 3.0) * vec3(0.3, 0.4, 0.4);
  }
  float halo = exp(-3.0 * dot(uv, uv));
  color += vec3(0.015, 0.026, 0.034) * halo;
  color *= 0.72 + 0.28 * halo;
  gl_FragColor = vec4(color, 1.0);
}
