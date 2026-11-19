# Control híbrido — Sprint 4 y contexto del proyecto

**Proyecto:** EcoLogística Huancayo. **Responsable:** Jordy Steve Chancasanampa Torres. **Versión:** 1.0.0. **Corte:** 18/11/2026.

## Propósito y línea base

Se aplican los cuatro reportes de la guía: estado, variaciones, valor ganado y tablero visual. El [informe de estado](01%20Informe%20de%20estado%20del%20proyecto%20V_1_0_0.md) corresponde a un solo sprint; las cifras globales siguientes se identifican como contexto, sin mezclarlas con el rendimiento del Sprint 4. Las cifras del ejemplo To-Do list no pertenecen a EcoLogística.

## Informe de variaciones

| Dimensión | Plan o referencia | Real acreditado | Variación / causa | Respuesta y verificación |
|---|---|---|---|---|
| Cronograma S4 | Calendario por acordar en Jira. | Sprint 4 existe sin fechas oficiales. | Días de adelanto/retraso no calculables. | Jordy confirmará fechas antes de comparar plazos; conservar línea base anterior. |
| Rendimiento EN-002 | Generación ≤45 s; replanificación ≤30 s en condiciones del requisito. | Corte 18/11: 15 casos 10/50/150 × cinco semillas, posteriores a la deduplicación, dentro de ≤45 s y <30 s. El fallo previo queda conservado. | Se corrigieron consultas redundantes y protocolo OSRM monopunto; destinos repetidos limitan representatividad. | Mantener regresiones y ampliar diversidad; no extrapolar a carga concurrente. Ver expediente del 18/11. |
| Calidad Semana 14 | E2E tres navegadores, métricas web, SUS, CI/CD y producción. | 145 backend, 30 E2E en tres motores, nueve mediciones de login y tres workflows preparados. | Faltan respuestas humanas SUS, ejecución remota y producción. | Aplicar encuesta y obtener evidencias remotas cuando se autorice; no sumar pruebas de distinto tipo como sustitución. |
| Costos | Presupuesto académico referencial S/500 000 de desarrollo. | No hay gastos reales ni horas imputadas al Sprint 4. | Variación no calculable; el presupuesto profesional supuesto no acredita consumo. | Registrar costos reales y autorización, sin convertir SP en dinero arbitrariamente. |

## Informe de valor ganado (EVM)

El [presupuesto](../../02%20Planificaci%C3%B3n/04%20Presupuesto%20del%20proyecto%20V_1_2_0.md) es una estimación académica, no un registro contable. No existe distribución temporal aprobada del valor planificado ni costos reales acreditados. Por ello no se informa un CPI/SPI favorable ni un EAC ficticio.

| Indicador | Periodo Sprint 4 | Acumulado al corte | Acumulado anterior |
|---|---|---|---|
| BAC, presupuesto al concluir | Sin BAC exclusivo por sprint. | Referencia académica: S/500 000 desarrollo; no equivale a fondos aprobados reales. | No existe cierre financiero anterior acreditado. |
| PV, valor planificado | No calculable sin línea base temporal monetaria. | No calculable. | No calculable. |
| EV, valor ganado | No calculable sin valoración monetaria del trabajo aceptado. | No calculable. | No calculable. |
| AC, costo real | Sin comprobantes o imputación real; no se asume cero. | No calculable. | No calculable. |
| SV = EV − PV; CV = EV − AC | No calculables. | No calculables. | No calculables. |
| SPI = EV/PV; CPI = EV/AC | No calculables; no dividir por datos ausentes o cero. | No calculables. | No calculables. |
| % planificado, ganado y gastado | PV/BAC, EV/BAC y AC/BAC no calculables. | No calculables. | No calculables. |
| EAC por productividad de costos | BAC/CPI no calculable. | No calculable. | No calculable. |
| EAC por costos y cronograma | AC + (BAC − EV)/(CPI × SPI) no calculable. | No calculable. | No calculable. |

**Causa e impacto:** usar el presupuesto supuesto con SP de Jira como si fueran desembolsos daría indicadores sin validez. No se selecciona una previsión EAC hasta contar con datos; después se justificará si el desempeño de costos o también el de calendario explica el saldo. No se rebaselina para esconder desviaciones. La única progresión cuantificable aquí es el estado del backlog, no EVM financiero.

## Tablero visual de seguimiento

Semáforos: verde = verificado en el alcance declarado; ámbar = validación parcial; rojo = requisito sin evidencia suficiente. No son calificaciones del profesor.

| Componente | Semáforo | Motivo / acción |
|---|---|---|
| Operación local de mapa e indicadores | Verde | Pruebas y evidencias del 14/17 de noviembre; conservar límites de estimación y datos QA. |
| EN-002 | Ámbar | Campaña limitada; ampliar antes de generalizar. |
| Playwright local | Verde | 30/30 ejecuciones y tres revalidaciones visuales; reportes, capturas y persistencia conservados. |
| Publicación manual | Verde | Web/API en Wasmer y PostgreSQL en Neon; ambos roles y entrega final persistida, 19/11. [Evidencias](../evidencias/20261119-despliegue-publico/RESULTADOS.md). |
| SUS humano y CI/CD automático | Rojo | Sin respuestas SUS ni ejecuciones Actions; el workflow de producción requiere adaptarse a Wasmer. La publicación manual no cubre esos requisitos. |
| Cierre académico y calendario | Ámbar | Elementos En curso y sin aceptación formal; acordar y registrar decisión. |

### Kanban al corte de Jira del 18/11

| Agrupación | Hecho | En curso | Total SP |
|---|---|---|---|
| Sprint 4: EHAPP-14, EHAPP-15 y EHAPP-16 | 0 elementos / 0 SP | 3 elementos / 15 SP | 15 |
| Contexto global: 12 US y 5 EN | 5 elementos / 19 SP | 12 elementos / 65 SP | 84 |

Los 19/84 SP en estado Hecho representan 22,62 % del flujo registrado, no porcentaje funcional del sistema ni aceptación de todas las historias. Se excluye EHAPP-25, registro administrativo sin SP. La distribución respeta los valores originales; no se modificó Jira en este trabajo.

### Burnup, burndown y clima del equipo

Una captura actual no proporciona el historial diario de cambios. No se dibuja una curva histórica ni una velocidad ficticia: falta exportar las transiciones y confirmar calendario/cambios de alcance. El burnup deberá mostrar trabajo aceptado y alcance por fecha; el burndown, trabajo restante y línea ideal de la línea base. Sin encuesta de clima no se asignan caritas o promedios; el proyecto individual conserva aprendizajes en su retrospectiva.

## Acciones correctivas y prevención

Se sigue el ciclo causa raíz → alternativas e impacto → decisión autorizada → ejecución → comprobación. Cambiar solo el reporte sin corregir el origen no cierra una acción.

| Hallazgo / causa | Solución aplicada o decisión | Aprendizaje / compromiso medible | Responsable |
|---|---|---|---|
| Asignación manual omitía ETA e indicadores; validación temporal incompleta. | Reutilizar evaluación de restricciones y persistir los indicadores; comprobación del 14/11. | Antes de integrar cambios, probar salida inviable y comprobar que no modifica la ruta anterior. | Jordy. |
| Script de benchmark esperaba 200 al crear un recurso. | Corregir expectativa a 201 y conservar medición, sin atribuir el error del instrumento a FastAPI. | Revisar contrato y respuesta antes de cada campaña. | Jordy. |
| Confusión entre prueba técnica y aceptación de Semana 14. | Separar informes E2E y SUS y matriz requisito/evidencia. | Ninguna cifra sin artefacto, fecha y alcance; revisar antes de exponer. | Jordy. |

Las mejoras de tráfico y contraste del 17/11 se conservan como regresión transversal en sus evidencias; no se registran como nuevos impedimentos históricos de este sprint. Consulte el [registro de impedimentos](02%20Registro%20de%20Impedimentos%20V_1_0_0.md) y la [retrospectiva](02%20Retrospectiva%20del%20Sprint%20V_1_0_0.md).


[← Volver al README principal](../../../README.md)


## Revalidación técnica — 18/11/2026

Se añaden resultados posteriores sin sustituir los cortes históricos: 145 backend y 30 ejecuciones Playwright aprobadas, cobertura combinada backend 2882/3200 ≈ 90.0625 %. La campaña amplió a cinco semillas por cada tamaño 10/50/150; 15 casos posteriores a la deduplicación verificados. Se conservó el fallo frío inicial y se corrigió además el protocolo OSRM 1×1 con regresiones y GOLD posterior. La demanda sigue siendo sintética, sobre tres destinos, y no demuestra un SLA general.

El instrumento SUS y su calculador están implementados, pero no hay respuestas humanas; por tanto no hay puntuación SUS. Existen los tres workflows localmente, validados por actionlint y sintaxis Bash, sin ejecución en GitHub y todavía sin producción al corte del 18/11. La publicación manual posterior del 19/11 consta en las evidencias enlazadas. La declaración anterior sobre ausencia de estos archivos queda sustituida por este corte; sus resultados anteriores no se reetiquetan. Las mediciones web pueden carecer de una entrada LCP elegible en canvas y no se completan artificialmente. Continúan sin acreditarse costos reales, aceptación formal o cierre administrativo.

Consulte [resultados](../evidencias/20261118-semana14/RESULTADOS.md), [rendimiento](../evidencias/20261118-semana14/RENDIMIENTO.md), [análisis E2E](03%20Analisis%20PlayWrigth%20V_1_0_0.md), [usabilidad](04%20Usabilidad%20V_1_0_0.md) y [CI/CD](12%20Automatizaci%C3%B3n%20CI-CD%20V_1_0_0.md).


## Estado documental consolidado — 19/11/2026

La URL pública y la persistencia por roles ya se comprobaron en Wasmer y Neon; [resultado y límites](../evidencias/20261119-despliegue-publico/RESULTADOS.md). Esta evidencia actualiza el estado de publicación, sin alterar las cifras locales de rendimiento/cobertura, los costos no acreditados o el calendario no confirmado. SUS real, Actions/CD automático y aceptación permanecen abiertos en las [acciones de cierre](ACCIONES_PARA_CERRAR_SPRINT4.md).
