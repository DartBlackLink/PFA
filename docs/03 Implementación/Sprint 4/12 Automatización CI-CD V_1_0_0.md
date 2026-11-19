# Automatización CI/CD — Semana 14

**Proyecto:** EcoLogística Huancayo. **Responsable:** Jordy Steve Chancasanampa Torres. **Versión del contenido:** 1.1.0. **Corte:** 19/11/2026.

## Objetivo y estado comprobado

CI comprueba que el código integra correctamente; el workflow de pruebas verifica comportamientos y conserva informes; CD publica exactamente la versión que superó ambos controles. La web ya tiene una publicación manual en Wasmer y PostgreSQL en Neon. Eso acredita producción accesible, pero no acredita un despliegue automático desde GitHub.

El alcance autorizado de esta actualización es **solo documentación**. No se ejecutó Actions, no se configuraron credenciales, no se modificaron workflows y no se realizó commit ni push. La adaptación a Wasmer que se describe es el procedimiento por implementar y verificar, no una ejecución ya aprobada.

## Archivos existentes y su función

| Archivo | Qué contiene actualmente | Qué demuestra su estado actual |
|---|---|---|
| [ci.yml](../../../.github/workflows/ci.yml) | Push/PR a main/develop y ejecución manual; revisión estática, dependencias, compilación backend/Flutter y comprobaciones E2E. | Configuración local; las validaciones de sintaxis del 18/11 no sustituyen un runner GitHub. |
| [tests.yml](../../../.github/workflows/tests.yml) | Pruebas backend con PostgreSQL efímero, Flutter y Playwright en Chromium, Firefox y WebKit; artefactos de resultados. | Suite preparada con aislamiento de datos. Faltan enlaces y resultados de ejecuciones remotas. |
| [deploy-production.yml](../../../.github/workflows/deploy-production.yml) | Puerta de éxito de tests y CI sobre el mismo SHA; entrega a VPS por SSH. | **No corresponde todavía al proveedor Wasmer**. No se activa para la aplicación pública actual. |

Los resultados locales se conservan en el [expediente del 18/11](../evidencias/20261118-semana14/RESULTADOS.md). Los resultados de la URL pública están separados en el [expediente del 19/11](../evidencias/20261119-despliegue-publico/RESULTADOS.md). No se mezclan sus entornos, cantidades de pruebas ni mediciones.

## Arquitectura de destino para la automatización

| Componente | Destino existente | Entrega prevista |
|---|---|---|
| Flutter Web, ADMIN y REPARTIDOR | https://ecologistica-huancayo-web.wasmer.app/ | Compilación release con API pública; contenido estático, sin claves. |
| FastAPI | https://ecologistica-huancayo-api.wasmer.app/api/v1 | Fuentes de backend, migraciones y dependencias compatibles con WASIX. |
| PostgreSQL | Neon, proyecto del responsable | Se conserva la base existente; no se empaquetan datos ni se recrean tablas/usuarios. |

La integración debe actualizar las dos aplicaciones existentes de la cuenta `pudge`, sin generar aplicaciones paralelas. El contrato y los límites del paquete están descritos en [deploy/wasmer](../../../deploy/wasmer/README.md). Se mantiene `America/Lima` para Huancayo.

## Adaptación técnica pendiente del workflow de producción

1. Conservar el disparador tras pruebas de main, el control del repositorio propio, el entorno production, la exclusión mutua y la comprobación de CI/pruebas exitosos para **el mismo SHA**. No publicar fuentes de una rama distinta ni de un PR externo con secretos.
2. Sustituir la transferencia SSH/VPS por la integración oficial de Wasmer, una vez comprobada su interfaz y autenticación para las dos aplicaciones existentes. Confirmar aplicación, propietario y versión antes de promover. No suponer que cambiar una URL hace compatible el workflow VPS.
3. Preparar el paquete backend mediante una lista permitida: `backend/app/`, `backend/migrations/`, `backend/alembic.ini`, `deploy/wasmer/main.py` como `main.py` y `backend/requirements-wasmer.lock.txt` como los archivos de requisitos de la entrega. Excluir pruebas, entornos virtuales, cachés, respaldos y configuraciones privadas del paquete runtime.
4. Mantener el arranque `python main.py`. En la publicación manual, concatenar `&&` en el campo de inicio produjo un fallo porque el proveedor no lo interpretó como shell. No reintroducir ese comando.
5. Compilar Flutter con la API pública. Publicar únicamente la salida estática; no subir código backend ni conexión Neon en el cliente. Comparar el SHA256 de `main.dart.js` generado con el archivo servido.
6. Mantener las variables sensibles del backend en Wasmer y la autenticación de despliegue en GitHub Secrets. Comprobar que actualizar la aplicación no elimina ni revela esas variables. No volver a inicializar las cuentas existentes.
7. Revisar migraciones respecto a la versión de Neon y conservar respaldo privado antes de cualquier cambio de esquema. La entrega no necesita vaciar datos ni volver a ejecutar las semillas de demostración. Una migración fallida detiene la promoción.
8. Promover la versión solo con verificaciones satisfactorias; registrar identificadores de versión. Si falla salud o contrato, detener la entrega y evaluar volver a la versión de aplicación previa. No restaurar datos automáticamente ni borrar entregas para conseguir un resultado verde.

La documentación oficial describe [despliegues desde Git](https://docs.wasmer.io/edge/git/), [CLI](https://docs.wasmer.io/edge/cli/) y [configuración de aplicaciones](https://docs.wasmer.io/edge/configuration/). La elección y los comandos exactos de automatización se validarán en la implementación; este documento no presenta un comando no probado como integración funcional.

## Configuración pública y privada

| Elemento | Dónde debe estar | Qué se conserva en Git |
|---|---|---|
| URL de web y API | Variables de GitHub y compilación del cliente | URL pública y nombres de variables. |
| Credencial de despliegue Wasmer | GitHub Secret del entorno production, con permisos mínimos | Solo el nombre que defina la implementación; jamás su valor. |
| Conexión Neon y clave de sesiones | Variables privadas del backend en Wasmer | Nombres y propósito, nunca cadena de conexión ni clave. |
| Accesos de ADMIN/REPARTIDOR | Entrega privada al responsable o sesión supervisada | Ninguna contraseña ni archivo de accesos. |
| Activación de producción | Variable de control, tras configurar la integración y revisar el entorno | Regla de activación. No habilitar el workflow VPS actual para Wasmer. |

Documentar el uso de un secreto **no significa publicarlo**. La parte ejecutora necesita autenticarse aunque los documentos no contengan credenciales. No se requiere revelar tokens en el chat ni añadirlos al repositorio.

## Orden de ejecución y evidencia de aceptación

| Paso | Resultado exigido | Evidencia que se incorporará cuando exista |
|---|---|---|
| Revisar y publicar fuentes autorizadas | Diff revisado, sin secretos, origin correcto y sincronización sin sobrescribir trabajo ajeno. | Commit y SHA reales. |
| Ejecutar CI | Todos sus jobs obligatorios terminan correctamente. | URL del run, SHA, fecha y artefacto de compilación. |
| Ejecutar pruebas | Backend, Flutter y los tres motores E2E pasan; informes conservados. | URL del run, JUnit/HTML/cobertura y fallos corregidos si los hubiera. |
| Ejecutar CD adaptado | Actualiza las apps Wasmer con ese mismo SHA. | URL del run, versiones frontend/backend y resultado del proveedor. |
| Verificar servicio publicado | Salud API, web, CORS y sesiones de ambos roles; flujo con registros QA autorizados persistidos. | Respuestas HTTP sanitizadas, capturas, hash web y evidencia de persistencia. |

La validación pública debe comprobar generación y asignación, consulta por repartidor, incidencia, reoptimización, aprobación, recepción y finalización, preservando entregas anteriores. Un HTTP 200 de la portada no demuestra todo ese flujo. Las pruebas destructivas deben usar datos QA autorizados, nunca eliminar registros operativos.

## Criterio de cierre y situación actual

Este requisito se acredita con **CI + pruebas + CD Wasmer ejecutados con éxito y sus evidencias enlazadas**. Tener tres YAML, una URL pública o badges sin ejecuciones no basta. Al corte actual, producción manual está comprobada y automatización remota sigue pendiente. El estado se actualizará solo después de ejecutar, sin anticipar aprobación.

[Acciones de cierre](ACCIONES_PARA_CERRAR_SPRINT4.md) · [Control de Semana 14](CONTROL_SEMANA14.md) · [README principal](../../../README.md).
