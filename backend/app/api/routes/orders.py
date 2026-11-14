import uuid

from typing import Literal

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.models.entities import Cliente, Pedido
from app.schemas import PedidoCreate, PedidoRead

router = APIRouter()


@router.get("/", response_model=list[PedidoRead])
def read_pedidos(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    estado: Literal["PENDIENTE", "ASIGNADO"] | None = Query(default=None),
    db: Session = Depends(get_db),
):
    query = (
        select(Pedido, Cliente.nombre)
        .join(Cliente, Cliente.cliente_id == Pedido.cliente_id)
        .order_by(Pedido.ventana_inicio, Pedido.pedido_id)
    )
    if estado is not None:
        query = query.where(Pedido.estado == estado)
    rows = db.execute(query.offset(skip).limit(limit)).all()
    return [
        {
            **{
                column.name: getattr(pedido, column.name)
                for column in Pedido.__table__.columns
            },
            "cliente_nombre": cliente_nombre,
        }
        for pedido, cliente_nombre in rows
    ]


@router.post("/", response_model=PedidoRead, status_code=201)
def create_pedido(pedido_in: PedidoCreate, db: Session = Depends(get_db)):
    cliente_id = pedido_in.cliente_id
    if cliente_id is None:
        cliente = Cliente(nombre=pedido_in.cliente_nombre or "Cliente sin nombre")
        db.add(cliente)
        db.flush()
        cliente_id = cliente.cliente_id

    elif not (client := db.get(Cliente, cliente_id)) or client.estado != "ACTIVO":
        raise HTTPException(422, "Cliente no encontrado.")

    pedido = Pedido(
        cliente_id=cliente_id,
        direccion=pedido_in.direccion,
        latitud=pedido_in.latitud,
        longitud=pedido_in.longitud,
        punto_referencia=pedido_in.punto_referencia,
        peso_kg=pedido_in.peso_kg,
        ventana_inicio=pedido_in.ventana_inicio,
        ventana_fin=pedido_in.ventana_fin,
        prioridad=pedido_in.prioridad,
        tipo_producto=pedido_in.tipo_producto,
        estado=pedido_in.estado,
    )
    db.add(pedido)
    db.commit()
    db.refresh(pedido)
    return {
        **{
            column.name: getattr(pedido, column.name)
            for column in Pedido.__table__.columns
        },
        "cliente_nombre": db.get(Cliente, cliente_id).nombre,
    }


@router.put("/{pedido_id}", response_model=PedidoRead)
def update_pedido(pedido_id: uuid.UUID, payload: PedidoCreate, db: Session = Depends(get_db)):
    pedido = db.scalar(select(Pedido).where(Pedido.pedido_id == pedido_id).with_for_update())
    if pedido is None:
        raise HTTPException(404, "Pedido no encontrado.")
    if pedido.estado != "PENDIENTE":
        raise HTTPException(409, "Solo puedes editar pedidos pendientes sin asignación.")
    if payload.cliente_id is not None:
        cliente = db.get(Cliente, payload.cliente_id)
        if cliente is None or cliente.estado != "ACTIVO":
            raise HTTPException(422, "Cliente activo no encontrado.")
        pedido.cliente_id = cliente.cliente_id
    elif payload.cliente_nombre != db.get(Cliente, pedido.cliente_id).nombre:
        cliente = Cliente(nombre=payload.cliente_nombre)
        db.add(cliente)
        db.flush()
        pedido.cliente_id = cliente.cliente_id
    for key, value in payload.model_dump(exclude={"cliente_id", "cliente_nombre", "estado"}).items():
        setattr(pedido, key, value)
    db.commit()
    db.refresh(pedido)
    return {
        **{column.name: getattr(pedido, column.name) for column in Pedido.__table__.columns},
        "cliente_nombre": db.get(Cliente, pedido.cliente_id).nombre,
    }
