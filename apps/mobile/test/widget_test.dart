import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecologistica/features/auth/presentation/providers/auth_provider.dart';
import 'package:ecologistica/features/auth/presentation/screens/login_screen.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  for (final seconds in [5, 10, 300]) {
    test(
      'Bloqueo $seconds segundos impide solicitudes adicionales y persiste',
      () async {
        var calls = 0;
        final auth = AuthProvider(
          apiUrl: 'http://test/api/v1',
          client: MockClient((r) async {
            calls++;
            return http.Response(
              '{}',
              429,
              headers: {'retry-after': '$seconds'},
            );
          }),
        );
        await auth.ready;
        expect(await auth.iniciarSesion(' TEST@example.test ', 'wrong'), false);
        expect(auth.segundosRestantes, inInclusiveRange(seconds - 1, seconds));
        expect(await auth.iniciarSesion('test@example.test', 'wrong'), false);
        expect(calls, 1);
        auth.dispose();
        final reloaded = AuthProvider(
          apiUrl: 'http://test/api/v1',
          client: MockClient((r) async => http.Response('{}', 500)),
        );
        await reloaded.ready;
        await reloaded.actualizarCorreo('test@example.test');
        expect(reloaded.bloqueado, true);
        if (seconds == 300) {
          expect(reloaded.contador, matches(RegExp(r'^4:59$|^5:00$')));
        }
        reloaded.dispose();
      },
    );
  }
  test('Valida sesión guardada y elimina token vencido', () async {
    SharedPreferences.setMockInitialValues({
      'auth_token': 'expired',
      'auth_role': 'ADMIN',
    });
    final auth = AuthProvider(
      apiUrl: 'http://test/api/v1',
      client: MockClient((r) async {
        expect(r.headers['Authorization'], 'Bearer expired');
        return http.Response('{}', 401);
      }),
    );
    await auth.ready;
    expect(auth.estaAutenticado, false);
    expect(
      (await SharedPreferences.getInstance()).getString('auth_token'),
      null,
    );
    auth.dispose();
  });
  test(
    'Sesión válida conserva el rol del servidor y permite cerrar sesión',
    () async {
      SharedPreferences.setMockInitialValues({
        'auth_token': 'valid',
        'auth_role': 'ADMIN',
      });
      final auth = AuthProvider(
        apiUrl: 'http://test/api/v1',
        client: MockClient(
          (r) async => http.Response(jsonEncode({'rol': 'REPARTIDOR'}), 200),
        ),
      );
      await auth.ready;
      expect(auth.esRepartidor, true);
      await auth.cerrarSesion();
      expect(auth.estaAutenticado, false);
      auth.dispose();
    },
  );
  test('Un inicio exitoso conserva identidad sin duplicar solicitudes concurrentes', () async {
    var calls = 0;
    final auth = AuthProvider(
      apiUrl: 'http://test/api/v1',
      client: MockClient((r) async {
        calls++;
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(r.bodyFields['username'], 'admin@example.test');
        return http.Response(
          jsonEncode({'rol': 'ADMIN', 'access_token': 'valid'}),
          200,
        );
      }),
    );
    await auth.ready;
    final results = await Future.wait([
      auth.iniciarSesion('admin@example.test', 'test'),
      auth.iniciarSesion('admin@example.test', 'test'),
    ]);
    expect(results.where((e) => e).length, 1);
    expect(calls, 1);
    expect(auth.esAdministrador, true);
    auth.dispose();
  });
  testWidgets(
    'Login móvil muestra contador y deshabilita el botón tras tercer fallo',
    (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var calls = 0;
      final auth = AuthProvider(
        apiUrl: 'http://test/api/v1',
        client: MockClient((r) async {
          calls++;
          return http.Response(
            '{}',
            calls < 3 ? 401 : 429,
            headers: {'retry-after': '5'},
          );
        }),
      );
      await auth.ready;
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: auth,
          child: const MaterialApp(home: LoginScreen()),
        ),
      );
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'test@example.test',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'wrong');
      for (var i = 0; i < 3; i++) {
        await tester.ensureVisible(find.byType(FilledButton));
        await tester.tap(find.byType(FilledButton));
        await tester.pumpAndSettle();
      }
      expect(calls, 3);
      expect(find.byKey(const Key('login-countdown')), findsOneWidget);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        null,
      );
      expect(tester.takeException(), null);
      await tester.pumpWidget(const SizedBox.shrink());
      auth.dispose();
    },
  );
}
