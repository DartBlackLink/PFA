# Informe 02 — Estándares de ingeniería de software y guía de desarrollo verde

**Proyecto:** EcoLogística Huancayo — DistriRápido S.A.C.

| Metadato | Valor |
|---|---|
| Responsable | Jordy Steve Chancasanampa Torres; modalidad individual, sin revisor ficticio. |
| Versión del contenido | 1.2.0, 13/11/2026, America/Lima. Se conserva el nombre oficial del archivo. |
| Código de entrega examinado | PFA `ad8012c`; desarrollo activo D diferenciado. |
| Guía de estructura | [Informe 02 del ejemplo](https://github.com/JulioNaupariC/EcoLog-stica-Lima/blob/main/docs/03%20Implementaci%C3%B3n/reduccion%20del%20impacto%20ambiental/02%20Estandares%20Ingenier%C3%ADa%20de%20software%20V_1_0_0.md); sus personas, tickets y cifras no se trasladan a EHAPP. |

## 1. Objeto, alcance y estado de la evidencia

Se sigue el orden del documento de guía: calidad ISO, principios GSF, correspondencia WSG, reglas por capa, matriz de las ocho optimizaciones y cierre. Se adapta a Flutter/FastAPI/PostgreSQL. El [Informe 01](01%20Informe%20de%20reduccion%20del%20impacto%20ambiental%20V_1_0_0.md) detalla la evidencia y separa medidas presentes de mejoras propuestas.

La redacción y las fuentes están actualizadas; no se declara una evaluación ambiental ejecutada ni conformidad integral con todas las normas. El [Sprint 4](../Sprint%204/README.md) propone mapa, dashboard y rendimiento, 15 SP; Green IT acompaña esa evaluación sin inventar tickets o SP adicionales.

## 2. ISO/IEC 25010 y calidad de producto

Se utiliza [ISO/IEC 25010:2023](https://www.iso.org/standard/78176.html) como referencia de calidad, sin certificación. Su modelo vigente contiene nueve características; no se trasladan automáticamente numerales de la edición anterior.

| Aspecto seleccionado | Aplicación a nuestro proyecto | Evidencia y límite |
|---|---|---|
| Comportamiento temporal | Tiempo de consulta y cálculo bajo carga reproducible. | Ensayo histórico del motor; el flujo completo 150/15 exige medición aparte. |
| Utilización de recursos | Lecturas, bytes, solicitudes y memoria por tarea. | Carga por lotes con cuatro SELECT en el ensayo; no kWh medidos. |
| Capacidad | Pedidos/equipos y concurrencia admitidos sin perder factibilidad. | Límites del motor y casos de borde; no capacidad máxima global acreditada. |
| Modularidad | Separar API, servicios viales, motor y presentación. | Fuentes propias; no se afirma ahorro energético por la mera separación de archivos. |
| Analizabilidad | Localizar una causa y relacionar cambios con su prueba. | JUnit, reportes fechados, casos y manifiestos; evitar mezclar versiones D/PFA. |

Como referencias complementarias se mantienen [ISO/IEC/IEEE 12207:2026](https://www.iso.org/standard/90219.html) para ciclo de vida, [29119-2:2021](https://www.iso.org/standard/79428.html) para procesos de prueba y [33001:2015](https://www.iso.org/standard/54175.html) para conceptos de evaluación de procesos. No se deduce madurez CMMI o certificación por citarlas.

## 3. Principios seleccionados de Green Software Foundation

| Principio | Aplicación propia | Evidencia necesaria |
|---|---|---|
| Eficiencia de carbono | Reducir emisiones por la misma tarea digital útil. | Frontera, factores y comparación equivalente. |
| Eficiencia energética | Evitar trabajo innecesario sin perder resultados. | Energía o modelo explícito, además de tiempos/bytes. |
| Eficiencia de hardware | Examinar recursos y fabricación asignados al uso. | Datos de hardware, vida útil y asignación; no inferirlos de Lighthouse. |
| Medición | Mantener una unidad funcional y comunicar incertidumbre. | Método, entradas, versión y cálculo reproducible. |

### 3.1 Distinción entre SCI y SWDM v4

[SCI](https://sci.greensoftware.foundation/) expresa `SCI = (E × I + M) / R`: energía operativa, intensidad de carbono, emisiones de hardware asignadas y unidades funcionales. Fijar componentes y período; no contabilizar el CO₂ de vehículos como emisiones del servidor.

[SWDM v4](https://sustainablewebdesign.org/estimating-digital-emissions/) utiliza transferencia y supuestos de infraestructura/dispositivo para estimar emisiones. No es una lectura de consumo eléctrico ni acredita por sí solo un SCI completo. En EcoLogística faltan entradas y cálculo propios; no se importan factores o cifras del ejemplo sin verificar su pertinencia.

## 4. WSG: versión, numeración y correspondencia

Se fija la [publicación W3C del 16/10/2026](https://www.w3.org/TR/2026/DNOTE-web-sustainability-guidelines-20261016/), **Group Note Draft**, no Recomendación final. El mapeo siguiente es una interpretación de aplicación, no declaración de conformidad.

### 4.1 Equivalencias de la guía docente y la publicación fijada

| Tema empleado en la guía docente | Apartado oficial equivalente | Aplicación a EcoLogística |
|---|---|---|
| Imágenes/recursos, rotulado 1.2 en el modelo de clase | 2.9 — Optimize media to reduce resource use | Inventario de assets propios y externos; no inventar una conversión WebP. |
| Caché, rotulada 2.4 en el modelo de clase | 4.2 — Optimize caching and support offline access | Matrices y recursos con vigencia, privacidad e invalidación. |
| Red/compresión, rotulada 3.1 en el modelo de clase | 4.3 — Reduce data transfer with compression | Medir bytes y costo CPU de respuestas equivalentes. |

En esa publicación, 1.2 trata las capas de orientación, 2.4 los recorridos de usuario y 3.1 los objetivos de rendimiento/energía; no se les atribuyen títulos alternativos. Se evita copiar una numeración del ejemplo sin fijar su versión.

## 5. Guía de desarrollo verde para nuestro stack

### 5.1 Backend — FastAPI, SQLAlchemy y PostgreSQL

| Regla de trabajo | Cómo se comprueba |
|---|---|
| Evitar lecturas por cada fila y seleccionar datos necesarios. | Conteo SQL y contenido/propiedad equivalente; no asumir que toda carga por lotes ya es proyección mínima. |
| Paginar y validar parámetros sin debilitar permisos. | Registros devueltos, límites, tiempos y payload. |
| Acotar cálculo y caché; preservar transacciones e idempotencia. | Semilla, restricciones, tiempo, caché fría/caliente y ausencia de duplicados. |
| Evaluar compresión/validación condicional con evidencia. | Cabeceras, cuerpos, autorizaciones y costo CPU; no afirmar middleware nuevo que no existe. |

### 5.2 Frontend — Flutter Web

| Regla de trabajo | Cómo se comprueba |
|---|---|
| Cargar datos/elementos de acuerdo con la tarea visible. | Memoria, bytes y navegación; la consulta actual de hasta 1000 elementos sigue siendo oportunidad de mejora. |
| Revisar el refresco de 10 s sin perder avisos. | Peticiones por intervalo, visibilidad de pestaña y acuse efectivo. |
| Justificar paquetes, fuentes, iconos y medios. | pubspec y artefacto con sus versiones; no usar conclusiones de React/Vite para Dart. |
| Confirmar el build servido y la caché real. | Hash/cabeceras y recuperación; la corrección de D no se presume incorporada a PFA. |

## 6. Matriz de mapeo directo de las ocho optimizaciones

| N.º / área del Informe 01 | Calidad pretendida | Principio GSF | Correspondencia WSG | Evidencia propia / estado |
|---|---|---|---|---|
| 1. Consultas | Recursos y análisis. | Energía/hardware. | 3.1: objetivos medibles. | Carga por lotes histórica; falta comparación ambiental. |
| 2. Paginación | Capacidad y tiempo. | Trabajo proporcional. | 2.4: tarea eficiente. | API limitada; paginación visual parcial. |
| 3. Medios/fuentes | Recursos del cliente. | Energía/hardware. | 2.9: medios. | Inventario pendiente; build histórico diferenciado. |
| 4. Carga diferida | Recursos y modularidad. | Trabajo necesario. | 3.7: recursos no críticos. | Evaluación Flutter pendiente; no React.lazy. |
| 5. Dependencias | Mantenibilidad/recursos. | Hardware/energía. | 3.12: dependencias. | Retiro de dotenv verificable; ahorro no cuantificado. |
| 6. HTTP | Recursos y tiempo. | Energía. | 2.4: pasos/recargas. | Polling actual identificado; reducción no medida. |
| 7. Caché | Tiempo y fiabilidad. | Evitar repetición. | 4.2: caché/offline. | Caché vial presente; medir frío/caliente. |
| 8. Compresión | Transferencia y CPU. | Energía/carbono. | 4.3: compresión. | Sin medición ni implementación nueva acreditada. |

Es una correspondencia temática y no ocho mejoras ambientales aprobadas. Seguridad y accesibilidad permanecen como condiciones de conservación funcional: [OWASP S4](../Sprint%204/06%20Seguridad%20OWASP%20V_1_0_0.md) y [WCAG S4](../Sprint%204/07%20Accesibilidad%20WCAG%20V_1_0_0.md).

## 7. Método de comprobación y condiciones de cierre

Cada cambio debe enlazar ANTES de un commit propio, DESPUÉS, equivalencia funcional, medición y versión. Conservar resultados fallidos, capturas y datos originales; no ocultar errores de CI ni atribuir a una campaña futura los resultados previos.

| Corte | Resultado de calidad propio | Interpretación |
|---|---|---|
| 30/10 | 94 backend, 58 Flutter, cobertura combinada 91,39 %. | Histórico del incremento; no medición ambiental. |
| [04/11, Sonar](../evidencias/20261104-cierre/SONARQUBE_ACTUAL.md) | ecologisticas2.1: gate OK, cobertura backend 90,9 %. | Último resultado conservado de ese análisis, no Sonar nuevo de S4. |
| [08–09/11, PFA](../evidencias/20261109-validacion-danleo/CIERRE_DANLEO_20261109.md) | 127 backend, 83 Flutter y 90,88 % combinado backend. | Antecedente de entrega con sus límites documentados. |
| 13/11, D | 131 backend, 86 Flutter, 90,01 % combinado backend. | Desarrollo local; reportes en `D:/UC/App/ecologistica/reports/validacion_persistente_20261113`. No acredita automáticamente el código PFA ni ahorro digital. |

La última cobertura local resulta de 2214/2377 líneas y 498/636 ramas. No mide toda Flutter ni porcentaje de funciones correctas. El cierre Green IT requiere la campaña comparable, explicación de cambios y revisión real; sigue las [acciones S4](../Sprint%204/ACCIONES_PARA_CERRAR_SPRINT4.md).

## 8. Referencias verificadas

Fuentes normativas y técnicas enlazadas en sus apartados: ISO 25010/12207/29119/33001, GSF SCI, SWDM v4 y WSG fijado. Fuentes propias: [Informe 01](01%20Informe%20de%20reduccion%20del%20impacto%20ambiental%20V_1_0_0.md), [trazabilidad S4](../Sprint%204/08%20Trazabilidad%20y%20versionamiento%20V_1_0_0.md) y materiales Green IT del profesor. El ejemplo aporta el orden del informe, no evidencia o autoridad sobre la aceptación del proyecto propio.

## 9. Historial de versiones

| Contenido | Fecha | Cambio |
|---|---|---|
| 1.0.0 | 30/10/2026 | Relación inicial de estándares. |
| 1.1.0 | 13/11/2026 | Actualización de referencias, guía verde y relación S4. |
| 1.2.0 | 13/11/2026 | Organización directa del Informe 02 de la guía: ISO, GSF, SCI/SWDM, WSG, reglas por capa, matriz de ocho áreas y cierre, adaptados a Flutter. |

[Informe 01](01%20Informe%20de%20reduccion%20del%20impacto%20ambiental%20V_1_0_0.md) · [Sprint 4](../Sprint%204/README.md) · [Índice de implementación](../README.md)
