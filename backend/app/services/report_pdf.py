"""Small text-only PDF writer: bounded content, WinAnsi Helvetica, no HTML/files/URLs."""

import textwrap
from datetime import datetime
from zoneinfo import ZoneInfo


def _text(value):
    # Literal PDF strings must not allow user-controlled operators or newlines.
    value = " ".join(str(value).split())
    value = value.replace("₂", "2").replace("→", "->").replace("−", "-")
    value = value.replace("\\", "\\\\").replace("(", "\\(").replace(")", "\\)")
    return value.encode("cp1252", errors="replace")


def create_pdf(lines):
    wrapped = [part for line in lines for part in (textwrap.wrap(str(line), 88) or [""])]
    pages = [wrapped[i:i + 48] for i in range(0, len(wrapped), 48)] or [[]]
    objects = [b"<< /Type /Catalog /Pages 2 0 R >>", b"",
               b"<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica /Encoding /WinAnsiEncoding >>"]
    kids = []
    for page_number, page in enumerate(pages, 1):
        page_id = len(objects) + 1
        kids.append(f"{page_id} 0 R")
        objects.append(f"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Resources << /Font << /F1 3 0 R >> >> /Contents {page_id + 1} 0 R >>".encode())
        stream = b"BT /F1 11 Tf 48 790 Td 15 TL\n"
        for line in page:
            stream += b"(" + _text(line) + b") Tj T*\n"
        stream += b"ET\nBT /F1 9 Tf 48 30 Td (" + _text(f"EcoLogística Huancayo - Página {page_number}/{len(pages)}") + b") Tj ET"
        objects.append(b"<< /Length " + str(len(stream)).encode() + b" >>\nstream\n" + stream + b"\nendstream")
    objects[1] = f"<< /Type /Pages /Kids [{' '.join(kids)}] /Count {len(kids)} >>".encode()
    result = bytearray(b"%PDF-1.4\n%\xe2\xe3\xcf\xd3\n")
    offsets = [0]
    for identifier, obj in enumerate(objects, 1):
        offsets.append(len(result))
        result.extend(f"{identifier} 0 obj\n".encode() + obj + b"\nendobj\n")
    start = len(result)
    result.extend(f"xref\n0 {len(offsets)}\n0000000000 65535 f \n".encode())
    for offset in offsets[1:]:
        result.extend(f"{offset:010d} 00000 n \n".encode())
    result.extend(f"trailer\n<< /Size {len(offsets)} /Root 1 0 R >>\nstartxref\n{start}\n%%EOF\n".encode())
    return bytes(result)


def route_pdf(data):
    def metric(key, unit):
        value = data[key]
        return "No disponible" if value is None else f"{value:.3f} {unit}"

    windows = data["ventanas"]
    lines = ["ECOLOGÍSTICA HUANCAYO", "Reporte de planificación y sostenibilidad",
             "Emitido: " + datetime.now(ZoneInfo("America/Lima")).strftime("%d/%m/%Y %H:%M:%S UTC-05:00"),
             f"Ruta: {data['ruta_id']} | Versión: {data['version']}",
             f"Estado: {data['estado']} | Algoritmo: {data['algoritmo']}",
             f"Zona: {data['ambito']}", "", "Indicadores estimados guardados",
             "Distancia: " + metric("distancia_km", "km"),
             "Duración de viaje: " + metric("tiempo_min", "min"),
             "Combustible: " + metric("combustible_l", "L"),
             "Emisiones: " + metric("co2_kg", "kg CO2"), "",
             f"Entregas: {windows['entregas']} | Entregadas: {windows['entregadas']}",
             f"Ventanas previstas: {windows['previstas_en_ventana']}/{windows['previstas_evaluadas']} evaluadas (ETA + atención).",
             f"Ventanas reales: {windows['reales_en_ventana']}/{windows['reales_evaluadas']} evaluadas (hora de entrega).",
             "Cero entregas evaluables significa indicador no disponible, no 100%.", ""]
    eq = data["equivalencia"]
    if eq:
        lines += [f"Equivalencia: {eq['valor']:.3f} {eq['unidad']}",
                  f"Factor: {eq['factor_kg_por_unidad']} kg CO2 por unidad. Fuente: {eq['fuente']}", eq['advertencia']]
    else:
        lines += ["Equivalencia ambiental: no disponible (requiere emisiones y factor documentado)."]
    lines += ["", "Alcance y limitaciones", data["metodologia"],
              "Documento generado desde PostgreSQL; conserva la versión indicada al momento de su descarga."]
    return create_pdf(lines)
