# EcoLogística Huancayo · validación final del Sprint 3

## Comparación del caso DEMO

La ruta `16e23300-c351-4b13-97c6-c15d4701aece` recibió un reporte manual de congestión desde Android el 8 de noviembre de 2026. La bandeja ADMIN mostró el aviso sin F5. La administración abrió el comparador, revisó las geometrías y aprobó la versión 2 a las 10:09:47, hora Perú. El servidor guardó el acuse del repartidor a las 10:09:59.

| Evidencia | Resultado |
| --- | --- |
| Geometría original | 165 puntos |
| Geometría de la propuesta | 87 puntos, 85 compartidos con la original |
| Ruta vigente recalculada desde la ubicación actual | 4,0404 km y 19,10 min |
| Alternativa para las dos paradas pendientes | 4,0404 km y 19,10 min |
| Consulta de matriz | Una solicitud al proveedor, sin acierto de caché |
| Demora manual | 3 min aplicados a la salida de las dos opciones |

La geometría roja abarca el recorrido anterior y la verde parte de la ubicación confirmada para las entregas pendientes. Las dos opciones calculadas para ese mismo tramo pendiente conservan el orden Plaza Huamanmarca → Plaza de la Constitución. El tiempo incluye la atención en parada. El color verde identifica la propuesta, que resultó factible con las estimaciones vigentes.

El proveedor OSRM aporta distancias y tiempos de red vial. El punto de incidencia y la demora manual no identifican qué calle debe evitarse. Por eso se incorpora una espera común al iniciar el cálculo y no se atribuye un desvío ni un ahorro. El código aplica aparte las franjas zonales configuradas cuando corresponden. La geometría de la propuesta coincide con la activa después de aprobar.

La corrección muestra **Sin mejora estimada: mismo tiempo y misma distancia** cuando las diferencias redondeadas a la precisión de la interfaz son cero. Cuando una opción recorre más distancia y tarda menos, presenta ambas diferencias. Este último caso se cubrió con datos controlados en Flutter. No se observó una ventaja de tiempo en el recorrido real de demostración.

[Captura roja y verde](danleo-comparacion-rojo-verde.png) · [Métricas del cálculo](danleo-comparison-analysis.json) · [Guía de exposición](GUIA_EXPOSICION_DANLEO.md).


## Verificación por flujo

| Estado | Prueba y resultado |
| --- | --- |
| APROBADO | Web ADMIN generó y asignó recorridos viales de Huancayo. Recibió la incidencia reportada por Android, abrió el comparador y aprobó la versión 2. La comparación real se capturó el 08/11. |
| APROBADO | Android del repartidor mostró la ruta v2 recibida. La API registró el acuse 2. La prueba retomó la ruta con dos entregas hechas y confirmó únicamente la tercera. Quedó FINALIZADA con tres pedidos únicos, con el historial v1 y la fecha original de la primera entrega. |
| APROBADO | Web REPARTIDOR mostró el recorrido propio a cada cuenta. Pepe recibió, inició y finalizó WQX-972 v1 desde la web. La API devuelve 404 al solicitar la ruta ajena y 403 si ADMIN intenta iniciar la ruta como repartidor. |
| PARCIAL | Android conservó la sesión y la última consulta disponible al perder la conexión. Tras quitar el modo avión, una lectura directa a la API agotó el tiempo de espera. La recuperación completa debe volver a comprobarse. |
| PARCIAL | El mensaje explícito de empate pasó 8 pruebas específicas y la regresión pasó 83 pruebas Flutter. El análisis estático quedó limpio y la web compiló. El contenedor web activo conserva el comparador anterior ya verificado. El nuevo texto aún no se desplegó. |
| APROBADO | La regresión backend del 08/11 reportó 127 pruebas aprobadas y 90,88 % de cobertura. No se ejecutó de nuevo porque este cambio se limita al texto de comparación de Flutter. |
| PENDIENTE | Validar Android con la segunda cuenta y completar la recuperación en el emulador. Probar el mensaje nuevo en la web desplegada. |
| BLOQUEADO | Validación en teléfono físico y distribución release. El teléfono se detectó al final. La APK debug compilada apunta al host especial del emulador y queda pendiente comprobar el flujo desde el teléfono con una URL accesible. |

La comprobación actual se concentró en rutas, versiones, entregas y permisos. Las comprobaciones de flota, repartidores y pedidos quedan referenciadas en las evidencias previas. Pedidos admite registro y consulta en el alcance comprobado.

[Web ADMIN](danleo-admin-web.png) · [Aviso recibido](danleo-aviso-admin.png) · [Aprobación](danleo-aprobada-admin.png) · [Acuse en Android](danleo_android_02_version_recibida.png) · [Ruta finalizada](danleo_android_06_finalizada_historial.png) · [Desconexión en Android](danleo_android_07_desconexion_sin_perder_sesion.png) · [Ruta propia de Pepe](danleo-pepe-finalizada.png).

## Resultado para la revisión

El flujo principal de reoptimización y confirmación de entregas se puede demostrar con las evidencias del 08 y 09 de noviembre. El cierre completo de Android queda sujeto a comprobar de nuevo la recuperación de red y el segundo acceso en el emulador. Los datos de la demostración corresponden a QA y emplean placas y pedidos sintéticos con destinos públicos de Huancayo.

La API QA se reinició después de completar la ruta. Las lecturas autenticadas antes y después coincidieron en los datos de ambas rutas, las entregas, las revisiones y las incidencias. WQX-971 permaneció FINALIZADA, versión 2, acuse 2 y tres entregas. WQX-972 permaneció FINALIZADA, versión 1, acuse 1 y una entrega. Tras la prueba se reactivó la API operativa y se comprobó que las huellas de sus tablas coincidían con la referencia inicial de esta sesión. Se conservaron los recursos Docker existentes.

[Comparación antes y después del reinicio](danleo-state-after.json).

En la API operativa se verificó el acceso de admin@danleo.com con rol ADMIN y el de repartidor@danleo.com y pepe@danleo.com con rol REPARTIDOR. La contraseña suministrada para cada cuenta se comprobó contra su hash. La web, FastAPI y PostgreSQL reportaron estado saludable al cierre.

## APK debug

La APK normal del 09/11 se compiló desde lib/main.dart, pasó la verificación de firma v2, se instaló y arrancó en el emulador. El flujo de entregas se comprobó con el ejecutable de integración sobre las mismas fuentes. La APK debug usa http://10.0.2.2:8000/api/v1 para acceder desde el emulador. Se conserva fuera del repositorio en D:/UC/App/ecologistica/build/apk/ecologistica-huancayo-danleo-20261109-debug.apk.

SHA-256 `D14B2D60571F2CD8F97754E438CDDE965211BBC1FD60441F627D612601BB7F80`.
