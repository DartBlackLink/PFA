import jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jwt import InvalidTokenError
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.db.session import get_db
from app.models.entities import Usuario

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login")


def get_current_user(
    token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)
) -> Usuario:
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(
            token,
            get_settings().secret_key,
            algorithms=[get_settings().algorithm],
            options={"require": ["exp", "sub"]},
        )
        email: str | None = payload.get("sub")
        if not isinstance(email, str) or not email:
            raise credentials_exception
    except InvalidTokenError:
        raise credentials_exception

    user = db.scalar(select(Usuario).where(Usuario.email == email))
    if user is None:
        raise credentials_exception
    if user.estado != "ACTIVO":
        raise credentials_exception

    return user


def require_roles(*roles: str):
    def role_dependency(user: Usuario = Depends(get_current_user)) -> Usuario:
        if user.rol not in roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="El usuario no tiene permisos para esta operación",
            )
        return user

    return role_dependency
