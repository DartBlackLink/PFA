[← Volver al README principal](../../README.md)

# Presupuesto del Proyecto

## 1. Metadatos

| Campo | Información |
|---|---|
| Proyecto | EcoLogística Lima |
| Integrante | Jordy Steve Chancasanampa Torres |
| Versión | 1.0.0 |
| Horizonte | 14 semanas |
| Modalidad | Proyecto académico individual |

## 2. Objetivo

Modelar el costo del MVP de forma coherente con su alcance real. El presupuesto de **S/ 500,000** de la consigna se interpreta como techo del caso empresarial, no como un monto que el proyecto académico deba consumir.

Las horas se valorizan por **rol equivalente**, aunque una sola persona desempeñe varios roles. Los montos representan costo imputado de planificación y no necesariamente desembolsos reales.

## 3. Supuestos financieros

- Horizonte: 14 semanas.
- Capacidad planificada: aproximadamente **280 horas** (20 h/semana promedio).
- Herramientas open source o planes gratuitos siempre que sea posible.
- Conversión de referencia del caso: **USD 1 ≈ S/ 3.70**, derivada de la equivalencia aproximada indicada en la consigna.
- Reserva de contingencia: **12 %**.

## 4. Recursos Humanos (CAPEX)

**Fórmula:** `Costo = Horas asignadas × Tarifa por hora (USD)`

| Rol equivalente | Horas | Tarifa USD/h | Subtotal USD | Actividades principales |
|---|---:|---:|---:|---|
| Project Manager | 30 | 12.00 | 360.00 | backlog, riesgos, Jira, alcance |
| Software Architect | 25 | 14.00 | 350.00 | C4, decisiones técnicas, estructura modular |
| Full-Stack Developer | 170 | 12.00 | 2,040.00 | React, FastAPI, PostgreSQL, algoritmo, integración |
| QA Engineer | 30 | 10.00 | 300.00 | pruebas, rendimiento y evidencias |
| UI/UX Designer | 25 | 10.00 | 250.00 | mockups, responsive y accesibilidad |
| **Total RRHH** | **280** |  | **3,300.00** |  |

> Una sola persona desempeña los cinco roles. La separación se usa para modelar el esfuerzo.

## 5. Licenciamiento y herramientas

| Herramienta / concepto | Modelo | Costo USD |
|---|---|---:|
| Git + GitHub/GitLab | Gratuito | 0.00 |
| Jira Software | Plan gratuito sujeto a disponibilidad | 0.00 |
| Figma | Gratuito | 0.00 |
| VS Code / IDE equivalente | Gratuito | 0.00 |
| SonarQube Community / equivalente | Gratuito | 0.00 |
| OpenStreetMap + Leaflet | Open source | 0.00 |
| Dominio opcional para demo | Reserva | 20.00 |
| Certificado SSL | Let's Encrypt / equivalente | 0.00 |
| Otros consumibles menores | Reserva | 40.00 |
| **Total herramientas** |  | **60.00** |

## 6. Infraestructura Cloud y Servicios (OPEX)

| Concepto | Periodo | Costo USD |
|---|---|---:|
| Hosting frontend/API de bajo costo | hasta 4 meses | 80.00 |
| PostgreSQL administrado o VPS pequeño | hasta 4 meses | 50.00 |
| Backups / almacenamiento | reserva | 20.00 |
| Tráfico/API externa | preferentemente simulada/gratuita | 0.00 |
| **Total infraestructura** |  | **150.00** |

## 7. Consolidación presupuestaria

| Categoría | Costo Subtotal (USD) | Porcentaje del subtotal |
|---|---:|---:|
| 1. Recursos Humanos (CAPEX) | 3,300.00 | 94.02 % |
| 2. Licenciamiento y Herramientas | 60.00 | 1.71 % |
| 3. Infraestructura Cloud (OPEX) | 150.00 | 4.27 % |
| **SUBTOTAL DEL PROYECTO** | **3,510.00** | **100.00 %** |
| 4. Reserva de Contingencia (12 %) | **421.20** | N/A |
| **PRESUPUESTO TOTAL ESTIMADO** | **3,931.20** | **100.00 % del total final** |

### Equivalencia referencial

- Total: **USD 3,931.20**.
- Equivalente de planificación: **S/ 14,545.44** usando USD 1 ≈ S/ 3.70.
- Proporción respecto al techo de S/ 500,000: aproximadamente **2.91 %**.

## 8. Justificación

El presupuesto es conservador porque el proyecto es individual, usa un monolito modular, una sola metaheurística principal, herramientas gratuitas y pocas dependencias externas. No incluye compra de flota, hardware empresarial ni alta disponibilidad real.

## 9. Uso de contingencia

La reserva del 12 % puede utilizarse para un servicio cloud temporal, consumo imprescindible de API, reemplazo urgente de un servicio o esfuerzo extraordinario por un riesgo High materializado. No debe financiar nuevas funciones fuera de alcance.

## 10. Control financiero

Al cierre de cada Sprint se registran horas, servicios activados, costo acumulado, uso de contingencia y variación. Si una categoría se desvía más de 10 %, se revisa primero el alcance antes de comprar recursos adicionales.

## 11. Conclusión

El MVP académico puede desarrollarse con un costo imputado muy inferior al límite empresarial del caso, reforzando la decisión de mantener arquitectura simple y alcance controlado.

[← Volver al README principal](../../README.md)
