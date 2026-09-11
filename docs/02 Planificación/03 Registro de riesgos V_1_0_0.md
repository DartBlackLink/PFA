[← Volver al README principal](../../README.md)

# Registro de Riesgos

## 1. Metadatos

| Campo | Información |
|---|---|
| Proyecto | EcoLogística Lima |
| Integrante | Jordy Steve Chancasanampa Torres |
| Versión | 1.0.0 |
| Método | Probabilidad × Impacto |

## 2. Objetivo

Consolidar los riesgos principales del MVP sin convertir el registro en una lista excesiva. Se priorizan los riesgos capaces de comprometer plazo, funcionalidad, calidad o demostración académica.

## 3. Escala

**Severidad = Probabilidad (1 a 5) × Impacto (1 a 5)**

| Severidad | Nivel |
|---:|---|
| 1-6 | Low |
| 8-12 | Medium |
| 15-25 | High |

## 4. Matriz de riesgos

| ID | Descripción del riesgo | Categoría | P | I | Severidad | Nivel | Plan de Mitigación (Preventivo) | Plan de Contingencia (Reactivo) | Responsable |
|---|---|---|---:|---:|---:|---|---|---|---|
| RSK-01 | Crecimiento del alcance por intentar implementar todas las capacidades documentadas. | Gestión / Alcance | 5 | 5 | 25 | High | Aplicar MoSCoW; bloquear nuevas funciones mientras exista un Must incompleto; revisión semanal. | Mover Should/Could a Post-MVP y proteger el flujo mínimo de demostración. | Project Manager / Developer |
| RSK-02 | El motor de optimización no alcanza tiempo o calidad de solución aceptable. | Técnica / Algoritmo | 4 | 5 | 20 | High | Implementar primero un Algoritmo Genético simple; medir con datasets crecientes. | Simplificar parámetros, limitar escenario de demo y documentar limitaciones sin cambiar de metaheurística a último momento. | Developer |
| RSK-03 | La capacidad de un único integrante resulta insuficiente para desarrollo, pruebas y documentación. | Recursos / Tiempo | 4 | 5 | 20 | High | Mantener baja carga inicial; reservar tiempo semanal para pruebas/documentación; WIP 1-2 historias. | Recortar historias Should y concentrarse en el camino crítico. | Project Manager |
| RSK-04 | Datos geográficos o direcciones no estandarizadas impiden ubicar pedidos. | Datos | 4 | 4 | 16 | High | Validar coordenadas y usar puntos de referencia; preparar dataset limpio. | Permitir corrección/carga manual de coordenadas para demo. | Developer |
| RSK-05 | API de tráfico no disponible, cambia condiciones o requiere pago. | Integración / Costos | 4 | 3 | 12 | Medium | Adaptador desacoplado; no hacer del tráfico en vivo una dependencia del núcleo. | Usar tráfico simulado o carga manual con el mismo contrato interno. | Developer |
| RSK-06 | Vulnerabilidad o error de autorización expone información u operaciones. | Seguridad | 3 | 5 | 15 | High | Autorizar en backend, validar entradas, secretos fuera del repo y pruebas negativas. | Bloquear función afectada, corregir acceso y repetir pruebas antes de demo. | Developer / QA |
| RSK-07 | Integración frontend-backend-base de datos produce defectos tardíos. | Técnica / Integración | 3 | 4 | 12 | Medium | Integrar desde Sprint 1 y usar contratos OpenAPI. | Congelar funciones nuevas y corregir primero el flujo principal. | Developer |
| RSK-08 | Mapas o tiles externos no disponibles durante la demostración. | Dependencia externa | 2 | 3 | 6 | Low | Verificar disponibilidad antes de la demo y evitar dependencias cartográficas innecesarias. | Mostrar resultados tabulares/rutas persistidas y reintentar proveedor. | Developer |
| RSK-09 | Pruebas y documentación quedan relegadas al final. | Calidad / Académico | 4 | 4 | 16 | High | Aplicar DoD desde Sprint 1; actualizar pruebas, Swagger y documentos con cada historia. | Detener Should/Could y dedicar el cierre a evidencia, correcciones y documentación obligatoria. | Project Manager / QA |
| RSK-10 | Costos de nube, dominio o servicios superan lo previsto. | Económico | 2 | 3 | 6 | Low | Priorizar herramientas gratuitas/open source y revisar consumo. | Migrar a plan gratuito/local o eliminar dependencia no esencial. | Project Manager |

## 5. Priorización

Los riesgos `RSK-01`, `RSK-02`, `RSK-03`, `RSK-04`, `RSK-06` y `RSK-09` son High y reciben atención prioritaria. `RSK-05` y `RSK-07` se revisan al cierre de cada Sprint. `RSK-08` y `RSK-10` se monitorean sin consumir capacidad innecesaria.

## 6. Revisión

- revisar riesgos al cierre de cada Sprint;
- recalcular P e I cuando cambien las condiciones;
- registrar nuevos riesgos solo si requieren respuesta concreta;
- cerrar un riesgo cuando desaparezca su causa;
- cualquier riesgo que amenace un Must puede provocar repriorización inmediata.

## 7. Criterio de control

El registro se considera saludable cuando todos los riesgos High poseen responsable y acción preventiva en curso.

[← Volver al README principal](../../README.md)
