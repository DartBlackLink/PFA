import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ecologistica/main.dart' as app;
import 'package:provider/provider.dart';
import 'package:ecologistica/features/auth/presentation/providers/auth_provider.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Android real: login de repartidor, ruta propia y persistencia', (
    tester,
  ) async {
    const email = String.fromEnvironment('QA_EMAIL');
    const password = String.fromEnvironment('QA_PASSWORD');
    const plate = String.fromEnvironment('QA_PLATE', defaultValue: 'HYO-QA-03');
    const driverName = String.fromEnvironment(
      'QA_DRIVER_NAME',
      defaultValue: 'Conductor QA Huancayo',
    );
    expect(
      email.endsWith('@example.test'),
      isTrue,
      reason: 'Solo se admiten identidades QA sintéticas.',
    );
    expect(
      password,
      isNotEmpty,
      reason: 'Proporciona QA_PASSWORD mediante archivo privado fuera del repositorio.',
    );
    await app.main();
    Future<void> waitFor(Finder finder) async {
      final end = DateTime.now().add(const Duration(seconds: 60));
      while (finder.evaluate().isEmpty && DateTime.now().isBefore(end)) {
        await tester.pump(const Duration(milliseconds: 250));
      }
      if (finder.evaluate().isEmpty) {
        final auth = tester
            .element(find.byType(app.EcoLogisticaWebApp))
            .read<AuthProvider>();
        debugPrint(
          'Diagnóstico QA de acceso: ${auth.error ?? 'sin error de autenticación'}; rol: ${auth.rol ?? 'sin sesión'}',
        );
        await binding.convertFlutterSurfaceToImage();
        await tester.pump();
        await binding.takeScreenshot('android_fallo_funcional');
      }
      expect(finder, findsWidgets);
    }

    await waitFor(find.byType(TextFormField));
    await tester.enterText(find.byType(TextFormField).at(0), email);
    await tester.enterText(find.byType(TextFormField).at(1), password);
    await tester.pump();
    expect(
      tester
              .widget<TextFormField>(find.byType(TextFormField).at(0))
              .controller!
              .text ==
          email,
      isTrue,
    );
    expect(
      tester
              .widget<TextFormField>(find.byType(TextFormField).at(1))
              .controller!
              .text ==
          password,
      isTrue,
    );
    await tester.tap(find.text('Iniciar sesión'));
    await waitFor(find.text('Mis rutas asignadas'));
    await waitFor(find.text('Recorrido · $plate'));
    await tester.tap(find.text('Recorrido · $plate'));
    await waitFor(find.text('$driverName · $plate'));
    await waitFor(find.text('FINALIZADA'));
    expect(find.text('Iniciar recorrido'), findsNothing);
    await binding.convertFlutterSurfaceToImage();
    await tester.pump();
    await binding.takeScreenshot('android_ruta_propia_finalizada');
  });
}
