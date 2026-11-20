import { enableFlutterSemantics } from './flutter-semantics';
import { test, expect, apiURL, login, semantics, token, account, typeInFlutter } from './fixtures';

test('AUTH-01 · infeliz: formulario vacío rechaza sin enviar credenciales', async ({ page }) => {
  const calls: string[] = [];
  page.on('request', r => { if (r.url().endsWith('/auth/login')) calls.push(r.method()); });
  await page.goto('/#/login'); await semantics(page);
  await page.getByRole('button', { name: 'Iniciar sesión', exact: true }).click();
  await expect(page).toHaveURL(/#\/login/);
  await expect(page.getByText('Ingresa un correo válido', { exact: true }).last()).toBeVisible();
  await expect(page.getByText('La contraseña es obligatoria', { exact: true }).last()).toBeVisible();
  expect(calls).toHaveLength(0);
});

test('AUTH-02 · feliz: ADMIN, indicadores y sesión después de recargar', async ({ page }) => {
  await login(page);
  await expect(page.getByText('Resumen', { exact: true }).first()).toBeVisible();
  await expect(page.getByText(/Huancayo/).first()).toBeVisible();
  await page.reload();
  await enableFlutterSemantics(page, page.getByText('Pedidos', { exact: true }).first());
  await expect(page).toHaveURL(/#\/dashboard/);
  await expect(page.getByText('Pedidos', { exact: true }).first()).toBeVisible();
});

test('AUTH-03 · infeliz: credencial aleatoria incorrecta mantiene login', async ({ page }, info) => {
  await page.goto('/#/login'); await semantics(page);
  await typeInFlutter(page, 'Correo electrónico', `absent.${info.project.name}.e2e@example.test`);
  await typeInFlutter(page, 'Contraseña', 'invalid-qa-' + Date.now());
  const response = page.waitForResponse(r => r.url().endsWith('/auth/login'));
  await page.getByRole('button', { name: 'Iniciar sesión', exact: true }).click();
  expect((await response).status()).toBe(401);
  await expect(page).toHaveURL(/#\/login/);
});

test('ROLE-01 · REPARTIDOR ve su operación y no entra a ADMIN', async ({ page }, info) => {
  await login(page, info.project.name);
  await expect(page.getByRole('group', { name: /^Tu jornada de entregas/ })).toBeVisible();
  await page.goto('/#/dashboard');
  await expect(page).toHaveURL(/#\/repartidor/);
});

test('PERM-01 · servidor rechaza anónimo y REPARTIDOR en vehículos', async ({ request }, info) => {
  expect((await request.get(`${apiURL}/vehicles/`)).status()).toBe(401);
  const bearer = await token(request, account(info.project.name).email, true);
  expect((await request.get(`${apiURL}/vehicles/`, { headers: { Authorization: `Bearer ${bearer}` } })).status()).toBe(403);
});

test('FORM-01 · borde: pedido sin datos no se guarda desde ADMIN', async ({ page }) => {
  await login(page);
  const writes: string[] = [];
  page.on('request', r => { if (r.url().includes('/orders/') && r.method() === 'POST') writes.push(r.method()); });
  await page.getByText('Pedidos', { exact: true }).first().click();
  await page.getByRole('button', { name: /Nuevo pedido|Registrar pedido/ }).first().click();
  await page.getByRole('button', { name: 'Guardar', exact: true }).click();
  await expect(page.getByRole('alertdialog')).toBeVisible();
  await expect(page.getByRole('textbox', { name: 'Cliente', exact: true })).toHaveAttribute('aria-invalid', 'true');
  expect(writes).toHaveLength(0);
});

test('UX-01 · borde: login móvil 360 px y tema accesible', async ({ page }) => {
  await page.setViewportSize({ width: 360, height: 800 });
  await page.goto('/#/login'); await semantics(page);
  await page.getByRole('button', { name: 'Activar modo oscuro', exact: true }).click();
  await expect(page.getByRole('button', { name: /Activar modo claro/ })).toBeVisible();
  const box = await page.getByRole('textbox', { name: 'Correo electrónico', exact: true }).boundingBox();
  expect(box).not.toBeNull();
  expect(box!.x).toBeGreaterThanOrEqual(0);
  expect(box!.x + box!.width).toBeLessThanOrEqual(361);
  await expect(page.getByRole('button', { name: 'Iniciar sesión', exact: true })).toBeVisible();
});

test('NET-01 · recuperación web después de desconectar y reconectar', async ({ page, context }) => {
  await login(page);
  await context.setOffline(true);
  await page.getByRole('button', { name: /Actualizar/ }).first().click();
  await expect(page.getByText(/conexión|conectar|servidor|Reintentar|red|error/i).first()).toBeVisible();
  await context.setOffline(false);
  await page.getByRole('button', { name: /Actualizar/ }).first().click();
  await expect(page).toHaveURL(/#\/dashboard/);
  await expect(page.getByText('Pedidos', { exact: true }).first()).toBeVisible();
});
