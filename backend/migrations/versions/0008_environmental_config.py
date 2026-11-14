"""Optional, attributed environmental equivalence parameter. No invented defaults."""

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import UUID

revision = "0008_environmental_config"
down_revision = "0007_traffic_replanning"
branch_labels = None
depends_on = None


def upgrade():
    op.create_table(
        "configuracion_ambiental",
        sa.Column("configuracion_id", sa.Integer(), primary_key=True),
        sa.Column("factor_kg_por_unidad", sa.Numeric(16, 6), nullable=True),
        sa.Column("unidad", sa.String(80), nullable=True),
        sa.Column("fuente", sa.String(500), nullable=True),
        sa.Column("actualizado_por", UUID(as_uuid=True), sa.ForeignKey("usuario.usuario_id"), nullable=False),
        sa.Column("actualizado_en", sa.DateTime(timezone=True), nullable=False),
        sa.CheckConstraint("configuracion_id = 1", name="ck_ambiental_singleton"),
        sa.CheckConstraint("(factor_kg_por_unidad IS NULL AND unidad IS NULL AND fuente IS NULL) OR (factor_kg_por_unidad IS NOT NULL AND factor_kg_por_unidad > 0 AND factor_kg_por_unidad <= 100000000 AND unidad IS NOT NULL AND fuente IS NOT NULL)", name="ck_ambiental_complete"),
    )


def downgrade():
    op.drop_table("configuracion_ambiental")
