[README principal](README.md) | [Guía de ajustes y cierre](GUIA_DE_AJUSTES_Y_CIERRE.md)

# Registro de revisión documental

**Responsable:** Jordy Steve Chancasanampa Torres. **Fecha:** 07/10/2026. **Versión:** 1.1.0.

## Alcance y cambios

Se revisaron los 17 documentos separados de Inicio/Planificación y los cuatro de Implementación. La línea base distingue diseño, planificación y resultados de ejecución; la guía centraliza los ajustes y evidencias de cierre para evitar observaciones repetidas dentro de cada archivo.

| Área | Cambio |
| --- | --- |
| Requisitos y usuarios | Roles/canales, campos y autorización; RN-023 incorporado a login ADMIN/REPARTIDOR y futuro CLIENTE |
| Login | Tercer fallo 5 s, cuarto 10 s, quinto/posteriores 300 s; contador, persistencia, concurrencia y reinicio tras éxito |
| Calidad y pruebas | Criterios 5/10/300 s en RNF-02, US-001/002, EN-003-S1 y casos S1/S2 |
| Datos/C4 | control_acceso y secuencia API/BD/cliente; migración y estado atómico |
| Calendario/Jira | Propuesta 12/10/2026-18/01/2027; S1 22 SP y S2 19 SP; equivalencias, campos y Fix Version |
| Implementación | Periodos, alcance, cambios/mejoras, impedimentos, demo/aceptación y acciones por sprint |
| Evidencias | Tareas Jira/Figma/software y capturas históricas reunidas en guía |
| Navegación | README, cuatro nombres exactos, retorno, historial y enlaces relativos |

## Decisiones mantenidas

EcoLogística Huancayo es nombre de propuesta; Lima es escenario contractual. Flutter se justifica como adaptación, FastAPI/PostgreSQL mantienen la base. Web incluye preferencias CLIENTE RF-09; móvil corresponde a REPARTIDOR. Algoritmo genético backend, OSRM como proveedor de recorridos. Reglas simuladas del caso y normas verificadas se distinguen en Restricciones. Versiones de documentos y release del producto son independientes.

## Verificación y límites

Revisión de nombres, UTF-8, tablas, enlaces, IDs, BDD, totales SP/presupuesto, calendario y trazabilidad RN-023. Las imágenes se conservaron y el software no se modificó. Los documentos definen un plan detallado; resultados de pruebas/demos/cierre se incorporan al ejecutar. No se realizaron commits, push ni cambios en Jira/Figma.

## Continuación

Seguir [la guía de ajustes y cierre](GUIA_DE_AJUSTES_Y_CIERRE.md): configurar Jira, ajustar imágenes, corregir software, probar, registrar feedback y actualizar resultados de los cuatro documentos. Esta guía conserva lo que falta hacer y el criterio para dar cada acción por terminada.

[README principal](README.md)
