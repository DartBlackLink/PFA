"""Password and signed-session primitives; compatible with existing bcrypt hashes."""

import uuid
from datetime import datetime, timedelta, timezone

import bcrypt
import jwt

from app.core.config import get_settings


def verify_password(plain_password: str, hashed_password: str) -> bool:
    encoded = plain_password.encode("utf-8")
    if not 1 <= len(encoded) <= 72:
        return False
    try:
        return bcrypt.checkpw(encoded, hashed_password.encode("ascii"))
    except (ValueError, TypeError, UnicodeError):
        return False


def get_password_hash(password: str) -> str:
    encoded = password.encode("utf-8")
    if not 8 <= len(encoded) <= 72:
        raise ValueError("La contraseña debe tener entre 8 y 72 bytes UTF-8")
    return bcrypt.hashpw(encoded, bcrypt.gensalt(rounds=12)).decode("ascii")


def create_access_token(subject: str, role: str) -> str:
    settings = get_settings()
    now = datetime.now(timezone.utc)
    return jwt.encode(
        {
            "exp": now + timedelta(minutes=settings.access_token_expire_minutes),
            "iat": now,
            "jti": str(uuid.uuid4()),
            "sub": str(subject),
            "rol": role,
        },
        settings.secret_key,
        algorithm=settings.algorithm,
    )
