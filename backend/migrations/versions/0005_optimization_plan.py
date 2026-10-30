"""Reproducible genetic preview and atomic confirmation, retaining existing routes."""

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision = "0005_optimization_plan"
down_revision = "0004_route_schedule"
branch_labels = None
depends_on = None


def upgrade():
    op.create_table(
        "plan_optimizacion",
        sa.Column("plan_id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column(
            "usuario_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("usuario.usuario_id"),
            nullable=False,
        ),
        sa.Column("estado", sa.String(30), nullable=False),
        sa.Column("creado_en", sa.DateTime(timezone=True), nullable=False),
        sa.Column("vence_en", sa.DateTime(timezone=True), nullable=False),
        sa.Column("solicitud", postgresql.JSONB(), nullable=False),
        sa.Column("solucion", postgresql.JSONB(), nullable=False),
        sa.Column("huella_datos", sa.String(64), nullable=False),
        sa.CheckConstraint(
            "estado IN ('PREVISUALIZADO','CONFIRMADO')", name="ck_plan_estado"
        ),
    )
    op.add_column(
        "ruta",
        sa.Column("plan_optimizacion_id", postgresql.UUID(as_uuid=True), nullable=True),
    )
    op.create_foreign_key(
        "fk_ruta_plan",
        "ruta",
        "plan_optimizacion",
        ["plan_optimizacion_id"],
        ["plan_id"],
    )
    op.create_index("ix_ruta_plan_optimizacion_id", "ruta", ["plan_optimizacion_id"])


def downgrade():
    op.drop_index("ix_ruta_plan_optimizacion_id", table_name="ruta")
    op.drop_constraint("fk_ruta_plan", "ruta", type_="foreignkey")
    op.drop_column("ruta", "plan_optimizacion_id")
    op.drop_table("plan_optimizacion")
