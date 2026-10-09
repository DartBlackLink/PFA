import uuid
from datetime import datetime, time
from decimal import Decimal
import re
from typing import Literal
from pydantic import BaseModel, ConfigDict, Field, field_validator, model_validator

class Token(BaseModel):
    access_token: str
    token_type: str
    rol: str


class VehiculoCreate(BaseModel):
    placa: str = Field(min_length=3, max_length=15)
    tipo: str = Field(min_length=2, max_length=30)
    capacidad_kg: Decimal = Field(gt=0)
    consumo_km_l: Decimal = Field(gt=0)
    factor_emision_kg_km: Decimal = Field(ge=0)
    anio_fabricacion: int = Field(ge=1950, le=datetime.now().year + 1)
    estado: Literal["ACTIVO", "INACTIVO"] = "ACTIVO"

    @field_validator("placa")
    @classmethod
    def normalizar_placa(cls, value):
        value = value.strip().upper()
        if not re.fullmatch(r"[A-Z0-9-]{3,15}", value): raise ValueError("Placa inválida")
        return value

    @field_validator("tipo")
    @classmethod
    def limpiar_tipo(cls, value):
        value=value.strip()
        if len(value)<2: raise ValueError("Tipo obligatorio")
        return value

class VehiculoRead(BaseModel):
    vehiculo_id: uuid.UUID
    placa: str
    tipo: str
    capacidad_kg: Decimal
    consumo_km_l: Decimal
    factor_emision_kg_km: Decimal
    anio_fabricacion: int
    estado: str
    model_config = ConfigDict(from_attributes=True)

class RepartidorCreate(BaseModel):
    usuario_id: uuid.UUID | None = None
    nombre: str = Field(min_length=2, max_length=160)
    dni: str = Field(pattern=r"^[0-9]{8}$")
    licencia: str = Field(min_length=3, max_length=30)
    categoria_licencia: str = Field(min_length=2,max_length=20)
    anios_experiencia: int = Field(ge=0,le=70)
    contacto: str = Field(min_length=7,max_length=50)
    disponible_desde: time
    disponible_hasta: time
    origen_latitud: Decimal = Field(ge=-90,le=90)
    origen_longitud: Decimal = Field(ge=-180,le=180)
    estado: Literal["ACTIVO","INACTIVO"] = "ACTIVO"
    correo: str | None = None
    password: str | None = Field(default=None,min_length=8,max_length=72)

    @field_validator("nombre","licencia","categoria_licencia","contacto")
    @classmethod
    def limpiar(cls, value):
        value=value.strip()
        if not value:raise ValueError("Campo obligatorio")
        return value

    @field_validator("correo")
    @classmethod
    def validar_correo(cls, value):
        if value is None:return None
        value=value.strip().lower()
        if not re.fullmatch(r"[^@\s]+@[^@\s]+\.[^@\s]+",value):raise ValueError("Correo inválido")
        return value

    @field_validator("password")
    @classmethod
    def validar_password(cls, value):
        if value is not None and len(value.encode("utf-8"))>72:raise ValueError("Contraseña demasiado larga")
        return value

    @model_validator(mode="after")
    def validar_turno(self):
        if self.disponible_desde >= self.disponible_hasta:raise ValueError("Inicio debe ser anterior al fin de disponibilidad")
        return self

class RepartidorRead(BaseModel):
    repartidor_id: uuid.UUID
    usuario_id: uuid.UUID
    nombre: str
    dni: str
    licencia: str
    categoria_licencia: str
    anios_experiencia: int | None
    contacto: str | None
    disponible_desde: time | None
    disponible_hasta: time | None
    origen_latitud: Decimal | None
    origen_longitud: Decimal | None
    estado: str
    correo: str | None = None
    model_config=ConfigDict(from_attributes=True)

class PedidoCreate(BaseModel):
    cliente_id: uuid.UUID | None = None
    cliente_nombre: str | None = Field(default=None,min_length=2,max_length=160)
    direccion: str = Field(min_length=5,max_length=255)
    latitud: Decimal | None = Field(default=None,ge=-90,le=90)
    longitud: Decimal | None = Field(default=None,ge=-180,le=180)
    punto_referencia: str | None = Field(default=None,max_length=500)
    peso_kg: Decimal = Field(gt=0,le=99999999)
    ventana_inicio: datetime
    ventana_fin: datetime
    prioridad: Literal["ESTANDAR","ALTA","URGENTE"] = "ESTANDAR"
    tipo_producto: str = Field(min_length=2,max_length=30)
    estado: Literal["PENDIENTE","EN_RUTA","ENTREGADO","CANCELADO"] = "PENDIENTE"

    @field_validator("cliente_nombre","direccion","tipo_producto")
    @classmethod
    def limpiar_texto(cls,value):
        if value is None:return None
        value=value.strip()
        if len(value)<2:raise ValueError("Campo obligatorio")
        return value

    @model_validator(mode="after")
    def validar_pedido(self):
        if (self.latitud is None)!=(self.longitud is None):raise ValueError("Indica latitud y longitud juntas")
        if not self.cliente_id and not self.cliente_nombre:raise ValueError("Indica el nombre del cliente")
        if (self.ventana_inicio.tzinfo is None)!=(self.ventana_fin.tzinfo is None):raise ValueError("Usa la misma zona horaria en ambas fechas")
        if self.ventana_fin<=self.ventana_inicio:raise ValueError("Fin debe ser posterior al inicio")
        return self

class PedidoRead(BaseModel):
    latitud: Decimal | None = None
    longitud: Decimal | None = None
    punto_referencia: str | None = None
    pedido_id: uuid.UUID
    cliente_id: uuid.UUID
    cliente_nombre: str | None = None
    direccion: str
    peso_kg: Decimal
    ventana_inicio: datetime
    ventana_fin: datetime
    prioridad: str
    tipo_producto: str
    estado: str
    model_config = ConfigDict(from_attributes=True)

class RutaHorario(BaseModel):
    inicio_planificado: datetime
    servicio_min_por_entrega: int = Field(default=5, ge=0, le=120)

    @field_validator("inicio_planificado")
    @classmethod
    def zona_obligatoria(cls, value):
        if value.tzinfo is None or value.utcoffset() is None:
            raise ValueError("Indica fecha y hora con zona horaria")
        return value


class RutaCreate(RutaHorario):
    vehiculo_id: uuid.UUID
    repartidor_id: uuid.UUID
    pedidos: list[uuid.UUID] = Field(min_length=1,max_length=20)

    @field_validator("pedidos")
    @classmethod
    def no_repetidos(cls,value):
        if len(set(value))!=len(value):raise ValueError("No repitas pedidos")
        return value

class RutaRead(BaseModel):
    inicio_planificado: datetime | None = None
    fin_planificado: datetime | None = None
    servicio_min_por_entrega: int | None = None
    ruta_id: uuid.UUID
    vehiculo_id: uuid.UUID
    repartidor_id: uuid.UUID
    algoritmo: str
    estado: str
    creado_en: datetime
    distancia_km: Decimal | None = None
    tiempo_min: Decimal | None = None
    origen_latitud: Decimal | None = None
    origen_longitud: Decimal | None = None
    geometria: dict | None = None
    repartidor_nombre: str | None = None
    vehiculo_placa: str | None = None
    entregas: list[dict] = Field(default_factory=list)
    model_config = ConfigDict(from_attributes=True)
