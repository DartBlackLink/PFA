# Campaña EN-002 — resultados conservados y corrección

Semillas predeclaradas: 11, 22, 33, 44, 55. Tamaños: 10, 50, 150 pedidos sintéticos, 15 equipos. Tres destinos públicos repetidos. No se presenta una muestra de 150 direcciones distintas.

# Comparación del defecto

Antes: 14 de 15 casos verificados; 150/11 falló con 503 y ninguna asignación. Dos reproducciones conservaron el fallo. Diagnóstico: matriz de 165 posiciones para tres lugares y lotes de 40; el diseño anterior requería 25 bloques de consulta. El motor usó aproximadamente ocho segundos; se agotó el tiempo en el cálculo/validación vial restante.

Después de deduplicar coordenadas exactas, el caso frío 150/11 terminó en 23,330 s incluyendo confirmación, con una consulta de matriz para tres ubicaciones únicas. Se preserva el fallo previo: no se calcula un ahorro de tiempo comparando una operación fallida con otra completada.

# Campaña ampliada después de la corrección

| Pedidos | Semilla | Preview (s) | Confirmación (s) | Total (s), ≤45 | Replan (s), <30 | Pendientes replanificados | Resultado |
|---|---|---|---|---|---|---|---|
| 10 | 11 | 4,807 | 0,108 | 4,916 | 1,803 | 5 | VERIFICADO |
| 10 | 22 | 2,734 | 0,067 | 2,801 | 1,754 | 7 | VERIFICADO |
| 10 | 33 | 2,765 | 0,065 | 2,830 | 0,814 | 6 | VERIFICADO |
| 10 | 44 | 3,082 | 0,063 | 3,146 | 0,800 | 7 | VERIFICADO |
| 10 | 55 | 2,762 | 0,062 | 2,825 | 0,818 | 6 | VERIFICADO |
| 50 | 11 | 13,366 | 0,135 | 13,501 | 1,117 | 19 | VERIFICADO |
| 50 | 22 | 10,748 | 0,120 | 10,869 | 0,971 | 19 | VERIFICADO |
| 50 | 33 | 11,037 | 0,127 | 11,164 | 0,927 | 16 | VERIFICADO |
| 50 | 44 | 10,838 | 0,126 | 10,965 | 1,058 | 19 | VERIFICADO |
| 50 | 55 | 10,015 | 0,128 | 10,144 | 1,050 | 18 | VERIFICADO |
| 150 | 11 | 21,809 | 0,253 | 22,065 | 1,281 | 19 | VERIFICADO |
| 150 | 22 | 21,947 | 0,417 | 22,369 | 1,222 | 19 | VERIFICADO |
| 150 | 33 | 20,963 | 0,637 | 21,605 | 1,287 | 19 | VERIFICADO |
| 150 | 44 | 17,874 | 0,229 | 18,106 | 0,979 | 19 | VERIFICADO |
| 150 | 55 | 22,045 | 0,263 | 22,310 | 1,795 | 17 | VERIFICADO |

Los 15 casos confirmaron asignación única, preservación de la primera entrega y acuse de versión 2. El umbral de replan se refiere a los pendientes de una ruta asignada, no a reoptimizar simultáneamente los 150 pedidos de todas las rutas.

# Método y límites

Se mide ASGI/TestClient, PostgreSQL, OSRM real, algoritmo y confirmación persistida; excluye TCP entre cliente/servidor, navegador, proxy y render. Se conservan estadísticas de caché. Los accesos al servicio público se limitaron a un inicio por segundo; esa espera se incluye. El conjunto usa IDs deterministas y un mismo reloj/ventana dentro de cada campaña.

La campaña de 15 casos corresponde a la deduplicación. Después, el GOLD detectó el protocolo de una matriz de una sola ubicación; su corrección conserva la misma coordenada dos veces en la solicitud, con sources=0 y destinations=0, y se revalidó con cuatro regresiones de matriz, la suite backend completa y los tres GOLD E2E. No se afirma una campaña de carga concurrente ni un SLA general de ciudad.

[Antes](campana-antes.json) · [Diagnóstico](diagnostico-150-11.json) · [Caso frío corregido](caso-frio-150-11-corregido.json) · [Campaña corregida](campana-corregida.json) · [Dataset y reloj](dataset.json) · [Contrato OSRM 1×1](osrm-coordenada-unica.json).
