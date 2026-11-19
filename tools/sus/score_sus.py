"""Calculate SUS only from valid, consented anonymous responses; never impute.

No external packages. Exit 2 on invalid input, no score when fewer than five
valid responses are supplied. Input codes must not contain personal identifiers.
"""
from __future__ import annotations
import argparse
from collections import Counter
import csv
from datetime import datetime, timedelta, timezone
from decimal import Decimal, ROUND_HALF_UP
import hashlib
import json
from pathlib import Path
import re

# Perú uses UTC−05 at this study's cutoff. A named fixed offset makes this
# standalone calculator portable to Windows without downloading a tz database.
STUDY_TIMEZONE = timezone(timedelta(hours=-5), name='America/Lima')

ITEMS = [f'p{i}' for i in range(1, 11)]
HEADERS = ['codigo', 'rol', 'dispositivo', 'fecha', 'consentimiento', *ITEMS]


def calculate(answers):
    if len(answers) != 10 or any(type(x) is not int or not 1 <= x <= 5 for x in answers):
        raise ValueError('SUS requiere diez enteros entre 1 y 5')
    contributions = [x-1 if i % 2 == 0 else 5-x for i, x in enumerate(answers)]
    total = sum(contributions)
    return contributions, total, Decimal(total) * Decimal('2.5')


def grade(value):
    # One-decimal curved grading scale, as specified in the usability report.
    rounded = value.quantize(Decimal('.1'), rounding=ROUND_HALF_UP)
    thresholds = [('84.1', 'A+'), ('80.8', 'A'), ('78.9', 'A−'), ('77.2', 'B+'),
                  ('74.1', 'B'), ('72.6', 'B−'), ('71.1', 'C+'), ('65.0', 'C'),
                  ('62.7', 'C−'), ('51.7', 'D'), ('0', 'F')]
    return next(letter for limit, letter in thresholds if rounded >= Decimal(limit))


def read_responses(path):
    rows = []
    seen = set()
    with path.open(encoding='utf-8-sig', newline='') as stream:
        reader = csv.DictReader(stream)
        if reader.fieldnames != HEADERS:
            raise ValueError('Cabeceras CSV distintas a la plantilla oficial del estudio')
        for number, row in enumerate(reader, 2):
            if None in row or any(value is None for value in row.values()):
                raise ValueError(f'Fila {number}: cantidad de columnas inválida')
            code = row['codigo']
            if not re.fullmatch(r'SUS-[A-F0-9]{12}', code) or code in seen:
                raise ValueError(f'Fila {number}: código anónimo inválido o duplicado')
            if row['rol'] not in {'ADMIN', 'REPARTIDOR'}:
                raise ValueError(f'Fila {number}: perfil inválido')
            if row['dispositivo'] not in {'PC', 'TABLET', 'MOVIL'} or row['consentimiento'] != 'SI':
                raise ValueError(f'Fila {number}: dispositivo o consentimiento inválido')
            try:
                datetime.strptime(row['fecha'], '%Y-%m-%d')
                if any(not re.fullmatch('[1-5]', row[k]) for k in ITEMS): raise ValueError()
                answers = [int(row[k]) for k in ITEMS]
            except ValueError:
                raise ValueError(f'Fila {number}: fecha o respuesta incompleta/inválida') from None
            contributions, total, score = calculate(answers)
            seen.add(code)
            rows.append({'codigo': code, 'rol': row['rol'], 'dispositivo': row['dispositivo'],
                         'fecha': row['fecha'], 'respuestas': answers,
                         'contribuciones': contributions, 'suma': total, 'sus': str(score)})
    return rows


def report(path):
    rows = read_responses(path)
    n = len(rows)
    mean = sum((Decimal(row['sus']) for row in rows), Decimal(0)) / n if n >= 5 else None
    return {'instrumento': 'SUS', 'fecha_corte': datetime.now(STUDY_TIMEZONE).isoformat(),
            'zona_horaria': 'America/Lima',
            'entrada_sha256': hashlib.sha256(path.read_bytes()).hexdigest(),
            'n': n, 'perfiles': dict(Counter(row['rol'] for row in rows)),
            'estado': 'CALCULADO' if mean is not None else 'MUESTRA_INSUFICIENTE',
            'media_exacta': str(mean) if mean is not None else None,
            'grado': grade(mean) if mean is not None else None,
            'umbral_docente': '68', 'cumple_umbral': mean >= 68 if mean is not None else None,
            'personas': rows, 'limite': 'Puntuación SUS, no porcentaje; no demuestra representatividad ni certificación de accesibilidad.'}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('csv', type=Path)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    try: result = report(args.csv)
    except (ValueError, OSError) as error: parser.exit(2, f'No se calculó SUS: {error}\n')
    args.output.mkdir(parents=True, exist_ok=True)
    (args.output/'sus-resultados.json').write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding='utf-8')
    lines = ['# Resultado de usabilidad SUS', '', f"**Fecha:** {result['fecha_corte']}",
             f"**Estado:** {result['estado']}. **Respuestas válidas:** {result['n']}.",
             f"**SHA256 de entrada:** `{result['entrada_sha256']}`.", '',
             'Comando reproducible (desde la raíz):', '',
             '`python tools/sus/score_sus.py RUTA_CSV_ANONIMO --output reports/sus`', '',
             'Contribuciones: impares respuesta−1; pares 5−respuesta; suma×2,5.', '',
             '| Código | Rol | Respuestas P1–P10 | Contribuciones | Suma | SUS |',
             '|---|---|---|---|---|---|']
    for row in result['personas']:
        lines.append(f"| {row['codigo']} | {row['rol']} | {row['respuestas']} | {row['contribuciones']} | {row['suma']} | {row['sus']} |")
    lines += ['', f"**Media exacta:** {result['media_exacta'] if result['media_exacta'] is not None else 'No calculable con la muestra mínima exigida.'}",
              f"**Grado:** {result['grado'] or 'No calculable.'}", '', result['limite']]
    (args.output/'RESULTADO_SUS.md').write_text('\n'.join(lines)+'\n', encoding='utf-8')
    print(f"SUS: {result['estado']}; n={result['n']}. Informes en {args.output}")


if __name__ == '__main__': main()
