"""Persist assignment origin and street geometry without removing records."""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import JSONB
revision="0003_route_geometry"
down_revision="0002_access_resources"
branch_labels=None
depends_on=None

def upgrade():
    op.add_column("ruta",sa.Column("origen_latitud",sa.Numeric(9,6)))
    op.add_column("ruta",sa.Column("origen_longitud",sa.Numeric(9,6)))
    op.add_column("ruta",sa.Column("geometria",JSONB))
    op.create_index("ix_ruta_detalle_pedido","ruta_detalle",["pedido_id"])

def downgrade():
    op.drop_index("ix_ruta_detalle_pedido",table_name="ruta_detalle")
    for column in ["geometria","origen_longitud","origen_latitud"]:op.drop_column("ruta",column)
