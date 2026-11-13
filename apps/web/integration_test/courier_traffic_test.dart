import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:ecologistica/main.dart' as app;
import 'package:ecologistica/core/network/api_client.dart';
import 'package:ecologistica/features/auth/presentation/providers/auth_provider.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Android QA: consulta versión 2, acuse y entregas preservadas', (
    tester,
  ) async {
    const email = String.fromEnvironment('QA_EMAIL');
    const password = String.fromEnvironment('QA_PASSWORD');
    const plate = String.fromEnvironment(
      'QA_PLATE',
      defaultValue: 'QA-TRAF-03',
    );
    expect(email.endsWith('@example.test'), isTrue);
    expect(password, isNotEmpty);
    await app.main();
    Future<void> waitFor(Finder target) async {
      final deadline = DateTime.now().add(const Duration(seconds: 60));
      while (target.evaluate().isEmpty && DateTime.now().isBefore(deadline)) {
        await tester.pump(const Duration(milliseconds: 250));
      }
      expect(target, findsWidgets);
    }

    final deadline = DateTime.now().add(const Duration(seconds: 60));
    while (find.byType(TextFormField).evaluate().isEmpty &&
        find.text('Mis rutas asignadas').evaluate().isEmpty &&
        DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 250));
    }
    if (find.text('Mis rutas asignadas').evaluate().isNotEmpty) {
      await tester.tap(find.byTooltip('Cerrar sesión'));
    }
    await waitFor(find.byType(TextFormField));
    await tester.enterText(find.byType(TextFormField).at(0), email);
    await tester.enterText(find.byType(TextFormField).at(1), password);
    await tester.tap(find.text('Iniciar sesión'));
    await waitFor(find.text('Mis rutas asignadas'));
    final auth = tester
        .element(find.text('Mis rutas asignadas'))
        .read<AuthProvider>();
    final routes = await ApiClient(auth).request('/routes/');
    final route = (routes as List).singleWhere(
      (r) => r['vehiculo_placa'] == plate,
    );
    expect(route['version'], 2);
    expect(route['version_recibida'], 2);
    expect(route['estado'], 'FINALIZADA');
    final stops = route['entregas'] as List;
    expect(stops.length, 3);
    expect(stops.map((s) => s['pedido_id']).toSet().length, 3);
    expect(
      stops.every(
        (s) => s['estado_entrega'] == 'ENTREGADO' && s['entregado_en'] != null,
      ),
      isTrue,
    );
    await waitFor(find.text('Recorrido · $plate'));
    await tester.tap(find.text('Recorrido · $plate'));
    await waitFor(find.text('Planificación versión 2 · recibida: 2'));
    await waitFor(find.text('FINALIZADA'));
    expect(find.text('Confirmar recepción de nueva ruta'), findsNothing);
    await binding.convertFlutterSurfaceToImage();
    await tester.pump();
    await binding.takeScreenshot('android_ruta_v2_recibida_finalizada');
  });
}
