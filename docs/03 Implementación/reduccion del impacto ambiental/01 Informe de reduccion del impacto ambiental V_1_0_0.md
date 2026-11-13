[Índice de implementación](../README.md) · [Sprint 4](../Sprint%204/README.md)

# Informe de reducción del impacto ambiental

**Proyecto:** EcoLogística Huancayo. **Responsable:** Jordy Steve Chancasanampa Torres. **Versión del contenido:** 1.1.0. **Actualización:** 13/11/2026. El nombre del archivo se conserva para respetar la ubicación de entrega; el historial Git conserva la versión 1.0.0 del 30/10.

## 1. Introducción y propósito

El informe relaciona las optimizaciones digitales de EcoLogística con su evidencia y sus límites. Adapta las ocho áreas de la guía Green IT del profesor a **Flutter Web, FastAPI/Python y PostgreSQL**; no atribuye al proyecto cifras o técnicas MERN del ejemplo.

Se distinguen dos impactos: **digital**, por cómputo, transferencia y almacenamiento; y **logístico**, por recorridos y factores de los vehículos. Reducir consultas puede evitar trabajo, pero no demuestra por sí solo cuántos kWh o gramos de CO₂ se ahorraron.

## 2. Diagnóstico actualizado y alcance de las versiones

La inspección documental y de fuentes de PFA del 13/11 identifica carga por lotes, límites del motor y caché de matrices. También identifica consultas de hasta 1000 elementos en la Web y refresco periódico de 10 segundos. Son oportunidades concretas de mejora, no una paginación visual completa ni una reducción de tráfico ya medida.

El desarrollo activo está en `D:/UC/App/ecologistica`; PFA es la copia de entrega. Las correcciones de despliegue verificadas en D el 13/11 no se adjudican automáticamente a PFA. Esta actualización modifica documentación, no sincroniza código ni ejecuta una campaña nueva de rendimiento o energía.

## 3. Adaptación de las ocho áreas de optimización

| Área de la guía | Aplicación y evidencia propias | Estado y efecto que se puede sostener |
|---|---|---|
| 1. Consultas a datos | `results()` agrupa repartidores, vehículos y detalles en [routes.py](../../../backend/app/api/routes/routes.py). El ensayo histórico registra cuatro SELECT para 1 y 4 rutas. | Implementado en PFA; evita lecturas por cada ruta en el caso probado. No es una medición energética ni de latencia general. |
| 2. Paginación | Los endpoints limitan consultas, pero [dashboard](../../../apps/web/lib/features/dashboard/presentation/screens/dashboard_screen.dart) solicita hasta 1000 registros por colección. | Parcial: el límite de API no equivale a navegación por páginas. Debe medirse payload y evitar cargar datos que el usuario no necesita. |
| 3. Imágenes y recursos | [Build histórico](../evidencias/20261030/verificacion_build.json): 40 archivos y 42.527.825 bytes en disco. | No acredita WebP/AVIF, bytes transferidos por visita ni reducción porcentual. Inventariar recursos y cabeceras antes de proponer conversiones. |
| 4. Carga diferida | Flutter organiza pantallas y listas; la revisión actual no respalda la afirmación anterior de `ListView.builder` en estas vistas. | Se corrige esa afirmación. No se declara equivalente a React.lazy ni code splitting implementado; revisar creación diferida de elementos con medición. |
| 5. Dependencias | [pubspec.yaml](../../../apps/web/pubspec.yaml) ya no declara `flutter_dotenv`; el build histórico no empaquetó `.env`. | Retiro verificable de esa dependencia/recurso. Falta una comparación de bundle para cuantificar su impacto; no quitar paquetes funcionales solo por reducir peso. |
| 6. Solicitudes HTTP | [Panel ADMIN](../../../apps/web/lib/features/dashboard/presentation/screens/dashboard_screen.dart) y [REPARTIDOR](../../../apps/web/lib/features/auth/presentation/screens/repartidor_screen.dart) refrescan cada 10 s. La caché del servidor evita repetir algunas matrices. | No se ha cuantificado ahorro HTTP por sesión. Evaluar visibilidad de pestaña, actualización selectiva y frecuencia sin perder avisos o acuses. |
| 7. Caché | [matrix.py](../../../backend/app/services/matrix.py): TTL 300 s, cuatro entradas, bloques de 40 orígenes/destinos y hasta cuatro trabajadores. En D se verificó una entrada Web con hash y revalidación de caché. | Caché vial presente; distinguir frío/caliente. El cambio Web de D corrige versión servida, pero no prueba ahorro de transferencia ni debe llamarse caché inmutable: la configuración revisada revalida recursos. |
| 8. API y procesamiento | [optimization.py](../../../backend/app/api/routes/optimization.py) acota la operación, usa un semáforo por proceso y valida restricciones antes de confirmar. [genetic.py](../../../backend/app/services/genetic.py) limita pedidos/equipos y búsqueda. | Trabajo acotado, no garantía de cumplir todos los umbrales. No se afirma compresión Brotli/Gzip ni middleware equivalente a Express sin cabeceras y medición que lo demuestren. |

## 4. Comparación de métricas y evidencia real

| Métrica | ANTES disponible | DESPUÉS / evidencia disponible | Interpretación |
|---|---|---|---|
| SELECT de consulta y serialización | Diagnóstico de lecturas por ruta; sin conteo anterior conservado en una ejecución comparable. | 4 SELECT para 1 y para 4 rutas, corte 30/10. | Se comprueba el comportamiento por lotes. No se inventa un porcentaje de reducción. |
| Motor GA, 150 pedidos/15 equipos | Línea base factible normalizada 0,6654338017 del mismo ensayo. | Candidato 0,6641792544; 7.907,60 ms, 866 evaluaciones y 40 generaciones, semilla 42. | [Ensayo sintético del 30/10](../evidencias/20261030/benchmark_genetic.json), matriz euclídea y 30 km/h. No utiliza red vial real de Huancayo ni mide flujo integrado. |
| Build Web | Sin artefacto anterior equivalente capturado. | 40 archivos, 42.527.825 bytes, corte 30/10. | Peso en disco; no transferencia de una visita ni tamaño de la compilación del 13/11. |
| Lighthouse, FCP/LCP/TBT/CLS y bytes por tarea | Sin campaña propia ANTES comparable. | Sin campaña propia DESPUÉS comparable. | Las puntuaciones de la guía MERN y del repositorio de ejemplo no se incorporan como nuestras. |
| CPU, RAM, energía y CO₂ digital por tarea | Sin límites y medición ambiental comparable. | Sin E, I y M suficientes para una intensidad de carbono propia. | No hay reducción energética o ambiental cuantificada acreditada. |

[Resultados históricos y límites](../evidencias/20261030/RESULTADOS.md). Las pruebas funcionales y la cobertura ayudan a conservar el comportamiento; no son indicadores ambientales.

## 5. Análisis ambiental y fórmulas

### Impacto logístico

Para cada ruta: **litros estimados = km / rendimiento en km/L**; **kg CO₂ estimados = km × factor en kg CO₂/km**. Conservar factores, ruta/versión, retorno y fecha utilizados; no recalcular una ruta histórica con parámetros actuales sin identificar el cambio.

Comparar rutas requiere los mismos pedidos pendientes, origen, salida y restricciones. En la [demostración propia del 08–09/11](../evidencias/20261109-validacion-danleo/CIERRE_DANLEO_20261109.md), la comparación dio el mismo tiempo y distancia. Por ello no se afirma ahorro por el color verde del mapa ni tráfico en tiempo real.

### Impacto digital

La [especificación SCI de Green Software Foundation](https://sci.greensoftware.foundation/) requiere límites y unidad funcional. Propósito de medición: una tarea completa ADMIN que consulta un plan y sus indicadores; medir aparte el seguimiento del repartidor durante un intervalo fijo.

Como método de referencia: **O = E × I** y **SCI = (O + M) / R**. E es energía en kWh; I, intensidad de carbono en gCO₂e/kWh; M, emisiones de fabricación asignadas al uso; R, la unidad funcional. Los factores y supuestos deben documentarse. Sin esos datos no se calcula un SCI de EcoLogística. Un modelo por transferencia sería una estimación parcial, no energía medida de todo el sistema.

## 6. Protocolo ANTES/DESPUÉS y evidencias necesarias

1. Fijar versión base y candidata, hardware, navegador, build de producción, mismos datos sintéticos de Huancayo y misma tarea. Incluir red, backend, BD y cliente; declarar cualquier componente no observable, como infraestructura del proveedor vial.
2. Separar caché fría y caliente. Ejecutar al menos cinco repeticiones por escenario; conservar tiempos, bytes transferidos, peticiones, lecturas SQL, CPU/RAM y errores. Informar mediana y máximo sin eliminar los resultados desfavorables.
3. Aplicar una mejora concreta y repetir con condiciones equivalentes. Si no existe una base reproducible, registrar solo la medición actual; no fabricar un ANTES.
4. Verificar que permisos, ventanas, entregas y acuses siguen correctos. Calcular reducción `(antes − después) / antes ×100` solo para la misma métrica, unidad y tarea, con un antes mayor que cero.
5. Adjuntar informes crudos saneados y capturas propias de DevTools/Lighthouse cuando proceda. En Flutter, aclarar limitaciones del renderizador y no tratar una puntuación aislada como experiencia completa. Para energía, declarar instrumento o modelo, intervalo y factores.

## 7. Relación con el Sprint 4 y seguimiento

EHAPP-15 (mapa), EHAPP-16 (dashboard) y EHAPP-14 (rendimiento) aportan tareas observables para este protocolo. El benchmark integrado ≤45 s/<30 s se prepara en el [plan S4](../Sprint%204/09%20Plan%20de%20validaci%C3%B3n%20del%20rendimiento%20V_1_0_0.md); aprobar tiempo no demuestra ahorro de energía. Las capturas y mediciones pendientes están reunidas en [Acciones S4](../Sprint%204/ACCIONES_PARA_CERRAR_SPRINT4.md).

**Conclusión del corte:** existen controles técnicos verificables para evitar trabajo innecesario, pero todavía no una reducción cuantitativa acreditada de energía o CO₂ digital. La actualización desarrolla el método y corrige afirmaciones antiguas; no declara realizada una auditoría ambiental que falta ejecutar.

## Control de cambios y fuentes

| Versión | Fecha | Cambio |
|---|---|---|
| 1.0.0 | 30/10/2026 | Diagnóstico inicial, controles y ensayos técnicos. Conservado en Git. |
| 1.1.0 | 13/11/2026 | Huancayo, ocho áreas adaptadas, estado real de listas/paginación/HTTP/caché, separación de versiones y protocolo comparable de medición. |

Fuentes docentes: «Informe de reducción del impacto ambiental y estándares de ingeniería de software», Green engineering y Green JavaScript, materiales del 26–27/10. [Ejemplo de organización Green IT](https://github.com/JulioNaupariC/EcoLog-stica-Lima/tree/main/docs/03%20Implementaci%C3%B3n/reduccion%20del%20impacto%20ambiental), usado sin sus cifras. [Estándares y guía propia](02%20Estandares%20Ingenier%C3%ADa%20de%20software%20V_1_0_0.md).
