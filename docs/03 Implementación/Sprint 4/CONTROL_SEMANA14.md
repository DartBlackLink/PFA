# Correspondencia con Semana 14 — corte verificado

**Proyecto:** EcoLogística Huancayo. **Responsable:** Jordy Steve Chancasanampa Torres. **Versión:** 1.2.0. **Fecha:** 19/11/2026.

Se contrastaron la consigna de Inspección 5, las dos guías HTML de reporte híbrido/cierre, las lecturas 21/22 y las diapositivas. Las fuentes originales permanecen intactas y el cronograma con datos personales de otros estudiantes no se incorpora. Los videos no se presentan como revisados. Se usa la carpeta existente «03 Implementación», evitando duplicarla por la errata «Inplementación» de la consigna.

| Requisito | Situación real y evidencia |
|---|---|
| Revisión y retrospectiva | Estructura exacta, preguntas conservadas y respuestas con problemas, soluciones, aprendizaje y compromisos; Sprint 4 separado. No se inventan reuniones ni cierre de historias En curso. |
| E2E Playwright | Implementado y ejecutado: 30 ejecuciones aprobadas: diez casos por cada motor Chromium/Firefox/WebKit, HTML, JSON, JUnit y capturas. El GOLD distingue acciones UI y API. |
| Rendimiento y resiliencia web | TTFB/FCP/LCP cuando el motor expone la entrada, red sanitizada, errores esperados y recuperación. LCP ausente no se convierte en cero. Salud local 12/12 en ventana breve; no uptime de producción. |
| EN-002 | Cinco semillas por tamaño 10/50/150, 15 casos verificados después de corregir duplicación vial; se preserva fallo inicial y limitación geográfica. |
| SUS | Formulario completo, consentimiento, CSV, unificador y cálculo implementados/validados. Cero respuestas reales recibidas: puntuación y grado no calculables. |
| CI/CD | Tres workflows validados localmente. CI y pruebas no se ejecutaron en GitHub; la entrega VPS de producción debe adaptarse a Wasmer y acreditarse con una ejecución real. Publicación manual no equivale a CD automático. |
| Producción | Despliegue manual Wasmer + Neon verificado el 19/11: web/API 200, dos roles, acuse y entrega v2 persistidos. URL pública funcional; falta automatizar CD y ejecutar Actions. Véase el expediente del 19/11. |
| Control híbrido y cierre | Estado de un solo sprint, variaciones, EVM, tablero, acciones y lecciones. Sin PV/EV/AC reales no se inventan índices financieros, curvas históricas o firma de cierre. |
| Navegación y monorepo | Código cliente/servidor separado, README con cuatro entregables directos y regreso a raíz. Artefactos públicos seleccionados separados de credenciales, caches y respaldos privados. |

## Decisión

La parte automatizable local se implementó y verificó; no se limita a describir trabajo futuro. La aceptación integral de Semana 14 continúa parcial por respuestas SUS, ejecución real de Actions/CD y aceptación. La publicación manual en producción ya se comprobó el 19/11. Estos pasos dependen de datos y decisiones reales que no se fabrican. No se publicó en GitHub ni se modificó Jira en esta actualización; su lectura confirmó el alcance S4 EN-002, US-006 y US-007, 15 SP, En curso.

El [expediente del 18/11](../evidencias/20261118-semana14/RESULTADOS.md) permite auditar los resultados; [acciones de cierre](ACCIONES_PARA_CERRAR_SPRINT4.md) contiene únicamente el trabajo posterior y cómo acreditarlo.


[← Volver al README principal](../../../README.md)


[Publicación y evidencias del 19/11](../evidencias/20261119-despliegue-publico/RESULTADOS.md).

## Alcance documental confirmado — 19/11/2026

Se amplió el procedimiento de los dos requisitos abiertos: [SUS con cinco personas](instrumentos/GUIA_APLICACION_SUS.md) y [adaptación/ejecución CI/CD Wasmer](12%20Automatizaci%C3%B3n%20CI-CD%20V_1_0_0.md). El responsable confirmó que reunirá respuestas; no se han recibido todavía. La instrucción vigente es solo documentación: sin configuración de credenciales ni publicación. Se mantienen pendientes las ejecuciones remotas y la muestra humana; no se confunden con la publicación manual ya comprobada.
