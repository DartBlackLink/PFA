# Matriz de verificación por apartado — WEB, 17/11/2026

APROBADO corresponde a los casos y capa indicados. CORREGIDO identifica un defecto reproducido y reparado. No equivale a probar todas las combinaciones posibles de entradas.

| Rol / apartado | Operación y campos revisados | Resultado | Evidencia / capa |
|---|---|---|---|
| ADMIN y REPARTIDOR · Login | Obligatorios, rol, sesión independiente, sesión restaurada, caducidad y nuevo acceso; cuenta QA inactiva no entra. | APROBADO | Navegador y API; suite auth/login. |
| ADMIN · Resumen | Conteos, indicadores, distinción de ausencias y cero; accesos a módulos. | APROBADO | Navegador y regresión de indicadores; datos API. |
| ADMIN · Flota, registro | Placa, tipo, capacidad, año, consumo, factor y estado. Alta QA-1711 por formulario. Vacíos, formato, rangos y duplicados. | APROBADO | UI alta; API rechaza inválidos con 422 y placa repetida con 409. |
| ADMIN · Flota, mantenimiento | Buscar por placa; tarjetas/tabla; editar capacidad 250→300; desactivar y reactivar. | APROBADO | Navegador; lectura posterior de la API. |
| ADMIN · Repartidores | Nombre, DNI, licencia, categoría, experiencia, contacto, turno, origen, correo, contraseña y estado: obligatorios UI y valores inválidos/duplicados API. | APROBADO en capas indicadas | Alta positiva perfil/cuenta por API; validaciones UI. No se afirma un alta positiva nueva por formulario. |
| ADMIN · Repartidores, mantenimiento | Búsqueda, editar contacto, baja lógica y reactivación sin cambiar la contraseña. | APROBADO | Navegador; login inactivo 401, login reactivado correcto y perfil actualizado. |
| ADMIN · Clientes | Alta API y búsqueda por nombre; selección del mismo cliente en pedidos. | APROBADO en capas indicadas | API y selector web; nombre actualizado y asociación por cliente_id. |
| ADMIN · Preferencias | Inicio/fin, referencia y acceso; horario igual rechazado y actualización conservada. Cliente inactivo no admite nuevo pedido. | APROBADO | UI edición/validación; API asociación y estado. |
| ADMIN · Pedidos, alta | Cliente existente, producto, peso, dirección buscada en Huancayo, coordenadas, confirmación de punto, referencia, prioridad y ventana. | APROBADO | Alta web con Photon/OSM en Huamanmarca y selección de cliente registrado; detalle API. |
| ADMIN · Pedidos, actualización | Buscar QA FINAL; abrir detalle; cambiar peso 1→2 y prioridad ESTANDAR→ALTA; preservar destino y cliente. | APROBADO | [Pedido persistido](pedido-ui-final.json), [captura](pedido-actualizado.jpg). |
| ADMIN · Pedidos, negativos | Direcciones/formatos/rangos, peso inválido, ventana sin orden, cliente inactivo, campos extra y pedidos ya asignados. | APROBADO en API/regresión | Casos API y suites de pedidos; el formulario exige confirmar el punto. |
| ADMIN · Asignación manual/horario | Capacidad, turno, cruces, atención completa; indicadores/ETA; rechazo sin modificar datos. | APROBADO en regresión | test_reporting_clients.py e integración. No nueva asignación manual por navegador en este corte. |
| ADMIN · Planificación genética | Elegir dos pedidos y equipo QA; salida; propuesta vial; revisar mapa; confirmar y guardar. | APROBADO | Navegador; backend con proveedor vial real. |
| ADMIN · Propuesta desactualizada | Cambiar un pedido antes de confirmar; rechazar propuesta anterior sin asignación parcial; recalcular. | APROBADO | Mensaje UI y HTTP 409; propuesta válida posterior confirmada. |
| ADMIN · Tráfico estimado | Alta, edición 1.1→1.2 y retiro de la franja QA; referencia local y ausencia de tráfico en vivo identificadas. | APROBADO | Navegador y política final sin reglas; retiro autorizado expresamente. |
| ADMIN · Validación de franja | Factor 0/6, minutos fuera de rango, orden y coordenadas fuera de Huancayo. Formulario debe conservarse sin escribir. | CORREGIDO | Ocho regresiones; [modal final](trafico-corregido.jpg). |
| ADMIN/REPARTIDOR · Mapa | Punto de partida, paradas, geometría, comparación e historial; contraste del trazado. | CORREGIDO | [Mapa desplegado](mapa-final-corregido.jpg); regresión de ciclo de vida y contraste. |
| REPARTIDOR · Operación propia | Perfil, rutas asignadas, filtros, recepción versión 1 e inicio real. | APROBADO | Navegador con cuenta QA independiente. |
| REPARTIDOR · Entregas | Primera entrega, secuencia, última entrega y finalización; horas reales guardadas. | APROBADO | Navegador y [flujo final](flujo-final.json). |
| REPARTIDOR → ADMIN · Incidencia | Descripción mínima; tipo, posición manual QA, demora, afectación; aviso recibido por ADMIN. | APROBADO | Modal, notificación y registro persistido. |
| ADMIN → REPARTIDOR · Reoptimización | Posición manual de simulación, pendiente restante, comparación, aprobación, versión recibida 2 e historial de primera entrega. | APROBADO | Navegador y API. Alternativa más lenta/larga informada; no se afirma mejora. |
| ADMIN · Resolución | Motivo de gestión y cierre de la incidencia; repartidor conserva consulta de historial. | APROBADO | Navegador; incidencia resuelta en API. |
| ADMIN · Reportes y PDF | Ruta finalizada/v2, indicadores, botón sin selección deshabilitado, descarga desde botón y contenido real. | APROBADO | [PDF web](descarga-web.pdf) analizado con pypdf; pruebas de bytes y permisos. |
| ADMIN · Equivalencia | Fuente, factor, unidad, ausencias e inválidos; cálculo de referencia visible, sin afirmar compensación real. | APROBADO en API/regresión y consulta UI | Configuración inválida no altera valores existentes; informe y PDF. No cambio positivo del factor operativo en este corte. |
| Permisos y navegación | Sin sesión 401, repartidor sin acceso a módulos ADMIN 403, rutas de otros repartidores 404, entrada a /dashboard redirige al área propia. | APROBADO | API, navegador y suites de seguridad. |
| Sesión y cierre | Caducidad ADMIN y acceso posterior; cerrar sesión REPARTIDOR regresa a login. | APROBADO | Navegador; no se desactivaron límites de sesión. |
| Persistencia e integridad | Registros originales conservados; cambios QA visibles tras recargar; tabla de políticas y entregas verificadas. | APROBADO | [Integridad](integridad-final.json), [flujo](flujo-final.json) y backup privado. |

[Resultados, errores corregidos y límites](RESULTADOS.md).
