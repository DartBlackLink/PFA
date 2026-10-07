import json,math
from urllib.request import Request,urlopen
from fastapi import HTTPException
from app.core.config import get_settings

def compute_route(points):
    coordinates=";".join(f"{lon},{lat}" for lat,lon in points)
    url=get_settings().routing_base_url.rstrip("/")+"/"+coordinates+"?overview=full&geometries=geojson&steps=false"
    try:
        with urlopen(Request(url,headers={"User-Agent":"EcoLogistica/1.0"}),timeout=8) as response:data=json.load(response)
        if data.get("code")!="Ok" or not data.get("routes"):raise ValueError("Sin ruta")
        route=data["routes"][0];geometry=route["geometry"]
        if geometry["type"]!="LineString" or len(geometry["coordinates"])<2:raise ValueError("Geometría inválida")
        for lon,lat in geometry["coordinates"]:
            if not math.isfinite(lon) or not math.isfinite(lat) or not -180<=lon<=180 or not -90<=lat<=90:raise ValueError("Coordenada inválida")
        distance=float(route["distance"]);duration=float(route["duration"])
        if not math.isfinite(distance) or not math.isfinite(duration) or distance<0 or duration<0:raise ValueError("Medición inválida")
        return geometry,round(distance/1000,3),round(duration/60,2)
    except Exception as error:
        raise HTTPException(503,"No se pudo calcular el recorrido vial. Reintenta; ningún pedido fue asignado.") from error
