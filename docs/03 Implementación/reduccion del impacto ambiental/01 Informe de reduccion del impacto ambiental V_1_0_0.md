[Índice de implementación](../README.md)

# Informe de reducción del impacto ambiental

**Proyecto:** EcoLogística. **Responsable:** Jordy Steve Chancasanampa Torres. **Versión:** 1.0.0. **Fecha:** 30/10/2026. Informe técnico preparatorio, no aceptación de la inspección de semana 13.

## Diagnóstico y alcance

El material de clase diferencia trabajo innecesario en datos, backend, transferencia y frontend. EcoLogística usa PostgreSQL/FastAPI/Flutter: no se trasladan las métricas ni la arquitectura MERN del ejemplo.

Se observó serialización de rutas con lecturas de repartidor, vehículo y entregas dentro del recorrido de cada registro. También se incorporó una búsqueda genética que necesita límites explícitos para no consumir recursos sin control.

## Cambios aplicados

| Capa | Antes / problema | Después / control |
|---|---|---|
| PostgreSQL | La serialización realizaba lecturas por ruta | Tres lecturas por lotes más el SELECT de rutas; sin cambiar el filtro por propietario |
| Proveedor vial | Recalcular la misma matriz implica transferencias repetidas | Caché LRU de 4 matrices, TTL de 300 s, lotes de hasta 80 ubicaciones y 4 trabajadores; se revalida la geometría final |
| Cálculo | Un GA sin límites podría prolongar la búsqueda | Hasta 150 pedidos/15 equipos, población hasta 64, generaciones hasta 150, presupuesto temporal acotado y una búsqueda concurrente por proceso |
| UI | Listado y parámetros extensos | ListView.builder, búsqueda y parámetros avanzados plegados; confirmar solo tras revisar |

## Medición propia

| Medición | Resultado | Interpretación válida |
|---|---|---|
| Prueba SQL con misma lógica de carga por lotes | 4 SELECT tanto para 1 como para 4 rutas | La cantidad de consultas no crece por cada ruta en el ensayo. No es una reducción de kWh medida |
| Benchmark de GA | 150 pedidos, 15 equipos, 7.907,60 ms; 866 evaluaciones/40 generaciones | CPU del motor con datos sintéticos y semilla 42; no latencia total ni una garantía para toda entrada |
| Función objetivo normalizada del benchmark | Línea base factible 0,6654338017; candidato 0,6641792544 | Comparación en el mismo conjunto sintético; no representa gramos de CO₂ ni porcentaje de ahorro real |
| Web release | 40 archivos, 42.527.825 bytes en disco | Tamaño del artefacto completo, no bytes transferidos por una visita; no se atribuye mejora porcentual sin una base comparable |

El ensayo SQL usa la prueba test_routes_are_batched_and_order_filter_is_validated. [Resultados y artefactos](../evidencias/20261030/RESULTADOS.md). No se publica un porcentaje de ahorro antes/después de energía porque no se midieron potencia, intensidad de carbono ni uso real.

## Impacto digital y logística

El impacto digital exige definir infraestructura y límites, medir transferencia/ejecución y documentar potencia, factores y su incertidumbre. El ejemplo CO2.js puede apoyar estimaciones por transferencia, pero no demuestra toda la energía del sistema. No se implementó un contador público con cifras aparentes.

Las cifras logísticas del plan se calculan como litros = km/(km/L) y kg CO₂ = km×factor kg/km del vehículo. Son estimaciones basadas en factores registrados, no emisiones de servidor ni telemetría física del vehículo. El GA pondera distancia, combustible, CO₂ y tiempo; no demuestra ahorro real frente a una ruta operativa no observada.

## Seguimiento

Repetir benchmark con datos viales representativos y medir el flujo completo 150/15; conservar equipo, versión, semilla y parámetros. Para un informe ambiental cuantitativo, medir transferencias y energía con límites comparables antes/después, declarar factores y no confundir kWh, kg CO₂ y función objetivo.

Referencia: [Green Software Foundation, medición](https://learn.greensoftware.foundation/measurement/). Las presentaciones de Green engineering/Green JavaScript y el HTML del profesor se utilizaron como guía, sin reutilizar sus cifras de ejemplo.
