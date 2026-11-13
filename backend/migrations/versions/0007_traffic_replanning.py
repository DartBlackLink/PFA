"""Durable traffic estimates, reports, route versions and notifications."""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import JSONB, UUID

revision = '0007_traffic_replanning'
down_revision = '0006_route_operation'
branch_labels = None
depends_on = None


def upgrade():
    op.add_column('ruta', sa.Column('version', sa.Integer(), nullable=False, server_default='1'))
    op.add_column('ruta', sa.Column('version_recibida', sa.Integer(), nullable=False, server_default='0'))
    op.create_check_constraint('ck_ruta_version', 'ruta', 'version >= 1 AND version_recibida >= 0 AND version_recibida <= version')
    for name, kind, default, nullable in [
        ('demora_min', sa.Integer(), None, True),
        ('afectacion', sa.String(20), 'NO_INDICADA', False),
        ('registrado_en', sa.DateTime(timezone=True), sa.func.now(), False),
        ('resuelto_en', sa.DateTime(timezone=True), None, True),
        ('resolucion', sa.Text(), None, True),
    ]:
        op.add_column('incidente', sa.Column(name, kind, nullable=nullable, server_default=default))
    op.create_check_constraint('ck_incident_delay', 'incidente', 'demora_min IS NULL OR demora_min BETWEEN 0 AND 240')
    op.create_table('politica_trafico',
        sa.Column('politica_id', sa.Integer(), primary_key=True),
        sa.Column('revision', sa.Integer(), nullable=False),
        sa.Column('reglas', JSONB(), nullable=False),
        sa.Column('actualizado_en', sa.DateTime(timezone=True), nullable=False),
        sa.Column('usuario_id', UUID(as_uuid=True), sa.ForeignKey('usuario.usuario_id'), nullable=False))
    op.create_table('revision_ruta',
        sa.Column('revision_id', UUID(as_uuid=True), primary_key=True),
        sa.Column('ruta_id', UUID(as_uuid=True), sa.ForeignKey('ruta.ruta_id'), nullable=False),
        sa.Column('version_base', sa.Integer(), nullable=False),
        sa.Column('estado', sa.String(20), nullable=False),
        sa.Column('autor_id', UUID(as_uuid=True), sa.ForeignKey('usuario.usuario_id'), nullable=False),
        sa.Column('aprobado_por', UUID(as_uuid=True), sa.ForeignKey('usuario.usuario_id'), nullable=True),
        sa.Column('creado_en', sa.DateTime(timezone=True), nullable=False),
        sa.Column('vence_en', sa.DateTime(timezone=True), nullable=False),
        sa.Column('aprobado_en', sa.DateTime(timezone=True), nullable=True),
        sa.Column('recibido_en', sa.DateTime(timezone=True), nullable=True),
        sa.Column('motivo', sa.Text(), nullable=False),
        sa.Column('huella', sa.String(64), nullable=False),
        sa.Column('anterior', JSONB(), nullable=False),
        sa.Column('propuesta', JSONB(), nullable=False),
        sa.CheckConstraint("estado IN ('PROPUESTA','APROBADA','RECHAZADA')", name='ck_revision_estado'))
    op.create_index('ix_revision_ruta_ruta_id', 'revision_ruta', ['ruta_id'])
    op.create_table('notificacion',
        sa.Column('notificacion_id', UUID(as_uuid=True), primary_key=True),
        sa.Column('usuario_id', UUID(as_uuid=True), sa.ForeignKey('usuario.usuario_id'), nullable=True),
        sa.Column('rol', sa.String(30), nullable=True),
        sa.Column('ruta_id', UUID(as_uuid=True), sa.ForeignKey('ruta.ruta_id'), nullable=False),
        sa.Column('tipo', sa.String(40), nullable=False),
        sa.Column('referencia_id', UUID(as_uuid=True), nullable=False),
        sa.Column('creado_en', sa.DateTime(timezone=True), nullable=False),
        sa.CheckConstraint("(usuario_id IS NOT NULL AND rol IS NULL) OR (usuario_id IS NULL AND rol = 'ADMIN')", name='ck_notification_recipient'))
    op.create_index('ix_notificacion_usuario_id', 'notificacion', ['usuario_id'])
    op.create_table('lectura_notificacion',
        sa.Column('notificacion_id', UUID(as_uuid=True), sa.ForeignKey('notificacion.notificacion_id'), primary_key=True),
        sa.Column('usuario_id', UUID(as_uuid=True), sa.ForeignKey('usuario.usuario_id'), primary_key=True),
        sa.Column('leido_en', sa.DateTime(timezone=True), nullable=False))


def downgrade():
    op.drop_table('lectura_notificacion')
    op.drop_table('notificacion')
    op.drop_table('revision_ruta')
    op.drop_table('politica_trafico')
    op.drop_constraint('ck_incident_delay', 'incidente', type_='check')
    for name in ['resolucion', 'resuelto_en', 'registrado_en', 'afectacion', 'demora_min']:
        op.drop_column('incidente', name)
    op.drop_constraint('ck_ruta_version', 'ruta', type_='check')
    op.drop_column('ruta', 'version_recibida')
    op.drop_column('ruta', 'version')
