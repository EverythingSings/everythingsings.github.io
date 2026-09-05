// Aperture Choir — seven optical instruments share a slowly shifting illumination.
precision highp float;
uniform float u_time;
uniform vec2 u_resolution;
uniform vec2 u_pointer;

void main() {
  vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution) / min(u_resolution.x, u_resolution.y);
  vec2 p = uv * 1.85;
  vec3 color = vec3(0.023, 0.025, 0.025);
  for (int i = 0; i < 7; i++) {
    float k = float(i);
    float a = (k - 1.0) * 1.0471976 + 0.12 * sin(u_time * 0.035);
    vec2 center = i == 0 ? vec2(0.0) : 0.55 * vec2(cos(a), sin(a));
    vec2 q = p - center;
    float r = length(q);
    float radius = i == 0 ? 0.27 : 0.205;
    float edgeWidth = 1.85 / min(u_resolution.x, u_resolution.y);
    float mask = 1.0 - smoothstep(radius - edgeWidth, radius + edgeWidth, r);
    float bevel = 1.0 - smoothstep(0.004, 0.012, abs(r - radius + 0.014));
    vec2 light = vec2(-0.32, 0.42) + u_pointer * 0.16;
    float z = sqrt(max(0.0, radius * radius - dot(q, q)));
    vec3 n = normalize(vec3(q, z + 0.001));
    float diffuse = max(dot(n, normalize(vec3(light, 0.65))), 0.0);
    vec2 refracted = q / (0.28 + z * 3.0) + center * 0.3;
    float phase = refracted.x * 22.0 + refracted.y * 7.0 + u_time * 0.1 + k * 0.8;
    float fringe = pow(0.5 + 0.5 * sin(phase), 4.0);
    float pupilRadius = radius * (0.2 + 0.12 * (0.5 + 0.5 * sin(u_time * 0.12 + k * 0.7)));
    vec2 aperturePoint = q - u_pointer * 0.015;
    float apertureAngle = atan(aperturePoint.y, aperturePoint.x) + u_time * 0.025 + k * 0.3;
    float bladeAngle = mod(apertureAngle, 0.8975979) - 0.44879895;
    float apertureDistance = length(aperturePoint) * cos(bladeAngle);
    float pupil = smoothstep(pupilRadius - edgeWidth, pupilRadius + edgeWidth, apertureDistance);
    float blade = fract(apertureAngle / 0.8975979 + r * 3.0);
    float bladeSeam = 1.0 - smoothstep(0.01, 0.04, min(blade, 1.0 - blade));
    vec3 tint = mix(vec3(0.12, 0.34, 0.36), vec3(0.55, 0.32, 0.17), 0.5 + 0.5 * sin(k * 2.4));
    vec3 lens = tint * (0.14 + diffuse * 0.55 + fringe * 0.27) * pupil;
    lens *= 1.0 - bladeSeam * 0.4;
    float highlight = pow(max(dot(n, normalize(vec3(light, 1.5))), 0.0), 40.0);
    lens += highlight * vec3(0.35, 0.44, 0.4) * pupil + bevel * (0.1 + diffuse * 0.28);
    lens += exp(-abs(apertureDistance - pupilRadius) * 350.0) * vec3(0.22, 0.3, 0.27);
    float engrave = (1.0 - smoothstep(0.0, 0.018, abs(r - radius * 0.88))) * pow(0.5 + 0.5 * cos(atan(q.y, q.x) * 80.0), 8.0);
    lens += engrave * vec3(0.26, 0.27, 0.23);
    color = mix(color, lens, mask);
  }
  color *= 1.0 - 0.3 * smoothstep(0.25, 0.95, length(uv));
  gl_FragColor = vec4(color, 1.0);
}
