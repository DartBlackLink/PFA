"""Serve unchanged Flutter/FastAPI sources against a new schema in the QA DB.

Never rebuild, truncate or migrate the operational database. Schemas are retained
locally as evidence; this runner deliberately has no destructive cleanup command.
"""
from __future__ import annotations

import functools
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
import json
import os
from pathlib import Path
import re
import secrets
import signal
import subprocess
import sys
import threading
import time
import urllib.request
from urllib.parse import urlsplit

from sqlalchemy import create_engine, text, update
from sqlalchemy.engine import make_url
from sqlalchemy.schema import CreateSchema


def main():
    root = Path(os.environ.get("E2E_APP_ROOT", Path(__file__).resolve().parents[2]))
    web = Path(os.environ.get("E2E_WEB_DIR", root / "apps/web/build/e2e"))
    source = os.environ.get("E2E_QA_DATABASE_URL", "")
    url = make_url(source)
    if (url.database != "ecologistica_revision_20261007"
            or url.host not in {"127.0.0.1", "localhost", "postgres-qa"}
            or os.environ.get("E2E_ALLOW_SCHEMA_CREATE") != "1"):
        raise RuntimeError("E2E requires the named QA database and explicit schema consent")
    schema = os.environ["E2E_SCHEMA"]
    if not re.fullmatch(r"e2e_[a-z0-9_]{8,55}", schema):
        raise RuntimeError("Invalid isolated QA schema name")
    if not (web / "index.html").is_file():
        raise RuntimeError("Build Flutter Web for API port 8010 before running E2E")
    for key in ("E2E_SECRET_KEY", "E2E_ADMIN_PASSWORD", "E2E_DRIVER_PASSWORD"):
        if len(os.environ.get(key, "")) < 24:
            raise RuntimeError("Missing random QA-only credentials")

    engine = create_engine(url)
    with engine.begin() as connection:
        # No IF NOT EXISTS: never take ownership of a pre-existing schema.
        connection.execute(CreateSchema(schema))
    engine.dispose()
    os.environ.update({
        "DATABASE_URL": source,
        "SECRET_KEY": os.environ["E2E_SECRET_KEY"],
        "PGOPTIONS": f"-c search_path={schema}",
        "BOOTSTRAP_DEMO_USERS": "false",
        "TRUSTED_HOSTS": "127.0.0.1,localhost,testserver",
        "CORS_ORIGINS": os.environ["E2E_WEB_URL"],
    })
    sys.path.insert(0, str(root / "backend"))
    from alembic import command
    from alembic.config import Config
    config = Config(str(root / "backend/alembic.ini"))
    config.set_main_option("script_location", str(root / "backend/migrations"))
    command.upgrade(config, "head")
    from app.core.security import get_password_hash
    from app.db.session import SessionLocal
    from app.models.entities import Usuario, Repartidor, Vehiculo
    from datetime import time as clock
    from decimal import Decimal
    accounts = {}
    with SessionLocal() as db:
        db.add(Usuario(email="admin.e2e@example.test", rol="ADMIN", estado="ACTIVO",
                       password_hash=get_password_hash(os.environ["E2E_ADMIN_PASSWORD"])))
        for index, browser in enumerate(("chromium", "firefox", "webkit"), 1):
            user = Usuario(email=f"{browser}.e2e@example.test", rol="REPARTIDOR", estado="ACTIVO",
                           password_hash=get_password_hash(os.environ["E2E_DRIVER_PASSWORD"]))
            db.add(user); db.flush()
            driver = Repartidor(usuario_id=user.usuario_id, nombre=f"QA E2E {browser}",
                dni=f"9000000{index}", licencia=f"QA-E2E-{index}", categoria_licencia="A-IIb",
                anios_experiencia=3, contacto="QA sintético", disponible_desde=clock(0),
                disponible_hasta=clock(23, 59), origen_latitud=Decimal('-12.068046'),
                origen_longitud=Decimal('-75.210073'), estado="ACTIVO")
            vehicle = Vehiculo(placa=f"E2E-{index:03}", tipo="Furgón QA", capacidad_kg=100,
                consumo_km_l=10, factor_emision_kg_km=Decimal('0.2'),
                anio_fabricacion=2025, estado="ACTIVO")
            db.add_all([driver, vehicle]); db.flush()
            accounts[browser] = {"email": user.email, "driver_id": str(driver.repartidor_id),
                                 "vehicle_id": str(vehicle.vehiculo_id)}
        db.commit()
    report = Path.cwd() / "reports"
    report.mkdir(exist_ok=True)
    # IDs only, no hashes, tokens, connection strings or passwords.
    (report / "e2e-fixture.json").write_text(json.dumps({"schema": schema, "accounts": accounts}), encoding="utf-8")
    env = os.environ.copy()
    env["PYTHONPATH"] = str(root / "backend")
    api = subprocess.Popen([sys.executable, "-m", "uvicorn", "app.main:app", "--host", "127.0.0.1",
                            "--port", "8010", "--no-access-log"], cwd=root, env=env)
    try:
        for _ in range(60):
            if api.poll() is not None:
                raise RuntimeError("Isolated QA API did not start")
            try:
                with urllib.request.urlopen("http://127.0.0.1:8010/api/v1/health", timeout=1) as response:
                    if response.status == 200: break
            except OSError:
                time.sleep(.5)
        else: raise RuntimeError("QA API health timeout")

        class Handler(SimpleHTTPRequestHandler):
            def log_message(self, *args):
                pass

            def do_GET(self):
                if self.path == '/healthz':
                    self.send_response(200); self.end_headers(); self.wfile.write(b'QA ready')
                elif self.path == '/qa/sus':
                    form = Path(__file__).resolve().parents[2] / 'docs/03 Implementación/Sprint 4/instrumentos/Encuesta_SUS.html'
                    data = form.read_bytes()
                    self.send_response(200)
                    self.send_header('Content-Type', 'text/html; charset=utf-8')
                    self.send_header('Content-Length', str(len(data)))
                    self.end_headers(); self.wfile.write(data)
                else: super().do_GET()

        class QAServer(ThreadingHTTPServer):
            def handle_error(self, request, address):
                # Closing a browser tab can cancel an asset download normally.
                if isinstance(sys.exc_info()[1], (ConnectionResetError, BrokenPipeError)):
                    return
                super().handle_error(request, address)

        web_port = urlsplit(os.environ['E2E_WEB_URL']).port or 8095
        server = QAServer(('127.0.0.1', web_port), functools.partial(Handler, directory=str(web)))
        def stop(*_):
            threading.Thread(target=server.shutdown, daemon=True).start()
        signal.signal(signal.SIGTERM, stop)
        signal.signal(signal.SIGINT, stop)
        try: server.serve_forever()
        finally: server.server_close()
    finally:
        api.terminate()
        try: api.wait(timeout=8)
        except subprocess.TimeoutExpired:
            api.kill(); api.wait()
        # Retain evidence, but retire all credentials generated in this run.
        with SessionLocal() as db:
            if db.scalar(text('select current_schema()')) != schema:
                raise RuntimeError('Refusing credential cleanup outside this QA schema')
            db.execute(update(Usuario).values(estado='INACTIVO',
                password_hash=get_password_hash(secrets.token_hex(24))))
            db.commit()


if __name__ == '__main__':
    main()
