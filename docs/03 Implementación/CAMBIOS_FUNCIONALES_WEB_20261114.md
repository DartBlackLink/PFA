# Cambios funcionales verificables de la web

**Proyecto:** EcoLogística Huancayo. **Responsable:** Jordy Steve Chancasanampa Torres. **Corte técnico:** 14/11/2026, America/Lima.

| Antes | Después | Código y regresión |
|---|---|---|
| Reportes era una pantalla informativa. | Resumen SQL, selección paginada, JSON/PDF por ruta, versión, ventanas y equivalencia opcional. | [reports.py](../../backend/app/api/routes/reports.py);test_reporting_clients.py;completion_modules_test.dart. |
| ApiClient solo decodificaba JSON. | Respuesta binaria autenticada: valida application/pdf y la firma %PDF; descarga mediante Blob sin poner el token en la URL. | [ApiClient](../../apps/web/lib/core/network/api_client.dart);core/download. |
| Nombre del cliente en cada pedido, sin gestión web de preferencias. | Clientes, estado, horario/referencia/acceso y selección por cliente_id en pedidos. | [clients.py](../../backend/app/api/routes/clients.py);features/clients. |
| Sin parámetro ambiental documentado. | Configuración opcional auditada; valida el conjunto completo; ausencia → no disponible. | Migración0008;reports/environment. |
| Asignación manual sin indicadores ni ETA; el horario ignoraba la ventana de entrega. | Evaluación secuencial con restricciones del motor, indicadores y ETA guardados; rechazo sin mutación. | [manual_planning.py](../../backend/app/services/manual_planning.py);routes.py;test_reporting_clients.py. |
| RutaRead omitía combustible/CO₂. | El contrato incluye los datos guardados y OpenAPI se actualiza. | schemas.py;regresiónasignación. |
| El lock contenía opentelemetry-api 1.45.1 afectado. | Pin 1.45.2 y auditoría de dependencias repetida. | requirements.lock.txt;auditoríasantes/después. |

Ejemplo propio de la corrección manual:

```python
candidate, start, end, etas = evaluate_manual(
    db, driver, vehicle, ordered, payload.inicio_planificado,
    payload.servicio_min_por_entrega, points, legs,
)
# Al persistir Ruta:
combustible_l=candidate.fuel,
co2_kg=candidate.carbon,
# En cada RutaDetalle:
eta=etas[str(order.pedido_id)]
```

El fragmento es explicativo; el código completo y la prueba están en los archivos enlazados. No modifica métricas históricas por suposición. [Resultados y evidencia](evidencias/20261114-desarrollo-integral/RESULTADOS.md).
