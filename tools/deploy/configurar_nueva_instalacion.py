"""Genera .env privado solo para un clúster nuevo; no altera bases existentes."""
from pathlib import Path
import secrets


def main():
    project = Path(__file__).resolve().parents[2]
    target = project / '.env'
    if target.exists():
        raise SystemExit('.env ya existe: consérvalo. No regenerar claves de una base existente.')
    text = (project / '.env.sample').read_text(encoding='utf-8-sig')
    replacements = {
        'REPLACE_WITH_PRIVATE_RANDOM_VALUE': secrets.token_urlsafe(36),
        'REPLACE_WITH_ANOTHER_PRIVATE_RANDOM_VALUE': secrets.token_urlsafe(36),
        'REPLACE_WITH_PRIVATE_RANDOM_JWT_SECRET': secrets.token_urlsafe(48),
    }
    for key, value in replacements.items():
        text = text.replace(key, value)
    with target.open('x', encoding='utf-8', newline='\n') as stream:
        stream.write(text)
    print('.env privado generado. No publicarlo. Usar solo con un volumen nuevo; revisar OPERACION_LOCAL.md.')


if __name__ == '__main__':
    main()
