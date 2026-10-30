"""Public optimization contracts. Inputs contain IDs, never arbitrary provider URLs."""

from datetime import datetime
from typing import Literal
from uuid import UUID

from pydantic import BaseModel, Field, field_validator, model_validator

from app.schemas import ValidatedInput


class TeamSelection(ValidatedInput):
    repartidor_id: UUID
    vehiculo_id: UUID


class OptimizationRequest(ValidatedInput):
    pedidos: list[UUID] = Field(min_length=1, max_length=150)
    equipos: list[TeamSelection] = Field(min_length=1, max_length=15)
    inicio_planificado: datetime
    servicio_min_por_entrega: int = Field(default=5, ge=1, le=120)
    jornada_max_min: int = Field(default=480, ge=1, le=480)
    descanso_cada_min: int = Field(default=240, ge=1, le=480)
    descanso_min: int = Field(default=30, ge=1, le=120)
    regresar_al_origen: bool = True
    semilla: int = Field(default=42, ge=0, le=2**32 - 1)
    poblacion: int = Field(default=24, ge=4, le=64)
    generaciones: int = Field(default=40, ge=1, le=150)
    limite_calculo_seg: float = Field(default=8, gt=0, le=15, allow_inf_nan=False)

    @field_validator("inicio_planificado")
    @classmethod
    def aware_start(cls, value):
        if value.utcoffset() is None:
            raise ValueError("Indica fecha con zona horaria")
        return value

    @model_validator(mode="after")
    def unique_resources(self):
        if len(set(self.pedidos)) != len(self.pedidos):
            raise ValueError("No repitas pedidos")
        if len({item.repartidor_id for item in self.equipos}) != len(self.equipos):
            raise ValueError("Un repartidor solo puede pertenecer a un equipo")
        if len({item.vehiculo_id for item in self.equipos}) != len(self.equipos):
            raise ValueError("Un vehículo solo puede pertenecer a un equipo")
        return self


class PlanView(BaseModel):
    plan_id: UUID
    estado: Literal["PREVISUALIZADO", "CONFIRMADO"]
    creado_en: datetime
    vence_en: datetime
    algoritmo: str
    estadisticas: dict
    rutas: list[dict]
    advertencias: list[str]
    ruta_ids: list[UUID] = Field(default_factory=list)
