import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../config/env.dart';

class ApiClient {
  ApiClient(this.auth);
  final AuthProvider auth;
  Future<dynamic> request(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    final headers = {
      'Authorization': 'Bearer ${auth.token}',
      'Content-Type': 'application/json',
    };
    final uri = Uri.parse('${EntornoConfig.apiBaseUrl}$path');
    final response =
        await (method == 'POST'
                ? http.post(uri, headers: headers, body: jsonEncode(body))
                : method == 'PUT'
                ? http.put(uri, headers: headers, body: jsonEncode(body))
                : http.get(uri, headers: headers))
            .timeout(const Duration(seconds: 15));
    if (response.statusCode == 401) {
      await auth.cerrarSesion(
        mensaje: 'Tu sesión venció. Inicia sesión nuevamente.',
      );
      throw Exception('Tu sesión venció.');
    }
    final data = jsonDecode(response.body);
    if (response.statusCode >= 400) {
      final detail = data is Map ? data['detail'] : null;
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
