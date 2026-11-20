import { expect, type Locator, type Page } from '@playwright/test';

/** Activate Flutter accessibility without waiting on a disappearing placeholder. */
export async function enableFlutterSemantics(
  page: Page,
  ready: Locator = page.getByRole('textbox').first(),
) {
  await page.waitForFunction(() => !!document.querySelector('flutter-view'), null, { timeout: 60_000 });
  await expect.poll(async () => {
    if (await ready.isVisible()) return true;
    // Flutter can remove/replace this node as semantics activates. Lookup and
    // click in the same browser task, instead of count() then locator.evaluate().
    await page.evaluate(() => {
      document.querySelector<HTMLElement>('flt-semantics-placeholder')?.click();
    });
    return ready.isVisible();
  }, {
    timeout: 20_000,
    intervals: [50, 100, 250],
    message: 'Flutter debe exponer el control accesible de la pantalla actual',
  }).toBe(true);
}
