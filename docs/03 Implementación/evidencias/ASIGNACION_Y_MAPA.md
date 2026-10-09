# Asignación de pedidos y recorrido — 07/10/2026

## Funcionamiento implementado

1. Registrar un pedido con dirección, latitud/longitud de entrega, referencia, cliente, peso, producto, prioridad y ventana horaria.
2. Registrar un repartidor activo con cuenta y punto de partida; registrar un vehículo activo con capacidad suficiente.
3. En Rutas → Asignar pedidos, seleccionar repartidor, vehículo y entre 1 y 20 pedidos pendientes. El orden de selección determina el orden de las entregas.
4. Guardar: la API valida datos y exclusividad, consulta el recorrido vial, guarda la geometría y las paradas, y cambia los pedidos a ASIGNADO en una misma transacción.
5. Abrir una ruta: tanto ADMIN como su REPARTIDOR consultan el mismo recorrido y los detalles. Un repartidor ajeno recibe 404 al solicitar ese recurso.

El punto azul identifica la partida; los marcadores numerados identifican las entregas; la línea verde representa el trazado por calles. Actualizar vuelve a consultar la asignación guardada. La duración es una estimación sin tráfico en tiempo real.

## Datos de demostración

Se añadió un ejemplo persistente etiquetado como demostración, sin reemplazar los registros anteriores: cuenta repartidor@ecologistica.com vinculada a Repartidor de demostración; vehículo DEMO-001; pedido Entrega de demostración. DNI 00000001, licencia DEMO-001 y teléfono 000000000 son valores ficticios de prueba y deben sustituirse por información real al operar. El origen/destino son coordenadas de ejemplo en Huancayo. No es una entrega real.

Ruta de prueba: 2.709 km, 5.52 minutos estimados y un pedido. El proveedor vial devolvió 57 puntos de geometría. Las dos cuentas existentes conservan sus contraseñas locales. Este ejemplo permite comprobar la vista Web del repartidor.

## Verificación

8 pruebas de integración API aprobadas, incluyendo conservación de asignaciones, consulta por propietario, rechazo de duplicados/coordenadas/peso, concurrencia y fallo del proveedor sin asignar el pedido. Para estas pruebas se usó una base aislada y un proveedor HTTP simulado; el proveedor real se verificó por separado con el recorrido de ejemplo. Las 11 pruebas Flutter también pasaron; análisis sin incidencias y compilación Web completada. Evidencias visuales tras la comprobación en navegador: ruta-admin.jpg y ruta-repartidor.jpg.

La migración 0003 agrega origen y geometría a ruta, más un índice; no elimina registros. Respaldo previo: C:\Users\jordy\OneDrive\Documentos\ChatGPT\Ecologistica\tmp\rutas\respaldo\ecologistica_antes_rutas.dump.

## Condiciones del recorrido verificado

La asignación es manual y el orden de selección determina las paradas. Se validan recursos activos, coordenadas, estado del pedido y capacidad por peso. El mapa muestra el recorrido planificado; actualizar consulta el registro guardado. La dirección y las coordenadas se ingresan explícitamente y deben corresponder al mismo destino.

El cálculo de recorrido y el mapa base requieren conexión. Ante un fallo del proveedor, la API devuelve 503 sin confirmar la asignación. Distancia y duración son estimaciones del trazado vial. La prueba real usa un ejemplo sintético; los ensayos de concurrencia/error usan un proveedor HTTP simulado en una base aislada.

Referencia del contrato de recorrido: https://project-osrm.org/docs/v26.4.0/http. Política y atribución del mapa: https://operations.osmfoundation.org/policies/tiles/.
