[Índice de implementación](../README.md) · [Sprint 4](../Sprint%204/README.md)

# Estándares de ingeniería de software y guía de desarrollo verde

**Proyecto:** EcoLogística Huancayo. **Responsable:** Jordy Steve Chancasanampa Torres. **Versión del contenido:** 1.1.0. **Actualización:** 13/11/2026. Se conserva el nombre de archivo solicitado y la versión anterior en Git.

## 1. Propósito y criterio de aplicación

Relacionar referencias de calidad, pruebas, seguridad, accesibilidad y sostenibilidad con decisiones verificables de Flutter Web/FastAPI/PostgreSQL. Se actualiza el documento del 30/10 y se enlaza con el Sprint 4. Las referencias orientan prácticas: este informe no acredita certificación ISO, madurez CMMI ni conformidad integral OWASP/WCAG.

## 2. Referencias y prácticas propias

| Referencia | Aplicación a EcoLogística | Evidencia / límite |
|---|---|---|
| [ISO/IEC/IEEE 12207:2026](https://www.iso.org/standard/90219.html) | Conectar requisitos, diseño, desarrollo, verificación y mantenimiento; identificar responsables y cambios. | [Trazabilidad S4](../Sprint%204/08%20Trazabilidad%20y%20versionamiento%20V_1_0_0.md), sprints separados y migraciones. Alineamiento de prácticas, no evaluación completa de la norma. |
| [ISO/IEC 25010:2023](https://www.iso.org/standard/78176.html) | Evaluar eficiencia, funcionalidad, fiabilidad, seguridad e interacción mediante requisitos medibles. | RNF y criterios por historia. La edición actual incorpora nueve características; no se presenta el modelo anterior de ocho como si fuera el vigente. |
| [ISO/IEC/IEEE 29119-2:2021](https://www.iso.org/standard/79428.html) | Preparar condiciones, casos, resultados y gestión de pruebas. | GOLD/feliz/infeliz/borde, JUnit y revisión de fallos. No se afirma aplicar todas sus partes ni un proceso certificado. |
| [ISO/IEC 33001:2015](https://www.iso.org/standard/54175.html) | Usar conceptos de evaluación y mejora del proceso. | Causas y compromisos en retrospectivas. ISO/IEC 15504/CMMI se conservan como antecedentes de clase; no se atribuye nivel de madurez. |
| [OWASP Top 10:2025](https://top10.owasp.org/2025/) | Control del servidor por rol/propietario, entradas, sesiones, integridad y errores. | [Plan S4](../Sprint%204/06%20Seguridad%20OWASP%20V_1_0_0.md) y pruebas propias anteriores. No equivale a un pentest integral. |
| [WCAG 2.1 AA](https://www.w3.org/TR/WCAG21/) | Alternativa textual al mapa, foco, errores, contraste y reflujo. | [Matriz S4](../Sprint%204/07%20Accesibilidad%20WCAG%20V_1_0_0.md); falta completar evaluación manual aplicable, no basta una captura. |
| [W3C WSG](https://www.w3.org/TR/web-sustainability-guidelines/) | Reducir recursos innecesarios y diseñar tareas comprensibles, medibles y reutilizables. | Guía de sostenibilidad en **Group Note Draft, 16/10/2026**; es trabajo en curso, no una Recomendación W3C ni certificación obtenida. |
| [Green Software Foundation / SCI](https://sci.greensoftware.foundation/) | Delimitar componentes y unidad funcional; separar energía, intensidad y fabricación del hardware. | [Informe ambiental](01%20Informe%20de%20reduccion%20del%20impacto%20ambiental%20V_1_0_0.md). No se ha calculado un SCI propio con datos suficientes. |

Las ediciones se verificaron al actualizar este informe. Se conserva la referencia histórica usada en clase sin reescribir resultados anteriores como si se hubieran evaluado con la edición nueva.

## 3. Guía de desarrollo verde adaptada al proyecto

| Capa | Práctica y comprobación | Estado de la afirmación |
|---|---|---|
| PostgreSQL/SQLAlchemy | Evitar lecturas dentro de cada fila; consultar por lotes y verificar planes/índices antes de cambios de esquema. | Carga por lotes demostrada en el ensayo histórico; no se afirma haber ejecutado un EXPLAIN nuevo. |
| API y listados | Validar límite/filtros, conservar autorización y medir tamaño/tiempo; solicitar solo el bloque necesario. | API con límites; la Web pide hasta 1000 elementos. Paginación visual completa y proyecciones específicas requieren revisión, no se declaran realizadas. |
| Motor genético | Fijar población, generaciones, tiempo y concurrencia; conservar semilla, restricciones y factibilidad. | Controles existentes. El benchmark integrado 150/15 sigue su protocolo, sin reducir datos o restricciones para aprobar. |
| Red vial | Caché acotada con clave y expiración; conservar origen y edad del dato, validar matrices y geometrías. | TTL 300 s/cuatro entradas en PFA. No usar matrices antiguas como tráfico observado ni representar fallos con rutas inventadas. |
| Flutter y recursos | Evaluar dependencias, renderización, listas, iconos y fuentes; comparar artefactos equivalentes antes de declarar ahorro. | No trasladar React.lazy, `.lean()` o Bundlephobia como técnicas implementadas en Dart/Python. El retiro de dotenv está documentado; su ahorro no está cuantificado. |
| Solicitudes y avisos | Medir el refresco cada 10 s y valorar actualizaciones selectivas y pausas de trabajo no visible. | Oportunidad identificada; cualquier cambio futuro debe conservar notificación y acuse efectivo de rutas. |
| Servidor Web | Comprobar build servido, compresión, caché e invalidación mediante contenido y cabeceras reales. | Entrada con hash/revalidación verificada en D; no se presume sincronizada a PFA ni se afirma Brotli/Gzip o caché inmutable sin evidencia. |
| Repositorio y calidad | Evitar secretos, cachés, builds y duplicados; versionar fuentes, pruebas y evidencia seleccionada. | Publicación documental separada del código funcional. Una exclusión de Git no demuestra que un secreto no esté empaquetado. |

## 4. Matriz de mapeo entre optimización, calidad y sostenibilidad

| Intervención o evaluación | Calidad que se pretende mejorar | Indicador propio que debe conservarse |
|---|---|---|
| Consultas por lotes | Eficiencia de recursos sin perder permisos. | SELECT y registros devueltos para el mismo escenario. |
| Paginación y actualización selectiva | Tiempo de respuesta y uso de red/memoria. | Bytes transferidos, solicitudes y tiempos por tarea. |
| Límites GA y caché vial | Capacidad y comportamiento temporal. | Tiempo, memoria, caché fría/caliente y factibilidad del mismo dataset. |
| Recursos y entrega Web | Transferencia y funcionamiento del cliente. | Artefacto, cabeceras, CPU/TBT cuando aplique, y comportamiento en ambos temas/tamaños. |
| Seguridad/accesibilidad | Protección y uso correcto del producto. | Casos negativos, teclado, lector y estados sin pérdida de funciones. |

Estos indicadores técnicos ayudan a identificar trabajo evitable. Solo se convierten en una estimación ambiental cuando existen método, factores, límites y unidad funcional explícitos. La corrección funcional tiene prioridad frente a una reducción aparente del consumo.

## 5. Calidad, versiones y evidencia vigente

| Corte y ámbito | Resultado propio conservado | Tratamiento |
|---|---|---|
| 30/10, incremento inicial | 94 backend, 58 Flutter, cobertura combinada 91,39 %; Sonar 91,4 %. | Histórico: no es el resultado actual del Sprint 4. |
| [04/11, SonarQube](../evidencias/20261104-cierre/SONARQUBE_ACTUAL.md) | Proyecto ecologisticas2.1, gate OK/PASSED, cobertura backend 90,9 %; líneas 93,8 % y ramas 79,1 %. | Sustituye la referencia de «último análisis» del documento anterior, conservando aquel corte. No se atribuye a Flutter ni a una ejecución nueva del 13/11. |
| [08–09/11, entrega documentada en PFA](../evidencias/20261109-validacion-danleo/CIERRE_DANLEO_20261109.md) | 127 backend, 83 Flutter y 90,88 % combinado backend en sus respectivas ejecuciones. | Antecedente de la copia de entrega, con límites Android/Web indicados en el informe. |
| 13/11, desarrollo activo en D | 131 backend y 86 Flutter; 90,01 % combinado backend; análisis sin incidencias y GOLD Web persistente. | Informes locales: `D:/UC/App/ecologistica/reports/validacion_persistente_20261113`. No se copiaron fuentes ni se convirtió este resultado en evidencia del código PFA mediante esta corrección documental. |

La cobertura del 13/11 combina 2214/2377 líneas y 498/636 ramas: 90,00995685 %, redondeado a 90,01 %. No es la cobertura de todo el proyecto ni una nueva medición de Sonar. Un porcentaje menor entre cortes no demuestra deterioro por sí solo: revisar código, plataforma, ramas incluidas y denominador.

## 6. Calidad continua y condiciones de entrega

No se afirma que exista un pipeline Green IT completo solo porque el ejemplo contiene un workflow. Para incorporarlo posteriormente: ejecutar análisis y pruebas pertinentes, guardar reportes de la misma versión, realizar comparación ambiental reproducible y bloquear el cierre cuando falle un criterio obligatorio. No ignorar errores de Lighthouse o pruebas con `|| true` para presentar un pase.

La documentación S4 define mapa/dashboard/rendimiento con 15 SP propuestos, sin duplicar EHAPP-13 del S3. Seguridad y accesibilidad son controles transversales. La aceptación exige revisión real y evidencia por criterio; la modalidad individual no autoriza inventar un par revisor.

## 7. Seguimiento y control de cambios

Las capturas, mediciones ANTES/DESPUÉS, revisión manual y alineación D/PFA se gestionan en [Acciones S4](../Sprint%204/ACCIONES_PARA_CERRAR_SPRINT4.md). La [matriz S4](../Sprint%204/08%20Trazabilidad%20y%20versionamiento%20V_1_0_0.md) mantiene las claves vigentes y los alias históricos. Este informe actualiza la documentación; no declara completadas las tareas propuestas.

| Versión | Fecha | Cambio |
|---|---|---|
| 1.0.0 | 30/10/2026 | Relación inicial de estándares y evidencias del incremento. |
| 1.1.0 | 13/11/2026 | Referencias verificadas, WSG identificado como borrador, guía verde propia, ocho áreas conectadas y resultados separados por corte/versión y repositorio. |
