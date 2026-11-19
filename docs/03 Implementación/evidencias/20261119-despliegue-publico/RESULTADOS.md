# Publicación y validación real — 19/11/2026

**Proyecto:** EcoLogística Huancayo. **Zona:** America/Lima. **Publicación:** Wasmer Hobby + Neon Free. **Método:** publicación manual y comprobación posterior; sin push ni GitHub Actions.

- [Web pública ADMIN / REPARTIDOR](https://ecologistica-huancayo-web.wasmer.app/).
- [Salud de FastAPI](https://ecologistica-huancayo-api.wasmer.app/api/v1/health).
- [Configuración reproducible](../../../../deploy/wasmer/README.md).

## Resultados realmente ejecutados

| Control | Resultado y alcance | Evidencia |
|---|---|---|
| Publicación | Web y salud API HTTP 200. JavaScript servido idéntico a la compilación configurada para HTTPS público. | [Verificación y SHA256](cierre-verificado.json), [manifiesto frontend](manifest-web.json) |
| PostgreSQL | 19 tablas, migración 0008; base nueva sin datos previos sobrescritos. Conexión con TLS y channel binding exigidos, certificado/hostname verificados en prueba TLS1.3. pg_stat_ssl del pooler describe su enlace interno, no el del cliente. | [Migraciones](neon-migrada.json), [TLS](neon-preflight.json) |
| API pública | 41 comprobaciones de HTTP/contrato, todas conformes tras corregir una expectativa del instrumento. Incluyen accesos, permisos 401/403, validaciones 422, duplicado 409, creación/lectura/edición de recursos, generación y confirmación idempotente, incidencia, notificación y reoptimización aprobada. | [Peticiones y tiempos](verificacion-api-publica.json) |
| Chromium real | 12 comprobaciones: login ADMIN, navegación de seis apartados, login REPARTIDOR, mapa, acuse v2, entrega final y sesión tras recargar. 44 respuestas API observadas; cero errores de página o respuestas 5xx en la ejecución final. Las seis comprobaciones de apartados son navegación con sesión; sus escrituras se verificaron por API, no se presentan como CRUD completo por botones. | [Reporte de navegador](verificacion-web-publica.json), [capturas](capturas/web-repartidor-finalizada.png) |
| Persistencia final | Ruta FINALIZADA, versión 2 recibida, dos entregas ENTREGADO; instante de la primera entrega sin cambios después de reoptimizar. Comprobación por interfaz, respuesta API y lectura directa de PostgreSQL. | [Lectura final Neon](persistencia-neon-final.json) |
| Dependencias Wasmer | 31 distribuciones compatibles comprobadas y hasheadas; auditoría upstream sin vulnerabilidades conocidas al corte. No es nueva cobertura de pruebas ni calificación SonarQube. | [Auditoría](auditoria-dependencias-wasmer.json), [hashes de ruedas](manifest-wheels-wasmer.json) |
| Integridad de entrega | 40 archivos Dart de desarrollo y PFA coinciden normalizando saltos de línea. Fuentes funcionales locales, Docker y otros proyectos no modificados. | [Comparación](integridad-fuentes.json) |

## Problemas encontrados y correcciones

1. El primer build rechazó cffi 2.1.1, sin distribución WASIX; otros pines nativos tampoco tenían rueda. Se preparó una lista separada compatible, se verificó el conjunto y se auditó antes de usarlo. No se degradaron las dependencias de desarrollo ni se eliminaron permisos o validadores.
2. El comando `alembic upgrade head && python main.py` se interpretó sin shell; Alembic recibió `&& python main.py` como argumentos y la aplicación devolvió 500. Se aplicaron las migraciones y se cambió el arranque a `python main.py`; luego se comprobó salud 200.
3. Las variables personalizadas no persistieron en la primera creación previa a vincular la aplicación a la cuenta. El log mostró Settings sin DATABASE_URL/SECRET_KEY. Se guardaron en el panel definitivo, con valores sensibles protegidos y reconstrucción posterior. No se introdujeron contraseñas fijas.
4. El instrumento esperaba 201 al reportar incidencia, pero el contrato existente responde 200; la incidencia ya estaba guardada. Se conservó el primer resultado y se corrigió la expectativa, continuando desde los mismos registros, sin recrearlos.
5. La prueba de navegación no regresaba desde Flota porque GoRouter mantiene la URL del panel al usar navegación imperativa. Se utilizó el botón real «Volver al centro de control» y se repitió la prueba. No se atribuye este error de instrumentación a pérdida de sesión.

## Datos y alcance

Se conservaron los registros sintéticos identificados como DEMO: perfil, DNI/contacto/licencia, placa QA-WEB-001 y dos destinos públicos. La congestión fue simulada; no constituye tráfico observado. No se copiaron datos operativos, identidades privadas o contraseñas de la base local. Las credenciales del entorno público son nuevas y se entregan por archivos privados protegidos, nunca aquí.

La campaña local del 18/11 (145 backend, 30 E2E y cobertura combinada 90,0625 %) mantiene su fecha y entorno; **no se presenta como cobertura medida en Wasmer**. En este despliegue se comprobó Chromium; no se volvió a acreditar Firefox, WebKit, Android o carga de 150 pedidos en producción. La base QA local estaba detenida; no se modificó Docker para repetir la regresión local.

## Lo que aún no acredita este despliegue

SUS continúa sin respuestas humanas, y los workflows no se han ejecutado en GitHub ni automatizan todavía Wasmer. La aceptación docente/calendario oficial no se inventa. La publicación manual cubre la existencia de una URL operativa, pero no completa por sí sola la rúbrica de CI/CD ni Semana 14 entera.

[Sprint 4](../../Sprint%204/README.md) · [README principal](../../../../README.md).

## Lectura visual e integridad

El [expediente explicado para Semana 14](../../Sprint%204/EVIDENCIAS_PUBLICAS_SEMANA14.md) presenta tres capturas con su interpretación y enlaza las otras pantallas. El [manifiesto visual](MANIFIESTO_VISUAL.json) conserva hashes de las diez imágenes y cuatro reportes originales. Es una revisión documental de evidencias existentes, sin una nueva ejecución del flujo ni cambios de registros.
