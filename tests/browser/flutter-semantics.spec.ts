import { test, expect } from '@playwright/test';
import { enableFlutterSemantics } from '../e2e/flutter-semantics';

test('accepts an already accessible screen without resetting input', async ({ page }) => {
  await page.setContent('<flutter-view><input aria-label="Correo" value="retained@example.test"></flutter-view>');
  await enableFlutterSemantics(page);
  await enableFlutterSemantics(page);
  await expect(page.getByRole('textbox')).toHaveValue('retained@example.test');
});

test('waits for an activation placeholder mounted after the view', async ({ page }) => {
  await page.setContent('<flutter-view></flutter-view>');
  await page.evaluate(() => {
    setTimeout(() => {
      const trigger = document.createElement('flt-semantics-placeholder');
      trigger.onclick = () => {
        trigger.remove();
        document.querySelector('flutter-view')!.innerHTML = '<input aria-label="Correo">';
      };
      document.body.append(trigger);
    }, 150);
  });
  await enableFlutterSemantics(page);
  await expect(page.getByRole('textbox', { name: 'Correo' })).toBeVisible();
});

test('survives placeholder removal while the accessibility tree is still loading', async ({ page }) => {
  await page.setContent('<flutter-view></flutter-view><flt-semantics-placeholder></flt-semantics-placeholder>');
  await page.evaluate(() => {
    const trigger = document.querySelector('flt-semantics-placeholder')!;
    trigger.addEventListener('click', () => {
      trigger.remove();
      setTimeout(() => {
        document.querySelector('flutter-view')!.innerHTML = '<input aria-label="Correo">';
      }, 150);
    });
  });
  await enableFlutterSemantics(page);
  await expect(page.getByRole('textbox', { name: 'Correo' })).toBeVisible();
});

test('accepts automatic activation without requiring a placeholder', async ({ page }) => {
  await page.setContent('<flutter-view></flutter-view>');
  await page.evaluate(() => {
    setTimeout(() => {
      document.querySelector('flutter-view')!.innerHTML = '<input aria-label="Correo">';
    }, 150);
  });
  await enableFlutterSemantics(page);
  await expect(page.getByRole('textbox')).toBeVisible();
});

test('waits for a dashboard control after reload instead of a login textbox', async ({ page }) => {
  await page.setContent('<flutter-view></flutter-view>');
  const ready = page.getByRole('button', { name: 'Pedidos', exact: true });
  let completed = false;
  const activation = enableFlutterSemantics(page, ready).then(() => { completed = true; });
  await page.waitForTimeout(100);
  expect(completed).toBe(false);
  await page.evaluate(() => {
    document.querySelector('flutter-view')!.innerHTML = '<button>Pedidos</button>';
  });
  await activation;
  await expect(ready).toBeVisible();
  expect(completed).toBe(true);
});
