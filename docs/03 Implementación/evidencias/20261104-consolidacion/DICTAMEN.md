# Dictamen de consolidación — 04/11/2026

| Estado | Comprobación | Evidencia / alcance |
| --- | --- | --- |
| APROBADO | Un entorno operativo Compose ecologistica con postgres/api/web | activation-result.json; API y web sin montajes temporales; origen D |
| APROBADO | Base operativa limpia y ADMIN privado | Login Web real y listas vacías; clean-runtime-result.json y admin-base-limpia.png |
| APROBADO | Recuperación de datos | Principal, las tres bases QA y la nueva operativa restauradas en aislamiento, con cantidades/hashes por tabla idénticos. Datos originales conservados |
| APROBADO | Regresión actual | 127 backend / 81 Flutter; analyze sin incidencias; cobertura backend 90,88 %; HTML/XML/JUnit persistidos |
| APROBADO | Copia de entrega y configuración | Fuentes comparadas sin diferencias funcionales (finales de línea normalizados); Compose validado; herramientas de instalación y arranque verificadas por sintaxis; exclusiones y escaneo de secretos candidatos sin hallazgos |
| APROBADO | Conservación de proyectos ajenos | DanleoPay, su test exacto, Sonar y MegaBlog sin cambios de estado, configuración, imagen ni montajes |
| PARCIAL | Revisión funcional de esta consolidación | Login/listas/permisos anónimos comprobados ahora. El flujo completo de generación, asignación, incidencia, reoptimización y recepción está demostrado en el corte anterior del mismo día; no se presenta como una nueva prueba completa contra la base limpia |
| PARCIAL | APK Android | SHA-256 7abd7e926d5939c89c3493cbcfdb750b988dfd38f1f4b1b8a428720a1d474edf y firma v2 Android Debug verificadas ahora; prueba de operación del emulador pertenece al corte anterior |
| PARCIAL | Cierre académico Sprint 3 | Subsisten inspección manual/aceptación descritas en el informe de cierre; no se cambia Jira ni se inventa aprobación |
| PENDIENTE | Limpieza irreversible | Plan local con 9 contenedores, 4 imágenes, 1 volumen QA y 8 directorios. Necesita autorización expresa; ninguna eliminación ejecutada |
| BLOQUEADO | Nuevo análisis Sonar de infraestructura | No existe sonar-token.local.txt; no se reutilizan tokens expuestos. El análisis backend previo de ecologisticas2.1 del mismo día permanece documentado, 90,9 % y gate OK |
| BLOQUEADO | Teléfono físico | ADB devices no detecta equipos conectados al comprobar este corte |
| BLOQUEADO | APK release distribuible | Gradle usa firma debug; no hay configuración de firma release y API HTTPS de entrega verificada |

La base se deja sin repartidores inventados: el administrador debe registrar el perfil y su acceso desde el formulario antes de operar. Los datos anteriores eran sintéticos, por confirmación del responsable, y permanecen respaldados. No hay una nueva contraseña pública de repartidor.

Las claves y los respaldos de filas están fuera del repositorio. Esta documentación no contiene la contraseña del ADMIN. No se ha hecho commit/push ni se ha modificado Jira. La entrega técnica consolidada no equivale a cierre académico total.
