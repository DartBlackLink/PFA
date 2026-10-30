"""Geocoding proxy for explicit delivery searches; never sends customer data."""

import math
import time
from threading import Lock
from urllib.parse import urlencode

from fastapi import APIRouter, HTTPException, Query

from app.core.config import get_settings
from app.services.provider_http import fetch_json

router = APIRouter()
_lock = Lock()
_cache = {}
_next_request = 0.0


def _fetch(path, params):
    global _next_request
    key = (path, tuple(sorted(params.items())))
    now = time.monotonic()
    with _lock:
        cached = _cache.get(key)
        if cached and now - cached[0] < 3600:
            return cached[1]
        if now < _next_request:
            raise HTTPException(
                429,
                "Espera un momento antes de otra búsqueda.",
                headers={"Retry-After": "1"},
            )
        _next_request = now + 1.1
    url = get_settings().geocoding_base_url.rstrip("/") + path + "?" + urlencode(params)
    try:
        data = fetch_json(url)
        if not isinstance(data, dict) or not isinstance(data.get("features"), list):
            raise ValueError("Invalid provider response")
        results = []
        for feature in data["features"]:
            props = feature.get("properties", {})
            if props.get("countrycode", "").upper() != "PE":
                continue
            geometry = feature.get("geometry", {})
            if geometry.get("type") != "Point":
                continue
            lon, lat = map(float, geometry["coordinates"])
            if (
                not math.isfinite(lat)
                or not math.isfinite(lon)
                or not -90 <= lat <= 90
                or not -180 <= lon <= 180
            ):
                continue
            street = " ".join(
                str(props.get(k, "")) for k in ("street", "housenumber")
            ).strip()
            pieces = [
                props.get("name"),
                street,
                props.get("district"),
                props.get("city"),
                props.get("state"),
                "Perú",
            ]
            label = ", ".join(
                dict.fromkeys(str(p).strip() for p in pieces if p and str(p).strip())
            )
            if len(label) < 5:
                continue
            results.append(
                {
                    "direccion": label[:255],
                    "latitud": lat,
                    "longitud": lon,
                    "detalle": label,
                    "fuente": "OpenStreetMap / Photon",
                }
            )
        with _lock:
            if len(_cache) >= 256:
                _cache.pop(next(iter(_cache)))
            _cache[key] = (time.monotonic(), results)
        return results
    except HTTPException:
        raise
    except Exception as error:
        raise HTTPException(
            503,
            "La búsqueda no está disponible. Puedes escribir la dirección y marcar el destino manualmente.",
        ) from error


@router.get("/search")
def search(q: str = Query(min_length=3, max_length=200)):
    q = " ".join(q.split())
    if len(q) < 3:
        raise HTTPException(422, "Escribe al menos 3 caracteres del lugar.")
    return _fetch(
        "/api/",
        {
            "q": q,
            "limit": 6,
            "lat": -12.0675,
            "lon": -75.2103,
            "bbox": "-81.4,-18.4,-68.6,0.1",
        },
    )


@router.get("/reverse")
def reverse(
    lat: float = Query(ge=-90, le=90, allow_inf_nan=False),
    lon: float = Query(ge=-180, le=180, allow_inf_nan=False),
):
    return _fetch("/reverse", {"lat": lat, "lon": lon, "limit": 1})
