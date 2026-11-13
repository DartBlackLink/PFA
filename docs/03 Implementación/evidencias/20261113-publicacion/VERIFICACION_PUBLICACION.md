# Verificación previa a la publicación · 13/11/2026

## Seguridad y credencial administrativa

Se identificó una contraseña histórica en backend/app/core/config.py del commit ed3298f6bd71331c4cc7840530757e93e293871a, alcanzable desde origin/main. Su valor coincidía con la credencial administrativa operativa. Se bloqueó la publicación hasta rotarla con autorización expresa.

Antes de modificar la credencial se generó un respaldo PostgreSQL de formato custom y se validó su catálogo mediante pg_restore --list. El respaldo permanece fuera del repositorio con permisos restringidos.

La comparación transaccional de las 18 tablas confirmó que la rotación modificó únicamente el hash de la cuenta ADMIN autorizada. Se utilizó bcrypt con coste 12 mediante get_password_hash de la aplicación. El login con la clave anterior devolvió 401 y el login con la nueva devolvió 200 y rol ADMIN. También se comprobó el acceso al dashboard desde la web.

Las solicitudes de autenticación generan sus registros normales. La comprobación de integridad de datos corresponde a la transacción de rotación previa a esas solicitudes.

Se contrastaron los valores literales de configuración histórica y los fixtures de pruebas con las cuatro cuentas activas de la base operativa. Ningún hash coincidió. Tampoco coincidieron con los secretos del entorno de la API. El escaneo por patrones de tokens, JWT y claves privadas no detectó coincidencias adicionales en el conjunto publicable ni en los blobs históricos examinados.

## Riesgo histórico y prevención

El commit antiguo permanece público. La rotación invalida la contraseña para el acceso nuevo a la cuenta operativa, pero el valor histórico sigue siendo recuperable y debe considerarse comprometido para siempre. Cualquier reutilización en otro servicio debe eliminarse por su responsable. La rotación de contraseña conserva el vencimiento original de los tokens ya emitidos.

Se conservaron el historial y las ramas. Las pruebas automatizadas mantienen claves sintéticas identificadas para QA aislado. Los scripts de instalación solicitan claves privadas o generan valores aleatorios. La plantilla .env.sample contiene marcadores para sustituir, sin credenciales operativas.

## Integridad y pruebas

- 83 pruebas Flutter aprobadas en la copia apps/web de PFA durante la preparación de esta publicación.
- Los cuatro documentos de cada Sprint 1, 2 y 3 permanecen separados.
- La retrospectiva del Sprint 3 conserva su estructura y diferencia correcciones comprobadas de compromisos propuestos.
- Los enlaces relativos de los Markdown incluidos fueron contrastados con el índice de Git.
- Las fuentes lib de ambos clientes y app/migrations del backend coinciden con D:/UC/App/ecologistica, salvo diferencias de fin de línea.
- La regresión backend y cobertura conservan sus fechas previas. Esta revisión no ejecutó un nuevo análisis SonarQube ni una nueva suite backend.
- Compose y sus instrucciones se incluyen como configuración reproducible. La publicación no reinicia ni reconstruye los servicios.

## Límites académicos conservados

Siguen documentados el seguimiento de reconexión Android, la segunda cuenta en emulador, la validación del flujo en teléfono físico, la distribución release, la publicación del mensaje nuevo del comparador y la aceptación académica formal. Las evidencias técnicas permiten revisar el incremento con esos límites explícitos.
