"""Actual operational timestamps; retain existing planned routes unchanged."""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision = '0006_route_operation'
down_revision = '0005_optimization_plan'
branch_labels = None
depends_on = None


def upgrade():
    op.drop_constraint('ck_plan_estado', 'plan_optimizacion', type_='check')
    op.create_check_constraint('ck_plan_estado', 'plan_optimizacion', "estado IN ('PREVISUALIZADO','CONFIRMADO','CANCELADO')")
    op.add_column('ruta', sa.Column('iniciado_en', sa.DateTime(timezone=True), nullable=True))
    op.add_column('ruta', sa.Column('finalizado_en', sa.DateTime(timezone=True), nullable=True))
    op.add_column('ruta_detalle', sa.Column('entregado_en', sa.DateTime(timezone=True), nullable=True))
    op.add_column('ruta_detalle', sa.Column('entregado_por', postgresql.UUID(as_uuid=True), nullable=True))
    op.create_foreign_key('fk_entrega_autor', 'ruta_detalle', 'usuario', ['entregado_por'], ['usuario_id'])


def downgrade():
    op.execute("UPDATE plan_optimizacion SET estado='PREVISUALIZADO' WHERE estado='CANCELADO'")
    op.drop_constraint('ck_plan_estado', 'plan_optimizacion', type_='check')
    op.create_check_constraint('ck_plan_estado', 'plan_optimizacion', "estado IN ('PREVISUALIZADO','CONFIRMADO')")
    op.drop_constraint('fk_entrega_autor', 'ruta_detalle', type_='foreignkey')
    op.drop_column('ruta_detalle', 'entregado_por')
    op.drop_column('ruta_detalle', 'entregado_en')
    op.drop_column('ruta', 'finalizado_en')
    op.drop_column('ruta', 'iniciado_en')
