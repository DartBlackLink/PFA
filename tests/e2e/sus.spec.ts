// Instrument validation only. These synthetic UI selections are NEVER study data.
import { test, expect } from './fixtures';
import { readFile } from 'node:fs/promises';

test('SUS-UI · formulario anónimo valida, se adapta y descarga CSV sin enviarlo', async ({ page }, info) => {
  await page.setViewportSize({ width: 360, height: 800 });
  const requests: string[] = [];
  page.on('request', r => { if (r.method() !== 'GET') requests.push(r.method()); });
  await page.goto('/qa/sus');
  await expect(page.getByRole('heading', { level: 1 })).toContainText('EcoLogística Huancayo');
  expect(await page.getByRole('radio').count()).toBe(50);
  await info.attach('encuesta-360-sin-respuestas', { body: await page.screenshot({ fullPage: true }), contentType: 'image/png' });
  await page.getByRole('button', { name: 'Descargar mis respuestas anónimas' }).click();
  expect(await page.locator('#role').evaluate((e: HTMLSelectElement) => e.validity.valid)).toBe(false);
  await page.getByLabel('Rol probado').selectOption('ADMIN');
  await page.getByLabel('Dispositivo utilizado').selectOption('PC');
  for (let i = 1; i <= 10; i++) await page.locator(`input[name=p${i}][value="3"]`).check();
  await page.locator('#consent').check();
  const pending = page.waitForEvent('download');
  await page.getByRole('button', { name: 'Descargar mis respuestas anónimas' }).click();
  const download = await pending;
  expect(download.suggestedFilename()).toMatch(/^SUS-[A-F0-9]{12}\.csv$/);
  const csv = await readFile((await download.path())!, 'utf8');
  expect(csv.trim().split('\n')).toHaveLength(2);
  expect(csv.split('\n')[0]).toBe('codigo,rol,dispositivo,fecha,consentimiento,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10');
  expect(requests).toHaveLength(0);
  const overflows = await page.evaluate(() => document.documentElement.scrollWidth > innerWidth);
  expect(overflows).toBe(false);
  // Download remains in Playwright temporary storage, not in academic responses.
});
