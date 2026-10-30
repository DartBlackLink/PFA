"""Migration-based PostgreSQL fixture. Refuses the application database."""

from pathlib import Path

import pytest
from alembic import command
from alembic.config import Config

from app.core.config import get_settings


@pytest.fixture(scope="session", autouse=True)
def isolated_database():
    url = get_settings().database_url
    if "@postgres-qa:5432/" not in url or not url.endswith(
        "/ecologistica_revision_20261007"
    ):
        raise RuntimeError("Las pruebas requieren la base PostgreSQL aislada de QA")
    backend = Path(__file__).resolve().parents[1]
    config = Config(str(backend / "alembic.ini"))
    config.set_main_option("script_location", str(backend / "migrations"))
    command.upgrade(config, "head")
    yield
    command.downgrade(config, "base")
    command.upgrade(config, "head")
