import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecologistica/core/network/api_client.dart';
import 'package:ecologistica/features/auth/presentation/providers/auth_provider.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  Future<AuthProvider> user() async {
    final auth = AuthProvider(
      client: MockClient((_) async => http.Response('{}', 401)),
    );
    await auth.ready;
    addTearDown(auth.dispose);
    return auth;
  }

  test(
    'Respuesta HTML de error produce diagnóstico seguro sin FormatException',
    () async {
      final api = ApiClient(
        await user(),
        client: MockClient(
          (_) async => http.Response('<html>upstream failure</html>', 503),
        ),
      );
      await expectLater(
        api.request('/routes/'),
        throwsA(
          predicate(
            (e) =>
                e.toString().contains('HTTP 503') &&
                !e.toString().contains('<html>'),
          ),
        ),
      );
    },
  );
  test('Error de red conserva mensaje de recuperación', () async {
    final api = ApiClient(
      await user(),
      client: MockClient(
        (_) async =>
            throw http.ClientException('private implementation detail'),
      ),
    );
    await expectLater(
      api.request('/routes/'),
      throwsA(
        predicate(
          (e) =>
              e.toString().contains('No se pudo conectar') &&
              !e.toString().contains('private'),
        ),
      ),
    );
  });
  test('Timeout no confirma una escritura ni informa éxito', () async {
    final api = ApiClient(
      await user(),
      requestTimeout: const Duration(milliseconds: 5),
      client: MockClient((_) => Completer<http.Response>().future),
    );
    await expectLater(
      api.request('/optimizations/id/confirm', method: 'POST'),
      throwsA(
        predicate((e) => e.toString().contains('Consulta el estado guardado')),
      ),
    );
  });

  test('Geocodificación distingue fallo externo y expiración de sesión', () async {
    SharedPreferences.setMockInitialValues({'auth_token': 'qa-token'});
    var sessionExpired = false;
    final auth = AuthProvider(
      client: MockClient((_) async => sessionExpired
          ? http.Response('{}', 401)
          : http.Response('{"rol":"ADMIN"}', 200)),
    );
    await auth.ready;
    addTearDown(auth.dispose);
    final api = ApiClient(
      auth,
      client: MockClient((_) async => http.Response('{}', 401)),
    );
    await expectLater(
      api.request('/locations/search?q=Huancayo'),
      throwsA(predicate((e) => e.toString().contains('marcar el punto'))),
    );
    expect(auth.estaAutenticado, isTrue);
    sessionExpired = true;
    await expectLater(
      api.request('/locations/search?q=Huancayo'),
      throwsA(predicate((e) => e.toString().contains('sesión venció'))),
    );
    expect(auth.estaAutenticado, isFalse);
  });
}
