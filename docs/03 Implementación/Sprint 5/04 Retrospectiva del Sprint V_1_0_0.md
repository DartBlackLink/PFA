# Retrospectiva del Sprint 5

**Proyecto:** EcoLogística Huancayo. **Responsable:** Jordy Steve Chancasanampa Torres. **Corte técnico:** 14/11/2026, America/Lima. **Versión:** 1.0.0.

**Método:** análisis técnico de problemas, correcciones y pruebas del corte. No se inventa una reunión. Los compromisos preventivos siguientes quedan propuestos al responsable para su retrospectiva real.

## ¿Qué aprendimos?

El cliente HTTP solo manejaba JSON; un PDF necesita una respuesta binaria autenticada, validación de Content-Type y firma %PDF antes de descargar. Se añadió ese camino y se comprobó el rechazo de HTML exitoso y errores JSON. En la operación real, la versión 2 no se consideró recibida al aprobar: se esperó el acuse del repartidor y se conservó la fecha de la primera entrega.

## ¿Qué estamos haciendo bien?

Se realizó ADMIN → REPARTIDOR → ADMIN → REPARTIDOR por botones con FastAPI/PostgreSQL y OSRM. La incidencia se identificó como simulada, tuvo resolución y no se presentó una alternativa sin mejora como ahorro. El PDF descargado fue parseado y renderizado, no solo abierto.

## ¿Qué podemos hacer mejor?

### Personas

Distinguir quién aprueba una propuesta y quién confirma recepción. La descripción de la simulación debe evitar que un lector interprete un reporte QA como congestión real.

### Relaciones

El administrador comunica la nueva versión por el mecanismo del sistema; el repartidor confirma con su cuenta. No atribuir al docente la aceptación del flujo sin revisión real.

### Procesos

La auditoría del lock encontró CVE-2026-126360 en opentelemetry-api 1.45.1. Se actualizó a 1.45.2, se conservó el hallazgo y se repitieron el análisis y las pruebas. No se demostró explotación en esta aplicación y no se afirma seguridad absoluta.

### Herramientas

Los permisos se verificaron en el servidor: anónimo 401, repartidor 403 en reportes/clientes y recurso de otro repartidor404. Un botón oculto no sustituye esa autorización. El PDF escapa texto y no interpreta HTML ni URLs del usuario.

### Acciones a realizar

| ID | Compromiso preventivo | Hito | Verificación |
|---|---|---|---|
| R5-A01 | Mantener prueba binaria válida/inválida al cambiar la exportación | Antes de modificar PDF | Un error JSON o HTML nunca se descarga como informe válido. |
| R5-A02 | Preservar la primera entrega en cada nueva reoptimización | En cada revisión del flujo | Timestamps/historial iguales y acuse de la nueva versión registrado. |
| R5-A03 | Auditar versiones bloqueadas antes de cada entrega | Antes de empaquetar una versión | Informe de dependencias con fecha y correcciones rastreables, sin ocultar hallazgos. |

Responsable propuesto: Jordy. No se marcan compromisos como cumplidos solo por redactarlos. Vinculación: [evidencias y resultados](../evidencias/20261114-desarrollo-integral/RESULTADOS.md) y [acciones externas](../ACCIONES_EXTERNAS_Y_CIERRE_WEB.md).

[Índice](README.md)
