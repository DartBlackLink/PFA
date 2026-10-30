"""Environment configuration. No built-in credentials or signing secrets."""

from functools import lru_cache
from ipaddress import ip_address
from typing import Literal
from urllib.parse import urlsplit

from pydantic import Field, field_validator, model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_name: str = "EcoLogistica API"
    database_url: str
    secret_key: str = Field(min_length=32)
    bootstrap_demo_users: bool = False
    admin_email: str = "admin@ecologistica.com"
    admin_password: str | None = Field(default=None, min_length=8, max_length=72)
    driver_email: str = "repartidor@ecologistica.com"
    driver_password: str | None = Field(default=None, min_length=8, max_length=72)
    cors_origins: str = "http://localhost:8080,http://127.0.0.1:8080"
    trusted_hosts: str = "localhost,127.0.0.1,backend,testserver"
    routing_base_url: str = "https://router.project-osrm.org/route/v1/driving"
    geocoding_base_url: str = "https://photon.komoot.io"
    allow_local_provider_urls: bool = False
    algorithm: Literal["HS256"] = "HS256"
    access_token_expire_minutes: int = Field(default=30, ge=1, le=120)
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    @field_validator("secret_key")
    @classmethod
    def strong_secret(cls, value):
        if len(set(value)) < 12 or "change" in value.lower():
            raise ValueError("Configure una clave aleatoria de al menos 32 caracteres")
        return value

    @model_validator(mode="after")
    def validate_endpoints(self):
        for value in (self.routing_base_url, self.geocoding_base_url):
            url = urlsplit(value)
            local = url.hostname in ("localhost", "127.0.0.1", "::1")
            if (
                not url.hostname
                or url.username
                or url.password
                or url.query
                or url.fragment
            ):
                raise ValueError("URL de proveedor inválida")
            if local and self.allow_local_provider_urls and url.scheme == "http":
                continue
            if url.scheme != "https" or local:
                raise ValueError("El proveedor debe usar HTTPS público")
            try:
                if not ip_address(url.hostname).is_global:
                    raise ValueError("No se permiten proveedores en redes privadas")
            except ValueError as error:
                if "No se permiten" in str(error):
                    raise
        if self.bootstrap_demo_users and not (
            self.admin_password and self.driver_password
        ):
            raise ValueError(
                "La carga demo requiere contraseñas configuradas explícitamente"
            )
        if "*" in self.cors_origin_list or "*" in self.trusted_host_list:
            raise ValueError("No se permiten comodines de origen o host")
        return self

    @property
    def cors_origin_list(self):
        return [
            origin.strip() for origin in self.cors_origins.split(",") if origin.strip()
        ]

    @property
    def trusted_host_list(self):
        return [host.strip() for host in self.trusted_hosts.split(",") if host.strip()]


@lru_cache
def get_settings() -> Settings:
    return Settings()
