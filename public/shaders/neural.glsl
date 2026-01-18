// Neural Shader - Minimal test version
precision mediump float;

uniform float u_time;
uniform vec2 u_resolution;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  float t = u_time * 0.5;

  // Just a simple pulsing circle - most basic possible shader
  vec2 center = vec2(0.5, 0.5);
  float d = length(uv - center);
  float pulse = 0.1 + 0.05 * sin(t * 2.0);
  float brightness = smoothstep(pulse + 0.05, pulse, d) * 0.3 + 0.02;

  gl_FragColor = vec4(vec3(brightness), 1.0);
}
