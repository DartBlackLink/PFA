from datetime import datetime, timedelta
from passlib.context import CryptContext
from jose import jwt

from app.core.config import get_settings

# Configuración del algoritmo de hashing bcrypt
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """
    Verifica que la contraseña en texto plano coincida con el hash de la base de datos.
    """
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password: str) -> str:
    """
    Genera un hash seguro utilizando bcrypt para una nueva contraseña.
    """
    return pwd_context.hash(password)

def create_access_token(subject: str, role: str) -> str:
    """
    Crea un token JWT firmado para la sesión del usuario.
    Inyecta la fecha de expiración y el identificador (email).
    """
    settings = get_settings()
    expire = datetime.utcnow() + timedelta(minutes=settings.access_token_expire_minutes)
    
    to_encode = {"exp": expire, "sub": str(subject), "rol": role}
    
    encoded_jwt = jwt.encode(
        to_encode, 
        settings.secret_key, 
        algorithm=settings.algorithm
    )
    return encoded_jwt