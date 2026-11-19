// Anonymous navigation only: no input or accessibility click before measurement.
import { chromium, firefox, webkit } from '@playwright/test';
import { parseArgs } from 'node:util';
import { mkdir, writeFile } from 'node:fs/promises';
import { dirname } from 'node:path';
import os from 'node:os';

const { values } = parseArgs({ options: {
  url: { type: 'string' }, samples: { type: 'string', default: '3' },
  output: { type: 'string', default: 'reports/web-vitals.json' },
} });
const target = new URL(values.url || 'http://127.0.0.1:8080/#/login');
if (target.username || target.password || target.search ||
    (target.protocol !== 'https:' && !(['localhost', '127.0.0.1'].includes(target.hostname) && target.protocol === 'http:')))
  throw new Error('Use an authorized HTTPS URL or loopback URL without credentials/query');
const samples = Number(values.samples);
if (!Number.isInteger(samples) || samples < 1 || samples > 10) throw new Error('1–10 samples required');
let ready = false;
for (let attempt = 0; attempt < 40; attempt++) {
  try { if ((await fetch(target.origin, { signal: AbortSignal.timeout(1000) })).status === 200) { ready = true; break; } } catch {}
  await new Promise(resolve => setTimeout(resolve, 250));
}
if (!ready) throw new Error('Authorized web server not ready');
const report = {
  started: new Date().toISOString(), url: target.href,
  environment: { node: process.version, platform: os.platform(), cpu: os.cpus()[0]?.model, logicalCPUs: os.cpus().length, ramBytes: os.totalmem() },
  method: 'Fresh context per sample; no user input; wait for FCP then observe another 3000ms. Local lab, not field or monthly uptime.',
  records: [],
};
for (const [name, type] of Object.entries({ chromium, firefox, webkit })) {
  const browser = await type.launch({ headless: true });
  try {
    for (let index = 0; index < samples; index++) {
      const context = await browser.newContext({ viewport: { width: 1440, height: 1000 }, locale: 'es-PE', timezoneId: 'America/Lima', colorScheme: 'light' });
      const page = await context.newPage();
      const row = { browser: name, browserVersion: browser.version(), sample: index + 1, at: new Date().toISOString(), userInteraction: false };
      try {
        await page.addInitScript(() => {
          window.__labLcp = null;
          window.__labLcpSupported = PerformanceObserver.supportedEntryTypes.includes('largest-contentful-paint');
          if (window.__labLcpSupported) new PerformanceObserver(list => {
            window.__labLcp = list.getEntries().at(-1)?.startTime ?? null;
          }).observe({ type: 'largest-contentful-paint', buffered: true });
        });
        const response = await page.goto(target.href, { waitUntil: 'load', timeout: 45000 });
        row.status = response.status();
        if (row.status !== 200) throw new Error('Document not available');
        await page.waitForFunction(() => performance.getEntriesByName('first-contentful-paint').length > 0, null, { timeout: 30000 });
        await page.waitForTimeout(3000);
        row.metrics = await page.evaluate(() => {
          const navigation = performance.getEntriesByType('navigation')[0];
          return {
            ttfbMs: navigation.responseStart - navigation.requestStart,
            fcpMs: performance.getEntriesByName('first-contentful-paint')[0].startTime,
            lcpMs: window.__labLcp,
            lcpSupported: window.__labLcpSupported,
            observationEndMs: performance.now(),
            lcpLimitation: window.__labLcp === null ? 'No eligible LCP entry during this observation window; not substituted by FCP or algorithm time.' : null,
          };
        });
        row.result = 'MEASURED';
      } catch (error) {
        row.result = 'FAILED'; row.error = error.name;
      } finally {
        await context.close(); report.records.push(row);
      }
    }
  } finally { await browser.close(); }
}
report.finished = new Date().toISOString();
await mkdir(dirname(values.output), { recursive: true });
await writeFile(values.output, JSON.stringify(report, null, 2));
console.log(`Navigation measurements: ${report.records.filter(x => x.result === 'MEASURED').length}/${report.records.length}`);
if (report.records.some(x => x.result !== 'MEASURED')) process.exitCode = 1;
