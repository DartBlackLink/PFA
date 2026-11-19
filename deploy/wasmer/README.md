# Despliegue web en Wasmer y Neon

La aplicación pública utiliza Flutter Web estático y FastAPI en dos aplicaciones Wasmer Hobby, y PostgreSQL en Neon Free. Es independiente de Docker y de la computadora de desarrollo.

| Componente | Dirección / configuración |
|---|---|
| Interfaz ADMIN y REPARTIDOR | https://ecologistica-huancayo-web.wasmer.app/ |
| API | https://ecologistica-huancayo-api.wasmer.app/api/v1 |
| Salud API | https://ecologistica-huancayo-api.wasmer.app/api/v1/health |
| Base | Neon, N. Virginia; creada con PostgreSQL 18. Las ocho migraciones existentes se aplicaron y verificaron, sin cambiar PostgreSQL 16 local. |

## Paquete FastAPI

Preparar una carpeta de despliegue fuera del repositorio con `backend/app/`, `backend/migrations/`, `backend/alembic.ini` y el archivo `deploy/wasmer/main.py` copiado como `main.py` en la raíz de esa carpeta. Copiar `backend/requirements-wasmer.lock.txt` como `requirements.txt` y `requirements.lock.txt`. Comprimir el contenido, sin carpeta contenedora ni archivos privados.

Subir ese ZIP a Wasmer con preset `python`. El comando de arranque es **`python main.py`**. No concatenar `&&` en ese campo: el runtime lo pasó como argumento de Alembic y produjo errores 500. Las migraciones se aplican previamente con el entorno privado del operador; el hook Alembic detectado por el proveedor también necesita configuración y debe terminar sin errores.

## Variables del backend

Configurar en el panel definitivo de la aplicación, guardar y reconstruir la versión. Comprobar los nombres después del guardado; la configuración anterior a vincular la aplicación a la cuenta no conservó las variables personalizadas.

| Nombre | Configuración |
|---|---|
| DATABASE_URL | URL SQLAlchemy `postgresql+psycopg` de Neon con TLS y channel binding exigidos. Marcar **Sensitive**. Valor entregado únicamente por mecanismo privado. |
| SECRET_KEY | Clave aleatoria independiente, mínimo 32 caracteres y suficiente diversidad. Marcar **Sensitive**. |
| BOOTSTRAP_DEMO_USERS | `false`; sin contraseñas por defecto ni recreación de cuentas. |
| CORS_ORIGINS | `https://ecologistica-huancayo-web.wasmer.app` |
| TRUSTED_HOSTS | `ecologistica-huancayo-api.wasmer.app,localhost,127.0.0.1` |
| TZ | `America/Lima` |

Las variables se habilitaron para ejecución y tareas de construcción/migración del mismo servicio. No ponerlas en Flutter, ZIP, Git, capturas o logs. No cambiar las variables del sistema que Wasmer añade. Las cuentas nuevas se inicializaron con bcrypt, sin modificar cuentas de desarrollo. Sus claves se entregaron en archivos privados locales, fuera de PFA.

## Compatibilidad de dependencias

El runtime Wasmer es WASIX/Python 3.13; no admite todas las ruedas del entorno Linux/Windows. Se conserva intacto `backend/requirements.lock.txt` para el desarrollo habitual. La lista separada fija las versiones compatibles de SQLAlchemy 2.0.51, psycopg 3.3.4, pydantic 2.13.4/core 2.46.4, greenlet 3.5.3 y MarkupSafe 3.0.3; se añadió tzdata 2026.6. No se modificó la lógica de negocio para adaptar el hosting.

Se usa Uvicorn con asyncio/h11 y JWT HS256, por lo que el paquete de despliegue omite extras no utilizados como uvloop, watchfiles y el extra de criptografía asimétrica de PyJWT. Se mantienen bcrypt, firma HMAC de sesiones, TLS y controles de autorización. Las 31 distribuciones WASIX se comprobaron en el registro oficial, conservando sus hashes. La auditoría del 19/11 no encontró vulnerabilidades conocidas en las versiones upstream; no certifica los parches del proveedor ni garantiza ausencia de vulnerabilidades.

## Flutter Web

Desde la aplicación Flutter, con la versión fijada en el proyecto:

```text
flutter build web --release --dart-define=API_BASE_URL=https://ecologistica-huancayo-api.wasmer.app/api/v1
```

Publicar el contenido de `build/web/` en otra aplicación Wasmer con preset `staticfile`; `index.html` debe estar en la raíz. No subir fuentes privadas, `.env`, mapas de código fuente, llaves Android o el backend en este paquete. No conectar el navegador directamente a PostgreSQL. La compilación pública fue contrastada por SHA256 con el archivo servido.

## Operación y límites

Comprobar salud, login, CORS, restricciones y el flujo por ambos roles tras cada publicación. Conservar un respaldo privado antes de cambiar datos; no inicializar usuarios sobre una base ya operativa. El ejemplo guardado usa un repartidor, vehículo, cliente y dos pedidos de **demostración**, con puntos públicos de Huancayo. No son identidades, placas o entregas comerciales verificadas.

Este despliegue se hizo mediante carga de ZIP y panel del proveedor. **No se ejecutó GitHub Actions**: el workflow de producción existente se preparó para VPS y todavía requiere adaptación a Wasmer, credenciales privadas autorizadas y una ejecución comprobada. No confundir una URL pública funcional con CD automatizado ya acreditado. Las cuotas gratuitas y los servicios cartográficos externos limitan la disponibilidad; no se ofrece un SLA ni se extrapola la carga local de 150 pedidos a este servidor.

[Resultados del despliegue](../../docs/03%20Implementaci%C3%B3n/evidencias/20261119-despliegue-publico/RESULTADOS.md) · [README principal](../../README.md).
