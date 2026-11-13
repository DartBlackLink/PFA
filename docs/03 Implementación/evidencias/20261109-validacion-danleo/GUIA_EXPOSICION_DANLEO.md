# Guía de exposición de EcoLogística Huancayo

Usa las tres cuentas locales del encargo. Introduce las claves en el formulario de acceso. La base QA contiene los perfiles, las placas ficticias y los pedidos de la demostración. Los destinos corresponden a puntos públicos que devolvió Photon. Los pesos, nombres de cliente y entregas son simulados.

## Preparar la demostración

Desde `C:\Users\jordy\OneDrive\Documentos\ChatGPT\Ecologistica`, ejecuta `python verificacion_integral_20261104/danleo_runtime.py qa`. El comando usa el contenedor QA existente y la misma dirección web `http://127.0.0.1:8080/#/login`. Al finalizar ejecuta `python verificacion_integral_20261104/danleo_runtime.py operativa` para devolver el puerto a la base operativa.

Para un recorrido en vivo, registra tres pedidos DEMO con ventanas vigentes. Busca Plaza de la Constitución, Plaza Huamanmarca y Parque de la Identidad Huanca. Selecciona cada coincidencia, revisa el distrito y confirma el punto en el mapa. La ruta ya finalizada sirve para presentar el historial sin volver a registrar entregas.

## Secuencia de pantallas

1. Entra como `admin@danleo.com`. Abre **Rutas → Optimizar rutas**. Selecciona los tres pedidos, añade **Repartidor DEMO 1** y la furgoneta **WQX-971**. Revisa la fecha y la ventana. Pulsa **Generar propuesta**, luego **Revisar mapa de la propuesta** y **Confirmar y asignar pedidos**.
2. Entra como `repartidor@danleo.com`. Abre **Recorrido · WQX-971**. Confirma la recepción e inicia el recorrido. Confirma una entrega desde su parada y conserva el resto pendiente.
3. Con el vehículo simulado detenido, pulsa **Reportar incidencia de tráfico**. Registra una descripción DEMO, demora estimada y una ubicación confirmada. Guarda la incidencia.
4. En ADMIN, abre **Notificaciones de operación**, abre el aviso de incidencia y pulsa **Evaluar reoptimización**. Confirma la ubicación actual del vehículo detenido. Pulsa **Calcular alternativa** y abre **Comparar en mapa**.
5. Señala la línea roja del recorrido reportado, el marcador del reporte y la alternativa verde. Lee los estados y versiones en la leyenda. Compara los tiempos y distancias de las paradas pendientes. Si el sistema rechaza el recálculo, muestra su motivo y revisa la ruta vigente.
6. Vuelve al panel de la ruta y pulsa **Aprobar y enviar ruta optimizada**. Confirma la decisión en el diálogo. El historial muestra la versión nueva y el acuse pendiente.
7. En el repartidor, abre la actualización y revisa la ruta verde. Pulsa **Confirmar recepción de nueva ruta** y termina las paradas restantes en orden. Comprueba que el historial mantiene la primera entrega y muestra la versión 2 recibida.
8. Entra como `pepe@danleo.com`. Su equipo DEMO corresponde a la camioneta **WQX-972**. Comprueba que la ruta del primer repartidor queda fuera de su lista. ADMIN puede ver ambos equipos.

El fondo del mapa necesita acceso a OpenStreetMap. Las líneas vienen de la geometría vial que devuelve el motor. La congestión procede del reporte del repartidor. La línea roja señala el recorrido reportado y el marcador indica el punto comunicado. La extensión del tramo congestionado requiere datos adicionales.

La capacidad se valida en kilogramos. La versión actual no modela volumen ni dimensiones en los formularios. El proveedor OSRM usado en la demo calcula con su perfil vial disponible. La accesibilidad específica de una motocicleta requiere un perfil validado para esa categoría. Las placas DEMO son identificadores sintéticos con formatos de ejemplo por clase. Consulta el [reglamento de placa de rodaje](https://www.gob.pe/institucion/mtc/normas-legales/10021-017-2008-mtc) y las [medidas para vehículos menores](https://www.gob.pe/institucion/mtc/normas-legales/7584589-021-2025-mtc).

| Vehículo sintético | Carga máxima | Consumo del escenario | Dimensiones útiles aproximadas del escenario |
| --- | --- | --- | --- |
| Furgoneta WQX-971 | 650 kg | 10 km/L | Caja de 2,1 × 1,4 × 1,3 m |
| Camioneta WQX-972 | 420 kg | 12 km/L | Tolva de 1,5 × 1,4 × 0,45 m |
| Motocicleta WQX-9703 | 40 kg | 30 km/L | Caja de 0,45 × 0,40 × 0,38 m |

Las dimensiones describen los vehículos inventados para la exposición. El cálculo actual usa peso, consumo, disponibilidad, horario y estado activo. La motocicleta queda disponible en la flota de prueba.

## Rotación local

Con la API operativa activa, ejecuta `python tools/deploy/rotar_acceso_demo.py CORREO` desde la fuente principal. Introduce la nueva clave dos veces en el prompt oculto. El comando modifica el hash de la cuenta elegida y conserva sus relaciones. Las sesiones ya emitidas siguen su vencimiento original. Rota las claves iniciales antes de usar las cuentas fuera de la exposición local.
