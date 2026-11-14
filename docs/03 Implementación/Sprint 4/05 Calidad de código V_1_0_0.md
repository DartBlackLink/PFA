# Calidad de código — Sprint 4

**Proyecto:** EcoLogística Huancayo. **Responsable:** Jordy Steve Chancasanampa Torres. **Versión:** 1.0.0. **Corte documental:** 13/11/2026.

## Resumen del control de calidad

Este documento prepara la comprobación de la versión candidata S4. No se ejecutó un análisis SonarQube ni una regresión nueva como parte del encargo documental. El código de entrega en PFA y la aplicación en D deben identificarse y compararse antes de atribuirles un mismo resultado.

## Métricas principales y antecedentes

| Evidencia propia conservada | Resultado de su corte | Uso correcto en S4 |
|---|---|---|
| [Validación S3 del 09/11](../evidencias/20261109-validacion-danleo/CIERRE_DANLEO_20261109.md) | Backend del 08/11: 127 pruebas, 90,88 % de cobertura combinada. Flutter del 09/11: 83 pruebas. | Antecedente; no prueba cambios nuevos ni aceptación de EHAPP-15/16/14. |
| [SonarQube del 04/11](../evidencias/20261104-cierre/SONARQUBE_ACTUAL.md) | ecologisticas2.1: procesamiento SUCCESS, gate OK/PASSED, cobertura backend 90,9 %, duplicación 0,0 %, incidencias devueltas 0. | Resultado histórico de su versión; no se renombra como análisis S4. La respuesta conservada tenía `conditions: []`, por lo que no se inventan condiciones del gate. |
| Cobertura de la versión candidata S4 | Sin ejecución nueva en esta preparación. | Obtener XML/HTML/JUnit y alcance real. No asignar a Flutter la cobertura de Python. |

La cobertura indica código ejercitado por las pruebas, no porcentaje de funciones correctas. Conservar los numeradores de líneas y ramas y las exclusiones; no alterar las exclusiones o simplificar pruebas para mejorar la cifra. El objetivo de la DoD local es cobertura de lógica testeable ≥80 %, junto con pruebas de comportamiento; no basta superar el porcentaje.

## Verificación prevista de la nueva versión

| Capa | Comprobación | Evidencia exigida |
|---|---|---|
| Backend | Pruebas pertinentes de mapa/serialización, indicadores, permisos, restricciones y persistencia; regresión tras cambios. | JUnit, log completo, versión y dataset. |
| Flutter | Análisis, pruebas de estados vacío/carga/error/éxito, selección de plan y navegación; tamaños/temas previstos. | Log del analizador y pruebas; hallazgos corregidos y repetidos. |
| Integración | Criterios de la Revisión con navegador, FastAPI y PostgreSQL conectados. | Solicitudes relevantes, capturas y lecturas persistidas sin secretos. |
| Cobertura | Medición del código candidato, diferenciando líneas/ramas y lenguaje. | XML/HTML y resumen de cálculo enlazado al commit o manifiesto de fuentes. |
| SonarQube | Token nuevo privado, clave verificada, importación del reporte correcto y consulta del procesamiento. | Fecha, clave, taskId/analysisId, gate y métricas; ningún token en Git o capturas. |
| Dependencias / estático | Analizadores y auditoría del entorno real del proyecto. | Versiones, comandos, alcance y hallazgos, sin afirmar cero vulnerabilidades globales. |

## Plan de remediación y deuda técnica

El responsable registrará cada hallazgo con archivo/función, causa, impacto, corrección, prueba de regresión y resultado repetido. Un fallo de permisos, escritura parcial o indicador falso impide aceptar la historia afectada. Las mejoras menores se priorizan con fecha y decisión, sin ocultarlas para presentar un gate favorable.

Usar los comandos de [tools/quality](../../../tools/quality/README.md) y del [backend](../../../backend/README.md), comprobando antes sus rutas y dependencias. Son instrucciones de reproducción, no ejecuciones realizadas por este expediente.

[Índice del Sprint 4](README.md) · [Acciones de cierre](ACCIONES_PARA_CERRAR_SPRINT4.md)


## Actualización técnica — 14/11/2026

Este apartado posterior sustituye únicamente el carácter futuro de los controles que sí se ejecutaron: 141 pruebas backend, 93 Flutter, análisis Flutter sin incidencias, Bandit y auditoría de dependencias con sus informes finales. Cobertura backend: 90.0313479624 % (2872/3190, líneas + ramas); líneas 2321/2492, ramas 551/698. No es una calificación nueva de SonarQube.

Se ejecutaron generación/confirmación/incidencia/reoptimización/acuse/entregas por navegador y verificación posterior API/PostgreSQL. Se inspeccionaron pantallas y modal nuevos a 360 px en ambos temas. El PDF real se descargó, parseó y renderizó.

EN-002: endpoint 150/15 en 16,649722 s; replan de 3 pendientes en 1,780739 s. OSRM real; demanda sintética en tres puntos repetidos; una semilla 42, no cinco. No cubre renderizado ni una campaña representativa ni el peor caso. Se conserva el protocolo ampliado como acción, sin adjudicarlo como ejecutado.

La nueva migración 0008 agrega configuración ambiental opcional y auditada. Datos y cuentas existentes se preservaron. El hallazgo CVE-2026-126360 del lock se corrigió de 1.45.1 a 1.45.2; conserva auditoría antes/después.

Consulte [evidencias y resultados](../evidencias/20261114-desarrollo-integral/RESULTADOS.md) para resultados, comandos, versión y límites; [acciones externas](../ACCIONES_EXTERNAS_Y_CIERRE_WEB.md) centraliza lo que necesita intervención posterior.
