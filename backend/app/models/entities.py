import uuid
from datetime import date, datetime, time, timezone
from decimal import Decimal

from sqlalchemy import Date, DateTime, ForeignKey, Integer, Numeric, String, Text, Time
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.db.session import Base


class Usuario(Base):
    __tablename__ = "usuario"
    usuario_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True)
    password_hash: Mapped[str] = mapped_column(String(255))
    rol: Mapped[str] = mapped_column(String(30))
    estado: Mapped[str] = mapped_column(String(20), default="ACTIVO")
    creado_en: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )


class ControlAcceso(Base):
    __tablename__ = "control_acceso"
    identificador_hmac: Mapped[str] = mapped_column(String(64), primary_key=True)
    intentos_fallidos: Mapped[int] = mapped_column(Integer, default=0)
    bloqueo_hasta: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    actualizado_en: Mapped[datetime] = mapped_column(DateTime(timezone=True))


class Vehiculo(Base):
    __tablename__ = "vehiculo"
    vehiculo_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    placa: Mapped[str] = mapped_column(String(15), unique=True, index=True)
    tipo: Mapped[str] = mapped_column(String(30))
    capacidad_kg: Mapped[Decimal] = mapped_column(Numeric(10, 2))
    consumo_km_l: Mapped[Decimal] = mapped_column(Numeric(8, 3))
    factor_emision_kg_km: Mapped[Decimal] = mapped_column(Numeric(10, 4))
    anio_fabricacion: Mapped[int] = mapped_column(Integer)
    estado: Mapped[str] = mapped_column(String(20), default="ACTIVO")


class Repartidor(Base):
    __tablename__ = "repartidor"
    repartidor_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    usuario_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("usuario.usuario_id"), unique=True
    )
    nombre: Mapped[str] = mapped_column(String(160))
    dni: Mapped[str] = mapped_column(String(20), unique=True)
    licencia: Mapped[str] = mapped_column(String(30))
    categoria_licencia: Mapped[str] = mapped_column(String(20))
    anios_experiencia: Mapped[int | None] = mapped_column(Integer, nullable=True)
    disponible_desde: Mapped[time | None] = mapped_column(Time, nullable=True)
    disponible_hasta: Mapped[time | None] = mapped_column(Time, nullable=True)
    contacto: Mapped[str | None] = mapped_column(String(50), nullable=True)

    origen_latitud: Mapped[Decimal | None] = mapped_column(Numeric(9, 6), nullable=True)
    origen_longitud: Mapped[Decimal | None] = mapped_column(
        Numeric(9, 6), nullable=True
    )
    estado: Mapped[str] = mapped_column(String(20), default="ACTIVO")


class Cliente(Base):
    __tablename__ = "cliente"
    cliente_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    nombre: Mapped[str] = mapped_column(String(160))
    contacto: Mapped[str | None] = mapped_column(String(80), nullable=True)
    estado: Mapped[str] = mapped_column(String(20), default="ACTIVO")


class PreferenciaEntrega(Base):
    __tablename__ = "preferencia_entrega"
    preferencia_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    cliente_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("cliente.cliente_id"))
    hora_preferida_inicio: Mapped[time | None] = mapped_column(Time, nullable=True)
    hora_preferida_fin: Mapped[time | None] = mapped_column(Time, nullable=True)
    punto_referencia: Mapped[str | None] = mapped_column(Text, nullable=True)
    restriccion_acceso: Mapped[str | None] = mapped_column(Text, nullable=True)


class Pedido(Base):
    __tablename__ = "pedido"
    pedido_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    cliente_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("cliente.cliente_id"))
    direccion: Mapped[str] = mapped_column(Text)
    punto_referencia: Mapped[str | None] = mapped_column(Text, nullable=True)
    latitud: Mapped[Decimal | None] = mapped_column(Numeric(9, 6), nullable=True)
    longitud: Mapped[Decimal | None] = mapped_column(Numeric(9, 6), nullable=True)
    peso_kg: Mapped[Decimal] = mapped_column(Numeric(10, 2))
    volumen_m3: Mapped[Decimal | None] = mapped_column(Numeric(10, 3), nullable=True)
    ventana_inicio: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    ventana_fin: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    prioridad: Mapped[str] = mapped_column(String(20))
    tipo_producto: Mapped[str] = mapped_column(String(30))
    estado: Mapped[str] = mapped_column(String(20), default="PENDIENTE")


class Ruta(Base):
    version: Mapped[int] = mapped_column(Integer, default=1)
    version_recibida: Mapped[int] = mapped_column(Integer, default=0)
    iniciado_en: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    finalizado_en: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    plan_optimizacion_id: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("plan_optimizacion.plan_id"), nullable=True, index=True
    )
    inicio_planificado: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    fin_planificado: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    servicio_min_por_entrega: Mapped[int | None] = mapped_column(Integer, nullable=True)
    __tablename__ = "ruta"
    ruta_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    vehiculo_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("vehiculo.vehiculo_id"))
    repartidor_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("repartidor.repartidor_id")
    )
    estado: Mapped[str] = mapped_column(String(20), default="PLANIFICADA")
    algoritmo: Mapped[str] = mapped_column(String(50))
    origen_latitud: Mapped[Decimal | None] = mapped_column(Numeric(9, 6), nullable=True)
    origen_longitud: Mapped[Decimal | None] = mapped_column(
        Numeric(9, 6), nullable=True
    )
    geometria: Mapped[dict | None] = mapped_column(JSONB, nullable=True)
    distancia_km: Mapped[Decimal | None] = mapped_column(Numeric(12, 3), nullable=True)
    tiempo_min: Mapped[Decimal | None] = mapped_column(Numeric(12, 2), nullable=True)
    combustible_l: Mapped[Decimal | None] = mapped_column(Numeric(12, 3), nullable=True)
    co2_kg: Mapped[Decimal | None] = mapped_column(Numeric(12, 3), nullable=True)
    penalizacion_total: Mapped[Decimal] = mapped_column(Numeric(14, 2), default=0)
    creado_en: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )


class RutaDetalle(Base):
    entregado_en: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    entregado_por: Mapped[uuid.UUID | None] = mapped_column(ForeignKey('usuario.usuario_id'), nullable=True)
    __tablename__ = "ruta_detalle"
    ruta_detalle_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    ruta_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("ruta.ruta_id"))
    pedido_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("pedido.pedido_id"))
    secuencia: Mapped[int] = mapped_column(Integer)
    eta: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    estado_entrega: Mapped[str] = mapped_column(String(20), default="PENDIENTE")


class Incidente(Base):
    demora_min: Mapped[int | None] = mapped_column(Integer, nullable=True)
    afectacion: Mapped[str] = mapped_column(String(20), default='NO_INDICADA')
    registrado_en: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    resuelto_en: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    resolucion: Mapped[str | None] = mapped_column(Text, nullable=True)
    __tablename__ = "incidente"
    incidente_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    ruta_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("ruta.ruta_id"))
    repartidor_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("repartidor.repartidor_id")
    )
    tipo: Mapped[str] = mapped_column(String(30))
    descripcion: Mapped[str | None] = mapped_column(Text, nullable=True)
    latitud: Mapped[Decimal | None] = mapped_column(Numeric(9, 6), nullable=True)
    longitud: Mapped[Decimal | None] = mapped_column(Numeric(9, 6), nullable=True)
    ocurrido_en: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )


class ReporteSostenibilidad(Base):
    __tablename__ = "reporte_sostenibilidad"
    reporte_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    ruta_id: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey("ruta.ruta_id"), nullable=True
    )
    periodo_inicio: Mapped[date] = mapped_column(Date)
    periodo_fin: Mapped[date] = mapped_column(Date)
    co2_kg: Mapped[Decimal] = mapped_column(Numeric(14, 3), default=0)
    combustible_l: Mapped[Decimal] = mapped_column(Numeric(14, 3), default=0)
    ahorro_estimado: Mapped[Decimal] = mapped_column(Numeric(14, 2), default=0)
    archivo_url: Mapped[str | None] = mapped_column(Text, nullable=True)


class CompensacionCarbono(Base):
    __tablename__ = "compensacion_carbono"
    compensacion_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    reporte_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("reporte_sostenibilidad.reporte_id")
    )
    co2_objetivo_kg: Mapped[Decimal] = mapped_column(Numeric(14, 3))
    descripcion_plan: Mapped[str] = mapped_column(Text)


class PlanOptimizacion(Base):
    __tablename__ = "plan_optimizacion"
    plan_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    usuario_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("usuario.usuario_id"))
    estado: Mapped[str] = mapped_column(String(30), default="PREVISUALIZADO")
    creado_en: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )
    vence_en: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    solicitud: Mapped[dict] = mapped_column(JSONB)
    solucion: Mapped[dict] = mapped_column(JSONB)
    huella_datos: Mapped[str] = mapped_column(String(64))


class PoliticaTrafico(Base):
    __tablename__ = 'politica_trafico'
    politica_id: Mapped[int] = mapped_column(Integer, primary_key=True)
    revision: Mapped[int] = mapped_column(Integer, default=1)
    reglas: Mapped[list] = mapped_column(JSONB, default=list)
    actualizado_en: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    usuario_id: Mapped[uuid.UUID] = mapped_column(ForeignKey('usuario.usuario_id'))


class RevisionRuta(Base):
    __tablename__ = 'revision_ruta'
    revision_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    ruta_id: Mapped[uuid.UUID] = mapped_column(ForeignKey('ruta.ruta_id'), index=True)
    version_base: Mapped[int] = mapped_column(Integer)
    estado: Mapped[str] = mapped_column(String(20), default='PROPUESTA')
    autor_id: Mapped[uuid.UUID] = mapped_column(ForeignKey('usuario.usuario_id'))
    aprobado_por: Mapped[uuid.UUID | None] = mapped_column(ForeignKey('usuario.usuario_id'), nullable=True)
    creado_en: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    vence_en: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    aprobado_en: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    recibido_en: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    motivo: Mapped[str] = mapped_column(Text)
    huella: Mapped[str] = mapped_column(String(64))
    anterior: Mapped[dict] = mapped_column(JSONB)
    propuesta: Mapped[dict] = mapped_column(JSONB)


class Notificacion(Base):
    __tablename__ = 'notificacion'
    notificacion_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    usuario_id: Mapped[uuid.UUID | None] = mapped_column(ForeignKey('usuario.usuario_id'), nullable=True, index=True)
    rol: Mapped[str | None] = mapped_column(String(30), nullable=True)
    ruta_id: Mapped[uuid.UUID] = mapped_column(ForeignKey('ruta.ruta_id'))
    tipo: Mapped[str] = mapped_column(String(40))
    referencia_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True))
    creado_en: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))


class LecturaNotificacion(Base):
    __tablename__ = 'lectura_notificacion'
    notificacion_id: Mapped[uuid.UUID] = mapped_column(ForeignKey('notificacion.notificacion_id'), primary_key=True)
    usuario_id: Mapped[uuid.UUID] = mapped_column(ForeignKey('usuario.usuario_id'), primary_key=True)
    leido_en: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))


class ConfiguracionAmbiental(Base):
    __tablename__ = "configuracion_ambiental"
    configuracion_id: Mapped[int] = mapped_column(Integer, primary_key=True)
    factor_kg_por_unidad: Mapped[Decimal | None] = mapped_column(Numeric(16, 6), nullable=True)
    unidad: Mapped[str | None] = mapped_column(String(80), nullable=True)
    fuente: Mapped[str | None] = mapped_column(String(500), nullable=True)
    actualizado_por: Mapped[uuid.UUID] = mapped_column(ForeignKey("usuario.usuario_id"))
    actualizado_en: Mapped[datetime] = mapped_column(DateTime(timezone=True))
