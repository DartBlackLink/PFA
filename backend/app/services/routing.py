import math

from fastapi import HTTPException

from app.core.config import get_settings
from app.services.provider_http import fetch_json


def compute_route(points, *, include_legs=False):
    coordinates = ";".join(f"{lon},{lat}" for lat, lon in points)
    url = (
        get_settings().routing_base_url.rstrip("/")
        + "/"
        + coordinates
        + "?overview=full&geometries=geojson&steps=false"
    )
    try:
        data = fetch_json(url)
        if data.get("code") != "Ok" or not data.get("routes"):
            raise ValueError("Sin ruta")
        route = data["routes"][0]
        geometry = route["geometry"]
        if geometry["type"] != "LineString" or len(geometry["coordinates"]) < 2:
            raise ValueError("Geometría inválida")
        for lon, lat in geometry["coordinates"]:
            if (
                not math.isfinite(lon)
                or not math.isfinite(lat)
                or not -180 <= lon <= 180
                or not -90 <= lat <= 90
            ):
                raise ValueError("Coordenada inválida")
        distance = float(route["distance"])
        duration = float(route["duration"])
        if (
            not math.isfinite(distance)
            or not math.isfinite(duration)
            or distance < 0
            or duration < 0
        ):
            raise ValueError("Medición inválida")
        result = geometry, round(distance / 1000, 3), round(duration / 60, 2)
        if not include_legs:
            return result
        legs = route.get("legs", [])
        if not legs and len(points) == 2:
            # One segment equals the full route: this is exact, not interpolation.
            legs = [{"distance": distance, "duration": duration}]
        if len(legs) != len(points) - 1:
            raise ValueError("Tramos incompletos")
        values = [(float(leg["distance"]) / 1000, float(leg["duration"]) / 60) for leg in legs]
        if any(not math.isfinite(v) or v < 0 for pair in values for v in pair):
            raise ValueError("Tramo inválido")
        if abs(sum(pair[0] for pair in values) * 1000 - distance) > max(2, distance * .01) or abs(sum(pair[1] for pair in values) * 60 - duration) > max(2, duration * .01):
            raise ValueError("Totales de tramos incoherentes")
        return (*result, values)
    except Exception as error:
        raise HTTPException(
            503,
            "No se pudo calcular el recorrido vial. Reintenta; ningún pedido fue asignado.",
        ) from error
