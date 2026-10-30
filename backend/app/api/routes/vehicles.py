import uuid

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import func, select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.models.entities import Vehiculo
from app.schemas import VehiculoCreate, VehiculoRead

router = APIRouter()


@router.get("/", response_model=list[VehiculoRead])
def read_vehiculos(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    db: Session = Depends(get_db),
):
    return db.scalars(
        select(Vehiculo).order_by(Vehiculo.placa).offset(skip).limit(limit)
    ).all()


def save(payload, db, current=None):
    query = select(Vehiculo).where(
        func.upper(func.trim(Vehiculo.placa)) == payload.placa
    )
    if current:
        query = query.where(Vehiculo.vehiculo_id != current.vehiculo_id)
    if db.scalar(query):
        raise HTTPException(409, "La placa ya está registrada.")
    item = current or Vehiculo()
    for k, v in payload.model_dump().items():
        setattr(item, k, v)
    db.add(item)
    try:
        db.commit()
    except IntegrityError:
        db.rollback()
        raise HTTPException(409, "Datos en conflicto; revisa la placa.")
    db.refresh(item)
    return item


@router.post("/", response_model=VehiculoRead, status_code=201)
def create_vehiculo(payload: VehiculoCreate, db: Session = Depends(get_db)):
    return save(payload, db)


@router.put("/{vehiculo_id}", response_model=VehiculoRead)
def update_vehiculo(
    vehiculo_id: uuid.UUID, payload: VehiculoCreate, db: Session = Depends(get_db)
):
    item = db.get(Vehiculo, vehiculo_id)
    if not item:
        raise HTTPException(404, "Vehículo no encontrado.")
    return save(payload, db, item)
