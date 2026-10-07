import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Dirección pública de la API. Este archivo no almacena secretos.
class EntornoConfig {
  static String get apiBaseUrl {
    final url = dotenv.env['API_BASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception(
        'ERROR CRÍTICO: API_BASE_URL no está definida en el archivo .env',
      );
    }
    return url;
  }
}
