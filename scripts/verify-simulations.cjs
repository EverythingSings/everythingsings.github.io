// Numerical GPU checks plus real pointer/touch integration against a served site.
const { chromium } = require(process.env.PLAYWRIGHT_MODULE || 'playwright');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const base = process.argv[2] || 'http://127.0.0.1:8765/';
const output = path.resolve(process.argv[3] || 'target/simulation-qa');
fs.mkdirSync(output, { recursive: true });
const studies = { morphogenesis: 'reaction', inkweather: 'fluid', resonantbasin: 'wave' };
const checks = [], errors = [];
const pass = name => { checks.push(name); console.log('PASS', name); };
const snapshot = page => page.evaluate(() => window.__ART_GALLERY__.snapshot(true));
async function waitStudy(page, id) { await page.waitForFunction(id => window.__ART_GALLERY__?.snapshot().study === id, id); }
(async () => {
  const browser = await chromium.launch({ headless: true, channel: process.env.PLAYWRIGHT_CHANNEL || 'chromium' });
  try {
    const rig = await browser.newPage({ reducedMotion: 'reduce' });
    await rig.goto(base);
    const numerical = await rig.evaluate(async () => {
      const { createSimulation } = await import('/js/art-simulation.js');
      const canvas = document.createElement('canvas');
      const gl = canvas.getContext('webgl', { antialias: false });
      if (!gl) throw Error('WebGL unavailable');
      const buffer = gl.createBuffer();
      gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
      gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([-1,-1, 1,-1, -1,1, -1,1, 1,-1, 1,1]), gl.STATIC_DRAW);
      const buildProgram = source => {
        const shaders = [];
        const program = gl.createProgram();
        for (const [type, code] of [[gl.VERTEX_SHADER, 'attribute vec2 a_position; void main(){gl_Position=vec4(a_position,0,1);}'], [gl.FRAGMENT_SHADER, source]]) {
          const shader = gl.createShader(type); shaders.push(shader);
          gl.shaderSource(shader, code); gl.compileShader(shader);
          if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) throw Error(gl.getShaderInfoLog(shader));
          gl.attachShader(program, shader);
        }
        gl.linkProgram(program); shaders.forEach(shader => gl.deleteShader(shader));
        if (!gl.getProgramParameter(program, gl.LINK_STATUS)) throw Error(gl.getProgramInfoLog(program));
        return program;
      };
      const bindGeometry = program => {
        gl.useProgram(program); gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
        const a = gl.getAttribLocation(program, 'a_position');
        gl.enableVertexAttribArray(a); gl.vertexAttribPointer(a, 2, gl.FLOAT, false, 0, 0);
      };
      const report = [];
      for (const kind of ['reaction', 'fluid', 'wave']) {
        const options = { kind, seed: 7, aspect: 1.25, buildProgram, bindGeometry };
        const control = createSimulation(gl, options), touched = createSimulation(gl, options);
        try {
          for (let i = 0; i < 36; i++) { control.advance(1 / 60); touched.advance(1 / 60); }
          const a = control.snapshot(true), b = touched.snapshot(true);
          for (let i = 0; i < 12; i++) {
            control.advance(1 / 60);
            touched.advance(1 / 60, { down: true, previous: [0.25 + i * 0.035, 0.5], position: [0.285 + i * 0.035, 0.5] });
          }
          const afterStroke = touched.snapshot(true);
          for (let i = 0; i < 90; i++) { control.advance(1 / 60); touched.advance(1 / 60); }
          const row = { kind, deterministic: a.checksum === b.checksum, initial: a, afterStroke, control: control.snapshot(true), touched: touched.snapshot(true) };
          for (let i = 0; i < 1800; i++) control.advance(1 / 60);
          row.longRun = control.snapshot(true);
          row.glError = gl.getError(); row.ditherRestored = gl.isEnabled(gl.DITHER);
          report.push(row);
        } finally { control.destroy(); touched.destroy(); }
      }
      gl.deleteBuffer(buffer);
      gl.getExtension('WEBGL_lose_context')?.loseContext();
      return report;
    });
    for (const item of numerical) {
      assert(item.deterministic, `${item.kind} seed and fixed steps reproduce the same field`);
      assert.equal(item.control.steps, item.touched.steps);
      assert.notEqual(item.control.checksum, item.touched.checksum, `${item.kind} retains stroke after 90 unforced ticks`);
      assert.equal(item.glError, 0);
      assert(item.ditherRestored);
      assert(item.touched.scalar.max - item.touched.scalar.min > 0.02, `${item.kind} field has not collapsed`);
      if (item.kind === 'wave') {
        assert(item.touched.scalar.min > 0.02 && item.touched.scalar.max < 0.98, 'Wave height avoids saturation');
        assert(item.longRun.scalar.min > 0.02 && item.longRun.scalar.max < 0.98, 'Wave field remains unsaturated after 30 additional simulation seconds');
        assert(Math.abs(item.longRun.scalar.mean - 0.5) < 0.03, 'Wave field has no accumulating DC drift');
      }
      assert(item.longRun.scalar.max - item.longRun.scalar.min > 0.015, `${item.kind} remains active after 30 additional simulation seconds`);
      if (item.kind === 'fluid') {
        assert(item.afterStroke.divergence.afterProjection < item.afterStroke.divergence.beforeProjection, 'Pressure projection reduces divergence during forcing');
        assert(item.touched.divergence.afterProjection < item.touched.divergence.beforeProjection, 'Pressure projection reduces divergence after release');
      }
      pass(`${item.kind}: reproducible GPU field; lasting brush effect; stable range; GL error 0; dither restored`);
      console.log(JSON.stringify(item));
    }
    await rig.close();

    const page = await browser.newPage({ viewport: { width: 1000, height: 800 } });
    page.on('pageerror', e => errors.push(String(e)));
    page.on('console', msg => { if (msg.type() === 'error') errors.push(msg.text()); });
    const interaction = [];
    for (const [id, kind] of Object.entries(studies)) {
      await page.goto(`${base}?study=${id}&view=art&seed=7`);
      await waitStudy(page, id);
      await page.locator('main').waitFor({ state: 'hidden' });
      await page.locator('#art-motion').click();
      const before = await snapshot(page);
      assert.equal(before.simulation.kind, kind);
      await page.mouse.move(260, 330); await page.mouse.down();
      await page.mouse.move(700, 390, { steps: 12 }); await page.mouse.up();
      await page.waitForTimeout(200);
      assert.deepEqual(await snapshot(page), before, 'Paused input cannot change the simulation');
      const still = await page.locator('#shader-canvas').screenshot();
      await page.waitForTimeout(100);
      assert(still.equals(await page.locator('#shader-canvas').screenshot()));
      await page.setViewportSize({ width: 480, height: 800 });
      await page.waitForTimeout(100);
      assert.deepEqual(await snapshot(page), before, 'Resize retains exact field');
      await page.setViewportSize({ width: 1000, height: 800 });
      await page.locator('#art-exit').click();
      await page.locator('main').waitFor({ state: 'visible' });
      await page.locator('#art-enter').click();
      await page.locator('main').waitFor({ state: 'hidden' });
      assert.deepEqual(await snapshot(page), before, 'Hide/show retains exact field');
      await page.evaluate(() => { window.trustedStroke = []; document.addEventListener('pointerdown', e => window.trustedStroke.push({ trusted: e.isTrusted, target: e.target.id })); });
      await page.locator('#art-motion').click();
      await page.mouse.move(250, 320); await page.mouse.down();
      await page.mouse.move(720, 480, { steps: 40 }); await page.mouse.up();
      await page.waitForTimeout(600);
      await page.locator('#art-motion').click();
      const after = await snapshot(page);
      assert.notEqual(before.simulation.checksum, after.simulation.checksum);
      assert((await page.evaluate(() => window.trustedStroke)).some(e => e.trusted && e.target === 'shader-canvas'));
      await page.screenshot({ path: path.join(output, `${id}-after-stroke.png`) });
      await page.locator('#art-reset').click();
      await page.waitForFunction(() => window.__ART_GALLERY__.snapshot().simulation.seed !== 7);
      const reset = await snapshot(page);
      assert(reset.paused, 'Restart respects pause');
      assert(reset.simulation.steps < after.simulation.steps);
      assert.notEqual(reset.simulation.checksum, after.simulation.checksum);
      assert.equal(new URL(page.url()).searchParams.get('seed'), String(reset.simulation.seed));
      assert.equal(await page.evaluate(() => document.querySelector('canvas').getContext('webgl').getError()), 0);
      interaction.push({ id, before, after, reset });
      pass(`${id}: real drag, pause, resize, hide/show preserve state; Restart changes seed and URL`);
    }
    await page.locator('#art-choose').click();
    await page.locator('#background-filter').fill('flow');
    await page.getByRole('option', { name: 'Flow', exact: true }).click();
    await waitStudy(page, 'flow');
    assert.equal((await snapshot(page)).simulation, null);
    assert(await page.locator('#art-reset').isHidden());
    assert(!new URL(page.url()).searchParams.has('seed'));
    pass('Switching to an original study releases simulation and removes simulation controls/seed');

    await page.goto(`${base}?study=inkweather&view=art&seed=31`);
    await waitStudy(page, 'inkweather');
    await page.locator('main').waitFor({ state: 'hidden' });
    await page.locator('#art-motion').click();
    await page.evaluate(() => { window.contextTest = document.querySelector('canvas').getContext('webgl').getExtension('WEBGL_lose_context'); window.contextTest.loseContext(); });
    await page.locator('#art-viewer').waitFor({ state: 'hidden' });
    await page.locator('main').waitFor({ state: 'visible' });
    await page.waitForTimeout(200);
    await page.evaluate(() => window.contextTest.restoreContext());
    await page.waitForFunction(() => window.__ART_GALLERY__.snapshot().simulation?.kind === 'fluid' && document.documentElement.classList.contains('webgl-backgrounds'));
    await page.locator('#art-enter').click();
    assert.equal((await snapshot(page)).simulation.seed, 31);
    assert((await snapshot(page)).paused);
    pass('GPU context loss restores static links; recovery rebuilds the simulation and preserves pause/seed');

    const failedImport = await browser.newPage();
    await failedImport.route('**/js/art-simulation.js*', route => route.abort());
    await failedImport.goto(`${base}?study=morphogenesis&view=art`);
    await waitStudy(failedImport, 'gyroidreliquary');
    assert.equal((await snapshot(failedImport)).simulation, null);
    await failedImport.locator('#art-exit').click();
    assert.equal(await failedImport.locator('.link-card').count(), 7);
    pass('Unavailable simulation module falls back to a working study and usable links');
    await failedImport.close();

    for (const size of [{ width: 320, height: 568 }, { width: 390, height: 844 }, { width: 844, height: 390 }]) {
      const touch = await browser.newPage({ viewport: size, hasTouch: true, isMobile: true, deviceScaleFactor: 2, colorScheme: 'light' });
      touch.on('pageerror', e => errors.push(String(e)));
      await touch.goto(`${base}?study=resonantbasin&view=art&seed=11`);
      await waitStudy(touch, 'resonantbasin');
      await touch.locator('main').waitFor({ state: 'hidden' });
      await touch.evaluate(() => { window.taps = []; document.addEventListener('pointerdown', e => window.taps.push({ type: e.pointerType, trusted: e.isTrusted, target: e.target.id })); });
      const before = await snapshot(touch);
      await touch.touchscreen.tap(size.width * 0.55, size.height * 0.45);
      await touch.waitForTimeout(350);
      await touch.locator('#art-motion').tap();
      assert.notEqual((await snapshot(touch)).simulation.checksum, before.simulation.checksum);
      assert((await touch.evaluate(() => window.taps)).some(e => e.type === 'touch' && e.trusted && e.target === 'shader-canvas'));
      for (const selector of ['#art-reset', '#art-exit', '#art-choose', '#art-motion', '#art-share']) {
        const b = await touch.locator(selector).boundingBox();
        assert(b && b.x >= 0 && b.y >= 0 && b.x + b.width <= size.width + 1 && b.y + b.height <= size.height + 1, `${selector} fits ${size.width}x${size.height}`);
      }
      await touch.screenshot({ path: path.join(output, `touch-${size.width}x${size.height}.png`) });
      await touch.locator('#art-reset').tap();
      await touch.waitForFunction(() => window.__ART_GALLERY__.snapshot().simulation.seed !== 11);
      await touch.locator('#art-exit').tap();
      await touch.locator('main').waitFor({ state: 'visible' });
      pass(`Trusted touch tap, restart and controls at ${size.width}x${size.height}`);
      await touch.close();
    }
    assert.deepEqual(errors, []);
    fs.writeFileSync(path.join(output, 'verification.json'), JSON.stringify({ base, browser: await browser.version(), checks, numerical, interaction, errors }, null, 2));
  } finally { await browser.close(); }
})().catch(error => { console.error(error); process.exitCode = 1; });
