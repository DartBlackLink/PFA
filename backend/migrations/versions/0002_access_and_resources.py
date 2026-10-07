"""Persistent login policy and driver fields; preserve historical records."""
from alembic import op
import sqlalchemy as sa
revision = "0002_access_resources"
down_revision = "0001_initial_schema"
branch_labels = None
depends_on = None

def upgrade():
    op.create_table("control_acceso",
        sa.Column("identificador_hmac", sa.String(64), primary_key=True),
        sa.Column("intentos_fallidos", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("bloqueo_hasta", sa.DateTime(timezone=True)),
        sa.Column("actualizado_en", sa.DateTime(timezone=True), nullable=False),
        sa.CheckConstraint("intentos_fallidos BETWEEN 0 AND 5", name="ck_access_attempts"))
    op.add_column("repartidor", sa.Column("origen_latitud", sa.Numeric(9,6)))
    op.add_column("repartidor", sa.Column("origen_longitud", sa.Numeric(9,6)))
    op.add_column("repartidor", sa.Column("estado", sa.String(20), nullable=False, server_default="ACTIVO"))
    # NOT VALID preserves pre-existing invalid data, enforces subsequent writes.
    checks = {
        "vehiculo": {"ck_vehicle_capacity": "capacidad_kg > 0", "ck_vehicle_consumption": "consumo_km_l > 0", "ck_vehicle_emissions": "factor_emision_kg_km >= 0"},
        "repartidor": {"ck_driver_hours": "disponible_desde IS NULL OR disponible_hasta IS NULL OR disponible_desde < disponible_hasta", "ck_driver_origin": "(origen_latitud IS NULL) = (origen_longitud IS NULL)", "ck_driver_lat": "origen_latitud BETWEEN -90 AND 90", "ck_driver_lon": "origen_longitud BETWEEN -180 AND 180"}}
    for table, rules in checks.items():
        for name, expression in rules.items():
            op.execute(f"ALTER TABLE {table} ADD CONSTRAINT {name} CHECK ({expression}) NOT VALID")

def downgrade():
    for table,names in {"vehiculo":["ck_vehicle_capacity","ck_vehicle_consumption","ck_vehicle_emissions"],"repartidor":["ck_driver_hours","ck_driver_origin","ck_driver_lat","ck_driver_lon"]}.items():
        for name in names: op.drop_constraint(name, table, type_="check")
    for field in ["origen_latitud","origen_longitud","estado"]:op.drop_column("repartidor",field)
    op.drop_table("control_acceso")
