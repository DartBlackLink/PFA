import { test as base, expect, Page, APIRequestContext } from '@playwright/test';
import fs from 'node:fs';
import { enableFlutterSemantics } from './flutter-semantics';

export const apiURL = process.env.E2E_API_URL!;
export function account(project: string) {
  return JSON.parse(fs.readFileSync('reports/e2e-fixture.json', 'utf8')).accounts[project];
}
export async function token(request: APIRequestContext, email = 'admin.e2e@example.test', courier = false) {
  const response = await request.post(`${apiURL}/auth/login`, {
    form: { username: email, password: process.env[courier ? 'E2E_DRIVER_PASSWORD' : 'E2E_ADMIN_PASSWORD']! },
  });
  if (response.status() !== 200) throw new Error(`QA login returned HTTP ${response.status()}`);
  return (await response.json()).access_token as string;
}
export async function semantics(page: Page) {
  await enableFlutterSemantics(page);
}
export async function login(page: Page, project?: string) {
  await page.goto('/#/login');
  await semantics(page);
  await typeInFlutter(page, 'Correo electrónico', project ? account(project).email : 'admin.e2e@example.test');
  await typeInFlutter(page, 'Contraseña', process.env[project ? 'E2E_DRIVER_PASSWORD' : 'E2E_ADMIN_PASSWORD']!);
  await page.getByRole('button', { name: 'Iniciar sesión', exact: true }).click();
  await expect(page).toHaveURL(project ? /#\/repartidor/ : /#\/dashboard/);
}

export async function typeInFlutter(page: Page, label: string, value: string) {
  const escaped = label.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  // A form card can merge its heading into the accessible input name.
  const field = page.getByRole('textbox', { name: new RegExp(`${escaped}$`) });
  for (let attempt = 0; attempt < 2; attempt++) {
    await field.focus();
    await expect(field).toBeFocused();
    // WebKit may replace the active semantics editor during the first frame.
    // Wait for that transition before typing; verify locally before submitting.
    await page.waitForTimeout(200);
    await field.focus();
    await field.press('ControlOrMeta+A');
    await field.press('Backspace');
    const delay = page.context().browser()?.browserType().name() === 'webkit' ? 100 : 40;
    await field.pressSequentially(value, { delay });
    if (await field.inputValue() === value) break;
  }
  if (await field.inputValue() !== value)
    throw new Error('El editor Flutter no confirmó el texto; no se enviaron credenciales.');
  // The Windows WebKit port can stall when Tab moves between Flutter editors.
  // Focusing the next native editor/button commits input without that shortcut.
  if (page.context().browser()?.browserType().name() !== 'webkit') await field.press('Tab');
}

export async function scrollToButton(page: Page, name: string) {
  const button = page.getByRole('button', { name, exact: true }).first();
  for (let i = 0; i < 10; i++) {
    if (await button.isVisible()) return button;
    const size = page.viewportSize()!;
    await page.mouse.move(size.width * .7, size.height * .7);
    await page.mouse.wheel(0, 500);
    // Allow Flutter to paint and materialize offscreen semantics after scrolling.
    await page.waitForTimeout(150);
  }
  await expect(button).toBeVisible();
  return button;
}

export const test = base.extend<{ monitor: void }>({
  monitor: [async ({ page }, use, testInfo) => {
    const network: object[] = [];
    const starts = new WeakMap<object, number>();
    const errors: string[] = [];
    const startedAt = new Date().toISOString();
    page.on('request', request => starts.set(request, performance.now()));
    page.on('response', response => {
      const request = response.request();
      const url = new URL(response.url());
      // Sanitize by design: no query, request/response body, headers or tokens.
      if (url.pathname.startsWith('/api/v1/')) network.push({ path: url.pathname,
        method: request.method(), status: response.status(),
        observedResponseMs: Math.round((performance.now() - (starts.get(request) || performance.now())) * 100) / 100 });
    });
    page.on('requestfailed', request => {
      const url = new URL(request.url());
      network.push({ path: url.pathname, method: request.method(), failed: true });
    });
    page.on('pageerror', error => errors.push(error.name));
    await page.addInitScript(() => {
      (window as any).__qaVitals = { lcp: null, lcpSupported: PerformanceObserver.supportedEntryTypes?.includes('largest-contentful-paint') || false };
      if ((window as any).__qaVitals.lcpSupported) {
        new PerformanceObserver(list => {
          const entries = list.getEntries();
          (window as any).__qaVitals.lcp = entries.at(-1)?.startTime ?? null;
        }).observe({ type: 'largest-contentful-paint', buffered: true });
      }
    });
    await use();
    if (!page.isClosed()) {
      const collect = page.evaluate(() => {
        const nav = performance.getEntriesByType('navigation')[0] as PerformanceNavigationTiming;
        const fcp = performance.getEntriesByName('first-contentful-paint')[0];
        const v = (window as any).__qaVitals || {};
        return { ttfbMs: nav ? nav.responseStart - nav.requestStart : null,
          fcpMs: fcp?.startTime ?? null, lcpMs: v.lcp ?? null, lcpSupported: v.lcpSupported ?? false,
          lcpLimitation: v.lcp == null ? 'No eligible LCP entry reported; Flutter canvas is not equivalent to an HTML text/image LCP candidate.' : null };
      }).catch(() => ({ unavailable: true, reason: 'browser evaluation failed' }));
      const metrics = await Promise.race([collect, new Promise(resolve => {
        const timer = setTimeout(() => resolve({ unavailable: true, reason: 'browser evaluation timeout' }), 5000);
        timer.unref();
      })]);
      await testInfo.attach('metricas-y-red-sanitizada', { body: JSON.stringify({
        project: testInfo.project.name, test: testInfo.title, startedAt, finishedAt: new Date().toISOString(),
        environment: 'local QA; not production uptime', metrics, network, pageErrors: errors,
      }, null, 2), contentType: 'application/json' });
    }
  }, { auto: true, timeout: 15000 }],
});
export { expect };
