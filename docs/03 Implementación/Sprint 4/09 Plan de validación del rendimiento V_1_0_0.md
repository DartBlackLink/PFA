# Plan de validación del rendimiento — Sprint 4

**Proyecto:** EcoLogística Huancayo. **Responsable:** Jordy Steve Chancasanampa Torres. **Versión:** 1.0.0. **Fecha:** 13/11/2026. **Elemento:** EHAPP-14 / EN-002, RNF-01.

## Objetivo y umbrales

Medir el flujo integrado con datos de Huancayo, red vial, FastAPI y PostgreSQL. Optimización: **≤45 segundos** para hasta 150 pedidos y 15 vehículos/equipos. Reoptimización: **<30 segundos** para el escenario equivalente con cambio operativo. Una ejecución justo en 30 s no cumple el segundo umbral.

El [benchmark histórico del motor](../Sprint%203/03%20Revisi%C3%B3n%20del%20Sprint%20V_1_0_0.md) utiliza matriz controlada y no acredita estos umbrales integrados. No se ejecutó un benchmark nuevo al redactar este protocolo ni se generó un dataset que se presente falsamente como disponible.

## Preparación del ensayo

| Elemento | Condición que debe quedar registrada |
|---|---|
| Versión | Commit o manifiesto SHA de fuentes, build servido, API/migraciones y dependencias. |
| Entorno | CPU, RAM, sistema, navegador/cliente, límites de contenedores, concurrencia y latencia observada. |
| Dataset | Escenarios fijos de 10, 50 y 150 pedidos sintéticos, identificados, con destinos públicos y trazados dentro del ámbito de Huancayo; semilla de generación y SHA del archivo. |
| Equipos | Hasta 15 pares únicos activos, con capacidad y turnos suficientes; datos sintéticos identificados. La cantidad de perfiles demo existentes no sustituye este requisito. |
| Red vial | Proveedor, versión/perfil cuando exista, origen de matrices, lotes y régimen de caché documentados. No saturar un servicio público; preparar una fuente con capacidad suficiente. |
| Seguridad | Base o esquema de prueba aislado autorizado, cuentas mínimas, respaldo y ausencia de datos personales reales. No cargar 150 pedidos QA en la base operativa por este plan. |
| Factibilidad | Ventanas, atención, capacidad, turnos y retorno recalculables; diagnóstico de casos imposibles separado. |

## Medición de extremo a extremo

1. Registrar datos y estado inicial; comprobar que no existen pedidos/equipos repetidos y que la geometría pertenece a Huancayo.
2. Para cada tamaño ejecutar cinco semillas fijas, propuestas **11, 22, 33, 44 y 55**, conservando los mismos datos y parámetros. Documentar esas semillas antes del ensayo; no elegir solo las que mejor rindan.
3. Iniciar reloj monotónico inmediatamente antes de solicitar la propuesta. Incluir consultas, cálculo vial y motor. Confirmar automáticamente el plan sin espera humana y detener al recibir la confirmación persistida. Guardar por separado tiempo de preview y confirmación; verificar lectura posterior.
4. Preparar la ruta en curso, una entrega ya realizada y una incidencia manual de prueba con posición válida. Medir desde la solicitud de replan hasta la propuesta persistida. Registrar aparte aprobación y acuse; el tiempo que una persona tarda en decidir no se oculta dentro del cálculo ni se usa para cambiar el umbral.
5. Distinguir primera ejecución sin caché de repeticiones con caché. No promediar ambas sin indicarlo. Anotar errores del proveedor, timeouts y reintentos con su tiempo original.
6. Recalcular factibilidad, unicidad, permisos y conservación de entregas previas. Una respuesta rápida inválida no aprueba rendimiento.

## Datos mínimos de cada resultado

`caso, fecha_hora, version, dataset_sha256, pedidos, equipos, semilla, parametros, cache, proveedor, t_preview_ms, t_confirm_ms, t_total_ms, t_replan_ms, factible, pedidos_unicos, estado_http, error, evidencia`.

El informe derivará mediana, máximo y porcentaje de factibilidad por tamaño y régimen de caché. Debe conservar todas las ejecuciones, no solo la mediana favorable. Las cinco de 150/15 deben respetar los umbrales y las restricciones para aprobar este protocolo; si alguna falla, registrar el hallazgo, corregir y repetir conservando ambos cortes.

## Dictamen y seguimiento

| Posible resultado | Tratamiento |
|---|---|
| Cumple tiempo y restricciones | Candidato a aceptación técnica con informe crudo y resumen. |
| Supera umbral o devuelve solución inválida | No conforme; analizar proveedor, consultas, parámetros o algoritmo según evidencia. No reducir el dataset ni flexibilizar restricciones para aprobar. |
| Proveedor/entorno no permiten medir | Resultado no concluyente y causa identificada; no adjudicar tiempo ficticio. Registrar impedimento solo si detiene una actividad comprometida y requiere gestión. |

El resultado y las capturas se incorporarán a [Evidencias](evidencias/README.md) y a la Revisión. [Índice del Sprint 4](README.md).


## Actualización técnica — 14/11/2026

Este apartado posterior sustituye únicamente el carácter futuro de los controles que sí se ejecutaron: 141 pruebas backend, 93 Flutter, análisis Flutter sin incidencias, Bandit y auditoría de dependencias con sus informes finales. Cobertura backend: 90.0313479624 % (2872/3190, líneas + ramas); líneas 2321/2492, ramas 551/698. No es una calificación nueva de SonarQube.

Se ejecutaron generación/confirmación/incidencia/reoptimización/acuse/entregas por navegador y verificación posterior API/PostgreSQL. Se inspeccionaron pantallas y modal nuevos a 360 px en ambos temas. El PDF real se descargó, parseó y renderizó.

EN-002: endpoint 150/15 en 16,649722 s; replan de 3 pendientes en 1,780739 s. OSRM real; demanda sintética en tres puntos repetidos; una semilla 42, no cinco. No cubre renderizado ni una campaña representativa ni el peor caso. Se conserva el protocolo ampliado como acción, sin adjudicarlo como ejecutado.

La nueva migración 0008 agrega configuración ambiental opcional y auditada. Datos y cuentas existentes se preservaron. El hallazgo CVE-2026-126360 del lock se corrigió de 1.45.1 a 1.45.2; conserva auditoría antes/después.

Consulte [evidencias y resultados](../evidencias/20261114-desarrollo-integral/RESULTADOS.md) para resultados, comandos, versión y límites; [acciones externas](../ACCIONES_EXTERNAS_Y_CIERRE_WEB.md) centraliza lo que necesita intervención posterior.

[← Volver al README principal](../../../README.md)


## Revalidación técnica — 18/11/2026

Se añaden resultados posteriores sin sustituir los cortes históricos: 145 backend y 30 ejecuciones Playwright aprobadas, cobertura combinada backend 2882/3200 ≈ 90.0625 %. La campaña amplió a cinco semillas por cada tamaño 10/50/150; 15 casos posteriores a la deduplicación verificados. Se conservó el fallo frío inicial y se corrigió además el protocolo OSRM 1×1 con regresiones y GOLD posterior. La demanda sigue siendo sintética, sobre tres destinos, y no demuestra un SLA general.

El instrumento SUS y su calculador están implementados, pero no hay respuestas humanas; por tanto no hay puntuación SUS. Existen los tres workflows localmente, validados por actionlint y sintaxis Bash, sin ejecución en GitHub y todavía sin producción al corte del 18/11. La publicación manual posterior del 19/11 consta en las evidencias enlazadas. La declaración anterior sobre ausencia de estos archivos queda sustituida por este corte; sus resultados anteriores no se reetiquetan. Las mediciones web pueden carecer de una entrada LCP elegible en canvas y no se completan artificialmente. Continúan sin acreditarse costos reales, aceptación formal o cierre administrativo.

Consulte [resultados](../evidencias/20261118-semana14/RESULTADOS.md), [rendimiento](../evidencias/20261118-semana14/RENDIMIENTO.md), [análisis E2E](03%20Analisis%20PlayWrigth%20V_1_0_0.md), [usabilidad](04%20Usabilidad%20V_1_0_0.md) y [CI/CD](12%20Automatizaci%C3%B3n%20CI-CD%20V_1_0_0.md).


## Estado documental consolidado — 19/11/2026

La URL pública y la persistencia por roles ya se comprobaron en Wasmer y Neon; [resultado y límites](../evidencias/20261119-despliegue-publico/RESULTADOS.md). Esta evidencia actualiza el estado de publicación, sin alterar las cifras locales de rendimiento/cobertura, los costos no acreditados o el calendario no confirmado. SUS real, Actions/CD automático y aceptación permanecen abiertos en las [acciones de cierre](ACCIONES_PARA_CERRAR_SPRINT4.md).
