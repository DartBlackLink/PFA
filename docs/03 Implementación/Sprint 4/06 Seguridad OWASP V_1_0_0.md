# Seguridad OWASP — Sprint 4

**Proyecto:** EcoLogística Huancayo. **Responsable:** Jordy Steve Chancasanampa Torres. **Versión:** 1.0.0. **Fecha:** 13/11/2026.

## Alcance

Plan de revisión defensiva de Web ADMIN/REPARTIDOR, FastAPI y datos de rutas/indicadores. Se utiliza [OWASP Top 10:2025](https://top10.owasp.org/2025/) como clasificación de riesgos, no como certificado ni como un pentest ejecutado. La matriz define qué contrastar en el incremento; este corte no ejecutó pruebas de seguridad nuevas.

## Matriz de riesgos y verificación prevista

| Categoría 2025 | Aplicación a EcoLogística | Comprobación requerida |
|---|---|---|
| A01 — Control de acceso | Ruta, planificación e indicadores ajenos. | Permisos del servidor y aislamiento por propietario. |
| A02 — Configuración | Entorno, CORS y exposición de servicios. | Configuración por entorno sin secretos en cliente. |
| A03 — Cadena de suministro | Paquetes Python/Dart e imágenes. | Versiones fijadas, auditoría y origen. |
| A04 — Criptografía | Contraseñas y sesiones. | Hash adecuado y configuración de transporte. |
| A05 — Inyección | Búsquedas, filtros y entradas. | Validación y consultas parametrizadas. |
| A06 — Diseño inseguro | Confirmación y métricas incoherentes. | Invariantes y límites explícitos. |
| A07 — Autenticación | Acceso, caducidad y bloqueo. | Rechazo de credenciales inválidas y sesión vencida. |
| A08 — Integridad | Planes y entregas persistidas. | Transacciones y versiones coherentes. |
| A09 — Registro y alertas | Incidencias y decisiones. | Trazabilidad sin datos privados. |
| A10 — Excepciones | Proveedor vial, datos ausentes y errores. | Fallo controlado sin información sensible. |

## Casos concretos del proyecto

- Sin autenticación, no devolver rutas/indicadores protegidos. Un repartidor no puede calcular ni confirmar planes administrativos ni leer rutas de otro usuario. El estado final de la base debe permanecer intacto tras el rechazo.
- Probar coordenadas ausentes o fuera del área, números no finitos, filtros inválidos y planes inexistentes. No ejecutar una escritura con datos parcialmente validados.
- Repetir una confirmación no debe duplicar rutas; una propuesta vencida o de otra versión no se aprueba. Registrar el identificador del caso y su lectura posterior.
- Revisar sesión vencida y política RN-023 (5/10/300 s) en su alcance real, sin reducir protecciones para facilitar la demo. No equiparar ocultar botones con autorización.
- Retirar de las evidencias credenciales, tokens, documentos personales y respaldos. Usar cuentas/datos sintéticos autorizados y evitar exponer los accesos actuales en el repositorio.

## Resultados y seguimiento

Hay [antecedentes de permisos y controles S3](../evidencias/20261104-cierre/MATRIZ_ACEPTACION.md); no constituyen una revisión completa OWASP del nuevo incremento. Cada caso S4 debe registrar versión, solicitud, respuesta, resultado en BD y evidencia saneada. Los hallazgos se gestionan con responsable y corrección comprobada; la ausencia de resultados nuevos no se representa como cero vulnerabilidades.

Los compromisos de seguridad no añaden automáticamente EHAPP-17 a S4 ni sus 5 SP. Cualquier ampliación se acuerda y registra primero.

[Índice del Sprint 4](README.md) · [Acciones de cierre](ACCIONES_PARA_CERRAR_SPRINT4.md)
