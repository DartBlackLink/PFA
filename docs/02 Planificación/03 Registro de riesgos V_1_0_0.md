[← Volver al README Principal](../../README.md)

# 03 Registro de riesgos

## 1. Metadatos

| Campo | Valor |
|---|---|
| Proyecto | **EcoLogística Huancayo - Optimizador de Rutas Sostenibles para DistriRápido S.A.C.** |
| Integrante | **Jordy Steve Chancasanampa Torres** |
| Fecha | **27/09/2026** |
| Versión | **1.0.0** |

## 2. Método

**Severidad = Probabilidad (1-5) × Impacto (1-5)**

- Probabilidad: 1 muy baja → 5 muy alta.
- Impacto: 1 insignificante → 5 catastrófico.
- Clasificación usada por la consigna: Low 1-6; Medium 8-12; High 15-25.

## 3. Matriz de riesgos

| ID | Descripción | Categoría | Prob. | Imp. | Severidad | Mitigación preventiva | Contingencia reactiva | Responsable |
|---|---|---|---:|---:|---|---|---|---|
| RSK-01 | El optimizador supera 45 s con 150 pedidos/15 vehículos. | Técnica | 4 | 5 | 20 (Alta) | Benchmark temprano, perfilado y optimización incremental. | Reducir complejidad del escenario, ajustar metaheurística o usar estrategia alternativa manteniendo criterios de aceptación. | Responsable del proyecto |
| RSK-02 | Servicio de mapas/tráfico no disponible o limitado. | Integración | 3 | 4 | 12 (Media) | Adaptador desacoplado, control de timeouts y pruebas con mocks. | Operar con datos disponibles y carga manual prevista por la consigna. | Responsable del proyecto |
| RSK-03 | Direcciones o coordenadas insuficientes. | Datos | 4 | 4 | 16 (Alta) | Validación de coordenadas y puntos de referencia. | Solicitar corrección del pedido o usar punto de referencia válido. | Responsable del proyecto |
| RSK-04 | Aumento de alcance durante el curso. | Gestión | 4 | 4 | 16 (Alta) | Backlog priorizado y control de cambios. | Replanificar, diferir elementos no obligatorios y preservar RF-01 a RF-07. | Responsable del proyecto |
| RSK-05 | Vulnerabilidad crítica antes de release. | Seguridad | 3 | 5 | 15 (Alta) | Análisis estático, dependencias actualizadas y pruebas OWASP. | Bloquear release, corregir y ejecutar regresión. | Responsable del proyecto |
| RSK-06 | Pérdida/corrupción de datos de desarrollo. | Datos | 2 | 5 | 10 (Media) | Migraciones, backups y repositorio de scripts. | Restaurar backup y reconstruir desde migraciones. | Responsable del proyecto |
| RSK-07 | Sobrecarga por equipo unipersonal. | Recursos | 5 | 4 | 20 (Alta) | Limitar WIP y priorizar por valor/riesgo. | Reducir alcance no obligatorio y renegociar secuencia con evidencia. | Responsable del proyecto |
| RSK-08 | Errores de integración frontend-backend. | Técnica | 3 | 3 | 9 (Media) | Contratos OpenAPI y pruebas de integración. | Congelar contrato afectado y corregir mediante prueba de regresión. | Responsable del proyecto |
| RSK-09 | Incumplimiento de accesibilidad. | Calidad | 3 | 3 | 9 (Media) | Checklist WCAG desde componentes base. | Corregir componentes y repetir auditoría. | Responsable del proyecto |
| RSK-10 | Estimación de costos se desvía del marco del MVP. | Financiera | 2 | 4 | 8 (Media) | Control de presupuesto y preferencia por tecnologías abiertas. | Reasignar partidas y usar reserva de contingencia. | Responsable del proyecto |
| RSK-11 | Modelo de datos requiere cambios tardíos. | Arquitectura | 3 | 4 | 12 (Media) | Revisión de requisitos y migraciones versionadas. | Aplicar migración compatible y actualizar trazabilidad. | Responsable del proyecto |
| RSK-12 | La solución optimizada es válida pero no mejora la línea base. | Algoritmo | 3 | 5 | 15 (Alta) | Definir baseline secuencial y métricas desde pruebas iniciales. | Ajustar función objetivo/parámetros o evaluar otra metaheurística permitida. | Responsable del proyecto |

## 4. Priorización

### Riesgos altos
RSK-01, RSK-03, RSK-04, RSK-05, RSK-07 y RSK-12.

### Riesgos medios
RSK-02, RSK-06, RSK-08, RSK-09, RSK-10 y RSK-11.

## 5. Disparadores de seguimiento

- Benchmark > 80% del límite de 45 s.
- Error de API externa repetido.
- Más de una historia bloqueada por dependencia.
- Vulnerabilidad alta/crítica.
- Cambio de requisito obligatorio.
- Desviación de presupuesto > 10%.
- Sprint con más del 30% de SP no terminados.
- Métrica de accesibilidad o disponibilidad por debajo del objetivo.

## 6. Revisión

El registro se revisará durante Sprint Planning, semanalmente durante ejecución y obligatoriamente en Sprint Review/Retrospective cuando un riesgo se materialice o cambie de exposición.
