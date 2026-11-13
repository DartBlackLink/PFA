# Estabilización EcoLogística Huancayo — 03/11/2026

## Resultado comprobado

La web principal **8080**, FastAPI **8000** y PostgreSQL se verificaron con un caso QA identificable y separado de los registros anteriores. El administrador generó y confirmó una planificación genética de tres destinos públicos de Huancayo. Android inició el recorrido, guardó una entrega y reportó congestión simulada con GPS emulado del Parque de la Identidad Huanca. El administrador recibió el aviso, abrió el detalle, comparó el mapa y aprobó una alternativa para las **dos entregas pendientes**. Android confirmó la recepción de la versión 2 y completó las tres entregas sin duplicados.

**Ruta:** `045076c1-d16c-4f2b-ba14-5a74a59ad97f`, vehículo QA `HYO-CONT-03`. Resultado persistente: `FINALIZADA`, versión `2`, recibida `2`, tres pedidos distintos. La primera entrega conserva `2026-11-04T04:13:44.510019+00:00` (03/11, 23:13 Perú). La API se reinició y se compararon los datos e historial completos antes/después: idénticos. La web del repartidor volvió a consultar ese estado después del reinicio.

El recorrido inicial midió 7,469 km. La comparación correcta de **pendientes desde la posición actual** dio 4,04 km/11,10 min tanto en la secuencia vigente como en la alternativa: **diferencia cero**. No se atribuye ahorro a la reoptimización. Los tiempos son estimados; el reporte de congestión es QA, no tráfico observado en vivo. Zona horaria `America/Lima`.

## Correcciones realizadas

| Problema observado | Corrección y comprobación |
|---|---|
| El mapa reutilizaba recursos ya desmontados al desplazarse por el detalle | Componente con controlador y proveedor propios, conservación de estado y callbacks posteriores al frame. Regresión de tres desplazamientos, cambio de geometría y una sola liberación; recorrido real Android y Web revisados. |
| Etiquetas desbordadas a 360 px con texto al 200 % | Texto flexible dentro de la insignia. Pruebas en claro/oscuro, móvil, tableta y escritorio. |
| Panel repartidor poco claro y refrescos que sustituían la consulta | Resumen de activos/pendientes/versiones, perfil plegable y filtros. Se conserva la última consulta ante desconexión y se recupera sin perder la sesión; comprobado en Android. |
| Android no disponía del mecanismo nativo de ubicación utilizado por el formulario | Canal nativo de ubicación en primer plano, permisos, espera acotada y cancelación. Se obtuvo una fijación nueva en el emulador de Huancayo. No equivale a probar precisión física ni seguimiento continuo. |
| Fuentes preparadas podían confundirse con aplicación activa | Copias verificadas por SHA a D/PFA; web principal desplegada desde `D:\UC\App\ecologistica\build\web-principal-20261103`. Contenedores anteriores y respaldos preservados. |

El caso anterior `HYO-E2E-03` mantiene su primera entrega de las 09:47 Perú y su incidencia. Tras la interrupción de unas trece horas, el servidor rechazó correctamente su replanificación por jornada agotada. **No se alteraron tiempos ni límites para hacerla aprobar.** Por ello se creó el caso independiente con ventanas vigentes hasta las 23:58. El pedido histórico sin coordenadas también se conserva sin inventar su ubicación.

## Pruebas ejecutadas en este corte

| Verificación | Resultado real |
|---|---|
| Backend sobre PostgreSQL QA desechable | **127 aprobadas**, 82,74 s; una advertencia de obsolescencia del cliente de pruebas, sin fallos. |
| Flutter, regresión completa | **81 aprobadas**, aproximadamente 25 s. No incluye las pruebas nativas de integración. |
| Analizador final Flutter | **Sin incidencias**, 8,7 s, incluyendo los tests de continuación. |
| Android, API 36 oficial en emulador independiente | Un caso compuesto de continuación aprobado: recepción v2, entregas únicas, preservación, desconexión, recuperación y logout. La salida `+2` incluye el cierre de la instrumentación; no son dos recorridos distintos. |
| Permisos reales en API principal desde Android | Solo su ruta; acceso a flota rechazado 403 y ruta ajena 404. |
| Web principal ADMIN | Planificación/mapa/confirmación, incidencia/replan/aprobación, validación de flota vacía, alta/edición/inactivación de vehículo QA y edición de contacto QA. |
| Web principal REPARTIDOR | Login, ruta propia finalizada, filtro Historial, modo oscuro y mapa a 360 px; lectura tras reinicio. Las escrituras del caso de este corte se realizaron en Android. |
| Persistencia | Reinicio real de FastAPI, comparación íntegra de rutas, entregas, incidencia y revisiones; sin diferencias. |
| Bandit / pip-audit | Cero hallazgos Bandit y cero vulnerabilidades conocidas en los requisitos Python auditados. No acredita seguridad absoluta ni auditoría de todas las dependencias móviles. |

El flujo se verificó por tramos conservando lo ya persistido. Los intentos monolíticos no obtuvieron un pase completo: detectaron el defecto del mapa y también problemas del test (coordenadas iniciales del emulador, espera de carga, controles fuera de pantalla y codificación). Se conservaron sus registros; no se borraron datos ni se rebajaron restricciones. La continuación aprobada está en `android-receive.log` y sus fases en `native-continuity-phases.json`.

## Cobertura y SonarQube

Coverage.py midió **2261/2410 líneas** y **478/604 ramas** del backend y sus migraciones. Combinada: `(2261 + 478) / (2410 + 604) × 100 = 90,87591240875912408759124088 %`, redondeada **90,88 %**. No es cobertura de todo el proyecto ni calificación académica; Flutter/Android no están incluidos en ese porcentaje.

Informe HTML (archivo local de auditoría: `index.html`) · [XML real](coverage.xml) · [Detalle por módulo](COBERTURA.md) · [JUnit](test-results.xml).

SonarQube se restauró tras las pruebas Android. **No se ejecutó un análisis nuevo:** el archivo local con token no estaba disponible al cierre. El 91,4 % histórico no se atribuye a esta versión.

## APK y alcance de entrega

Se compiló, instaló y abrió una APK normal desde `lib/main.dart`, independiente de la instrumentación. Es **debug para emulador**, API `http://10.0.2.2:8000/api/v1`. No incluye las contraseñas QA ni el control efímero de integración. Ruta local de entrega: `D:\UC\App\ecologistica\build\apk\ecologistica-huancayo-debug.apk`. Huella en [APK.json](APK.json). No se probó un teléfono físico ni una APK release firmada con HTTPS.

Las fuentes y pruebas verificadas se sincronizaron con PFA. No se publicó en GitHub ni se modificó Jira. Sprints 1 y 2 y los cortes históricos se conservaron. Consultar [archivos](ARCHIVOS.md), [guía manual](GUIA_MANUAL.md) y [acciones restantes](PENDIENTES.md). **No se declara el cierre formal del Sprint 3.**
