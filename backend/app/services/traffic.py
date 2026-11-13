"""Time-dependent manual estimates. Never described as live or historical traffic.

Rules affect pairs whose origin OR destination lies in the configured rectangle.
This is a zonal approximation, not street-level observation. Travel integrates a
piecewise speed over time, so leaving a peak interval does not violate FIFO.
"""
import hashlib
import json
from datetime import timedelta

from pydantic import Field, model_validator

from app.models.entities import PoliticaTrafico
from app.schemas import ValidatedInput
from app.services.operation_area import contains, metadata
from app.services.scheduling import LIMA

# Reuse the application's operational America/Lima UTC-05 clock. This also works
# on Windows Python installations without an IANA timezone database dependency.


class TrafficRule(ValidatedInput):
    nombre: str = Field(min_length=3, max_length=80)
    sur: float = Field(ge=-90, le=90, allow_inf_nan=False)
    norte: float = Field(ge=-90, le=90, allow_inf_nan=False)
    oeste: float = Field(ge=-180, le=180, allow_inf_nan=False)
    este: float = Field(ge=-180, le=180, allow_inf_nan=False)
    dias: list[int] = Field(min_length=1, max_length=7)
    inicio_min: int = Field(ge=0, le=1439)
    fin_min: int = Field(ge=1, le=1440)
    factor: float = Field(ge=1, le=5, allow_inf_nan=False)
    fundamento: str = Field(min_length=10, max_length=400)

    @model_validator(mode='after')
    def consistent(self):
        if self.sur >= self.norte or self.oeste >= self.este:
            raise ValueError('El rectángulo debe tener límites ordenados')
        if not contains(self.sur, self.oeste) or not contains(self.norte, self.este):
            raise ValueError('La franja debe pertenecer a la zona operativa de Huancayo.')
        if self.inicio_min >= self.fin_min:
            raise ValueError('Divide las franjas nocturnas en dos reglas')
        if len(set(self.dias)) != len(self.dias) or any(d not in range(7) for d in self.dias):
            raise ValueError('Días únicos: 0 lunes a 6 domingo')
        self.nombre = self.nombre.strip()
        self.fundamento = self.fundamento.strip()
        if len(self.nombre) < 3 or len(self.fundamento) < 10:
            raise ValueError('Describe la zona y el fundamento de la aproximación')
        return self


class TrafficPolicyInput(ValidatedInput):
    revision: int = Field(ge=0)
    reglas: list[TrafficRule] = Field(max_length=40)


def policy_snapshot(db):
    # Serialize absent-row creation and revision changes even with multiple API workers.
    row = db.get(PoliticaTrafico, 1)
    return {'revision': row.revision if row else 0, 'reglas': row.reglas if row else [],
            'fuente': 'APROXIMACION_MANUAL_ZONAL', 'zona_horaria': 'America/Lima',
            'trafico_en_vivo': False, 'area_operativa': metadata()}


def digest(value):
    return hashlib.sha256(json.dumps(value, sort_keys=True, default=str).encode()).hexdigest()


class TrafficDurations(list):
    def __init__(self, base, coordinates, departure, policy, delay=0):
        if any(not contains(r['sur'], r['oeste']) or not contains(r['norte'], r['este']) for r in policy['reglas']):
            from fastapi import HTTPException
            raise HTTPException(422, 'Hay franjas fuera de Huancayo. Actualiza la configuración antes de calcular.')
        super().__init__([row[:] for row in base])
        self.coordinates = coordinates
        self.departure = departure
        self.policy = policy
        self.delay = delay

    def with_base(self, base):
        return TrafficDurations(base, self.coordinates, self.departure, self.policy, self.delay)

    def factor(self, source, destination, minute):
        local = (self.departure + timedelta(minutes=minute)).astimezone(LIMA)
        clock = local.hour * 60 + local.minute
        factors = [1.0]
        for rule in self.policy['reglas']:
            if local.weekday() not in rule['dias'] or not rule['inicio_min'] <= clock < rule['fin_min']:
                continue
            if any(rule['sur'] <= lat <= rule['norte'] and rule['oeste'] <= lon <= rule['este']
                   for lat, lon in (self.coordinates[source], self.coordinates[destination])):
                factors.append(rule['factor'])
        return max(factors)

    def minutes(self, source, destination, minute):
        remaining = self[source][destination]
        delay = self.delay if source == 0 and source != destination else 0
        if not self.policy['reglas']:
            return remaining + delay
        elapsed = float(delay)
        # One-minute intervals respect every configurable minute boundary.
        while remaining > 1e-9:
            instant = self.departure + timedelta(minutes=minute + elapsed)
            span = (60 - instant.second - instant.microsecond / 1_000_000) / 60
            factor = self.factor(source, destination, minute + elapsed)
            consumed = min(remaining, span / factor)
            elapsed += consumed * factor
            remaining -= consumed
        return elapsed


def travel_minutes(duration, source, destination, minute):
    if hasattr(duration, 'minutes'):
        return duration.minutes(source, destination, minute)
    return duration[source][destination]
