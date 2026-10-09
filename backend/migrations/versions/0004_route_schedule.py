"""Persist planned route schedules without inventing dates for historical routes."""
from alembic import op
import sqlalchemy as sa
revision = "0004_route_schedule"
down_revision = "0003_route_geometry"
branch_labels = None
depends_on = None


def upgrade():
    op.add_column("ruta", sa.Column("inicio_planificado", sa.DateTime(timezone=True)))
    op.add_column("ruta", sa.Column("fin_planificado", sa.DateTime(timezone=True)))
    op.add_column("ruta", sa.Column("servicio_min_por_entrega", sa.Integer()))
    op.create_check_constraint("ck_ruta_horario", "ruta", "(inicio_planificado IS NULL AND fin_planificado IS NULL AND servicio_min_por_entrega IS NULL) OR (inicio_planificado IS NOT NULL AND fin_planificado IS NOT NULL AND fin_planificado > inicio_planificado AND servicio_min_por_entrega BETWEEN 0 AND 120)")
    op.create_index("ix_ruta_repartidor_inicio", "ruta", ["repartidor_id", "inicio_planificado"])
    op.create_index("ix_ruta_vehiculo_inicio", "ruta", ["vehiculo_id", "inicio_planificado"])


def downgrade():
    op.drop_index("ix_ruta_vehiculo_inicio", table_name="ruta")
    op.drop_index("ix_ruta_repartidor_inicio", table_name="ruta")
    op.drop_constraint("ck_ruta_horario", "ruta", type_="check")
    for column in ["servicio_min_por_entrega", "fin_planificado", "inicio_planificado"]:
        op.drop_column("ruta", column)
