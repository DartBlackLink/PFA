[Índice de implementación](../README.md) · [README del proyecto](../../../README.md)

# Informe de estado — Sprint 3

**Proyecto:** EcoLogística — caso académico EcoLogística Lima; interfaz existente Huancayo. **Responsable:** Jordy Steve Chancasanampa Torres. **Sprint:** 3. **Versión:** 1.0.0. **Corte técnico:** 30/10/2026.

**Periodo del informe:** 30/10/2026–30/10/2026, fecha de implementación y verificación de este incremento. No sustituye las fechas oficiales de inicio/cierre del sprint.

## Estado del proyecto

| Variable de control | Resultado exclusivo del incremento |
|---|---|
| Alcance | RF-03: generación de rutas mediante algoritmo genético, vista previa, confirmación y consulta. Referencia comunicada por el responsable: EHAPP-13 / US-005, Sprint 3, 13 SP. La lectura autenticada de Jira no pudo verificarse; no se declara aceptación ni se suman esos SP como terminados. |
| Cronograma | Incremento técnico ejecutado el 30/10. Las fechas del sprint y su compromiso deben contrastarse con Jira antes del cierre; no se usa la antigua propuesta de 22 SP. |
| Costos | No se aportó un registro de horas o desembolsos exclusivo de S3. No se transforma el presupuesto global en gasto real. |
| Calidad | 94 pruebas backend aprobadas, cobertura combinada de líneas/ramas 91,39 %; 58 pruebas Flutter aprobadas; analizador Dart sin incidencias; Web release compilada. Ruff, Bandit y pip-audit sin hallazgos en esta ejecución. SonarQube ecologisticas: gate OK, cobertura 91,4 % y cero incidencias abiertas con perfiles Sonar way core. Estas herramientas no prueban ausencia absoluta de vulnerabilidades. |

## Cambios y mejoras

| Componente | Implementación y finalidad |
|---|---|
| Motor | Población de permutaciones, selección por torneo, cruce ordenado, mutación e elitismo. Busca una solución factible; no certifica un óptimo global. |
| Restricciones | Peso, atención completa dentro de cada ventana, turno, jornada disponible, pausas y cruces de repartidor/vehículo. Los pares de repartidor y vehículo los selecciona el administrador; el motor distribuye y ordena los pedidos entre esos equipos. |
| Datos viales | Matrices dirigidas OSRM, lotes acotados, caché temporal y validación de cada tramo final; no se reemplaza un fallo por líneas rectas presentadas como rutas viales. |
| Confirmación | Vista previa de 10 minutos sin asignación; confirmación transaccional, idempotente y con comprobación de cambios. Se guardan semilla, parámetros, secuencia, ETA, geometría y estimaciones. |
| Integración | La Web permite elegir pedidos/equipos, revisar y confirmar. Las rutas confirmadas se consultan por administrador y por su repartidor con los permisos existentes. |
| Migración | 0005 añade plan_optimizacion y el vínculo opcional con ruta. El arranque local conservó 8 vehículos, 8 repartidores, 23 pedidos y 21 rutas. |
| Calidad transversal | Consulta de rutas por lotes y retiro del .env como recurso Web. No se adjudican EN-002, EN-003 o EN-005 como historias aceptadas sin compromiso verificable. |

## Riesgos

| Riesgo | Responsable | Mitigación |
|---|---|---|
| Indisponibilidad o demora del proveedor vial de demostración | Jordy | Plazos acotados, respuesta controlada y ausencia de asignaciones parciales; usar proveedor con capacidad contratada antes de producción. |
| Confundir estimaciones de combustible/CO₂ con mediciones reales | Jordy | Identificar fórmula, factores del vehículo y ausencia de tráfico/telemetría real. |
| Confundir el resultado técnico con cierre Scrum | Jordy | Contrastar compromiso, fechas y decisión real de revisión en la lista de acciones separada. |

## Próximos avances

Realizar la demostración con ventanas compatibles, registrar la revisión real y repetir las verificaciones si se modifica el código. El análisis SonarQube de este incremento ya se ejecutó: [resultado y alcance](../evidencias/20261030/SONARQUBE.md). La APK no forma parte de la evidencia técnica de este incremento Web.

## Notas

[Pruebas y límites de la verificación](../evidencias/20261030/RESULTADOS.md). [Acciones externas y cierre](../evidencias/20261030/ACCIONES_EXTERNAS.md). El objetivo de 150 pedidos/15 equipos se probó en el motor con datos sintéticos; no acredita todavía el límite de 45 s para el flujo completo con red y base de datos.
