import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:ecologistica/main.dart' as app;
import 'package:ecologistica/core/location/current_location.dart';
import 'package:ecologistica/core/network/api_client.dart';
import 'package:ecologistica/features/auth/presentation/providers/auth_provider.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'Continuación real Android: incidencia existente, nueva ruta, acuse y entregas preservadas',
    (tester) async {
      const control = String.fromEnvironment('QA_CONTROL_URL');
      expect(control.startsWith('http://10.0.2.2:8789/'), isTrue);
      Future<void> command(
        String endpoint, [
        Map<String, dynamic> body = const {},
      ]) async {
        final result = await http
            .post(
              Uri.parse('$control/$endpoint'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(body),
            )
            .timeout(const Duration(seconds: 30));
        expect(result.statusCode, 200);
      }

      Future<void> phase(String name, [Map<String, dynamic> data = const {}]) =>
          command('phase', {'stage': name, 'evidence': data});
      Future<void> waitFor(Finder finder, {int seconds = 60}) async {
        final end = DateTime.now().add(Duration(seconds: seconds));
        while (finder.evaluate().isEmpty && DateTime.now().isBefore(end)) {
          await tester.pump(const Duration(milliseconds: 250));
        }
        expect(finder, findsWidgets);
      }

      Future<void> tap(Finder finder) async {
        if (finder.evaluate().isEmpty &&
            find.byType(Scrollable).evaluate().isNotEmpty) {
          final scroll = find.byType(Scrollable).first;
          tester.state<ScrollableState>(scroll).position.jumpTo(0);
          await tester.pump(const Duration(milliseconds: 300));
          for (var i = 0; finder.evaluate().isEmpty && i < 35; i++) {
            final position = tester.state<ScrollableState>(scroll).position;
            position.jumpTo(
              (position.pixels + 250)
                  .clamp(position.minScrollExtent, position.maxScrollExtent)
                  .toDouble(),
            );
            await tester.pump(const Duration(milliseconds: 300));
          }
        }
        await waitFor(finder);
        await tester.ensureVisible(finder.first);
        await tester.pump(const Duration(milliseconds: 300));
        await tester.tap(finder.first);
        await tester.pump();
      }

      Future<void> capture(String name) async {
        await tester.pump();
        final bytes = await binding.takeScreenshot(name);
        await File('${Directory.systemTemp.path}/$name.png')
            .writeAsBytes(bytes);
      }

      final account = jsonDecode(
        (await http.get(Uri.parse('$control/session'))).body,
      ) as Map;
      await app.main();
      final startup = DateTime.now().add(const Duration(seconds: 60));
      while (find.byType(TextFormField).evaluate().isEmpty &&
          find.text('Mis rutas asignadas').evaluate().isEmpty &&
          DateTime.now().isBefore(startup)) {
        await tester.pump(const Duration(milliseconds: 250));
      }
      if (find.text('Mis rutas asignadas').evaluate().isNotEmpty) {
        await tap(find.byTooltip('Cerrar sesión'));
      }
      await waitFor(find.byType(TextFormField));
      await tester.enterText(
        find.byType(TextFormField).at(0),
        account['email'],
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        account['password'],
      );
      await tap(find.text('Iniciar sesión'));
      await waitFor(find.text('Mis rutas asignadas'));
      final auth = tester
          .element(find.text('Mis rutas asignadas'))
          .read<AuthProvider>();
      final api = ApiClient(auth);
      var route = await api.request('/routes/${account['route_id']}') as Map;
      expect(route['estado'], 'EN_CURSO');
      expect(route['version'], 1);
      expect(route['version_recibida'], 1);
      final done = (route['entregas'] as List)
          .where((s) => s['estado_entrega'] == 'ENTREGADO')
          .toList();
      expect(done.length, 1);
      expect(done.single['cliente'], 'QA principal Huancayo 3');
      final firstID = done.single['pedido_id'];
      final firstTime = done.single['entregado_en'];
      expect(
        DateTime.parse(firstTime),
        DateTime.parse('2026-11-03T14:47:54.057120+00:00'),
      );
      final incidents = await api.request(
        '/routes/${account['route_id']}/incidentes',
      ) as List;
      expect(
        incidents.where(
          (i) => i['tipo'] == 'CONGESTION' && i['resuelto_en'] == null,
        ),
        isNotEmpty,
      );
      await binding.convertFlutterSurfaceToImage();
      await tap(find.text('Recorrido · HYO-E2E-03'));
      await waitFor(find.text('Planificación versión 1 · recibida: 1'));
      await command('gps');
      var position = await currentLocation();
      for (
        var attempt = 0;
        attempt < 3 &&
            ((position['latitud']! + 12.0492152).abs() > 0.0001 ||
                (position['longitud']! + 75.1978246).abs() > 0.0001);
        attempt++
      ) {
        await command('gps');
        await tester.pump(const Duration(seconds: 1));
        position = await currentLocation();
      }
      expect(position['latitud'], closeTo(-12.0492152, 0.0001));
      expect(position['longitud'], closeTo(-75.1978246, 0.0001));
      await capture('resume_01_incidente_y_entrega_preservados');
      await phase('resume_incident_ready', {
        'route_id': account['route_id'],
        'first_delivered_at': firstTime,
        'confirmed_position': position,
        'confirmed_at': DateTime.now().toUtc().toIso8601String(),
      });
      final limit = DateTime.now().add(const Duration(minutes: 8));
      do {
        await tester.pump(const Duration(seconds: 2));
        route = await api.request('/routes/${account['route_id']}') as Map;
      } while (route['version'] == 1 && DateTime.now().isBefore(limit));
      expect(route['version'], 2);
      expect(route['version_recibida'], 1);
      await waitFor(find.text('Planificación versión 2 · recibida: 1'));
      await capture('resume_02_version_nueva_sin_acuse');
      await tap(find.text('Confirmar recepción de nueva ruta'));
      await waitFor(find.text('Planificación versión 2 · recibida: 2'));
      await capture('resume_03_recepcion_confirmada');
      await phase('version2_acknowledged');
      for (var expected = 2; expected <= 3; expected++) {
        await tap(find.text('Confirmar entrega'));
        await tap(find.text('Confirmar'));
        final deadline = DateTime.now().add(const Duration(seconds: 30));
        do {
          await tester.pump(const Duration(milliseconds: 300));
          route = await api.request('/routes/${account['route_id']}') as Map;
        } while ((route['entregas'] as List)
                    .where((s) => s['estado_entrega'] == 'ENTREGADO')
                    .length <
                expected &&
            DateTime.now().isBefore(deadline));
        expect(
          (route['entregas'] as List)
              .where((s) => s['estado_entrega'] == 'ENTREGADO')
              .length,
          expected,
        );
      }
      expect(route['estado'], 'FINALIZADA');
      expect(route['version_recibida'], 2);
      final stops = route['entregas'] as List;
      expect(stops.map((s) => s['pedido_id']).toSet().length, 3);
      expect(
        stops.singleWhere((s) => s['pedido_id'] == firstID)['entregado_en'],
        firstTime,
      );
      await capture('resume_04_finalizada_tres_entregas');
      await phase('resume_route_finalized', {
        'route_id': account['route_id'],
        'first_delivered_at': firstTime,
        'unique_deliveries': 3,
        'version': 2,
        'received': 2,
      });
      await tap(find.byTooltip('Back'));
      await waitFor(find.text('Mis rutas asignadas'));
      await tap(find.byTooltip('Cerrar sesión'));
      await waitFor(find.text('Iniciar sesión'));
      expect(auth.estaAutenticado, isFalse);
      await phase('resume_logout_passed');
      await command('done');
    },
    timeout: const Timeout(Duration(minutes: 13)),
  );
}
