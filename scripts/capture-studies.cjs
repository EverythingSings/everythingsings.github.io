// Capture the actual page and measure frame cadence; no renderer stubs.
const { chromium } = require(process.env.PLAYWRIGHT_MODULE || 'playwright');
const path = require('node:path');
const fs = require('node:fs');
const assert = require('node:assert/strict');
const studies = ['lacuna', 'silkcurrent', 'tidalmemory', 'orbitalloom', 'prismaticfold', 'noctiluca', 'aperturechoir', 'palimpsest'];
const names = ['Lacuna', 'Silk Current', 'Tidal Memory', 'Orbital Loom', 'Prismatic Fold', 'Noctiluca', 'Aperture Choir', 'Palimpsest'];
const base = process.argv[2] || 'http://127.0.0.1:8765/';
const out = path.resolve(process.argv[3] || 'target/collection-qa');
fs.mkdirSync(out, { recursive: true });
(async () => {
  const browser = await chromium.launch({ headless: true, channel: process.env.PLAYWRIGHT_CHANNEL || 'chromium' });
  try {
  const page = await browser.newPage({ viewport: { width: 1000, height: 800 }, colorScheme: 'dark' });
  const errors = [];
  page.on('pageerror', error => errors.push(String(error)));
  page.on('console', msg => { if (msg.type() === 'error') errors.push(msg.text()); });
  const report = [];
  for (const id of studies) {
    await page.goto(`${base}?study=${id}&view=art`, { waitUntil: 'load' });
    await page.locator('#art-viewer').waitFor({ state: 'visible' });
    await page.locator('main').waitFor({ state: 'hidden' });
    await page.waitForTimeout(600);
    if (new URL(page.url()).searchParams.get('study') !== id) throw new Error(`${id} fell back to another shader`);
    assert.equal(await page.locator('#art-title').textContent(), names[studies.indexOf(id)], `${id} must actually load instead of silently falling back`);
    const performance = await page.evaluate(async () => {
      const times = [];
      let last;
      await new Promise(resolve => { function sample(t) { if (last) times.push(t - last); last = t; if (times.length < 45) requestAnimationFrame(sample); else resolve(); } requestAnimationFrame(sample); });
      const canvas = document.querySelector('canvas');
      const gl = canvas.getContext('webgl');
      const ext = gl.getExtension('WEBGL_debug_renderer_info');
      times.sort((a, b) => a - b);
      return { width: canvas.width, height: canvas.height, medianMs: times[22], p90Ms: times[40], gpu: ext ? gl.getParameter(ext.UNMASKED_RENDERER_WEBGL) : gl.getParameter(gl.RENDERER), glError: gl.getError() };
    });
    assert.equal(performance.glError, 0, `${id} must have no WebGL errors`);
    const movingA = await page.locator('#shader-canvas').screenshot();
    await page.waitForTimeout(1300);
    const movingB = await page.locator('#shader-canvas').screenshot();
    assert(!movingA.equals(movingB), `${id} must evolve over time`);
    await page.locator('#art-motion').click();
    await page.mouse.move(500, 400);
    const frozen = await page.locator('#shader-canvas').screenshot();
    await page.waitForTimeout(150);
    assert(frozen.equals(await page.locator('#shader-canvas').screenshot()), `${id} must really pause`);
    await page.screenshot({ path: path.join(out, `${id}.png`) });
    report.push({ id, title: await page.locator('#art-title').textContent(), temporalEvolution: true, stablePause: true, ...performance });
    console.log(JSON.stringify(report.at(-1)));
  }
  const mobile = await browser.newContext({ viewport: { width: 390, height: 844 }, hasTouch: true, isMobile: true, deviceScaleFactor: 2, colorScheme: 'light' });
  const touch = await mobile.newPage();
  touch.on('pageerror', error => errors.push(String(error)));
  for (const id of studies) {
    await touch.goto(`${base}?study=${id}`, { waitUntil: 'load' });
    await touch.getByRole('button', { name: 'Hide links', exact: true }).tap();
    await touch.locator('main').waitFor({ state: 'hidden' });
    await touch.waitForTimeout(550);
    assert.equal(await touch.locator('#art-title').textContent(), names[studies.indexOf(id)]);
    await touch.locator('#art-motion').tap();
    await touch.screenshot({ path: path.join(out, `${id}-mobile.png`) });
    for (const selector of ['#art-exit', '#art-choose', '#art-prev', '#art-motion', '#art-next', '#art-share']) {
      const box = await touch.locator(selector).boundingBox();
      assert(box && box.x >= 0 && box.y >= 0 && box.x + box.width <= 391 && box.y + box.height <= 845, `${id} ${selector} must fit on mobile`);
    }
    await touch.getByRole('button', { name: 'Show links', exact: true }).tap();
    await touch.locator('main').waitFor({ state: 'visible' });
    assert.equal(await touch.locator('.link-card').count(), 7);
    report.find(item => item.id === id).mobileTouch = true;
    console.log(`PASS mobile ${id}`);
  }
  await mobile.close();
  fs.writeFileSync(path.join(out, 'performance.json'), JSON.stringify({ base, report, errors }, null, 2));
  if (errors.length) throw new Error(errors.join('\n'));
  } finally {
    await browser.close();
  }
})().catch(error => { console.error(error); process.exitCode = 1; });
