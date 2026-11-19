import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecologistica/core/network/api_client.dart';
import 'package:ecologistica/features/auth/presentation/providers/auth_provider.dart';
import 'package:ecologistica/features/rutas/presentation/traffic_policy_screen.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  final cases = [
    [
      'Factor estimado de tiempo (1–5)',
      '0',
      'El factor debe estar entre 1 y 5',
    ],
    [
      'Factor estimado de tiempo (1–5)',
      '6',
      'El factor debe estar entre 1 y 5',
    ],
    [
      'Inicio (minuto del día: 0–1439)',
      '-1',
      'El inicio debe estar entre 0 y 1439 minutos',
    ],
    [
      'Fin (minuto del día: 1–1440)',
      '1441',
      'El fin debe estar entre 1 y 1440 minutos',
    ],
    [
      'Fin (minuto del día: 1–1440)',
      '480',
      'El fin debe ser posterior al inicio',
    ],
    ['Latitud sur', '-13', 'La coordenada debe estar dentro de Huancayo'],
    ['Latitud norte', '-12.09', 'El norte debe ser mayor que el sur'],
    ['Longitud este', '-75.24', 'El este debe ser mayor que el oeste'],
  ];
  for (final values in cases) {
    testWidgets(
      'Franja inválida conserva formulario y no escribe: ${values[0]}=${values[1]}',
      (tester) async {
        final auth = await tester.runAsync(() async {
          final value = AuthProvider(
            client: MockClient((_) async => http.Response('{}', 401)),
          );
          await value.ready;
          return value;
        });
        addTearDown(auth!.dispose);
        var puts = 0;
        final client = ApiClient(
          auth,
          client: MockClient((request) async {
            if (request.method == 'PUT') puts++;
            final data = request.url.path.endsWith('/references')
                ? []
                : {
                    'revision': 1,
                    'reglas': [
                      {
                        'nombre': 'Zona QA',
                        'sur': -12.08,
                        'norte': -12.06,
                        'oeste': -75.23,
                        'este': -75.20,
                        'inicio_min': 480,
                        'fin_min': 540,
                        'factor': 1.2,
                        'dias': [1],
                        'fundamento': 'Prueba sintética identificada, sin tráfico observado.',
                      },
                    ],
                  };
            return http.Response(
              jsonEncode(data),
              200,
              headers: {'content-type': 'application/json'},
            );
          }),
        );
        await tester.pumpWidget(
          MaterialApp(home: TrafficPolicyScreen(api: client)),
        );
        await tester.pumpAndSettle();
        final zone = find.text('Zona QA · factor 1.2');
        await tester.ensureVisible(zone);
        await tester.tap(zone);
        await tester.pumpAndSettle();
        final input = find.widgetWithText(TextFormField, values[0]);
        await tester.ensureVisible(input);
        await tester.enterText(input, values[1]);
        final save = find.text('Guardar franja');
        await tester.ensureVisible(save);
        await tester.tap(save);
        await tester.pumpAndSettle();
        expect(find.text('Editar franja estimada'), findsOneWidget);
        expect(find.text(values[2]), findsOneWidget);
        expect(puts, 0);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      },
    );
  }
}
