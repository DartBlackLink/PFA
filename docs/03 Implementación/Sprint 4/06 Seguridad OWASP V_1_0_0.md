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


## Actualización técnica — 14/11/2026

Este apartado posterior sustituye únicamente el carácter futuro de los controles que sí se ejecutaron: 141 pruebas backend, 93 Flutter, análisis Flutter sin incidencias, Bandit y auditoría de dependencias con sus informes finales. Cobertura backend: 90.0313479624 % (2872/3190, líneas + ramas); líneas 2321/2492, ramas 551/698. No es una calificación nueva de SonarQube.

Se ejecutaron generación/confirmación/incidencia/reoptimización/acuse/entregas por navegador y verificación posterior API/PostgreSQL. Se inspeccionaron pantallas y modal nuevos a 360 px en ambos temas. El PDF real se descargó, parseó y renderizó.

EN-002: endpoint 150/15 en 16,649722 s; replan de 3 pendientes en 1,780739 s. OSRM real; demanda sintética en tres puntos repetidos; una semilla 42, no cinco. No cubre renderizado ni una campaña representativa ni el peor caso. Se conserva el protocolo ampliado como acción, sin adjudicarlo como ejecutado.

La nueva migración 0008 agrega configuración ambiental opcional y auditada. Datos y cuentas existentes se preservaron. El hallazgo CVE-2026-126360 del lock se corrigió de 1.45.1 a 1.45.2; conserva auditoría antes/después.

Consulte [evidencias y resultados](../evidencias/20261114-desarrollo-integral/RESULTADOS.md) para resultados, comandos, versión y límites; [acciones externas](../ACCIONES_EXTERNAS_Y_CIERRE_WEB.md) centraliza lo que necesita intervención posterior.
