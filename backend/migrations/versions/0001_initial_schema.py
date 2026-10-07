"""Initial frozen schema (eleven original tables)."""
import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import UUID
from alembic import op
revision = '0001_initial_schema'
down_revision = None
branch_labels = None
depends_on = None

def upgrade():
    op.create_table('usuario',
        sa.Column('usuario_id', UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column('email', sa.String(255), unique=True, nullable=False),
        sa.Column('password_hash', sa.String(255), nullable=False),
        sa.Column('rol', sa.String(30), nullable=False),
        sa.Column('estado', sa.String(20), nullable=False),
        sa.Column('creado_en', sa.DateTime(timezone=True), nullable=False),
    )
    op.create_index("ix_usuario_email", 'usuario', ['email'])
    op.create_table('vehiculo',
        sa.Column('vehiculo_id', UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column('placa', sa.String(15), unique=True, nullable=False),
        sa.Column('tipo', sa.String(30), nullable=False),
        sa.Column('capacidad_kg', sa.Numeric(10, 2), nullable=False),
        sa.Column('consumo_km_l', sa.Numeric(8, 3), nullable=False),
        sa.Column('factor_emision_kg_km', sa.Numeric(10, 4), nullable=False),
        sa.Column('anio_fabricacion', sa.Integer, nullable=False),
        sa.Column('estado', sa.String(20), nullable=False),
    )
    op.create_index("ix_vehiculo_placa", 'vehiculo', ['placa'])
    op.create_table('repartidor',
        sa.Column('repartidor_id', UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column('usuario_id', UUID(as_uuid=True), sa.ForeignKey('usuario.usuario_id'), unique=True, nullable=False),
        sa.Column('nombre', sa.String(160), nullable=False),
        sa.Column('dni', sa.String(20), unique=True, nullable=False),
        sa.Column('licencia', sa.String(30), nullable=False),
        sa.Column('categoria_licencia', sa.String(20), nullable=False),
        sa.Column('anios_experiencia', sa.Integer, nullable=True),
        sa.Column('disponible_desde', sa.Time, nullable=True),
        sa.Column('disponible_hasta', sa.Time, nullable=True),
        sa.Column('contacto', sa.String(50), nullable=True),
    )
    op.create_table('cliente',
        sa.Column('cliente_id', UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column('nombre', sa.String(160), nullable=False),
        sa.Column('contacto', sa.String(80), nullable=True),
        sa.Column('estado', sa.String(20), nullable=False),
    )
    op.create_table('preferencia_entrega',
        sa.Column('preferencia_id', UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column('cliente_id', UUID(as_uuid=True), sa.ForeignKey('cliente.cliente_id'), nullable=False),
        sa.Column('hora_preferida_inicio', sa.Time, nullable=True),
        sa.Column('hora_preferida_fin', sa.Time, nullable=True),
        sa.Column('punto_referencia', sa.Text, nullable=True),
        sa.Column('restriccion_acceso', sa.Text, nullable=True),
    )
    op.create_table('pedido',
        sa.Column('pedido_id', UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column('cliente_id', UUID(as_uuid=True), sa.ForeignKey('cliente.cliente_id'), nullable=False),
        sa.Column('direccion', sa.Text, nullable=False),
        sa.Column('punto_referencia', sa.Text, nullable=True),
        sa.Column('latitud', sa.Numeric(9, 6), nullable=True),
        sa.Column('longitud', sa.Numeric(9, 6), nullable=True),
        sa.Column('peso_kg', sa.Numeric(10, 2), nullable=False),
        sa.Column('volumen_m3', sa.Numeric(10, 3), nullable=True),
        sa.Column('ventana_inicio', sa.DateTime(timezone=True), nullable=False),
        sa.Column('ventana_fin', sa.DateTime(timezone=True), nullable=False),
        sa.Column('prioridad', sa.String(20), nullable=False),
        sa.Column('tipo_producto', sa.String(30), nullable=False),
        sa.Column('estado', sa.String(20), nullable=False),
    )
    op.create_table('ruta',
        sa.Column('ruta_id', UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column('vehiculo_id', UUID(as_uuid=True), sa.ForeignKey('vehiculo.vehiculo_id'), nullable=False),
        sa.Column('repartidor_id', UUID(as_uuid=True), sa.ForeignKey('repartidor.repartidor_id'), nullable=False),
        sa.Column('estado', sa.String(20), nullable=False),
        sa.Column('algoritmo', sa.String(50), nullable=False),
        sa.Column('distancia_km', sa.Numeric(12, 3), nullable=True),
        sa.Column('tiempo_min', sa.Numeric(12, 2), nullable=True),
        sa.Column('combustible_l', sa.Numeric(12, 3), nullable=True),
        sa.Column('co2_kg', sa.Numeric(12, 3), nullable=True),
        sa.Column('penalizacion_total', sa.Numeric(14, 2), nullable=False),
        sa.Column('creado_en', sa.DateTime(timezone=True), nullable=False),
    )
    op.create_table('ruta_detalle',
        sa.Column('ruta_detalle_id', UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column('ruta_id', UUID(as_uuid=True), sa.ForeignKey('ruta.ruta_id'), nullable=False),
        sa.Column('pedido_id', UUID(as_uuid=True), sa.ForeignKey('pedido.pedido_id'), nullable=False),
        sa.Column('secuencia', sa.Integer, nullable=False),
        sa.Column('eta', sa.DateTime(timezone=True), nullable=True),
        sa.Column('estado_entrega', sa.String(20), nullable=False),
    )
    op.create_table('incidente',
        sa.Column('incidente_id', UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column('ruta_id', UUID(as_uuid=True), sa.ForeignKey('ruta.ruta_id'), nullable=False),
        sa.Column('repartidor_id', UUID(as_uuid=True), sa.ForeignKey('repartidor.repartidor_id'), nullable=False),
        sa.Column('tipo', sa.String(30), nullable=False),
        sa.Column('descripcion', sa.Text, nullable=True),
        sa.Column('latitud', sa.Numeric(9, 6), nullable=True),
        sa.Column('longitud', sa.Numeric(9, 6), nullable=True),
        sa.Column('ocurrido_en', sa.DateTime(timezone=True), nullable=False),
    )
    op.create_table('reporte_sostenibilidad',
        sa.Column('reporte_id', UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column('ruta_id', UUID(as_uuid=True), sa.ForeignKey('ruta.ruta_id'), nullable=True),
        sa.Column('periodo_inicio', sa.Date, nullable=False),
        sa.Column('periodo_fin', sa.Date, nullable=False),
        sa.Column('co2_kg', sa.Numeric(14, 3), nullable=False),
        sa.Column('combustible_l', sa.Numeric(14, 3), nullable=False),
        sa.Column('ahorro_estimado', sa.Numeric(14, 2), nullable=False),
        sa.Column('archivo_url', sa.Text, nullable=True),
    )
    op.create_table('compensacion_carbono',
        sa.Column('compensacion_id', UUID(as_uuid=True), primary_key=True, nullable=False),
        sa.Column('reporte_id', UUID(as_uuid=True), sa.ForeignKey('reporte_sostenibilidad.reporte_id'), nullable=False),
        sa.Column('co2_objetivo_kg', sa.Numeric(14, 3), nullable=False),
        sa.Column('descripcion_plan', sa.Text, nullable=False),
    )

def downgrade():
    op.drop_table('compensacion_carbono')
    op.drop_table('reporte_sostenibilidad')
    op.drop_table('incidente')
    op.drop_table('ruta_detalle')
    op.drop_table('ruta')
    op.drop_table('pedido')
    op.drop_table('preferencia_entrega')
    op.drop_table('cliente')
    op.drop_table('repartidor')
    op.drop_table('vehiculo')
    op.drop_table('usuario')
