// Derive small gallery previews from the actual rendered studies, including exposure.
const { chromium } = require(process.env.PLAYWRIGHT_MODULE || 'playwright');
const fs = require('node:fs');
const path = require('node:path');
const base = process.argv[2] || 'http://127.0.0.1:8765/';
const output = path.resolve(process.argv[3] || 'public/study-previews');
const source = fs.readFileSync('public/js/shader-bg.js', 'utf8');
const studies = [...source.matchAll(/^\s*\{ id: '([^']+)', name: '([^']+)'/gm)].map(m => ({ id: m[1], name: m[2] }));
const selected = process.env.STUDIES ? studies.filter(s => process.env.STUDIES.split(',').includes(s.id)) : studies;
fs.mkdirSync(output, { recursive: true });
(async () => {
  const browser = await chromium.launch({ headless: true, channel: process.env.PLAYWRIGHT_CHANNEL || 'chromium' });
  try {
    const page = await browser.newPage({ viewport: { width: 640, height: 400 }, deviceScaleFactor: 1 });
    const report = [];
    for (const study of selected) {
      await page.goto(`${base}?study=${study.id}&view=art&seed=1`);
      await page.waitForFunction(id => window.__ART_GALLERY__?.snapshot().study === id, study.id);
      await page.addStyleTag({ content: '#art-viewer, #background-controls { visibility: hidden !important; }' });
      await page.waitForTimeout(study.id === 'inkweather' ? 5000 : study.id === 'morphogenesis' ? 2500 : 700);
      await page.keyboard.press('Space');
      const png = await page.locator('#shader-canvas').screenshot();
      const webp = await page.evaluate(async data => {
        const image = new Image(); image.src = `data:image/png;base64,${data}`; await image.decode();
        const target = document.createElement('canvas'); target.width = 288; target.height = 180;
        const ctx = target.getContext('2d'); ctx.imageSmoothingQuality = 'high'; ctx.drawImage(image, 0, 0, 288, 180);
        return target.toDataURL('image/webp', 0.82).split(',')[1];
      }, png.toString('base64'));
      const bytes = Buffer.from(webp, 'base64');
      fs.writeFileSync(path.join(output, `${study.id}.webp`), bytes);
      report.push({ ...study, bytes: bytes.length });
      console.log(`${study.id}: ${bytes.length} bytes`);
    }
    fs.mkdirSync('target/preview-qa', { recursive: true });
    fs.writeFileSync('target/preview-qa/capture.json', JSON.stringify({ base, report }, null, 2));
  } finally { await browser.close(); }
})().catch(error => { console.error(error); process.exitCode = 1; });
