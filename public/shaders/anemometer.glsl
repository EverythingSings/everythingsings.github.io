// Three-cup instruments rotate in a sparse wind-reading array.
precision mediump float;
uniform float u_time;
uniform vec2 u_resolution;

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  vec2 p = uv * vec2(u_resolution.x / u_resolution.y, 1.0) * 5.5;
  vec2 id = floor(p);
  vec2 f = fract(p) - 0.5;
  float active = step(0.64, hash(id));
  float spin = u_time * (0.09 + hash(id + 2.0) * 0.09) + hash(id + 4.0) * 6.283;
  float light = 0.006;
  for (int i = 0; i < 3; i++) {
    float a = spin + float(i) * 2.0944;
    vec2 dir = vec2(cos(a), sin(a));
    float arm = (1.0 - smoothstep(0.020, 0.055, abs(f.x * dir.y - f.y * dir.x)))
              * (1.0 - smoothstep(0.04, 0.31, dot(f, dir)));
    vec2 cup = f - dir * 0.29;
    float bowl = 1.0 - smoothstep(0.04, 0.09, abs(length(cup) - 0.09));
    bowl *= smoothstep(-0.02, 0.08, dot(cup, vec2(-dir.y, dir.x)));
    light += active * (arm * 0.030 + bowl * 0.050);
  }
  gl_FragColor = vec4(vec3(light), 1.0);
}
