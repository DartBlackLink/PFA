import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:ecologistica/main.dart' as app;
import 'package:ecologistica/core/config/env.dart';
import 'package:ecologistica/core/network/api_client.dart';
import 'package:ecologistica/features/auth/presentation/providers/auth_provider.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'GOLD Android principal: permisos, operación, GPS, replan, acuse, desconexión y sesión',
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

      Future<void> showRouteHeader() async {
        await waitFor(find.byType(Scrollable));
        await tester.pump(const Duration(milliseconds: 300));
        final routeScroll = tester
            .stateList<ScrollableState>(find.byType(Scrollable))
            .firstWhere((s) => s.position.axis == Axis.vertical);
        routeScroll.position.jumpTo(routeScroll.position.minScrollExtent);
        await tester.pump(const Duration(milliseconds: 500));
      }

      final own = await api.request('/routes/') as List;
      expect(own.length, 1);
      expect(own.single['ruta_id'], credentials['route_id']);
      for (final item in [
        ('/vehicles/', 403),
        ('/routes/${credentials['foreign_route_id']}', 404),
      ]) {
        final response = await http.get(
          Uri.parse('${EntornoConfig.apiBaseUrl}${item.$1}'),
          headers: {'Authorization': 'Bearer ${auth.token}'},
        );
        expect(response.statusCode, item.$2);
      }
      await binding.convertFlutterSurfaceToImage();
      await screenshot('android_01_panel_propio');
      await tap(find.text('Recorrido · ${credentials['plate']}'));
      expect(own.single['version'], 1);
      expect(['PLANIFICADA', 'EN_CURSO'], contains(own.single['estado']));
      final savedCompleted = (own.single['entregas'] as List)
          .where((s) => s['estado_entrega'] == 'ENTREGADO')
          .toList();
      expect(savedCompleted.length, lessThanOrEqualTo(1));
      if (savedCompleted.isNotEmpty) {
        expect(
          savedCompleted.single['cliente'],
          credentials['plate'] == 'HYO-CONT-03'
              ? 'QA continuidad Huancayo 3'
              : 'QA principal Huancayo 3',
        );
        expect(savedCompleted.single['entregado_en'], isNotNull);
        await phase('first_delivery_previously_confirmed_preserved', {
          'timestamp': savedCompleted.single['entregado_en'],
        });
      }
      if (own.single['version_recibida'] == 0) {
        await waitFor(find.text('Planificación versión 1 · recibida: 0'));
        await tap(find.text('Confirmar recepción de nueva ruta'));
      } else {
        // Preserve the receipt genuinely saved before the map lifecycle failure.
        expect(own.single['version_recibida'], 1);
        final repeated = await api.request(
          '/operations/routes/${credentials['route_id']}/ack',
          method: 'POST',
          body: {'version': 1},
        );
        expect(repeated['version_recibida'], 1);
        await phase('initial_receipt_preserved_and_idempotent');
      }
      await waitRoute((r) => r['version_recibida'] == 1);
      await showRouteHeader();
      await waitFor(find.text('Planificación versión 1 · recibida: 1'));
      if (own.single['estado'] == 'PLANIFICADA') {
        await tap(find.text('Iniciar recorrido'));
        await tap(find.text('Confirmar'));
      } else {
        expect(own.single['iniciado_en'], isNotNull);
        final repeatedStart = await api.request(
          '/routes/${credentials['route_id']}/iniciar',
          method: 'POST',
        );
        expect(repeatedStart['iniciado_en'], own.single['iniciado_en']);
        await phase('start_preserved_and_idempotent');
      }
      await showRouteHeader();
      await waitFor(find.text('Reportar incidencia de tráfico'));
      await screenshot('android_02_mapa_inicio');
      if (savedCompleted.isEmpty) {
        await tap(find.text('Confirmar entrega'));
        await tap(find.text('Confirmar'));
      }
      var route = await waitRoute(
        (r) =>
            (r['entregas'] as List)
                .where((s) => s['estado_entrega'] == 'ENTREGADO')
                .length ==
            1,
      );
      final completed = (route['entregas'] as List)
          .where((s) => s['estado_entrega'] == 'ENTREGADO')
          .toList();
      expect(completed.length, 1);
      final firstTime = completed.single['entregado_en'];
      await tap(find.text('Reportar incidencia de tráfico'));
      Finder field(String label) => find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.labelText == label,
      );
      await tester.enterText(
        field('Describe lo ocurrido'),
        'QA principal Android: congestión simulada, detenido junto al Parque de la Identidad Huanca. Sin tráfico observado real.',
      );
      await tester.enterText(
        field('Demora estimada por ti (minutos, opcional)'),
        '3',
      );
      await command('gps');
      await tap(find.text('Usar mi GPS (solicitar permiso)'));
      final gpsDeadline = DateTime.now().add(const Duration(seconds: 30));
      while (tester
              .widget<TextField>(
                field('Latitud opcional, GPS o confirmada manualmente'),
              )
              .controller!
              .text
              .isEmpty &&
          DateTime.now().isBefore(gpsDeadline)) {
        await tester.pump(const Duration(milliseconds: 300));
      }
      final lat = double.parse(
        tester
            .widget<TextField>(
              field('Latitud opcional, GPS o confirmada manualmente'),
            )
            .controller!
            .text,
      );
      expect(lat, closeTo(-12.0492152, 0.0001));
      await screenshot('android_03_incidencia_gps_emulado');
      await tap(find.text('Registrar incidencia'));
      await showRouteHeader();
      await waitFor(find.text('Reportar incidencia de tráfico'));
      await phase('incident_sent_waiting_admin', {
        'route_id': credentials['route_id'],
        'first_delivered_at': firstTime,
        'gps_latitude': lat,
      });
      final deadline = DateTime.now().add(const Duration(minutes: 6));
      do {
        await tester.pump(const Duration(seconds: 2));
        route = await api.request('/routes/${credentials['route_id']}') as Map;
      } while (route['version'] != 2 && DateTime.now().isBefore(deadline));
      expect(route['version'], 2);
      expect(route['version_recibida'], 1);
      await showRouteHeader();
      await waitFor(find.text('Planificación versión 2 · recibida: 1'));
      await screenshot('android_04_nueva_version_pendiente');
      await tap(find.text('Confirmar recepción de nueva ruta'));
      await waitRoute((r) => r['version_recibida'] == 2);
      await showRouteHeader();
      await waitFor(find.text('Planificación versión 2 · recibida: 2'));
      await screenshot('android_05_acuse_real');
      for (var i = 0; i < 2; i++) {
        await tap(find.text('Confirmar entrega'));
        await tap(find.text('Confirmar'));
        await waitRoute(
          (r) =>
              (r['entregas'] as List)
                  .where((s) => s['estado_entrega'] == 'ENTREGADO')
                  .length ==
              i + 2,
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
          (s) => s['pedido_id'] == completed.single['pedido_id'],
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
