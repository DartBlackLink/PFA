import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:ecologistica/main.dart' as app;
import 'package:ecologistica/core/network/api_client.dart';
import 'package:ecologistica/features/auth/presentation/providers/auth_provider.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'Continuación Android: versión aprobada, acuse efectivo, entregas, desconexión y sesión',
    (tester) async {
      const control = String.fromEnvironment('QA_CONTROL_URL');
      expect(control.startsWith('http://10.0.2.2:8789/'), isTrue);
      Future<void> command(
        String path, [
        Map<String, dynamic> body = const {},
      ]) async {
        final r = await http
            .post(
              Uri.parse('$control/$path'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(body),
            )
            .timeout(const Duration(seconds: 30));
        expect(r.statusCode, 200);
      }

      Future<void> phase(
        String name, [
        Map<String, dynamic> evidence = const {},
      ]) => command('phase', {'stage': name, 'evidence': evidence});
      final credentials = jsonDecode(
        (await http.get(Uri.parse('$control/session'))).body,
      ) as Map;
      Future<void> waitFor(Finder finder, {int seconds = 60}) async {
        final end = DateTime.now().add(Duration(seconds: seconds));
        while (finder.evaluate().isEmpty && DateTime.now().isBefore(end)) {
          await tester.pump(const Duration(milliseconds: 250));
        }
        expect(finder, findsWidgets);
      }

      Future<void> tap(Finder finder) async {
        await tester.pump(const Duration(milliseconds: 500));
        final searchDeadline = DateTime.now().add(const Duration(seconds: 45));
        while (finder.evaluate().isEmpty &&
            DateTime.now().isBefore(searchDeadline)) {
          final scrolls = tester
              .stateList<ScrollableState>(find.byType(Scrollable))
              .where((s) => s.position.axis == Axis.vertical)
              .toList();
          if (scrolls.isEmpty) {
            await tester.pump(const Duration(milliseconds: 300));
            continue;
          }
          final position = scrolls.first.position;
          position.jumpTo(position.minScrollExtent);
          await tester.pump(const Duration(milliseconds: 500));
          for (
            var attempt = 0;
            finder.evaluate().isEmpty && attempt < 40;
            attempt++
          ) {
            position.jumpTo(
              (position.pixels + 180).clamp(
                position.minScrollExtent,
                position.maxScrollExtent,
              ),
            );
            await tester.pump(const Duration(milliseconds: 300));
            if (position.pixels >= position.maxScrollExtent) break;
          }
        }
        await waitFor(finder, seconds: 5);
        final enabledDeadline = DateTime.now().add(const Duration(seconds: 45));
        bool enabled() {
          final element = finder.first.evaluate().single;
          var ready = true;
          void inspect(Widget widget) {
            if (widget is ButtonStyleButton) ready = widget.onPressed != null;
            if (widget is IconButton) ready = widget.onPressed != null;
          }

          inspect(element.widget);
          element.visitAncestorElements((ancestor) {
            if (ancestor.widget is ButtonStyleButton ||
                ancestor.widget is IconButton) {
              inspect(ancestor.widget);
              return false;
            }
            return true;
          });
          return ready;
        }

        while (!enabled() && DateTime.now().isBefore(enabledDeadline)) {
          await tester.pump(const Duration(milliseconds: 250));
        }
        expect(
          enabled(),
          isTrue,
          reason: 'La acción debe terminar su carga antes de pulsarla.',
        );
        await tester.ensureVisible(finder.first);
        await tester.pump(const Duration(milliseconds: 300));
        await tester.tap(finder.first);
        await tester.pump();
      }

      Future<void> screenshot(String name) async {
        await tester.pump();
        final bytes = await binding.takeScreenshot(name);
        await File('${Directory.systemTemp.path}/$name.png')
            .writeAsBytes(bytes);
      }

      await app.main();
      final startDeadline = DateTime.now().add(const Duration(seconds: 60));
      while (find.byType(TextFormField).evaluate().isEmpty &&
          find.text('Mis rutas asignadas').evaluate().isEmpty &&
          DateTime.now().isBefore(startDeadline)) {
        await tester.pump(const Duration(milliseconds: 250));
      }
      if (find.text('Mis rutas asignadas').evaluate().isNotEmpty) {
        await tap(find.byTooltip('Cerrar sesión'));
      }
      await waitFor(find.byType(TextFormField));
      await tester.enterText(
        find.byType(TextFormField).at(0),
        credentials['email'],
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        credentials['password'],
      );
      await tap(find.text('Iniciar sesión'));
      await waitFor(find.text('Mis rutas asignadas'));
      final auth = tester
          .element(find.text('Mis rutas asignadas'))
          .read<AuthProvider>();
      final api = ApiClient(auth);
      Future<Map> waitRoute(bool Function(Map) condition) async {
        final deadline = DateTime.now().add(const Duration(seconds: 30));
        Map current =
            await api.request('/routes/${credentials['route_id']}') as Map;
        while (!condition(current) && DateTime.now().isBefore(deadline)) {
          await tester.pump(const Duration(milliseconds: 300));
          current =
              await api.request('/routes/${credentials['route_id']}') as Map;
        }
        expect(
          condition(current),
          isTrue,
          reason: 'La operación debe estar realmente confirmada en PostgreSQL.',
        );
        return current;
      }

      final own = await api.request('/routes/') as List;
      expect(own.length, 1);
      expect(own.single['ruta_id'], credentials['route_id']);
      var route = own.single as Map;
      expect(route['version'], 2);
      expect([1, 2], contains(route['version_recibida']));
      expect(['EN_CURSO', 'FINALIZADA'], contains(route['estado']));
      final completed = (route['entregas'] as List)
          .where((s) => s['estado_entrega'] == 'ENTREGADO')
          .toList();
      expect(completed.length, inInclusiveRange(1, 3));
      final original = completed.singleWhere(
        (s) => s['cliente'] == 'QA continuidad Huancayo 3',
      );
      final firstTime = original['entregado_en'];
      expect(
        DateTime.parse(firstTime),
        DateTime.parse('2026-11-04T04:13:44.510019+00:00'),
      );
      await phase('version2_already_approved_first_delivery_preserved');
      await binding.convertFlutterSurfaceToImage();
      await tap(find.text('Recorrido · ${credentials['plate']}'));
      await waitFor(find.byType(Scrollable));
      await tester.pump(const Duration(milliseconds: 300));
      final routeScroll = tester
          .stateList<ScrollableState>(find.byType(Scrollable))
          .firstWhere((s) => s.position.axis == Axis.vertical);
      routeScroll.position.jumpTo(routeScroll.position.minScrollExtent);
      await tester.pump(const Duration(milliseconds: 500));
      if (route['version_recibida'] == 1) {
        await waitFor(find.text('Planificación versión 2 · recibida: 1'));
        await screenshot('android_04_nueva_version_pendiente');
        await tap(find.text('Confirmar recepción de nueva ruta'));
      }
      await waitRoute((r) => r['version_recibida'] == 2);
      final headerScroll = tester
          .stateList<ScrollableState>(find.byType(Scrollable))
          .firstWhere((s) => s.position.axis == Axis.vertical);
      headerScroll.position.jumpTo(headerScroll.position.minScrollExtent);
      await tester.pump(const Duration(milliseconds: 500));
      await waitFor(find.text('Planificación versión 2 · recibida: 2'));
      await screenshot('android_05_acuse_real');
      await phase('version2_received_confirmed_ui_and_database');
      for (var expected = completed.length + 1; expected <= 3; expected++) {
        await tap(find.text('Confirmar entrega'));
        await tap(find.text('Confirmar'));
        await waitRoute(
          (r) =>
              (r['entregas'] as List)
                  .where((s) => s['estado_entrega'] == 'ENTREGADO')
                  .length ==
              expected,
        );
      }
      route = await api.request('/routes/${credentials['route_id']}') as Map;
      expect(route['estado'], 'FINALIZADA');
      expect(route['version_recibida'], 2);
      final stops = route['entregas'] as List;
      expect(stops.length, 3);
      expect(stops.map((s) => s['pedido_id']).toSet().length, 3);
      expect(stops.every((s) => s['estado_entrega'] == 'ENTREGADO'), isTrue);
      expect(
        stops.singleWhere(
          (s) => s['pedido_id'] == original['pedido_id'],
        )['entregado_en'],
        firstTime,
      );
      await phase('deliveries_complete');
      await screenshot('android_06_finalizada_historial');
      await tap(find.byTooltip('Back'));
      await waitFor(find.text('Mis rutas asignadas'));
      await command('disconnect');
      await tester.pump(const Duration(seconds: 3));
      await tap(find.byTooltip('Actualizar'));
      await waitFor(
        find.text(
          'No se pudieron actualizar los datos. Se conserva la última consulta disponible.',
        ),
        seconds: 25,
      );
      expect(auth.estaAutenticado, isTrue);
      await screenshot('android_07_desconexion_sin_perder_sesion');
      await tester.pump(const Duration(seconds: 23));
      await tap(find.byTooltip('Actualizar'));
      await waitFor(find.text('Recorrido · ${credentials['plate']}'));
      route = await api.request('/routes/${credentials['route_id']}') as Map;
      expect(route['estado'], 'FINALIZADA');
      expect(route['version_recibida'], 2);
      await screenshot('android_08_recuperacion');
      await tap(find.byTooltip('Cerrar sesión'));
      await waitFor(find.text('Iniciar sesión'));
      expect(auth.estaAutenticado, isFalse);
      await phase('logout_and_recovery_passed');
      await command('done');
    },
    timeout: const Timeout(Duration(minutes: 12)),
  );
}
