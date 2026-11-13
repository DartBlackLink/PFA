"""Provisionamiento inicial explícito; nunca cambia una cuenta existente."""
from getpass import getpass
from pathlib import Path
import json
import re
import shutil
import subprocess


def main():
    project = Path(__file__).resolve().parents[2]
    docker = shutil.which('docker')
    if not docker:
        raise SystemExit('Docker CLI no está en PATH.')
    email = input('Correo del administrador inicial: ').strip().lower()
    if not re.fullmatch(r'[^\s@]+@[^\s@]+\.[^\s@]+', email) or len(email) > 254:
        raise SystemExit('Correo inválido.')
    password = getpass('Nueva clave privada (mínimo 16 caracteres): ')
    if len(password) < 16 or len(password.encode()) > 72:
        raise SystemExit('La clave debe tener al menos 16 caracteres y máximo 72 bytes.')
    if getpass('Repite la clave: ') != password:
        raise SystemExit('Las claves no coinciden.')
    code = '''import json, sys
from sqlalchemy import select, func
from app.db.session import SessionLocal
from app.models.entities import Usuario
from app.core.security import get_password_hash
data = json.load(sys.stdin)
with SessionLocal() as db:
    if db.scalar(select(func.count()).select_from(Usuario)) != 0:
        sys.exit('La base ya tiene usuarios: no se modificó ninguna cuenta.')
    db.add(Usuario(email=data['email'], password_hash=get_password_hash(data['password']), rol='ADMIN', estado='ACTIVO'))
    db.commit()
print('Administrador inicial creado.')
'''
    result = subprocess.run([docker, 'compose', 'exec', '-T', 'api', 'python', '-c', code],
                            input=json.dumps({'email': email, 'password': password}).encode(),
                            cwd=project, capture_output=True, timeout=30)
    if result.returncode:
        # No imprimir detalles de SQL ni parámetros de una excepción inesperada.
        raise SystemExit('No se creó la cuenta. Comprueba salud API y que la base no tenga usuarios. No se reemplazó ninguna cuenta.')
    print('Administrador inicial creado; conserva tu clave de forma privada.')


if __name__ == '__main__':
    main()
