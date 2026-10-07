from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_name: str = "EcoLogistica API"
    database_url: str = "postgresql+psycopg://ecologistica:ecologistica@localhost:5432/ecologistica"
    admin_email: str = "admin@ecologistica.com"
    admin_password: str = "Admin123!"
    driver_email: str = "repartidor@ecologistica.com"
    driver_password: str = "Repartidor123!"
    cors_origins: str = "http://localhost:8080,http://127.0.0.1:8080,http://localhost:59471"
    secret_key: str = "dev-only-change-this-secret-key"
    routing_base_url: str = "https://router.project-osrm.org/route/v1/driving"
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 30

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    @property
    def cors_origin_list(self) -> list[str]:
        return [origin.strip() for origin in self.cors_origins.split(",") if origin.strip()]


@lru_cache
def get_settings() -> Settings:
    return Settings()

