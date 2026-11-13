# Informe 01 — Reducción del impacto ambiental (Green IT)

**Proyecto:** EcoLogística Huancayo — DistriRápido S.A.C.

| Metadato | Valor |
|---|---|
| Responsable | Jordy Steve Chancasanampa Torres; modalidad individual. |
| Versión del contenido | 1.2.0, 13/11/2026, America/Lima. Se conserva el nombre oficial del archivo. |
| Código de entrega examinado | PFA, `ad8012c`; el código funcional no cambia con esta actualización documental. |
| Antecedente ANTES disponible | `66f25c8`: consultas de rutas por registro y declaración de dotenv. No existe una campaña ambiental completa de ese commit. |
| DESPUÉS disponible | Fuentes de PFA y ensayos históricos enlazados; desarrollo activo en D diferenciado. No se inventa una medición ambiental comparable. |
| Guía de estructura | [Informe 01 del ejemplo](https://github.com/JulioNaupariC/EcoLog-stica-Lima/blob/main/docs/03%20Implementaci%C3%B3n/reduccion%20del%20impacto%20ambiental/01%20Informe%20de%20reduccion%20del%20impacto%20ambiental%20V_1_0_0.md), consultado el 13/11. Sus resultados ECL no son resultados EHAPP. |

## 1. Introducción y propósito

EcoLogística organiza repartos de Huancayo mediante Flutter, FastAPI y PostgreSQL. Este informe sigue los apartados del documento de ejemplo: diagnóstico, ocho optimizaciones, comparación, modelo ambiental, evidencias y versiones. Explica el trabajo propio y la evidencia necesaria para cuantificar su efecto. El [Informe 02](02%20Estandares%20Ingenier%C3%ADa%20de%20software%20V_1_0_0.md) desarrolla los estándares y su correspondencia.

La huella digital del software y el CO₂ logístico de los vehículos se evalúan por separado. Menos consultas o bytes pueden evitar trabajo; no demuestran por sí solos energía o emisiones ahorradas.

## 2. Diagnóstico inicial y línea base propia

| Aspecto | Observación verificable |
|---|---|
| Consultas originales | El [código `66f25c8`](https://github.com/DartBlackLink/PFA/blob/66f25c8/backend/app/api/routes/routes.py) serializaba cada ruta con lecturas de sus recursos y detalles. |
| Backend actual | [Consulta por lotes](../../../backend/app/api/routes/routes.py), límites de API, caché vial y motor acotado. |
| Frontend actual de PFA | [Dashboard](../../../apps/web/lib/features/dashboard/presentation/screens/dashboard_screen.dart) solicita hasta 1000 elementos por colección y refresca cada 10 s. No equivale a paginación visible ni carga diferida completa. |
| Entorno de medición ambiental | No hay campaña propia ANTES/DESPUÉS con equipo, navegador, red, páginas y caché fijados. No se asignan especificaciones del equipo del ejemplo a este proyecto. |
| Versiones | D contiene desarrollo posterior al código de entrega. No se mezclan sus builds o resultados con los de PFA para construir una comparación. |

## 3. Las ocho optimizaciones

### 3.0 Equivalencias de la guía con nuestro stack

| Técnica de referencia | Equivalente que corresponde evaluar aquí |
|---|---|
| Mongoose `.select()` / `.lean()` e índices | Proyección y carga por lotes en SQLAlchemy, consultas e índices PostgreSQL; comprobar planes, no asumir beneficio. |
| `skip` / `limit` | `offset` / `limit` en API y navegación de páginas en Flutter. |
| Imágenes, fuentes y recursos | Inventario de assets Flutter, formatos adecuados y tamaño transferido. |
| React.lazy / división de código | Evaluación propia de carga de recursos y construcción diferida en Flutter; no afirmar que usa React. |
| Dependencias y APIs | Necesidad funcional y costo del paquete Dart/Python; revisar el artefacto resultante. |
| HTTP, caché y compresión | Proveedor vial, cliente HTTP, FastAPI/Starlette y servidor de estáticos utilizado. |

### 3.1 Optimización 1 — Consultas y serialización

**ANTES:** el listado invocaba la serialización individual por ruta. Fragmento propio conservado en `66f25c8`:

```python
driver=db.get(Repartidor,route.repartidor_id)
vehicle=db.get(Vehiculo,route.vehiculo_id)
```

**DESPUÉS:** [results()](../../../backend/app/api/routes/routes.py) reúne recursos y detalles de todas las rutas del lote y luego serializa con esos datos. El [ensayo del 30/10](../evidencias/20261030/RESULTADOS.md) registró cuatro SELECT tanto para una como para cuatro rutas, sin autenticación.

**Estado:** cambio implementado y probado históricamente. No existe conteo ANTES comparable para publicar una reducción porcentual ni se afirma una proyección mínima de todas las columnas implementada.

### 3.2 Optimización 2 — Paginación de datos

**ANTES/DESPUÉS observado:** el endpoint original ya tenía `skip` y `limit`; PFA conserva límites, pero la Web consulta hasta 1000 registros. No se presenta como una paginación nueva de 12 registros tomada del ejemplo.

**Estado:** parcial. Debe evaluarse carga de páginas bajo demanda, payload y respuesta con los mismos registros y permisos. Cambiarlo requiere una intervención de código posterior, no realizada en este informe.

### 3.3 Optimización 3 — Imágenes, fuentes y recursos estáticos

**Evidencia:** [build del 30/10](../evidencias/20261030/verificacion_build.json): 40 archivos, 42.527.825 bytes en disco. Es un inventario de aquel artefacto, no transferencia de una visita.

**Estado:** no existe conversión propia WebP/AVIF ni reducción de fuentes cuantificada acreditada. Inventariar recursos de la versión candidata, distinguir assets propios de teselas externas y conservar tamaño original/optimizado antes de afirmar ahorro.

### 3.4 Optimización 4 — Carga diferida y división de código

**Diagnóstico:** la estructura de pantallas Flutter no acredita automáticamente carga diferida. Se retiró la afirmación anterior de `ListView.builder`, que no corresponde a las vistas actuales revisadas.

**Estado:** optimización por evaluar. La comparación debe medir creación de elementos, memoria, recursos descargados y navegación; `React.lazy` y los chunks de Vite pertenecen al ejemplo, no a nuestra implementación.

### 3.5 Optimización 5 — Dependencias y APIs

**ANTES:** `66f25c8:apps/web/pubspec.yaml` declaraba `flutter_dotenv` y `.env` como asset. **DESPUÉS:** el [pubspec actual](../../../apps/web/pubspec.yaml) ya no los declara y el build histórico verificó ausencia de configuración privada empaquetada.

**Estado:** retiro verificable; no existe un antes/después equivalente del bundle que permita cuantificar ahorro. Se conservan las dependencias funcionales y no se inventa su peso evitado.

### 3.6 Optimización 6 — Reducción de solicitudes HTTP

**Diagnóstico:** paneles ADMIN/REPARTIDOR actualizan cada 10 s. La [caché de matrices](../../../backend/app/services/matrix.py) devuelve `provider_calls: 0` cuando hay un acierto válido, pero esto no significa cero solicitudes del navegador.

**Estado:** medir peticiones por la misma tarea e intervalo y evaluar actualización selectiva/visibilidad de pestaña. Cualquier mejora debe conservar avisos, acuse de ruta y datos actuales. No se afirma que se hayan implantado SVG inline o eliminado todas las peticiones redundantes.

### 3.7 Optimización 7 — Caché de API, matrices y estáticos

**Control presente en PFA:** cuatro matrices, TTL 300 s, bloques de 40 orígenes/destinos y hasta cuatro trabajadores. La clave incluye proveedor y coordenadas; no implica tráfico en vivo.

**Cambio posterior de D:** se verificó entrada Web con hash y cabeceras de revalidación. Es una corrección de versión servida; no se presume sincronizada a PFA ni se presenta como caché inmutable o ahorro medido. Comparar frío/caliente por separado y no compartir respuestas privadas entre usuarios.

### 3.8 Optimización 8 — Compresión Gzip/Brotli

**Estado:** no hay ensayo propio de cabeceras, cuerpos transferidos y costo CPU que acredite esta mejora en PFA. La configuración Web de D revisada no justifica afirmar Gzip/Brotli implementado.

**Evaluación prevista:** misma respuesta funcional con `Accept-Encoding: identity` y codificación habilitada; registrar `Content-Encoding`, `Vary`, bytes, tiempos y uso de CPU. No se modifica FastAPI, Nginx o Docker en esta tarea documental.

## 4. Comparación ANTES vs. DESPUÉS

### 4.1 Condiciones y variaciones declaradas

No se enfrenta un build de desarrollo de una versión con uno release de otra como si toda diferencia procediera de una optimización. Deben fijarse código, datos, navegador, hardware, red, servidor y caché. Protocolo propio: al menos cinco repeticiones por escenario, conservando errores y resultados crudos.

### 4.2 Páginas y métricas

**SM = sin medición propia comparable**, no cero ni incumplimiento demostrado.

| Página / rol | ANTES | DESPUÉS | Datos que deben capturarse |
|---|---|---|---|
| Login | SM | SM | Performance, FCP, LCP, TBT, CLS, bytes y peticiones. |
| Dashboard / ADMIN | SM | SM | Mismas métricas y alcance de los indicadores. |
| Flota / ADMIN | SM | SM | Misma cantidad de registros y operación. |
| Mi ruta / REPARTIDOR | SM | SM | Misma ruta/versión, teselas y estado de caché identificados. |

### 4.3 Umbrales de referencia de la guía

El ejemplo utiliza Performance ≥90, FCP ≤1 s, LCP ≤1,4 s, TBT ≤85 ms, CLS ≤0,02 y transferencia ≤1,1 MB. Se conservan como referencia para acordar la campaña propia, no como resultados obtenidos o una aceptación docente de nuestro stack. Su comprobación está SM. Los umbrales propios RNF-01 de optimización ≤45 s/replan <30 s se evalúan aparte en el [protocolo S4](../Sprint%204/09%20Plan%20de%20validaci%C3%B3n%20del%20rendimiento%20V_1_0_0.md).

### 4.4 API y otras mediciones técnicas conservadas

| Medición | Resultado real y alcance |
|---|---|
| Consultas SQL | 4 SELECT para 1 y 4 rutas, 30/10; no latencia/energía general. |
| Motor 150/15 | [7.907,60 ms](../evidencias/20261030/benchmark_genetic.json), semilla 42, 866 evaluaciones/40 generaciones; datos sintéticos y matriz euclídea, no red vial real de Huancayo. |
| Objetivo del mismo ensayo | Base 0,6654338017; candidato 0,6641792544. Valores normalizados, no kg CO₂. |
| Tiempo y bytes HTTP por endpoint | SM como ANTES/DESPUÉS comparable. Registrar cuerpo, codificación y respuesta válida; no copiar la media de 20 respuestas del ejemplo. |

### 4.5 Explicación del efecto

La carga por lotes evita trabajo por registro; la caché puede evitar consultas al proveedor. Todavía no se atribuye a esas medidas un porcentaje ambiental. Calcular `(antes − después) / antes ×100` solo con la misma métrica/tarea y un antes mayor que cero. Verificar además que permisos, entregas y restricciones siguen correctos.

## 5. Impacto ambiental: modelo, resultados y límites

### 5.1 Modelo

Siguiendo la organización de la guía, se contempla [SWDM v4](https://sustainablewebdesign.org/estimating-digital-emissions/) para estimar impacto a partir de transferencia y supuestos documentados de infraestructura/dispositivo. En EcoLogística aún no se ejecutó ese cálculo: no se importa el script ni los factores usados por ECL como si fueran propios.

SCI es distinto: [GSF](https://sci.greensoftware.foundation/) define una tasa por unidad funcional y frontera; se desarrolla en el Informe 02. Ni SWDM ni SCI se confunden con combustible/CO₂ de vehículos.

### 5.2 Resultados por visita y proyección anual

| Resultado digital | Situación de EcoLogística |
|---|---|
| kWh/visita y g CO₂e/visita | Sin estimación propia ejecutada: faltan bytes medidos y modelo/factores fijados. |
| Reducción ANTES/DESPUÉS | No cuantificable con la evidencia disponible. |
| kg CO₂e/año | Sin proyección: falta frecuencia de uso acreditada. No se copian las 4500 visitas/año del ejemplo. |

Cuando se disponga de datos: `kg CO₂e/año = g CO₂e/visita × visitas/año /1000`, declarando el origen de ambos valores. Para vehículos: litros = km/(km/L) y kg CO₂ = km×factor del vehículo conservado en la planificación. La [comparación propia del 08–09/11](../evidencias/20261109-validacion-danleo/CIERRE_DANLEO_20261109.md) dio empate; no se afirma ahorro logístico por mostrar una línea verde.

### 5.3 Límites

Una estimación por bytes no es potencia medida; frío, caliente y visita recurrente son escenarios distintos. La geografía de los repartos no identifica por sí sola la red eléctrica del servidor o proveedor. Sin límites, factores y unidad funcional equivalentes no se declara una reducción ambiental ni una calificación de sostenibilidad.

## 6. Evidencias Lighthouse y auditoría en CI

No se ha generado una campaña Lighthouse/Network propia ni un pipeline Green IT completo en este encargo. La campaña deberá guardar versión, configuración, resultados y capturas saneadas en `reduccion del impacto ambiental/evidencias/` cuando exista; un fallo no se ocultará con `|| true`. Para Flutter, contrastar la medición con el renderizador, controles reales y tareas completadas, no únicamente con una puntuación.

Se conservan [resultados técnicos](../evidencias/20261030/RESULTADOS.md), benchmark y verificación del build. Las tareas para la evidencia faltante están en [Acciones S4](../Sprint%204/ACCIONES_PARA_CERRAR_SPRINT4.md).

## 7. Gestión de versiones y secuencia Git

### 7.1 Secuencia propia

Histórico `66f25c8` → evidencia técnica del 30/10 → consolidación PFA `c53d5bc` → expediente S4 `849961f` → primera revisión Green IT `ad8012c` → presente alineación estructural. Ninguna secuencia de commits prueba por sí sola un ahorro ambiental; se conservan sus evidencias y alcance.

### 7.2 Historial de versiones

| Contenido | Fecha | Cambio |
|---|---|---|
| 1.0.0 | 30/10/2026 | Diagnóstico y controles iniciales. |
| 1.1.0 | 13/11/2026 | Corrección de afirmaciones antiguas y vínculo con S4. |
| 1.2.0 | 13/11/2026 | Estructura directa del Informe 01 de la guía: ocho apartados individuales, comparación, modelo ambiental, evidencia y Git; datos propios y límites explícitos. |

## 8. Límites generales del informe

No se implementaron nuevas optimizaciones ni se sincronizó D con PFA al redactar. Las ocho áreas no se presentan como ocho mejoras terminadas. Se preservan nombres, ubicación e historia; los resultados del ejemplo no se atribuyen a EcoLogística Huancayo.

[Informe 02](02%20Estandares%20Ingenier%C3%ADa%20de%20software%20V_1_0_0.md) · [Sprint 4](../Sprint%204/README.md) · [Índice de implementación](../README.md)
