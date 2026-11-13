# SonarQube actual — 04/11/2026

**Proyecto confirmado por el responsable: ecologisticas2.1. Resultado: SUCCESS, Quality Gate OK / PASSED.**

- Análisis: `99085f8d-8f96-432a-865a-a5b23c56ef41`.
- Tarea de procesamiento: `6bed0ce1-1e23-4fde-b577-243bcafacb17`.
- Corte de ejecución: 04/11/2026, 08:35 Perú; análisis de la misma versión backend probada.
- [Panel local](http://localhost:9000/dashboard?id=ecologisticas2.1).

| Medida SonarQube | Resultado |
|---|---:|
| Cobertura combinada backend | **90,9 %** |
| Cobertura de líneas | **93,8 %** |
| Cobertura de ramas | **79,1 %** |
| Líneas cubiertas/medidas | **2261/2410** |
| Ramas cubiertas/medidas | **478/604** |
| Vulnerabilidades / bugs / code smells | **0 / 0 / 0** |
| Security hotspots | **0** |
| Incidencias abiertas devueltas por la API | **0** |
| Duplicación | **0,0 %** |
| Ratings seguridad / fiabilidad / mantenibilidad | **A / A / A** (valor API 1,0) |

El 90,9 % es la presentación redondeada del **90,87591240875912408759124088 %** combinado de Coverage.py. La cobertura de ramas por sí sola es 79,1 %: no afirmar que todas las métricas superan el 80 %. No es cobertura Flutter/Android ni una calificación de todo el proyecto.

## Alcance y reproducción

Se copiaron y compararon por SHA-256 54 archivos Python de aplicación/migraciones/pruebas de D contra la versión probada, junto con Dockerfile y los informes XML/JUnit existentes. Se analizaron backend/app, backend/migrations y backend/Dockerfile; backend/tests se declaró como pruebas. El escáner importó correctamente coverage.xml. No se repitieron las127 pruebas backend ni las81 Flutter, ni se alteraron los tests, las exclusiones de cobertura o las fuentes para elevar la cifra.

Escáner @sonar/scan5.0.2, servidor26.10.0, perfiles **Sonar way core** para Python y Docker. Comando (credencial únicamente en entorno hijo del proceso):

```text
npx --yes --package=@sonar/scan@5.0.2 sonar-scanner-npm -Dsonar.host.url=http://localhost:9000 -Dsonar.qualitygate.wait=true -Dsonar.projectKey=ecologisticas2.1 -Dsonar.projectName=ecologistica2.1
```

El escáner terminó con exit0, informó PASSED y la tarea del servidor terminó SUCCESS; el analysisId confirmó Quality Gate OK. La respuesta de la API incluyó `conditions: []`: se conserva ese dato sin atribuir condiciones adicionales que no constan en la respuesta. No se cambió el Quality Gate, los perfiles ni los permisos. El escaneo de dependencias de Sonar fue omitido por la herramienta; no se confunde este resultado con la auditoría pip-audit previa ni con un pentest completo.

## Incidente de autorización y resolución

El primer intento apuntó al antiguo proyecto ecologisticas y fue rechazado por autorización. La credencial era válida, pero estaba destinada a **ecologisticas2.1**, clave confirmada después por Jordy. La consulta auxiliar de detalles tampoco estaba permitida por este token limitado; se ejecutó el escáner sin ampliar permisos, preservando el nombre del proyecto. Solo se registró un análisis enviado correctamente al proyecto confirmado; los intentos rechazados no generaron analysisId. Se conservó su registro como antecedente.

Se actualizaron las configuraciones de análisis locales y de PFA con la clave/nombre confirmados, sin incorporar tokens. La credencial se introdujo con entrada oculta, se mantuvo en memoria/entorno del escáner y no se guardó en archivos del repositorio. Como fue compartida en el chat, el responsable debe revocarla después del uso y utilizar una nueva credencial local para futuras ejecuciones.

## Efecto sobre el cierre

**Resuelto IMP-S3-C01 relativo al análisis SonarQube.** El dictamen general permanece PARCIAL por la inspección manual de accesibilidad/OWASP y la aceptación formal. Teléfono físico y APK release continúan bloqueados por requisitos ausentes. No se publicaron cambios en GitHub ni se modificó Jira.

[Respuesta real del servidor](sonar-current-result.json) · Log del escáner (archivo local de auditoría: `sonar-current-scanner.log`) · Intento rechazado (archivo local de auditoría: `sonar-authorization-rejected.log`) · [Informe de cierre](INFORME_CIERRE_SPRINT3.md).
