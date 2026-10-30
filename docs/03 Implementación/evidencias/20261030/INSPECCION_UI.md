# Inspección técnica de usabilidad

Método: inspección del flujo por el agente de desarrollo, pruebas Flutter y revisión visual de la Web. No es un estudio con participantes, una validación independiente ni una encuesta SUS. Severidad: 0 sin defecto observado; 1 menor; 2 importante; 3 grave; 4 bloqueante. Se aplica al flujo nuevo y a los componentes existentes usados por él, no a toda la aplicación por inferencia.

| Heurística | Pantalla y observación | Severidad | Tratamiento y evidencia |
|---|---|---|---|
| 1. Visibilidad del estado | Generación/confirmación puede demorar | 2, prevenido | Indicador de progreso, controles desactivados y mensajes; tests de éxito/error |
| 2. Correspondencia con el mundo real | Fecha interpretada con zona del dispositivo podía confundir operación Lima | 2, prevenido | Hora Lima explícita y conversión UTC; prueba de cambio de día |
| 3. Control y libertad | Calcular no debe asignar sin revisión | 3, prevenido | Vista previa sin mutación, confirmación separada, caducidad y regreso a Rutas; GOLD API/UI |
| 4. Consistencia | La pantalla debe conservar colores y componentes aprobados | 0 en escenarios probados | ThemeData existente; seis combinaciones de tema/tamaño aprobadas |
| 5. Prevención de errores | Repetir recursos o confirmar datos modificados | 3, prevenido | Pares únicos, límites y huella/locks en servidor; concurrencia aprobada |
| 6. Reconocimiento antes que recuerdo | Revisar solo identificadores o ETA dificulta entender la propuesta | 2, corregido | Selección por cliente/dirección, equipo por nombre/placa y destino en secuencia; API conserva dirección de la propuesta |
| 7. Flexibilidad y eficiencia | Seleccionar cada pedido y repetir cálculos viales idénticos | 1, mejorado | Búsqueda, selección acotada y caché de matriz; no se cachean decisiones de autorización |
| 8. Diseño estético y minimalista | Dos controles de selección desbordaban a 360 px | 2, corregido | Distribución Wrap; pruebas en 360/768/1440 y ambos temas |
| 9. Reconocer y recuperarse del error | Fallo del proveedor o datos inviables no deben mostrarse como éxito | 3, prevenido | Mensaje del backend y posibilidad de corregir/reintentar; test de fallo sin confirmación |
| 10. Ayuda y documentación | Semilla, pausas y retorno requieren contexto | 1, mejorado | Ayuda breve y parámetros avanzados; recorrido de demostración en la revisión S3 |

No se atribuyen mejoras a tasas de éxito o satisfacción no medidas. La navegación con teclado y lector de pantalla se completará según [Acciones externas](ACCIONES_EXTERNAS.md).
