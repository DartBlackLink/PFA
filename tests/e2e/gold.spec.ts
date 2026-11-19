import { test, expect, apiURL, token, account, login, scrollToButton } from './fixtures';
import { randomUUID } from 'node:crypto';

test('GOLD-S4 · generar, confirmar, mapa Huancayo y entregas propias persistidas', async ({ page, request, browser }, info) => {
  test.setTimeout(240_000);
  const visual = process.env.E2E_REPORT_SET === 'visual';
  const adminTiles: number[] = [];
  if (visual) page.on('response', r => { if (new URL(r.url()).hostname.endsWith('tile.openstreetmap.org')) adminTiles.push(r.status()); });
  const resource = account(info.project.name);
  const adminToken = await token(request);
  const headers = { Authorization: `Bearer ${adminToken}` };
  const ids: string[] = [];
  const windowStart = new Date(Date.now() - 60_000).toISOString();
  const windowEnd = new Date(Date.now() + 90 * 60_000).toISOString();
  const places = [
    { name: 'Plaza Constitución, Huancayo', lat: -12.068046, lon: -75.210073 },
    { name: 'Plaza Huamanmarca, Huancayo', lat: -12.0708548, lon: -75.2083245 },
  ];
  for (const place of places) {
    const response = await request.post(`${apiURL}/orders/`, { headers, data: {
      cliente_nombre: `QA E2E ${info.project.name}`, direccion: place.name,
      latitud: place.lat, longitud: place.lon, peso_kg: 1, tipo_producto: 'GENERAL',
      ventana_inicio: windowStart, ventana_fin: windowEnd,
    } });
    expect(response.status()).toBe(201);
    ids.push((await response.json()).pedido_id);
  }
  await login(page);
  await page.goto('/#/optimization');
  // Select the two QA orders explicitly; do not depend on a search field's
  // merged Flutter semantics rectangle or select unrelated pending records.
  const ownOrders = page.getByRole('checkbox', { name: new RegExp(`^QA E2E ${info.project.name} ·`) });
  await expect(ownOrders).toHaveCount(2);
  await ownOrders.nth(0).click();
  await ownOrders.nth(1).click();
  await page.getByRole('button', { name: /^Repartidor/ }).click();
  await page.getByRole('menuitem', { name: `QA E2E ${info.project.name}`, exact: true }).click();
  await page.getByRole('button', { name: /^Vehículo/ }).click();
  const fullPlate = `E2E-${(['chromium', 'firefox', 'webkit'].indexOf(info.project.name) + 1).toString().padStart(3, '0')}`;
  await page.getByRole('menuitem', { name: new RegExp(`^${fullPlate} ·`) }).click();
  await page.getByRole('button', { name: 'Agregar equipo', exact: true }).click();
  await page.getByRole('button', { name: 'Usar inicio de la primera ventana seleccionada', exact: true }).click();
  const previewResponse = page.waitForResponse(r => r.url().endsWith('/optimizations/preview'), { timeout: 60000 });
  await page.getByRole('button', { name: 'Generar propuesta', exact: true }).click();
  const preview = await previewResponse;
  expect(preview.status()).toBe(201);
  const plan = await preview.json();
  const confirmResponse = page.waitForResponse(r => r.url().endsWith(`/optimizations/${plan.plan_id}/confirm`));
  await page.getByRole('button', { name: 'Confirmar y asignar pedidos', exact: true }).click();
  const confirmed = await confirmResponse;
  expect(confirmed.status()).toBe(200);
  const routeId = (await confirmed.json()).ruta_ids[0];
  await page.getByRole('button', { name: 'Ver recorrido 1', exact: true }).click();
  await expect(page.getByRole('heading', { name: 'Recorrido de entrega', exact: true })).toBeVisible();
  const storedResponse = await request.get(`${apiURL}/routes/${routeId}`, { headers });
  expect(storedResponse.status()).toBe(200);
  const stored = await storedResponse.json();
  expect(stored.entregas.map((item: any) => item.pedido_id).sort()).toEqual([...ids].sort());
  expect(stored.geometria.type).toBe('LineString');
  expect(stored.geometria.coordinates.length).toBeGreaterThan(2);
  const otherProject = ['chromium', 'firefox', 'webkit'].find(name => name !== info.project.name)!;
  const otherToken = await token(request, account(otherProject).email, true);
  expect((await request.get(`${apiURL}/routes/${routeId}`, { headers: { Authorization: `Bearer ${otherToken}` } })).status()).toBe(404);
  for (const [lon, lat] of stored.geometria.coordinates) {
    expect(lat).toBeGreaterThan(-12.25); expect(lat).toBeLessThan(-11.85);
    expect(lon).toBeGreaterThan(-75.4); expect(lon).toBeLessThan(-75.05);
  }
  if (visual) {
    await expect.poll(() => adminTiles.filter(status => status === 200).length, { timeout: 20000 }).toBeGreaterThan(0);
    await page.waitForTimeout(3000);
  }
  await info.attach('mapa-Huancayo-ADMIN', { body: await page.screenshot(), contentType: 'image/png' });

  const courierContext = await browser.newContext({ viewport: { width: 1280, height: 1000 }, locale: 'es-PE', timezoneId: 'America/Lima', baseURL: process.env.E2E_WEB_URL });
  try {
    const courier = await courierContext.newPage();
    const courierTiles: number[] = [];
    if (visual) courier.on('response', r => { if (new URL(r.url()).hostname.endsWith('tile.openstreetmap.org')) courierTiles.push(r.status()); });
    await login(courier, info.project.name);
    await courier.getByRole('button', { name: new RegExp(`Recorrido · ${fullPlate}`) }).click();
    await courier.getByRole('button', { name: 'Iniciar recorrido', exact: true }).click();
    const started = courier.waitForResponse(r => r.url().includes(`/routes/${routeId}/iniciar`));
    await courier.getByRole('button', { name: 'Confirmar', exact: true }).click();
    expect((await started).status()).toBe(200);
    const courierToken = await token(request, resource.email, true);
    const courierHeaders = { Authorization: `Bearer ${courierToken}` };
    const before = await (await request.get(`${apiURL}/routes/${routeId}`, { headers: courierHeaders })).json();
    const firstOrder = before.entregas[0].pedido_id;
    await (await scrollToButton(courier, 'Confirmar entrega')).click();
    const delivered = courier.waitForResponse(r => r.url().includes(`/entregas/${firstOrder}/confirmar`));
    await courier.getByRole('button', { name: 'Confirmar', exact: true }).click();
    const firstDeliveryResponse = await delivered;
    expect(firstDeliveryResponse.status()).toBe(200);
    const firstDeliveredAt = (await firstDeliveryResponse.json()).entregas.find((item: any) => item.pedido_id === firstOrder).entregado_en;

    // Congestion is explicitly synthetic, never traffic observed in real time.
    const eventId = randomUUID();
    const incident = await request.post(`${apiURL}/routes/${routeId}/incidentes`, { headers: courierHeaders, data: {
      evento_id: eventId, tipo: 'CONGESTION', descripcion: 'QA E2E: congestión simulada para verificar el cambio de versión.',
      demora_min: 1, latitud: -12.068046, longitud: -75.210073, afectacion: 'BAJA',
    } });
    expect(incident.ok()).toBeTruthy();
    const inbox = await request.get(`${apiURL}/operations/notifications`, { headers });
    expect(inbox.status()).toBe(200);
    expect(JSON.stringify(await inbox.json())).toContain(routeId);
    const replan = await request.post(`${apiURL}/operations/routes/${routeId}/replan`, { headers, data: {
      evento_id: eventId, version: 1, latitud: -12.068046, longitud: -75.210073,
      ubicacion_en: new Date().toISOString(), motivo: 'QA E2E: reoptimización simulada; no representa tráfico real.',
    }, timeout: 45000 });
    expect(replan.status()).toBe(201);
    const revision = await replan.json();
    const approved = await request.post(`${apiURL}/operations/revisions/${revision.revision_id}/confirm`, { headers });
    expect(approved.status()).toBe(200);
    await courier.reload();
    const enable = courier.locator('flt-semantics-placeholder');
    if (await enable.count()) await enable.evaluate((node: HTMLElement) => node.click());
    // A page reload returns to the courier workspace, then the same saved route.
    await courier.getByRole('button', { name: new RegExp(`Recorrido · ${fullPlate}`) }).click();
    const receiveButton = courier.getByRole('button', { name: 'Confirmar recepción de nueva ruta', exact: true });
    await expect(receiveButton).toBeVisible();
    const [ack] = await Promise.all([
      courier.waitForResponse(r => r.url().endsWith(`/operations/routes/${routeId}/ack`)),
      receiveButton.click(),
    ]);
    expect(ack.status()).toBe(200);
    await (await scrollToButton(courier, 'Confirmar entrega')).click();
    const finalDelivery = courier.waitForResponse(r => r.url().includes('/entregas/') && r.url().includes('/confirmar'));
    await courier.getByRole('button', { name: 'Confirmar', exact: true }).click();
    expect((await finalDelivery).status()).toBe(200);
    const final = await (await request.get(`${apiURL}/routes/${routeId}`, { headers: courierHeaders })).json();
    expect(final.estado).toBe('FINALIZADA');
    expect(final.version_recibida).toBe(final.version);
    expect(final.version).toBe(2);
    expect(final.entregas.every((item: any) => item.estado_entrega === 'ENTREGADO')).toBeTruthy();
    expect(final.entregas.find((item: any) => item.pedido_id === firstOrder).entregado_en).toBe(firstDeliveredAt);
    if (visual) {
      await expect.poll(() => courierTiles.filter(status => status === 200).length, { timeout: 20000 }).toBeGreaterThan(0);
      await courier.waitForTimeout(3000);
      await info.attach('teselas-OSM', { body: JSON.stringify({ admin: adminTiles, courier: courierTiles,
        scope: 'Observed tile HTTP responses; route and delivery persistence asserted separately.' }), contentType: 'application/json' });
    }
    await info.attach('persistencia-GOLD', { body: JSON.stringify({ routeId, version: final.version, received: final.version_recibida,
      state: final.estado, deliveries: final.entregas.map((item: any) => ({ id: item.pedido_id, state: item.estado_entrega, deliveredAt: item.entregado_en })),
      caveat: 'Planning, map and courier operation through UI; congestion/replan/approval through authenticated API. QA only.' }, null, 2), contentType: 'application/json' });
    await info.attach('entregas-REPARTIDOR', { body: await courier.screenshot(), contentType: 'image/png' });
  } finally { await courierContext.close(); }
});
