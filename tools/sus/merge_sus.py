"""Merge anonymous validated CSV downloads; never overwrite input responses."""
import argparse
import csv
from pathlib import Path
import tempfile
from score_sus import HEADERS, read_responses


def merge(inputs, output):
    if output.exists() or output.resolve() in {p.resolve() for p in inputs}:
        raise ValueError('La salida debe ser un archivo nuevo, distinto de las respuestas originales')
    rows=[]
    for path in inputs:
        # Validate before accepting fields, no free-form personal columns.
        read_responses(path)
        with path.open(encoding='utf-8-sig',newline='') as source:
            rows.extend(csv.DictReader(source))
    # Validate global uniqueness before writing anything to the chosen output.
    with tempfile.TemporaryDirectory() as folder:
        temporary=Path(folder)/'merged.csv'
        with temporary.open('w',encoding='utf-8',newline='') as stream:
            writer=csv.DictWriter(stream,fieldnames=HEADERS);writer.writeheader();writer.writerows(rows)
        read_responses(temporary)
        output.parent.mkdir(parents=True,exist_ok=True)
        with output.open('x',encoding='utf-8',newline='') as stream:
            stream.write(temporary.read_text(encoding='utf-8'))
    return len(rows)


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('inputs',type=Path,nargs='+')
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args()
    try: count=merge(args.inputs,args.output)
    except (ValueError,OSError) as error: parser.exit(2,f'No se unieron respuestas: {error}\n')
    print(f'Respuestas validadas: {count}; archivo nuevo: {args.output}')
