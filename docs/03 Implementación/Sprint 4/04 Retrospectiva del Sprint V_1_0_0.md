# Retrospectiva del Sprint 4

**Proyecto:** EcoLogística Huancayo. **Responsable:** Jordy Steve Chancasanampa Torres. **Corte técnico:** 14/11/2026, America/Lima. **Versión:** 1.1.0.

**Método:** análisis técnico de problemas, correcciones y pruebas del corte. No se inventa una reunión. Los compromisos preventivos siguientes quedan propuestos al responsable para su retrospectiva real.

## ¿Qué aprendimos?

Un trazado visible no acredita una planificación temporal válida. La asignación manual guardaba distancia/tiempo, pero no combustible, CO₂ ni ETA por entrega; el cambio de horario tampoco revalidaba toda la ventana. Se reutilizó la evaluación de restricciones del motor, se guardaron los indicadores y ETA y se comprobó rechazo sin modificar la ruta ante una salida inviable. El cumplimiento previsto incluye atención completa, no solo la llegada.

## ¿Qué estamos haciendo bien?

Se conservó el mapa de Huancayo y el historial; se revalidó el flujo por navegador y se diferenció ETA de hora real. El benchmark usa carreteras reales y demanda sintética identificada, sin llamarla tráfico en vivo ni una muestra de 150 direcciones distintas.

## ¿Qué podemos hacer mejor?

### Personas

Antes de exponer, explicar si el dato es una estimación de la última versión, un tramo pendiente o una entrega real. Una métrica ausente no se sustituye por cero.

### Relaciones

Acordar con el docente qué evidencia mínima cierra EN-002 y registrar su decisión; una prueba favorable no es una aprobación del profesor.

### Procesos

El runner esperaba HTTP 200 aunque el endpoint documenta 201. Se corrigió el instrumento y conservó el tiempo real y la evidencia original, sin repetir selectivamente para ocultar el resultado. Deben conciliarse contrato y medición antes de ejecutar campañas.

### Herramientas

Se midieron SQL/proveedor/motor por endpoint, separándolos del navegador. Una muestra no establece percentiles poblacionales ni el peor caso. Quedan campañas de cinco semillas y un escenario de reoptimización mayor si se mantiene el protocolo ampliado.

### Acciones a realizar

| ID | Compromiso preventivo | Hito | Verificación |
|---|---|---|---|
| R4-A01 | Verificar ETA + atención, turno y solapamientos en toda nueva asignación o cambio de horario | Antes de integrar otra modificación de agenda | Regresión de horario inviable conserva fecha, ETA y pedidos. |
| R4-A02 | Anotar versión y alcance del indicador en toda tabla/PDF | Antes de agregar otro indicador | No confundir el pendiente recalculado con un acumulado físico. |
| R4-A03 | Validar HTTP esperado y guardar los resultados fallidos del instrumento | Antes de repetir el benchmark | Contrato201 y log original conservados; muestra y caché identificadas. |
| R4-A04 | Ampliar la campaña según protocolo acordado, sin cambiar las pruebas para obtener un porcentaje | Antes de aceptación formal de rendimiento | Cinco semillas o alcance reducido aprobado explícitamente por docente. |

Responsable propuesto: Jordy. No se marcan compromisos como cumplidos solo por redactarlos. Vinculación: [evidencias y resultados](../evidencias/20261114-desarrollo-integral/RESULTADOS.md) y [acciones externas](../ACCIONES_EXTERNAS_Y_CIERRE_WEB.md).

[Índice](README.md)
