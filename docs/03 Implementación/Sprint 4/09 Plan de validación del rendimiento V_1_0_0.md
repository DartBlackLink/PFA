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
