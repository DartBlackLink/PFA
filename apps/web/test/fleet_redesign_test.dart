import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecologistica/core/theme/app_theme.dart';
import 'package:ecologistica/core/theme/theme_controller.dart';
import 'package:ecologistica/features/auth/presentation/providers/auth_provider.dart';
import 'package:ecologistica/features/auth/presentation/providers/flota_provider.dart';
import 'package:ecologistica/flota/data/models/vehiculo_model.dart';
import 'package:ecologistica/flota/presentation/screens/flota_screen.dart';

class FleetFixture extends FlotaProvider {
  FleetFixture(super.auth);
  @override
  List<VehiculoModel> get vehiculos => [
    VehiculoModel(
      vehiculoId: 'test-1',
      placa: 'QA-001',
      tipo: 'Furgón',
      capacidadKg: 500,
      consumoKmL: 12,
      factorEmisionKgKm: .2,
      anioFabricacion: 2024,
    ),
    VehiculoModel(
      vehiculoId: 'test-2',
      placa: 'QA-002',
      tipo: 'Moto',
      capacidadKg: 25,
      consumoKmL: 38,
      factorEmisionKgKm: .05,
      anioFabricacion: 2023,
      estado: 'INACTIVO',
    ),
  ];
  @override
  Future<void> cargarVehiculos() async {}
}

void main() {
  for (final brightness in Brightness.values) {
    for (final width in [360.0, 768.0, 1440.0]) {
      testWidgets('Flota filtros y vistas $brightness $width', (tester) async {
        SharedPreferences.setMockInitialValues({});
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final auth = AuthProvider(
          apiUrl: 'http://test/api/v1',
          client: MockClient((_) async => http.Response('{}', 401)),
        );
        await auth.ready;
        final controller = ThemeController();
        await controller.ready;
        final fleet = FleetFixture(auth);
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<FlotaProvider>.value(value: fleet),
              ChangeNotifierProvider<ThemeController>.value(value: controller),
            ],
            child: MaterialApp(
              theme: AppTheme.build(brightness),
              home: const FlotaScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(
          find.widgetWithText(TextField, 'Buscar por placa, tipo o año'),
        );
        await tester.enterText(find.byType(TextField), 'QA-001');
        await tester.pumpAndSettle();
        expect(find.text('1 vehículo encontrado'), findsOneWidget);
        expect(
          find.byWidgetPredicate((w) => w is Text && w.data == 'QA-001'),
          findsOneWidget,
        );
        expect(find.text('QA-002'), findsNothing);
        await tester.ensureVisible(find.text('Limpiar filtros'));
        await tester.tap(find.text('Limpiar filtros'));
        await tester.pumpAndSettle();
        expect(find.text('2 vehículos encontrados'), findsOneWidget);
        if (width >= 950) {
          await tester.ensureVisible(find.byTooltip('Vista de tabla'));
          await tester.tap(find.byTooltip('Vista de tabla'));
          await tester.pumpAndSettle();
          expect(find.byType(DataTable), findsOneWidget);
          await tester.tap(find.byTooltip('Vista de tarjetas'));
          await tester.pumpAndSettle();
          expect(find.byType(DataTable), findsNothing);
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        fleet.dispose();
        controller.dispose();
        auth.dispose();
      });
    }
  }
}
