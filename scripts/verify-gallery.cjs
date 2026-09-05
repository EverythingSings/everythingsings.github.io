// Run against the generated site with Playwright installed or PLAYWRIGHT_MODULE set.
const { chromium } = require(process.env.PLAYWRIGHT_MODULE || 'playwright');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const base = process.argv[2] || 'http://127.0.0.1:8765/';
const output = path.resolve(process.argv[3] || 'target/gallery-qa');
fs.mkdirSync(output, { recursive: true });
const checks = [];
const errors = [];
const passed = name => { checks.push(name); console.log('PASS', name); };
async function textIs(page, selector, value) {
  await page.waitForFunction(({ selector, value }) => document.querySelector(selector)?.textContent === value, { selector, value });
}
async function visible(page, selector) { await page.locator(selector).waitFor({ state: 'visible' }); }
async function hidden(page, selector) { await page.locator(selector).waitFor({ state: 'hidden' }); }
async function settled(page) {
  await hidden(page, 'main');
  await page.waitForFunction(() => getComputedStyle(document.getElementById('art-viewer')).opacity === '1');
}
async function fits(page, selectors) {
  for (const selector of selectors) {
    const rect = await page.locator(selector).boundingBox();
    const size = page.viewportSize();
    assert(rect && rect.width > 0 && rect.height > 0, `${selector} has bounds`);
    assert(rect.x >= -1 && rect.y >= -1 && rect.x + rect.width <= size.width + 1 && rect.y + rect.height <= size.height + 1, `${selector} fits ${JSON.stringify(size)}: ${JSON.stringify(rect)}`);
  }
}
(async () => {
  const browser = await chromium.launch({ headless: true, channel: process.env.PLAYWRIGHT_CHANNEL || 'chromium' });
  try {
    const desktop = await browser.newContext({ viewport: { width: 1440, height: 960 }, colorScheme: 'dark' });
    const page = await desktop.newPage();
    page.on('pageerror', error => errors.push(String(error)));
    page.on('console', msg => { if (msg.type() === 'error') errors.push(msg.text()); });
    await page.goto(base + '?study=flow', { waitUntil: 'load' });
    await visible(page, '#art-enter');
    assert.equal(await page.locator('.link-card').count(), 7);
    await page.getByRole('button', { name: 'Hide links', exact: true }).click();
    await visible(page, '#art-viewer');
    assert(await page.getByRole('button', { name: 'Show links', exact: true }).isVisible());
    await hidden(page, 'main');
    assert.equal(await page.locator('main').evaluate(el => el.inert), true);
    assert.equal(new URL(page.url()).searchParams.get('view'), 'art');
    await fits(page, ['#art-exit', '#art-choose', '#art-prev', '#art-motion', '#art-next', '#art-share']);
    passed('Desktop entry, complete links, hidden/inert homepage, controls within viewport');

    await page.keyboard.press('ArrowRight');
    await textIs(page, '#art-title', 'Cloud Field');
    await page.keyboard.press('ArrowLeft');
    await textIs(page, '#art-title', 'Flow');
    await page.keyboard.press('Space');
    await textIs(page, '#art-motion', 'Play');
    const still = await page.locator('#shader-canvas').screenshot();
    await page.mouse.move(1200, 350);
    await page.waitForTimeout(300);
    assert(still.equals(await page.locator('#shader-canvas').screenshot()), 'Paused frame remains identical after pointer motion and elapsed time');
    await page.setViewportSize({ width: 1280, height: 800 });
    await page.waitForTimeout(100);
    const resizedStill = await page.locator('#shader-canvas').screenshot();
    assert(resizedStill.length > 10000, 'Paused resize has rendered detail');
    await page.waitForTimeout(150);
    assert(resizedStill.equals(await page.locator('#shader-canvas').screenshot()));
    passed('Keyboard selection, Space pause, identical paused pixels, rendered paused resize');

    await page.locator('#art-choose').click();
    await visible(page, '#background-panel');
    assert((await page.locator('.background-option').count()) >= 79);
    assert.equal(await page.locator('.background-option').first().getAttribute('data-name'), 'lacuna');
    assert.equal(await page.locator('.background-option[data-new]').count(), 8);
    await page.locator('#background-filter').fill('rosette');
    await page.getByRole('option', { name: 'Rosette', exact: true }).click();
    await textIs(page, '#art-title', 'Rosette');
    await hidden(page, '#background-panel');
    assert.equal(await page.locator('#art-choose').evaluate(el => el === document.activeElement), true);
    assert.equal(new URL(page.url()).searchParams.get('study'), 'rosette');
    assert.equal(await page.title(), 'Rosette | EverythingSings');
    passed('New studies appear first; search all 79 studies, return focus, study URL and title');

    await page.locator('#art-choose').click();
    await page.keyboard.press('Escape');
    await hidden(page, '#background-panel');
    await visible(page, '#art-viewer');
    await page.keyboard.press('Escape');
    await hidden(page, '#art-viewer');
    await visible(page, 'main');
    await page.waitForFunction(() => document.activeElement.id === 'art-enter');
    assert.equal(await page.locator('main').evaluate(el => el.inert), false);
    passed('Escape closes gallery first, then restores links and entry focus');

    await page.goto(base, { waitUntil: 'load' });
    await visible(page, '#art-enter');
    await page.locator('#art-enter').click();
    await page.locator('#art-next').click();
    const historyUrl = page.url();
    await page.goBack();
    await hidden(page, '#art-viewer');
    await page.goForward();
    await visible(page, '#art-viewer');
    assert.equal(page.url(), historyUrl);
    passed('Browser Back and Forward restore immersive state');

    await page.goto(base + '?study=kintsugi&view=art', { waitUntil: 'load' });
    await visible(page, '#art-viewer');
    await textIs(page, '#art-title', 'Kintsugi');
    assert.equal(await page.locator('#background-current').textContent(), 'Kintsugi');
    await page.locator('#art-motion').click();
    await settled(page);
    await page.screenshot({ path: path.join(output, 'desktop-kintsugi.png') });
    passed('Shared URL overrides saved selection and opens the requested study');

    await page.evaluate(() => Object.defineProperty(navigator, 'clipboard', { configurable: true, value: { writeText: () => Promise.reject(new Error('Clipboard unavailable')) } }));
    await page.locator('#art-share').click();
    await visible(page, '#art-share-url');
    assert.equal(await page.locator('#art-share-url').inputValue(), page.url());
    assert.equal(await page.locator('#art-share-url').evaluate(el => el.selectionEnd - el.selectionStart), page.url().length);
    await fits(page, ['#art-share-url', '#art-exit']);
    passed('Denied clipboard exposes and selects a usable study URL');
    await page.evaluate(() => Object.defineProperty(navigator, 'clipboard', { configurable: true, value: { writeText: async text => { window.copiedStudyUrl = text; } } }));
    await page.locator('#art-share').click();
    await textIs(page, '#art-notice', 'Link copied');
    assert.equal(await page.evaluate(() => window.copiedStudyUrl), page.url());
    passed('Clipboard success handler receives the exact study URL (stubbed clipboard)');

    await page.emulateMedia({ reducedMotion: 'reduce' });
    await hidden(page, '#art-viewer');
    await hidden(page, '#art-enter');
    await visible(page, 'main');
    await page.emulateMedia({ reducedMotion: 'no-preference' });
    await visible(page, '#art-enter');
    passed('Enabling reduced motion exits the viewer and restores the static homepage');

    for (const size of [{ width: 390, height: 844 }, { width: 320, height: 568 }, { width: 844, height: 390 }]) {
      const mobile = await browser.newContext({ viewport: size, hasTouch: true, isMobile: true, deviceScaleFactor: 1, colorScheme: 'dark' });
      const touch = await mobile.newPage();
      touch.on('pageerror', error => errors.push(String(error)));
      await touch.goto(base + '?study=rosette', { waitUntil: 'load' });
      await visible(touch, '#art-enter');
      await touch.locator('#art-enter').tap();
      await visible(touch, '#art-viewer');
      await touch.locator('#art-motion').tap();
      await settled(touch);
      await fits(touch, ['#art-exit', '#art-choose', '#art-prev', '#art-motion', '#art-next', '#art-share']);
      await touch.screenshot({ path: path.join(output, `touch-${size.width}x${size.height}-art.png`) });
      await touch.locator('#art-choose').tap();
      await visible(touch, '#background-panel');
      await fits(touch, ['#background-panel', '#background-filter', '#background-motion']);
      await touch.screenshot({ path: path.join(output, `touch-${size.width}x${size.height}-gallery.png`) });
      await touch.locator('#background-filter').fill('kintsugi');
      await touch.getByRole('option', { name: 'Kintsugi', exact: true }).tap();
      await textIs(touch, '#art-title', 'Kintsugi');
      await hidden(touch, '#background-panel');
      await touch.locator('#art-next').tap();
      await textIs(touch, '#art-title', 'Tesseract');
      await touch.locator('#art-exit').tap();
      await visible(touch, 'main');
      assert.equal(await touch.locator('.link-card').count(), 7);
      passed(`Touch entry, gallery search/select, next, exit and viewport bounds at ${size.width}x${size.height}`);
      await mobile.close();
    }

    for (const mode of ['no-javascript', 'no-webgl', 'reduced-motion']) {
      const context = await browser.newContext({ javaScriptEnabled: mode !== 'no-javascript', reducedMotion: mode === 'reduced-motion' ? 'reduce' : 'no-preference' });
      if (mode === 'no-webgl') await context.addInitScript(() => { const getContext = HTMLCanvasElement.prototype.getContext; HTMLCanvasElement.prototype.getContext = function(type, ...args) { return type.includes('webgl') ? null : getContext.call(this, type, ...args); }; });
      const fallback = await context.newPage();
      await fallback.goto(base + '?study=flow&view=art', { waitUntil: 'load' });
      await visible(fallback, 'main');
      await hidden(fallback, '#art-enter');
      await hidden(fallback, '#art-viewer');
      assert.equal(await fallback.locator('.link-card').count(), 7);
      passed(`Complete, usable static homepage with ${mode}`);
      await context.close();
    }
    assert.deepEqual(errors, []);
    passed('No browser JavaScript errors');
    fs.writeFileSync(path.join(output, 'verification.json'), JSON.stringify({ base, browser: await browser.version(), checks, errors, screenshots: fs.readdirSync(output).filter(name => name.endsWith('.png')) }, null, 2));
  } finally { await browser.close(); }
})().catch(error => { console.error(error); process.exitCode = 1; });
