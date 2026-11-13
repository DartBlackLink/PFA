# Consolidación operativa — 04/11/2026

## Problema y solución

Había varios servidores de EcoLogística y datos sintéticos mezclados con la demostración principal. Se consolidó la ejecución en Compose ecologistica, con postgres, api y web construidos desde D:\UC\App\ecologistica. API/web no montan stage ni el workspace. Los servidores anteriores de EcoLogística están detenidos y conservados; no se han eliminado recursos.

El responsable confirmó que todos los datos eran de prueba. Se creó ecologistica_operativa vacía, con un único administrador inicial y claves nuevas privadas. La base ecologistica se conserva completa como archivo; no se atribuyen sus registros a clientes reales. El panel nuevo muestra cero pedidos, rutas, vehículos y repartidores. El responsable debe registrar recursos operativos antes de asignar pedidos. Las cuentas demo antiguas no son accesos de esta base.

## Verificación de esta consolidación

| Comprobación | Resultado y evidencia |
| --- | --- |
| Respaldo principal | Restauración aislada; 18 tablas con cantidades y hashes idénticos. backup-result.json |
| Bases QA antiguas | Cada base exportada/restaurada y comparada; qa-backup-result.json |
| Nueva cuenta ADMIN | Login real por navegador aprobado, captura admin-base-limpia.png |
| API limpia | ADMIN válido, listas vacías, pedido sin sesión rechazado 401. clean-runtime-result.json |
| Compose | Tres servicios saludables. Imágenes compiladas desde la fuente activa. activation-result.json |
| Regresión backend | 127 aprobadas, 1 advertencia, 74,97 s; PostgreSQL de pruebas aislado. backend-tests.log y test-results.xml |
| Flutter | 81 aprobadas y analizador sin incidencias. flutter-tests.log y flutter-analyze.log |
| Cobertura backend | (2739/3014) × 100 = 90.875912408759 %, redondeada 90,88 %. XML y HTML adjuntos |
| Proyectos protegidos | DanleoPay, su contenedor de pruebas, SonarQube y MegaBlog sin cambios de configuración, imágenes, montajes ni estado |

Los tests se ejecutaron sin cambiar los casos ni las exclusiones para elevar la cobertura. Se cubrieron 2261/2410 líneas y 478/604 ramas del alcance Python definido en .coveragerc; no es la cobertura de todo Flutter ni una garantía de ausencia de errores.

## Continuidad y límites

El flujo completo ADMIN/REPARTIDOR y Android anterior se conserva en las evidencias de cierre del 04/11; no se ha repetido ese recorrido contra la base operativa limpia. No se insertan casos QA en esa base para simular operación real. Las nuevas suites verifican la misma lógica del producto en aislamiento. La APK debug normal y su validación anterior no equivalen a teléfono físico ni release firmado.

El Sonar vigente está documentado en ../20261104-cierre/SONARQUBE_ACTUAL.md (ecologisticas2.1, 90,9 %, gate OK); no se ejecutó otro análisis con tokens expuestos durante esta consolidación. El dictamen académico sigue PARCIAL por los controles manuales y aceptación descritos en el informe de cierre. No se modificó Jira.

## Operación y seguridad de entrega

Compose y .env.sample se incluyen por la última instrucción de consolidación; .env real, claves, respaldos de datos, tokens, AVD y artefactos privados quedan fuera. Las fuentes de apps/web y apps/mobile fueron comparadas con el cliente común activo antes de copiar configuración. No se sobrescribieron diferencias de código. No se tocaron Sprint 1 ni Sprint 2.

No se ha hecho commit ni push. La limpieza irreversible requiere aprobar primero los IDs, rutas y dependencias del plan local. Almacenamiento liberado por eliminación: 0 bytes.

[Dictamen por estado](DICTAMEN.md). La base operativa también fue restaurada y comparada: resultado sin datos privados (archivo local de auditoría: `operational-backup-result.json`).
