"""Batched directed OSRM matrices with a bounded short-lived cache."""

import math
from collections import OrderedDict
from concurrent.futures import ThreadPoolExecutor, as_completed
from threading import Lock
from time import monotonic
from urllib.parse import urlencode

from fastapi import HTTPException

from app.core.config import get_settings
from app.services.provider_http import fetch_json

_cache = OrderedDict()
_lock = Lock()
TTL_SECONDS = 300
MAX_CACHE_ENTRIES = 4
BLOCK_SIZE = 40


def _table_block(base, coordinates, sources, destinations, deadline):
    indices = list(dict.fromkeys(sources + destinations))
    positions = {index: position for position, index in enumerate(indices)}
    points = ";".join(f"{coordinates[i][1]},{coordinates[i][0]}" for i in indices)
    # OSRM requires at least two coordinates, even for a 1x1 diagonal block.
    # Repeat the same physical point; sources/destinations still select index 0.
    if len(indices) == 1:
        points = points + ";" + points
    query = urlencode(
        {
            "annotations": "distance,duration",
            "sources": ";".join(str(positions[i]) for i in sources),
            "destinations": ";".join(str(positions[i]) for i in destinations),
        }
    )
    remaining = deadline - monotonic()
    if remaining <= 0:
        raise TimeoutError("Matrix deadline exceeded")
    data = fetch_json(
        base.rstrip("/") + "/" + points + "?" + query, timeout=min(8, remaining)
    )
    if data.get("code") != "Ok":
        raise ValueError("No road matrix")
    for name in ("distances", "durations"):
        values = data.get(name)
        if not isinstance(values, list) or len(values) != len(sources):
            raise ValueError("Invalid matrix shape")
        for row in values:
            if len(row) != len(destinations):
                raise ValueError("Invalid matrix row")
            if any(
                value is None or not math.isfinite(value) or value < 0 for value in row
            ):
                raise ValueError("Disconnected or invalid road segment")
    return sources, destinations, data["distances"], data["durations"]


def road_matrix(coordinates, deadline):
    base = get_settings().routing_base_url.replace("/route/v1/", "/table/v1/", 1)
    if "/table/v1/" not in base:
        raise HTTPException(
            503, "Configura un proveedor OSRM con servicio de matrices."
        )
    # Several orders (and team origins) may share the exact same location.
    # Query each physical point once, then expand back to the caller's indexes.
    # Do not round or merge nearby points: distinct entrances must stay distinct.
    original = [tuple(point) for point in coordinates]
    unique = list(dict.fromkeys(original))
    positions = {point: index for index, point in enumerate(unique)}
    indices = [positions[point] for point in original]

    def expanded(values):
        # Fresh rows also prevent a caller from modifying cached provider data.
        return [[values[source][destination] for destination in indices] for source in indices]

    key = (base, tuple(unique))
    now = monotonic()
    with _lock:
        entry = _cache.get(key)
        if entry and now - entry[0] < TTL_SECONDS:
            _cache.move_to_end(key)
            return (
                expanded(entry[1]),
                expanded(entry[2]),
                {
                    "provider_calls": 0,
                    "cache_hit": True,
                    "age_seconds": round(now - entry[0], 2),
                    "input_locations": len(original),
                    "unique_locations": len(unique),
                },
            )
    size = len(unique)
    distance = [[0.0] * size for _ in range(size)]
    duration = [[0.0] * size for _ in range(size)]
    blocks = [
        list(range(i, min(i + BLOCK_SIZE, size))) for i in range(0, size, BLOCK_SIZE)
    ]
    requests = 0
    try:
        with ThreadPoolExecutor(max_workers=4) as pool:
            futures = [
                pool.submit(
                    _table_block, base, unique, sources, destinations, deadline
                )
                for sources in blocks
                for destinations in blocks
            ]
            for future in as_completed(futures):
                sources, destinations, distances, durations = future.result()
                requests += 1
                for row, index in enumerate(sources):
                    for column, destination in enumerate(destinations):
                        distance[index][destination] = distances[row][column] / 1000
                        duration[index][destination] = durations[row][column] / 60
    except (ValueError, TypeError, KeyError, OSError, TimeoutError) as error:
        raise HTTPException(
            503, "No se pudo obtener una matriz vial completa; no se asignaron pedidos."
        ) from error
    except Exception as error:
        raise HTTPException(
            503, "El proveedor de recorridos no está disponible; reintenta."
        ) from error
    with _lock:
        _cache[key] = (monotonic(), distance, duration)
        _cache.move_to_end(key)
        while len(_cache) > MAX_CACHE_ENTRIES:
            _cache.popitem(last=False)
    return (
        expanded(distance),
        expanded(duration),
        {"provider_calls": requests, "cache_hit": False, "age_seconds": 0,
         "input_locations": len(original), "unique_locations": len(unique)},
    )


def road_shape(points, deadline):
    coordinates = ";".join(f"{lon},{lat}" for lat, lon in points)
    url = (
        get_settings().routing_base_url.rstrip("/")
        + "/"
        + coordinates
        + "?overview=full&geometries=geojson&steps=false"
    )
    remaining = deadline - monotonic()
    if remaining <= 0:
        raise HTTPException(
            503, "Se agotó el plazo de cálculo vial; no se asignaron pedidos."
        )
    try:
        data = fetch_json(url, timeout=min(8, remaining))
        if data.get("code") != "Ok" or not data.get("routes"):
            raise ValueError("Missing road route")
        route = data["routes"][0]
        geometry = route["geometry"]
        if (
            geometry.get("type") != "LineString"
            or len(geometry.get("coordinates", [])) < 2
        ):
            raise ValueError("Missing road geometry")
        for point in geometry["coordinates"]:
            lon, lat = point
            if (
                not math.isfinite(lon)
                or not math.isfinite(lat)
                or not -180 <= lon <= 180
                or not -90 <= lat <= 90
            ):
                raise ValueError("Invalid road coordinate")
        legs = route.get("legs")
        if not isinstance(legs, list) or len(legs) != len(points) - 1:
            raise ValueError("Missing leg validation")
        costs = []
        for leg in legs:
            km, minutes = float(leg["distance"]) / 1000, float(leg["duration"]) / 60
            if (
                not math.isfinite(km)
                or not math.isfinite(minutes)
                or km < 0
                or minutes < 0
            ):
                raise ValueError("Invalid road leg")
            costs.append((km, minutes))
        return geometry, costs
    except HTTPException:
        raise
    except Exception as error:
        raise HTTPException(
            503, "No se pudo validar el recorrido vial final; no se asignaron pedidos."
        ) from error
