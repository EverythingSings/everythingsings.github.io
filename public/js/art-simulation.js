// Persistent GPU fields. Each scalar uses two RGBA8 channels (16-bit fixed point),
// so these studies do not depend on floating-point framebuffer extensions.
const COMMON = `
precision highp float;
uniform sampler2D u_state;
uniform sampler2D u_aux;
uniform sampler2D u_velocity;
uniform sampler2D u_extra;
uniform vec2 u_resolution;
uniform vec4 u_brush;
uniform float u_press;
uniform float u_step;
uniform float u_time;
uniform float u_seed;
const float ZERO = 32768.0 / 65535.0;
vec2 pack16(float x) {
  float n = floor(clamp(x, 0.0, 1.0) * 65535.0 + 0.5);
  return vec2(floor(n / 256.0), mod(n, 256.0)) / 255.0;
}
vec4 pack2(vec2 v) { return vec4(pack16(v.x), pack16(v.y)); }
vec2 unpack2(vec4 v) { return vec2(dot(v.rg, vec2(256.0, 1.0)), dot(v.ba, vec2(256.0, 1.0))) * (255.0 / 65535.0); }
vec2 read2(sampler2D tex, vec2 uv) { return unpack2(texture2D(tex, uv)); }
float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7)) + u_seed * 1.37) * 43758.5453); }
float brushDistance(vec2 uv) {
  vec2 aspect = u_resolution / min(u_resolution.x, u_resolution.y);
  vec2 a = u_brush.xy * aspect, b = u_brush.zw * aspect;
  vec2 p = uv * aspect;
  vec2 d = b - a;
  float h = clamp(dot(p - a, d) / max(dot(d, d), 0.000001), 0.0, 1.0);
  return length(p - a - d * h);
}
`;

const SOURCES = {
  reaction: `
void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  vec2 e = 1.0 / u_resolution;
  if (u_step < 0.0) {
    vec2 p = uv * u_resolution / 42.0;
    vec2 id = floor(p);
    vec2 center = vec2(0.3 + hash(id) * 0.4, 0.3 + hash(id + 19.7) * 0.4);
    float b = (1.0 - smoothstep(0.13, 0.25, length(fract(p) - center))) * step(0.3, hash(id + 2.7));
    gl_FragColor = pack2(vec2(1.0 - b * 0.65, b * 0.9));
    return;
  }
  vec2 c = read2(u_state, uv);
  vec2 lap = -c;
  lap += 0.2 * (read2(u_state, uv + vec2(e.x, 0)) + read2(u_state, uv - vec2(e.x, 0)) + read2(u_state, uv + vec2(0, e.y)) + read2(u_state, uv - vec2(0, e.y)));
  lap += 0.05 * (read2(u_state, uv + e) + read2(u_state, uv - e) + read2(u_state, uv + vec2(e.x, -e.y)) + read2(u_state, uv + vec2(-e.x, e.y)));
  float feed = 0.038 + 0.017 * uv.y;
  float kill = 0.061 + 0.002 * sin(uv.x * 3.14159);
  float reaction = c.x * c.y * c.y;
  vec2 next = c + vec2(lap.x - reaction + feed * (1.0 - c.x), 0.5 * lap.y + reaction - (feed + kill) * c.y);
  float brush = u_press * (1.0 - smoothstep(0.014, 0.027, brushDistance(uv)));
  next = mix(next, vec2(0.12, 0.95), brush);
  gl_FragColor = pack2(clamp(next, 0.0, 1.0));
}`,
  wave: `
void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  vec2 e = 1.0 / u_resolution;
  if (u_step < 0.0) {
    float h = 0.0;
    for (int i = 0; i < 8; i++) {
      vec2 center = vec2(hash(vec2(float(i), 3.1)), hash(vec2(float(i), 9.7))) * 0.8 + 0.1;
      vec2 q = (uv - center) * u_resolution / min(u_resolution.x, u_resolution.y);
      h += 0.3 * exp(-dot(q, q) * 2400.0);
    }
    gl_FragColor = pack2(vec2(h * 0.5 + ZERO, ZERO));
    return;
  }
  vec2 state = (read2(u_state, uv) - ZERO) * 2.0;
  float h = state.x, velocity = state.y;
  float lap = (read2(u_state, uv + vec2(e.x, 0)).x + read2(u_state, uv - vec2(e.x, 0)).x + read2(u_state, uv + vec2(0, e.y)).x + read2(u_state, uv - vec2(0, e.y)).x - 4.0 * (h * 0.5 + ZERO)) * 2.0;
  float lapV = (read2(u_state, uv + vec2(e.x, 0)).y + read2(u_state, uv - vec2(e.x, 0)).y + read2(u_state, uv + vec2(0, e.y)).y + read2(u_state, uv - vec2(0, e.y)).y - 4.0 * (velocity * 0.5 + ZERO)) * 2.0;
  velocity = (velocity + 0.23 * lap + 0.045 * lapV) * 0.993;
  float d = brushDistance(uv);
  float drop = exp(-d * d * 7500.0) - 0.25 * exp(-d * d * 1800.0);
  velocity += u_press * drop * 0.03;
  if (mod(u_step, 145.0) < 0.5) {
    vec2 center = 0.5 + 0.3 * vec2(sin(u_time * 0.73), cos(u_time * 0.61));
    vec2 q = (uv - center) * u_resolution / min(u_resolution.x, u_resolution.y);
    velocity += 0.05 * (exp(-dot(q, q) * 4000.0) - 0.25 * exp(-dot(q, q) * 1000.0));
  }
  float edge = min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y));
  velocity *= smoothstep(0.0, 0.025, edge);
  h = clamp(h + velocity, -0.98, 0.98);
  gl_FragColor = pack2(vec2(h, clamp(velocity, -0.8, 0.8)) * 0.5 + ZERO);
}`,
  velocity: `
void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  if (u_step < 0.0) { gl_FragColor = pack2(vec2(ZERO)); return; }
  vec2 v = (read2(u_state, uv) - ZERO) * 16.0;
  v = (read2(u_state, uv - v / u_resolution) - ZERO) * 16.0 * 0.997;
  vec2 aspect = u_resolution / min(u_resolution.x, u_resolution.y);
  for (int i = 0; i < 3; i++) {
    float k = float(i);
    vec2 center = 0.5 + 0.23 * vec2(sin(u_time * 0.13 + k * 2.1), cos(u_time * 0.11 + k * 2.7));
    vec2 q = (uv - center) * aspect;
    v += vec2(-q.y, q.x) * exp(-dot(q, q) * 35.0) * (0.18 + 0.07 * k) * (i == 1 ? -1.0 : 1.0);
  }
  float brush = u_press * exp(-pow(brushDistance(uv) / 0.035, 2.0));
  vec2 movement = (u_brush.zw - u_brush.xy) * u_resolution;
  v += clamp(movement * 0.5, -3.0, 3.0) * brush;
  if (uv.x < 1.5 / u_resolution.x || uv.x > 1.0 - 1.5 / u_resolution.x) v.x = 0.0;
  if (uv.y < 1.5 / u_resolution.y || uv.y > 1.0 - 1.5 / u_resolution.y) v.y = 0.0;
  gl_FragColor = pack2(clamp(v / 16.0 + ZERO, 0.0, 1.0));
}`,
  divergence: `
void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution, e = 1.0 / u_resolution;
  float dx = read2(u_state, uv + vec2(e.x, 0)).x - read2(u_state, uv - vec2(e.x, 0)).x;
  float dy = read2(u_state, uv + vec2(0, e.y)).y - read2(u_state, uv - vec2(0, e.y)).y;
  float div = 0.5 * 16.0 * (dx + dy);
  gl_FragColor = pack2(vec2(div / 32.0 + ZERO, ZERO));
}`,
  pressure: `
void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution, e = 1.0 / u_resolution;
  float sum = read2(u_state, uv + vec2(e.x, 0)).x + read2(u_state, uv - vec2(e.x, 0)).x + read2(u_state, uv + vec2(0, e.y)).x + read2(u_state, uv - vec2(0, e.y)).x;
  float div = read2(u_aux, uv).x - ZERO;
  gl_FragColor = pack2(vec2((sum - div) * 0.25, ZERO));
}`,
  project: `
void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution, e = 1.0 / u_resolution;
  vec2 v = (read2(u_state, uv) - ZERO) * 16.0;
  vec2 gradient = vec2(read2(u_aux, uv + vec2(e.x, 0)).x - read2(u_aux, uv - vec2(e.x, 0)).x, read2(u_aux, uv + vec2(0, e.y)).x - read2(u_aux, uv - vec2(0, e.y)).x) * 16.0;
  v -= gradient;
  if (uv.x < 1.5 / u_resolution.x || uv.x > 1.0 - 1.5 / u_resolution.x) v.x = 0.0;
  if (uv.y < 1.5 / u_resolution.y || uv.y > 1.0 - 1.5 / u_resolution.y) v.y = 0.0;
  gl_FragColor = pack2(clamp(v / 16.0 + ZERO, 0.0, 1.0));
}`,
  dye: `
void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  vec2 p = (uv - 0.5) * u_resolution / min(u_resolution.x, u_resolution.y);
  if (u_step < 0.0) {
    float band = 0.5 + 0.5 * sin((p.x + 0.12 * sin(p.y * 8.0)) * 38.0 + u_seed);
    gl_FragColor = pack2(vec2(band * 0.85, 0.5 + 0.4 * sin(p.y * 8.0 + p.x * 5.0)));
    return;
  }
  vec2 v = (read2(u_velocity, uv) - ZERO) * 16.0;
  vec2 pigment = read2(u_state, uv - v / u_resolution);
  gl_FragColor = pack2(pigment);
}`,
  dyeReverse: `
void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  vec2 v = (read2(u_velocity, uv) - ZERO) * 16.0;
  gl_FragColor = pack2(read2(u_state, uv + v / u_resolution));
}`,
  dyeCorrect: `
void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  vec2 v = (read2(u_velocity, uv) - ZERO) * 16.0;
  vec2 departure = uv - v / u_resolution;
  vec2 cell = (floor(departure * u_resolution - 0.5) + 0.5) / u_resolution;
  vec2 e = 1.0 / u_resolution;
  vec2 a = read2(u_state, cell), b = read2(u_state, cell + vec2(e.x, 0));
  vec2 c = read2(u_state, cell + vec2(0, e.y)), d = read2(u_state, cell + e);
  vec2 lo = min(min(a, b), min(c, d)), hi = max(max(a, b), max(c, d));
  vec2 pigment = read2(u_aux, uv) + 0.5 * (read2(u_state, uv) - read2(u_extra, uv));
  pigment = clamp(pigment, lo, hi);
  float brush = u_press * (1.0 - smoothstep(0.009, 0.029, brushDistance(uv)));
  pigment = mix(pigment, vec2(0.98, 0.5 + 0.45 * sin(u_time * 0.6)), brush * 0.5);
  vec2 p = (uv - 0.5) * u_resolution / min(u_resolution.x, u_resolution.y);
  vec2 source = p - 0.32 * vec2(cos(u_time * 0.07), sin(u_time * 0.09));
  float replenish = exp(-dot(source, source) * 380.0) * 0.022;
  pigment = mix(pigment, vec2(0.5 + 0.48 * sin(u_time * 0.35), 0.5 + 0.4 * cos(u_time * 0.23)), replenish);
  gl_FragColor = pack2(pigment);
}`
};

export function createSimulation(gl, { kind, seed = 1, aspect = 1, buildProgram, bindGeometry }) {
  const area = kind === 'fluid' ? 115000 : kind === 'reaction' ? 190000 : 170000;
  const width = Math.min(768, Math.max(160, Math.round(Math.sqrt(area * aspect))));
  const height = Math.min(768, Math.max(160, Math.round(width / aspect)));
  const targets = [];
  const programs = new Map();
  let steps = 0;
  let accumulator = 0;
  let destroyed = false;
  const black = gl.createTexture();
  gl.bindTexture(gl.TEXTURE_2D, black);
  gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, 1, 1, 0, gl.RGBA, gl.UNSIGNED_BYTE, new Uint8Array([128, 0, 128, 0]));
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);

  function target() {
    const texture = gl.createTexture();
    const framebuffer = gl.createFramebuffer();
    const result = { texture, framebuffer };
    targets.push(result);
    gl.bindTexture(gl.TEXTURE_2D, texture);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, width, height, 0, gl.RGBA, gl.UNSIGNED_BYTE, null);
    gl.bindFramebuffer(gl.FRAMEBUFFER, framebuffer);
    gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, texture, 0);
    if (gl.checkFramebufferStatus(gl.FRAMEBUFFER) !== gl.FRAMEBUFFER_COMPLETE) throw new Error('Simulation framebuffer unavailable');
    return result;
  }

  function pass(name, output, input, aux, velocity, brush, step = steps, extra = null) {
    let record = programs.get(name);
    if (!record) {
      const program = buildProgram(COMMON + SOURCES[name]);
      if (!program) throw new Error(`Could not compile ${name} simulation pass`);
      record = { program, uniforms: {} };
      for (const key of ['state', 'aux', 'velocity', 'extra', 'resolution', 'brush', 'press', 'step', 'time', 'seed']) {
        record.uniforms[key] = gl.getUniformLocation(program, `u_${key}`);
      }
      programs.set(name, record);
    }
    gl.bindFramebuffer(gl.FRAMEBUFFER, output.framebuffer);
    gl.viewport(0, 0, width, height);
    bindGeometry(record.program);
    const u = record.uniforms;
    [input, aux, velocity, extra].forEach((item, unit) => {
      gl.activeTexture(gl.TEXTURE0 + unit);
      gl.bindTexture(gl.TEXTURE_2D, item ? item.texture : black);
    });
    gl.uniform1i(u.state, 0);
    gl.uniform1i(u.aux, 1);
    gl.uniform1i(u.velocity, 2);
    gl.uniform1i(u.extra, 3);
    gl.uniform2f(u.resolution, width, height);
    gl.uniform4f(u.brush, ...(brush ? [...brush.previous, ...brush.position] : [0, 0, 0, 0]));
    gl.uniform1f(u.press, brush && brush.down ? 1 : 0);
    gl.uniform1f(u.step, step);
    gl.uniform1f(u.time, steps / 60);
    gl.uniform1f(u.seed, seed);
    gl.drawArrays(gl.TRIANGLES, 0, 6);
  }

  let field, flow, pressure, divergence, transport;
  const flip = pair => { pair.reverse(); };
  function tick(brush) {
    if (kind === 'fluid') {
      pass('velocity', flow[1], flow[0], null, null, brush);
      flip(flow);
      pass('divergence', divergence, flow[0]);
      for (let i = 0; i < 16; i++) {
        pass('pressure', pressure[1], pressure[0], divergence);
        flip(pressure);
      }
      pass('project', flow[1], flow[0], pressure[0]);
      flip(flow);
      pass('dye', transport[0], field[0], null, flow[0]);
      pass('dyeReverse', transport[1], transport[0], null, flow[0]);
      pass('dyeCorrect', field[1], field[0], transport[0], flow[0], brush, steps, transport[1]);
      flip(field);
      steps += 1;
    } else {
      const iterations = kind === 'reaction' ? 6 : 2;
      for (let i = 0; i < iterations; i++) {
        pass(kind, field[1], field[0], null, null, brush);
        flip(field);
        steps += 1;
      }
    }
  }

  function destroy() {
    if (destroyed) return;
    destroyed = true;
    targets.forEach(item => { gl.deleteTexture(item.texture); gl.deleteFramebuffer(item.framebuffer); });
    programs.forEach(item => gl.deleteProgram(item.program));
    gl.deleteTexture(black);
  }

  const dither = gl.isEnabled(gl.DITHER);
  gl.disable(gl.DITHER);
  try {
    field = [target(), target()];
    if (kind === 'fluid') {
      flow = [target(), target()];
      pressure = [target(), target()];
      divergence = target();
      transport = [target(), target()];
      for (const item of [...flow, ...pressure]) pass('velocity', item, null, null, null, null, -1);
    }
    for (const item of field) pass(kind === 'fluid' ? 'dye' : kind, item, null, null, null, null, -1);
    const warmup = kind === 'reaction' ? 60 : kind === 'wave' ? 20 : 28;
    for (let i = 0; i < warmup; i++) tick(null);
  } catch (error) {
    destroy();
    throw error;
  } finally {
    if (dither) gl.enable(gl.DITHER);
  }

  return {
    get texture() { return field[0].texture; },
    get size() { return [width, height]; },
    advance(seconds, brush) {
      accumulator += Math.min(Math.max(seconds, 0), 0.05);
      const wasDithered = gl.isEnabled(gl.DITHER);
      gl.disable(gl.DITHER);
      let ticks = 0;
      try {
        while (accumulator >= 1 / 60) {
          tick(brush);
          accumulator -= 1 / 60;
          ticks++;
        }
      } finally {
        if (wasDithered) gl.enable(gl.DITHER);
      }
      return ticks;
    },
    snapshot(readPixels = false) {
      const result = { kind, seed, width, height, steps, storage: 'RGBA8 / two 16-bit scalars' };
      if (readPixels && !destroyed && !gl.isContextLost()) {
        const previous = gl.getParameter(gl.FRAMEBUFFER_BINDING);
        gl.bindFramebuffer(gl.FRAMEBUFFER, field[0].framebuffer);
        const bytes = new Uint8Array(width * height * 4);
        gl.readPixels(0, 0, width, height, gl.RGBA, gl.UNSIGNED_BYTE, bytes);
        gl.bindFramebuffer(gl.FRAMEBUFFER, previous);
        let hash = 2166136261;
        for (const byte of bytes) hash = Math.imul(hash ^ byte, 16777619);
        result.checksum = (hash >>> 0).toString(16).padStart(8, '0');
        let min = 1, max = 0, sum = 0;
        for (let i = 0; i < bytes.length; i += 4) {
          const scalar = (bytes[i] * 256 + bytes[i + 1]) / 65535;
          min = Math.min(min, scalar); max = Math.max(max, scalar); sum += scalar;
        }
        result.scalar = { min, max, mean: sum / (width * height) };
        if (flow) {
          const divergenceRms = target => {
            gl.bindFramebuffer(gl.FRAMEBUFFER, target.framebuffer);
            gl.readPixels(0, 0, width, height, gl.RGBA, gl.UNSIGNED_BYTE, bytes);
            const value = (x, y, channel) => {
              const i = (y * width + x) * 4 + channel;
              return ((bytes[i] * 256 + bytes[i + 1] - 32768) / 65535) * 16;
            };
            let sumSq = 0;
            for (let y = 2; y < height - 2; y++) for (let x = 2; x < width - 2; x++) {
              const d = 0.5 * (value(x + 1, y, 0) - value(x - 1, y, 0) + value(x, y + 1, 2) - value(x, y - 1, 2));
              sumSq += d * d;
            }
            return Math.sqrt(sumSq / ((width - 4) * (height - 4)));
          };
          result.divergence = { beforeProjection: divergenceRms(flow[1]), afterProjection: divergenceRms(flow[0]) };
          gl.bindFramebuffer(gl.FRAMEBUFFER, previous);
        }
      }
      return result;
    },
    destroy
  };
}
