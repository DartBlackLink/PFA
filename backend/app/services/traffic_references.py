"""Documented local reference windows, not live forecasts or delay calibration."""
LOCAL_REFERENCES = [{
    'id': 'UNCP_1182_EL_TAMBO_2015',
    'titulo': 'El Tambo: Mariscal Castilla / Julio Sumar y La Marina',
    'inicio_min': 480, 'fin_min': 540,
    'estudio_anio': 2015, 'publicacion_anio': 2016,
    'fuente': 'https://hdl.handle.net/20.500.12894/1182',
    'ubicacion_fuente': 'Tablas 9–10 y sección 7.1.5, páginas 112–115',
    'alcance': 'Franja de mayor demanda en la muestra histórica de dos intersecciones. No es un horario vigente para toda Huancayo.',
    'factor_sugerido': None,
    'nota_factor': 'Los aforos no permiten deducir un multiplicador de tiempo. Requiere estimación manual identificada o calibración local.',
    'envolvente_configuracion': {'sur': -12.057, 'norte': -12.025, 'oeste': -75.232, 'este': -75.203},
}]
