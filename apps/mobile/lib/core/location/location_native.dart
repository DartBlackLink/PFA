import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import 'location_unavailable.dart' as unsupported;

const _location = MethodChannel('ecologistica/location');

Future<Map<String, double>> currentLocation() async {
  if (!Platform.isAndroid) return unsupported.currentLocation();
  try {
    final result = await _location
        .invokeMapMethod<String, num>('currentLocation')
        .timeout(const Duration(seconds: 25));
    if (result == null ||
        ![
          'latitud',
          'longitud',
          'precision_m',
        ].every((k) => result[k]?.isFinite ?? false)) {
      throw Exception(
        'El dispositivo no devolvió una ubicación válida. Puedes reportar sin GPS.',
      );
    }
    return result.map((key, value) => MapEntry(key, value.toDouble()));
  } on PlatformException catch (error) {
    throw Exception(
      error.message ??
          'GPS no disponible. Puedes confirmar manualmente el punto.',
    );
  } on TimeoutException {
    throw Exception(
      'No se obtuvo señal GPS a tiempo. Reintenta estando detenido o reporta sin ubicación.',
    );
  }
}
