import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecologistica/core/theme/app_theme.dart';
import 'package:ecologistica/core/widgets/record_widgets.dart';
import 'package:ecologistica/flota/data/models/vehiculo_model.dart';
import 'package:ecologistica/flota/presentation/widgets/modal_formulario_vehiculo.dart';
import 'package:ecologistica/features/auth/presentation/providers/auth_provider.dart';
import 'package:ecologistica/features/auth/presentation/providers/flota_provider.dart';
import 'package:ecologistica/features/auth/presentation/screens/login_screen.dart';

class RecordingFleet extends FlotaProvider {
  RecordingFleet(super.auth);
  VehiculoModel? saved;
  @override
  Future<bool> guardarVehiculo(VehiculoModel vehiculo) async {
    saved = vehiculo;
    return true;
  }
}

double contrast(Color a, Color b) {
  final x = a.computeLuminance(), y = b.computeLuminance();
  return x > y ? (x + .05) / (y + .05) : (y + .05) / (x + .05);
}

void main() {
  for (final brightness in Brightness.values) {
    final theme = AppTheme.build(brightness);
    test('Contraste de texto, campos y estados: $brightness', () {
      final s = theme.colorScheme;
      for (final background in [
        s.surface,
        s.surfaceContainerHighest,
        theme.scaffoldBackgroundColor,
      ]) {
        expect(contrast(s.onSurface, background), greaterThanOrEqualTo(4.5));
        expect(
          contrast(s.onSurfaceVariant, background),
          greaterThanOrEqualTo(4.5),
        );
      }
      expect(
        contrast(s.onPrimaryContainer, s.primaryContainer),
        greaterThanOrEqualTo(4.5),
      );
      expect(theme.dialogTheme.backgroundColor, s.surface);
    });
    for (final size in [const Size(360, 640), const Size(1440, 900)]) {
      testWidgets('Formulario y decimales: $brightness $size', (tester) async {
        SharedPreferences.setMockInitialValues({});
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final auth = AuthProvider(
          apiUrl: 'http://test/api/v1',
          client: MockClient((_) async => http.Response('{}', 401)),
        );
        await auth.ready;
        final fleet = RecordingFleet(auth);
        await tester.pumpWidget(
          ChangeNotifierProvider<FlotaProvider>.value(
            value: fleet,
            child: MaterialApp(
              theme: theme,
              home: Builder(
                builder: (context) => Scaffold(
                  body: TextButton(
                    onPressed: () => ModalFormularioVehiculo.mostrar(context),
                    child: const Text('Abrir'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Abrir'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Guardar'));
        await tester.pumpAndSettle();
        expect(fleet.saved, null);
        expect(tester.takeException(), null);
        final values = [
          'ABC-123',
          'Camioneta',
          '100,5',
          '2025',
          '12,5',
          '0,15',
        ];
        for (var i = 0; i < values.length; i++) {
          final field = find.byType(TextFormField).at(i);
          await tester.ensureVisible(field);
          await tester.enterText(field, values[i]);
        }
        await tester.ensureVisible(find.text('Guardar'));
        await tester.tap(find.text('Guardar'));
        await tester.pumpAndSettle();
        expect(fleet.saved?.capacidadKg, 100.5);
        expect(fleet.saved?.consumoKmL, 12.5);
        expect(fleet.saved?.factorEmisionKgKm, .15);
        expect(find.byType(AlertDialog), findsNothing);
        expect(tester.takeException(), null);
        await tester.pumpWidget(const SizedBox());
        fleet.dispose();
        auth.dispose();
      });
      testWidgets('Registros adaptables: $brightness $size', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: SingleChildScrollView(
                child: AdaptiveRecords(
                  columns: const [DataColumn(label: Text('Estado'))],
                  rows: const [
                    DataRow(cells: [DataCell(StatusBadge('ACTIVO'))]),
                  ],
                  cards: const [
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: StatusBadge('ACTIVO'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.byType(DataTable),
          size.width >= 850 ? findsOneWidget : findsNothing,
        );
        expect(find.text('ACTIVO'), findsOneWidget);
        expect(tester.takeException(), null);
      });
      testWidgets('Acceso con tema: $brightness $size', (tester) async {
        SharedPreferences.setMockInitialValues({});
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final auth = AuthProvider(
          apiUrl: 'http://test/api/v1',
          client: MockClient((_) async => http.Response('{}', 401)),
        );
        await auth.ready;
        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: auth,
            child: MaterialApp(theme: theme, home: const LoginScreen()),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), null);
        expect(find.byType(TextFormField), findsNWidgets(2));
        expect(
          tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
          null,
        );
        await tester.pumpWidget(const SizedBox());
        auth.dispose();
      });
    }
  }
}
