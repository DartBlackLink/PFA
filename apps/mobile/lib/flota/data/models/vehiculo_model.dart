// Archivo: lib/features/flota/data/models/vehiculo_model.dart

/// Modelo de datos para la entidad Vehículo.
/// Refleja la estructura de la base de datos PostgreSQL garantizando simetría.
double _parseDouble(dynamic value, {double fallback = 0}) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}

int _parseInt(dynamic value, {int fallback = 2020}) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

class VehiculoModel {
  final String? vehiculoId;
  final String placa;
  final String tipo;
  final double capacidadKg;
  final double consumoKmL;
  final double factorEmisionKgKm;
  final int anioFabricacion;
  final String estado;

  VehiculoModel({
    this.vehiculoId,
    required this.placa,
    required this.tipo,
    required this.capacidadKg,
    required this.consumoKmL,
    required this.factorEmisionKgKm,
    required this.anioFabricacion,
    this.estado = 'ACTIVO',
  });

  /// Crea una instancia desde un mapa JSON proveniente de la API
  factory VehiculoModel.fromJson(Map<String, dynamic> json) {
    return VehiculoModel(
      vehiculoId: (json['id'] ?? json['vehiculo_id'])?.toString(),
      placa: (json['plate'] ?? json['placa'] ?? '').toString(),
      tipo: (json['vehicle_type'] ?? json['tipo'] ?? 'Camioneta').toString(),
      capacidadKg: _parseDouble(json['capacity_kg'] ?? json['capacidad_kg']),
      consumoKmL: _parseDouble(
        json['consumption_km_l'] ?? json['consumo_km_l'],
      ),
      factorEmisionKgKm: _parseDouble(
        json['emission_factor_kg_km'] ?? json['factor_emision_kg_km'],
      ),
      anioFabricacion: _parseInt(
        json['manufacture_year'] ?? json['anio_fabricacion'],
      ),
      estado: (json['status'] ?? json['estado'] ?? 'ACTIVO').toString(),
    );
  }

  /// Convierte la instancia a un mapa JSON para enviar a la API
  Map<String, dynamic> toJson() {
    return {
      'placa': placa,
      'tipo': tipo,
      'capacidad_kg': capacidadKg,
      'consumo_km_l': consumoKmL,
      'factor_emision_kg_km': factorEmisionKgKm,
      'anio_fabricacion': anioFabricacion,
      'estado': estado,
    };
  }
}
