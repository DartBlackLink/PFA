"""Rotate one existing local EcoLogística demo account using hidden input."""
import argparse
import getpass
import json
import shutil
import subprocess
from pathlib import Path

ACCOUNTS = ('admin@danleo.com', 'repartidor@danleo.com', 'pepe@danleo.com')
ROTATE = """import json, sys
from sqlalchemy import select, text
from app.db.session import SessionLocal
from app.models.entities import Usuario
from app.core.security import get_password_hash, verify_password
data = json.load(sys.stdin)
with SessionLocal() as db:
    if db.scalar(text('SELECT current_database()')) != 'ecologistica_operativa':
        raise RuntimeError('La API no está conectada a la base operativa local.')
    account = db.scalar(select(Usuario).where(Usuario.email == data['email']).with_for_update())
    if account is None or verify_password(data['password'], account.password_hash):
        raise RuntimeError('Cuenta ausente o contraseña sin cambios.')
    account.password_hash = get_password_hash(data['password'])
    db.commit()
"""


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('correo', choices=ACCOUNTS)
    args = parser.parse_args()
    docker = shutil.which('docker')
    if not docker:
        raise SystemExit('Docker CLI no está en PATH.')
    password = getpass.getpass('Nueva contraseña privada: ')
    if len(password) < 16 or len(password.encode()) > 72:
        raise SystemExit('Usa al menos 16 caracteres y hasta 72 bytes.')
    if password != getpass.getpass('Repite la contraseña: '):
        raise SystemExit('Las contraseñas no coinciden.')
    project = Path(__file__).resolve().parents[2]
    result = subprocess.run(
        [docker, 'compose', 'exec', '-T', 'api', 'python', '-c', ROTATE],
        cwd=project,
        input=json.dumps({'email': args.correo, 'password': password}).encode(),
        capture_output=True,
        timeout=30,
    )
    if result.returncode:
        raise SystemExit('No se rotó la contraseña. Comprueba la base, la cuenta y que la clave sea distinta.')
    print('Contraseña rotada. Las sesiones existentes conservan su vencimiento original.')


if __name__ == '__main__':
    main()
