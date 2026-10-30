[README principal](../../../../README.md) | [Siguiente](02%20Registro%20de%20Impedimentos%20V_1_0_0.md)

# Informe de estado del proyecto

**Nombre del proyecto:** EcoLogística Huancayo - DistriRápido S.A.C.

**Líder del proyecto:** Jordy Steve Chancasanampa Torres

**Modalidad:** individual. **Versión documental:** 1.0.0. **Revisión de entrega:** 09/10/2026.

**Periodo del informe técnico:** 07/10/2026-09/10/2026; ejecuciones técnicas registradas el 07 y el 09/10/2026.

El documento presenta el avance técnico asociado al alcance de Sprint 1 y Sprint 2. El calendario del backlog es una línea base propuesta; las fechas de prueba identifican la evidencia real y no se atribuyen a ceremonias Scrum. La versión 1.0.0 conserva la nomenclatura de la primera entrega exigida por ambas consignas.

## Periodo del informe y alcance

| Incremento | Objetivo | Elementos de la línea base | SP planificados |
| --- | --- | --- | ---: |
| Sprint 1 | Base técnica, identidad, sesión y bloqueo progresivo | US-001; EN-001-S1, EN-002-S1, EN-007-S1, EN-003-S1 | 19 |
| Sprint 2 | Gestión válida de flota/repartidores, formularios y contrato API | US-003/004; EN-005-S2, EN-007-S2, EN-009-S2 | 19 |

El alcance detallado se conserva en [Backlog y DoD](../../../02%20Planificaci%C3%B3n/01%20Transformando%20a%20%C3%A1gil%20V_1_2_0.md). Los SP expresan planificación: el avance se informa por capacidades verificadas, sin convertir automáticamente pruebas aprobadas en SP aceptados.

## Sprint 1

### Estado del proyecto

| Variables de control | Descripción del estado al corte |
| --- | --- |
| Alcance | Acceso ADMIN y REPARTIDOR comprobado en API/Web; sesión JWT, usuario activo, autorización y filtro de propietario. RN-023 persiste en PostgreSQL y se representa con contador en Flutter. |
| Cronograma | Evidencias técnicas del 07/10/2026 consolidadas al 09/10/2026. Línea base de ejecución: 12-26/10/2026. El desarrollo preliminar se identifica por su fecha real. |
| Costos | Presupuesto de referencia del caso S/500,000; estimación profesional USD134,960, con reserva de 12%. Estos importes son presupuesto, no desembolsos ni costo ejecutado del sprint. Se mantienen en el documento de Presupuesto. |
| Calidad | Pruebas de credenciales, token vencido, inactivación, permisos, persistencia y concurrencia. Fallos 3/4/5 producen 5/10/300 s; un intento durante la espera no amplía el plazo. Análisis Flutter sin incidencias y construcción Web satisfactoria en la verificación registrada. |

### Cambios y mejoras

| Aspecto | Cambio aplicado | Resultado comprobado |
| --- | --- | --- |
| Bloqueo de acceso | Estado por identificador HMAC y bloqueo de fila en PostgreSQL | Los intentos simultáneos respetan la misma política. |
| Experiencia de login | Contador, error comprensible y botón deshabilitado durante la espera | La pantalla expresa el plazo de la API y conserva la espera al recargar. |
| Sesión | Restauración mediante /auth/me y validación del usuario activo | Un token vencido o cuenta inactiva no mantiene acceso protegido. |
| Integridad | Migraciones Alembic 0001 y 0002 | Esquema reproducible y controles añadidos conservando registros anteriores. |
| Separación técnica | Clientes en apps, API en backend y esquema en database | Un repositorio con responsabilidades identificables y configuración local excluida. |

### Riesgos

| Riesgo | Responsable | Mitigación |
| --- | --- | --- |
| Confundir login Web con validación en dispositivo | Jordy | Identificar plataforma y entorno en cada resultado; aplicar la matriz de pruebas al cliente correspondiente. |
| Aceptar una historia solo por su pantalla | Jordy | Comprobar UI, respuesta API, persistencia y permisos antes de su aceptación. |
| Diferencia entre calendario y evidencia | Jordy | Mantener fechas reales de pruebas separadas del periodo planificado. |

### Próximos avances

Consolidar la aceptación de los elementos contra BDD/DoD y asociar cada resultado a su actividad de gestión. Aplicar la misma política de acceso al cliente de repartidor y conservar el expediente por plataforma.

### Notas

RN-023: tercer fallo 5 s; siguiente fallo después de la espera 10 s; siguiente y posteriores 300 s, hasta acceso correcto. El servidor determina el plazo. Reiniciar la API o esperar no reinicia por sí solo el número de fallos.

## Sprint 2

### Estado del proyecto

| Variables de control | Descripción del estado al corte |
| --- | --- |
| Alcance | Alta, consulta, edición e inactivación de vehículos y repartidores; campos independientes de identidad, licencia, experiencia, contacto, horario y origen; documentación OpenAPI. |
| Cronograma | Capacidades verificadas el 07/10/2026 y consolidadas al corte documental. Línea base: 26/10-09/11/2026. La asignación/mapa se registra como avance adicional, sin sumar sus SP al alcance S2. |
| Costos | Se conserva la estimación del proyecto; el consumo de presupuesto se calcula con horas y comprobantes reales, separado del monto del caso. |
| Calidad | Capacidad/consumo positivos, emisiones no negativas, placa normalizada/única, DNI/correo sin duplicación, horario válido y coordenadas en rango. Lectura posterior y regresión de login/roles comprobadas. |

### Cambios y mejoras

| Aspecto | Cambio aplicado | Resultado comprobado |
| --- | --- | --- |
| Flota | Validación UI/API, placa en mayúsculas y conflictos 409 | Las altas inválidas no crean vehículos duplicados ni con capacidad cero. |
| Repartidores | Separación de DNI, licencia, categoría, experiencia, teléfono, horario y partida | Los valores se conservan en sus columnas; las cuentas y perfiles se vinculan por usuario_id. |
| Formularios | Etiquetas, ayudas, foco visible, botones y distribución adaptable | Pruebas de distribución a 360×640, 768×1024, 1440×900 y 1200×500. |
| Contrato | Esquemas Pydantic, códigos HTTP y guía de uso | Swagger describe los endpoints disponibles y los errores esperados. |

### Riesgos

| Riesgo | Responsable | Mitigación |
| --- | --- | --- |
| Datos históricos distintos de las reglas nuevas | Jordy | Preservar los registros, revisar su calidad y aplicar correcciones con datos reales. |
| Confundir horario registrado con factibilidad de ruta | Jordy | Separar validación del formulario y evaluación temporal de una asignación. |
| Dependencia del proveedor cartográfico | Jordy | Timeout y error controlado; la asignación se confirma en una transacción completa. |

### Próximos avances

Ejecutar la demostración por escenarios ADMIN/REPARTIDOR, revisar los criterios de accesibilidad y continuar el roadmap desde la gestión de datos hasta la optimización sostenible.

### Notas

La base de demostración conserva datos sintéticos etiquetados. Los tiempos del mapa son estimaciones del recorrido planificado. [Verificación técnica](../../evidencias/VERIFICACION_TECNICA.md) y [asignación/mapa](../../evidencias/ASIGNACION_Y_MAPA.md) contienen el soporte de este informe.

## Consolidación técnica de ambos incrementos — 09/10/2026

| Control | Resultado del corte |
| --- | --- |
| Sprint 1 | Identidad ADMIN/REPARTIDOR, sesión, permisos y bloqueo 5/10/300 s comprobados en API/Web. Migraciones 0001–0004 y fuentes organizadas en el repositorio. |
| Sprint 2 | CRUD de vehículos y repartidores, campos independientes, validaciones y documentación API comprobados. Interfaz clara/oscura adaptable, modales y menú expandible actualizados. |
| Regresión | 29 pruebas Flutter, 9 pruebas API aisladas, análisis estático y compilación Web. Los conjuntos son transversales; no se suman dos veces ni equivalen a SP aceptados. |
| Demostración adicional | 6 vehículos de 20 a 3000 kg, 6 repartidores, 20 pedidos y 20 rutas diferentes añadidos. Totales locales: 7 vehículos, 8 repartidores, 22 pedidos y 21 rutas. Datos ficticios, pedidos ASIGNADOS y rutas PLANIFICADAS. |
| Entrega | apps/web, apps/mobile, backend y database alineados con las fuentes actuales. Los registros viven en PostgreSQL local; schema.sql distribuye estructura, sin exportar usuarios ni contraseñas. |

[Pruebas y capturas actuales](../../evidencias/REVISION_UI_Y_PRUEBAS_20261009.md) · [Conjunto de demostración](../../evidencias/DATOS_DE_PRUEBA_20261009.md).

## Ajuste de alcance y disponibilidad — 09/10/2026

US-002 móvil (3 SP) se traslada a Sprint 3 por decisión del responsable; S1/S2/S3 quedan en 19/19/22 SP. La base de identidad API/Web permanece en S1 y no se duplica el esfuerzo. El cierre S1 ya no incluye una demostración de APK.

US-004 incorpora validación efectiva de la asignación: fecha y hora de salida, fin calculado con viaje y atención, turno completo del repartidor y rechazo de cruces del repartidor o vehículo. La API serializa solicitudes y no modifica pedidos al rechazar. Las rutas antiguas requieren registrar su horario mediante el calendario de Rutas. [Funcionamiento, pruebas y límites](../../evidencias/DISPONIBILIDAD_20261009.md).

## Historial de control de cambios

| Versión | Fecha | Responsable | Cambio |
| --- | --- | --- | --- |
| 1.0.0 | 07/10/2026 | Jordy Steve Chancasanampa Torres | Primera redacción de alcance, controles y criterios S1/S2. |
| 1.0.0, revisión de entrega | 09/10/2026 | Jordy Steve Chancasanampa Torres | Consolidación de S1/S2 con fuentes sincronizadas, 29 pruebas Flutter, 9 API, mejoras UI y conjunto ficticio de 20 rutas. |

[README principal](../../../../README.md)
