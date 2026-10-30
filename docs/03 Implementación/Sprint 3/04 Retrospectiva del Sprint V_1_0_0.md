[Índice de implementación](../README.md) · [README del proyecto](../../../README.md)

# Retrospectiva del Sprint 3

**Proyecto:** EcoLogística — caso académico EcoLogística Lima; interfaz existente Huancayo. **Responsable:** Jordy Steve Chancasanampa Torres. **Sprint:** 3. **Versión:** 1.0.0. **Corte técnico:** 30/10/2026.

**Método:** análisis técnico del incremento y de las observaciones docentes. No se inventa una reunión ni acuerdos de personas ausentes. Los compromisos siguientes se proponen a Jordy para confirmar en la retrospectiva real.

## ¿Qué aprendimos?

Una geometría dibujada no demuestra una asignación factible. Deben verificarse las restricciones al calcular y al confirmar. Las pruebas detectaron además un desbordamiento de controles a 360 px; revisar solo escritorio habría dejado el defecto.

## ¿Qué estamos haciendo bien?

Se preservan originales y migraciones, se ensaya contra PostgreSQL temporal, se separa propuesta de asignación y se verifican permisos en el servidor. Se conservaron datos y la identidad visual existente.

## ¿Qué podemos hacer mejor?

### Personas

Confirmar con el responsable del producto qué historia y SP se aceptan; no convertir la actividad del desarrollador en aceptación del sprint.

### Relaciones

Mostrar una propuesta, un rechazo y una confirmación al profesor; registrar sus observaciones con fecha real y su impacto, en lugar de atribuirle comentarios supuestos.

### Procesos

Vincular cada escenario con la versión ejecutada y repetir las pruebas tras cambios. Registrar causas y prevención, no solo una lista de funciones futuras.

### Herramientas

Mantener la configuración privada del servidor fuera de los recursos Flutter; ejecutar QA aislado y SonarQube sin usar tokens del chat.

### Acciones a realizar

| Problema detectado | Causa raíz | Acción correctiva | Prevención de recurrencia | Responsable propuesto | Fecha objetivo propuesta | Indicador verificable |
|---|---|---|---|---|---|---|
| IDs y SP contradictorios entre documentos y Jira | Cambio de backlog sin correspondencia versionada | Conciliar EHAPP-13/US-005 y fechas con Jira, conservando los IDs históricos | Añadir revisión de alcance antes de cada informe | Jordy | 02/11/2026, antes del cierre | Una correspondencia aprobada y cero historias contabilizadas sin respaldo |
| .env del servidor declarado como recurso Web | Uso anterior de un único .env para dos responsabilidades | Retirar el asset y usar API_BASE_URL público como define | Inspeccionar artefactos en cada release; ignorar secretos en Git | Jordy | 30/10/2026, corrección técnica ejecutada | Artefacto de 40 archivos sin .env ni claves privadas |
| Controles desbordados a 360 px | Revisión inicial centrada en escritorio | Sustituir fila rígida por distribución que admite salto de línea | Mantener GOLD en 3 tamaños × 2 temas | Jordy | 30/10/2026, corrección técnica ejecutada | Seis recorridos aprobados sin overflow |
| Listado de rutas multiplica consultas | Serialización individual con lecturas por cada ruta | Cargar repartidores, vehículos y entregas por lotes | Mantener prueba de cantidad de consultas para evitar regresión | Jordy | 30/10/2026, corrección técnica ejecutada | Cuatro SELECT totales tanto para 1 como para 4 rutas en el ensayo |

El seguimiento se realiza con los indicadores y sus evidencias. Las fechas propuestas no reconstruyen la fecha de una ceremonia ni reemplazan compromisos que deba acordar el equipo.
