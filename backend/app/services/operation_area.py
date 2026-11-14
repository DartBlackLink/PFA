"""Approved urban operating envelope, not an administrative district boundary.

Huancayo, El Tambo, Chilca and urban surroundings towards Pilcomayo, San Agustín
de Cajas, Huancán, Huayucachi and Sapallanga. Preserve historical coordinates.
"""
import math

NAME = 'Huancayo y alrededores urbanos, Junín, Perú'
SOUTH, NORTH, WEST, EAST = -12.18, -11.94, -75.32, -75.12
CENTER = (-12.0675, -75.2103)
TIMEZONE = 'America/Lima'


def contains(latitude, longitude):
    try:
        lat, lon = float(latitude), float(longitude)
        return math.isfinite(lat) and math.isfinite(lon) and SOUTH <= lat <= NORTH and WEST <= lon <= EAST
    except (ValueError, TypeError, OverflowError):
        return False


def validate_point(latitude, longitude):
    if not contains(latitude, longitude):
        raise ValueError('La ubicación debe estar dentro de Huancayo y los alrededores urbanos habilitados.')


def metadata():
    return {'nombre': NAME, 'zona_horaria': TIMEZONE,
        'sur': SOUTH, 'norte': NORTH, 'oeste': WEST, 'este': EAST,
        'centro': {'latitud': CENTER[0], 'longitud': CENTER[1]},
        'tipo_limite': 'ENVOLVENTE_OPERATIVA_URBANA_NO_LIMITE_ADMINISTRATIVO'}


def contains_geometry(geometry):
    if not isinstance(geometry, dict) or geometry.get("type") != "LineString":
        return False
    coordinates = geometry.get("coordinates")
    return (
        isinstance(coordinates, list)
        and len(coordinates) >= 2
        and all(isinstance(point, (list, tuple)) and len(point) >= 2
                and contains(point[1], point[0]) for point in coordinates)
    )
