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

    elif not db.get(Cliente, cliente_id):
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
        "cliente_nombre": pedido_in.cliente_nombre,
    }
