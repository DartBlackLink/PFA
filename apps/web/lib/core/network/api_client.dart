import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';

import 'package:http/http.dart' as http;

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../config/env.dart';

class ApiClient {
  ApiClient(
    this.auth, {
    this.requestTimeout = const Duration(seconds: 15),
    this.client,
  });
  final AuthProvider auth;
  final http.Client? client;
  final Duration requestTimeout;
  Future<dynamic> request(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? body,
    bool binary = false,
  }) async {
    final requestToken = auth.token;
    final headers = {
      'Authorization': 'Bearer $requestToken',
      'Content-Type': 'application/json',
    };
    final uri = Uri.parse('${EntornoConfig.apiBaseUrl}$path');
    final transport = client ?? http.Client();
    late http.Response response;
    try {
      response =
          await (method == 'POST'
                  ? transport.post(
                      uri,
                      headers: headers,
                      body: jsonEncode(body),
                    )
                  : method == 'PUT'
                  ? transport.put(uri, headers: headers, body: jsonEncode(body))
                  : transport.get(uri, headers: headers))
              .timeout(requestTimeout);
    } on TimeoutException {
      throw Exception(
        'El servidor tardó demasiado. Consulta el estado guardado antes de reintentar.',
      );
    } on http.ClientException {
      throw Exception(
        'No se pudo conectar con el servidor. Comprueba la conexión y vuelve a intentar.',
      );
    } finally {
      if (client == null) transport.close();
    }
    if (response.statusCode == 401) {
      if (requestToken != auth.token) {
        throw Exception('La respuesta corresponde a una sesión anterior.');
      }
      if (uri.path.contains('/locations/') &&
          !await auth.confirmarSesionInvalida(requestToken)) {
        throw Exception(
          'La búsqueda de direcciones no está disponible. Puedes marcar el punto manualmente.',
        );
      }
      if (requestToken != auth.token) {
        throw Exception('La respuesta corresponde a una sesión anterior.');
      }
      await auth.cerrarSesion(
        mensaje: 'Tu sesión venció. Inicia sesión nuevamente.',
      );
      throw Exception('Tu sesión venció.');
    }
    if (binary && response.statusCode >= 200 && response.statusCode < 300) {
      final bytes = response.bodyBytes;
      if (!(response.headers['content-type'] ?? '').startsWith(
            'application/pdf',
          ) ||
          bytes.length < 5 ||
          ascii.decode(bytes.sublist(0, 5), allowInvalid: true) != '%PDF-') {
        throw Exception('El servidor no devolvió un PDF válido.');
      }
      return Uint8List.fromList(bytes);
    }
    dynamic data;
    try {
      data = response.body.isEmpty ? null : jsonDecode(response.body);
    } on FormatException {
      throw Exception(
        'El servidor devolvió una respuesta no válida (HTTP ${response.statusCode}). Reintenta o consulta al administrador.',
      );
    }
    if (response.statusCode >= 400) {
      final detail = data is Map ? data['detail'] : null;
      if (detail is Map && detail['mensaje'] is String) {
        throw Exception(detail['mensaje']);
      }
      if (detail is List) {
        throw Exception(
          detail
              .map((e) => '${(e['loc'] as List).last}: ${e['msg']}')
              .join('\n'),
        );
      }
      throw Exception(
        detail?.toString() ?? 'No se pudo completar la operación.',
      );
    }
    return data;
  }
}
