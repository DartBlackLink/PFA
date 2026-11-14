"""Simple client preferences, no customer portal or implicit schedule overrides."""

import uuid
from datetime import time
from typing import Literal

from fastapi import APIRouter, Depends, HTTPException, Query
from pydantic import Field, model_validator
from sqlalchemy import func, or_, select
from sqlalchemy.orm import Session

from app.api.deps import require_roles
from app.db.session import get_db
from app.models.entities import Cliente, PreferenciaEntrega
from app.schemas import ValidatedInput

router = APIRouter(dependencies=[Depends(require_roles("ADMIN"))])


class ClientInput(ValidatedInput):
    nombre: str = Field(min_length=2, max_length=160)
    contacto: str | None = Field(default=None, max_length=80)
    estado: Literal["ACTIVO", "INACTIVO"] = "ACTIVO"


class PreferenceInput(ValidatedInput):
    hora_preferida_inicio: time | None = None
    hora_preferida_fin: time | None = None
    punto_referencia: str | None = Field(default=None, max_length=500)
    restriccion_acceso: str | None = Field(default=None, max_length=500)

    @model_validator(mode="after")
    def valid_window(self):
        start, end = self.hora_preferida_inicio, self.hora_preferida_fin
        if (start is None) != (end is None):
            raise ValueError("Indica inicio y fin del horario, o deja ambos vacíos.")
        if start is not None and (start.tzinfo is not None or end.tzinfo is not None or start >= end):
            raise ValueError("Horario local de Huancayo: inicio anterior al fin, sin zona ni cruce de medianoche.")
        return self


def client_data(db, client):
    pref = db.scalar(select(PreferenciaEntrega).where(PreferenciaEntrega.cliente_id == client.cliente_id)
                     .order_by(PreferenciaEntrega.preferencia_id).limit(1))
    return serialize_client(client, pref)


def serialize_client(client, pref):
    return {"cliente_id": str(client.cliente_id), "nombre": client.nombre, "contacto": client.contacto,
            "estado": client.estado, "preferencia": {
                key: getattr(pref, key) for key in PreferenceInput.model_fields
            } if pref else None}


@router.get("/")
def list_clients(q: str = Query("", max_length=160), skip: int = Query(0, ge=0), limit: int = Query(25, ge=1, le=100), db: Session = Depends(get_db)):
    query = select(Cliente)
    if q.strip():
        # Parameter binding plus escaping: % and _ are literal search characters.
        pattern = "%" + q.strip().replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_") + "%"
        query = query.where(or_(Cliente.nombre.ilike(pattern, escape="\\"), Cliente.contacto.ilike(pattern, escape="\\")))
    total = db.scalar(select(func.count()).select_from(query.subquery()))
    clients = list(db.scalars(query.order_by(Cliente.nombre, Cliente.cliente_id).offset(skip).limit(limit)))
    preferences = {}
    if clients:
        for pref in db.scalars(select(PreferenciaEntrega).where(PreferenciaEntrega.cliente_id.in_(
            [client.cliente_id for client in clients])).order_by(PreferenciaEntrega.preferencia_id)):
            preferences.setdefault(pref.cliente_id, pref)
    return {"total": total, "items": [serialize_client(client, preferences.get(client.cliente_id)) for client in clients]}


@router.post("/", status_code=201)
def create_client(payload: ClientInput, db: Session = Depends(get_db)):
    client = Cliente(**payload.model_dump())
    db.add(client)
    db.commit()
    return client_data(db, client)


def find_client(db, identifier):
    client = db.scalar(select(Cliente).where(Cliente.cliente_id == identifier).with_for_update())
    if client is None:
        raise HTTPException(404, "Cliente no encontrado.")
    return client


@router.put("/{cliente_id}")
def update_client(cliente_id: uuid.UUID, payload: ClientInput, db: Session = Depends(get_db)):
    client = find_client(db, cliente_id)
    for key, value in payload.model_dump().items():
        setattr(client, key, value)
    db.commit()
    return client_data(db, client)


@router.get("/{cliente_id}")
def read_client(cliente_id: uuid.UUID, db: Session = Depends(get_db)):
    client = db.get(Cliente, cliente_id)
    if client is None:
        raise HTTPException(404, "Cliente no encontrado.")
    return client_data(db, client)


@router.put("/{cliente_id}/preferences")
def save_preferences(cliente_id: uuid.UUID, payload: PreferenceInput, db: Session = Depends(get_db)):
    client = find_client(db, cliente_id)
    pref = db.scalar(select(PreferenciaEntrega).where(PreferenciaEntrega.cliente_id == cliente_id)
                     .order_by(PreferenciaEntrega.preferencia_id).limit(1))
    if pref is None:
        pref = PreferenciaEntrega(cliente_id=cliente_id)
        db.add(pref)
    for key, value in payload.model_dump().items():
        setattr(pref, key, value)
    db.commit()
    return client_data(db, client)
