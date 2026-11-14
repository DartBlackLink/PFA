import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecologistica/core/network/api_client.dart';
import 'package:ecologistica/features/auth/presentation/providers/auth_provider.dart';
import 'package:ecologistica/features/reports/reports_screen.dart';
import 'package:ecologistica/features/clients/clients_screen.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  Future<ApiClient> api(
    Future<http.Response> Function(http.Request) handler,
  ) async {
    final auth = AuthProvider(
      client: MockClient((_) async => http.Response('{}', 401)),
    );
    await auth.ready;
    addTearDown(auth.dispose);
    return ApiClient(auth, client: MockClient(handler));
  }

  Future<ApiClient> widgetApi(
    WidgetTester tester,
    Future<http.Response> Function(http.Request) handler,
  ) async => (await tester.runAsync(() => api(handler)))!;
  http.Response json(Object value, [int status = 200]) => http.Response(
    jsonEncode(value),
    status,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
  const windows = {
    'cumplimiento_previsto_pct': 100,
    'cumplimiento_real_pct': null,
  };
  final summary = {
    'rutas': 1,
    'distancia_km': {'valor': 2, 'rutas_sin_dato': 0},
    'combustible_l': {'valor': null, 'rutas_sin_dato': 1},
    'co2_kg': {'valor': 0.4, 'rutas_sin_dato': 0},
    'ventanas': windows,
  };

  test('Indicador ausente no se convierte en cero', () {
    expect(indicatorText(null, 'kg'), 'No disponible');
    expect(indicatorText('NaN', 'kg'), 'No disponible');
    expect(indicatorText(0, 'kg'), '0.00 kg');
  });
  test('Descarga rechaza HTML exitoso y conserva errores JSON', () async {
    final invalid = await api(
      (_) async => http.Response(
        '<html>error</html>',
        200,
        headers: {'content-type': 'text/html'},
      ),
    );
    await expectLater(
      invalid.request('/reports/routes/r/pdf', binary: true),
      throwsA(predicate((e) => e.toString().contains('PDF válido'))),
    );
    final denied = await api(
      (_) async => json({'detail': 'Selecciona una ruta válida'}, 409),
    );
    await expectLater(
      denied.request('/reports/routes/r/pdf', binary: true),
      throwsA(
        predicate((e) => e.toString().contains('Selecciona una ruta válida')),
      ),
    );
  });
  test('Descarga devuelve bytes PDF sin decodificar como JSON', () async {
    final client = await api(
      (_) async => http.Response(
        '%PDF-1.4\n%%EOF',
        200,
        headers: {'content-type': 'application/pdf'},
      ),
    );
    expect(
      await client.request('/reports/routes/r/pdf', binary: true),
      isA<Uint8List>(),
    );
  });
  testWidgets('Reporte requiere selección y descarga indicadores reales', (
    tester,
  ) async {
    final client = await widgetApi(tester, (request) async {
      if (request.url.path.endsWith('/summary')) return json(summary);
      if (request.url.path.endsWith('/routes')) {
        return json({
          'total': 1,
          'items': [
            {'ruta_id': 'ruta-qa', 'version': 2, 'estado': 'PLANIFICADA'},
          ],
        });
      }
      if (request.url.path.endsWith('/pdf')) {
        return http.Response(
          '%PDF-1.4\n%%EOF',
          200,
          headers: {'content-type': 'application/pdf'},
        );
      }
      return json({
        'ruta_id': 'ruta-qa',
        'version': 2,
        'distancia_km': 2,
        'tiempo_min': 4,
        'combustible_l': 0.2,
        'co2_kg': 0.4,
        'ventanas': windows,
        'equivalencia': null,
        'metodologia': 'Estimación QA controlada',
      });
    });
    String? downloaded;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReportsScreen(
            api: client,
            download: (bytes, name) async {
              downloaded = name;
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Descargar PDF'),
          )
          .onPressed,
      isNull,
    );
    await tester.ensureVisible(find.byType(DropdownButtonFormField<String>));
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('PLANIFICADA · v2 · ruta-qa').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Descargar PDF'));
    await tester.tap(find.text('Descargar PDF'));
    await tester.pumpAndSettle();
    expect(downloaded, 'ecologistica-ruta-qa-v2.pdf');
  });
  testWidgets('Preferencia con fin igual a inicio no hace escritura', (
    tester,
  ) async {
    var writes = 0;
    final client = await widgetApi(tester, (request) async {
      writes++;
      return json({});
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PreferenceDialog(
            api: client,
            client: const {'cliente_id': 'qa', 'nombre': 'Cliente QA'},
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextFormField).at(0), '10:00');
    await tester.enterText(find.byType(TextFormField).at(1), '10:00');
    await tester.ensureVisible(find.text('Guardar preferencias'));
    await tester.tap(find.text('Guardar preferencias'));
    await tester.pumpAndSettle();
    expect(writes, 0);
    expect(find.textContaining('inicio debe ser anterior'), findsOneWidget);
  });
  for (final dark in [false, true]) {
    testWidgets('Clientes y reportes adaptables 360px, oscuro=$dark', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final client = await widgetApi(
        tester,
        (request) async => request.url.path.endsWith('/summary')
            ? json(summary)
            : json({'total': 0, 'items': []}),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: dark ? Brightness.dark : Brightness.light,
          ),
          home: Scaffold(
            body: SingleChildScrollView(child: ClientsScreen(api: client)),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: dark ? Brightness.dark : Brightness.light,
          ),
          home: Scaffold(body: ReportsScreen(api: client)),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('No hay rutas confirmadas en esta página.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
