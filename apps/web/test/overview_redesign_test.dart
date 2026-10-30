import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecologistica/core/theme/app_theme.dart';
import 'package:ecologistica/core/theme/theme_controller.dart';
import 'package:ecologistica/features/dashboard/presentation/screens/operation_overview.dart';

void main() {
  test('El tema elegido se restaura al volver a abrir la app', () async {
    SharedPreferences.setMockInitialValues({});
    final first = ThemeController();
    await first.ready;
    first.toggle();
    final next = ThemeController();
    await next.ready;
    expect(next.isDark, true);
    next.toggle();
    final restored = ThemeController();
    await restored.ready;
    expect(restored.isDark, false);
    first.dispose();
    next.dispose();
    restored.dispose();
  });
  for (final brightness in Brightness.values) {
    for (final width in [360.0, 768.0, 1440.0]) {
      testWidgets('Resumen datos reales y acciones $brightness $width', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        var action = '';
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.build(brightness),
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: OperationOverview(
                  orders: const [
                    {
                      'cliente_nombre': 'Cliente de prueba',
                      'direccion': 'Calle de prueba 123',
                      'estado': 'PENDIENTE',
                    },
                  ],
                  drivers: const [
                    {'estado': 'ACTIVO'},
                    {'estado': 'INACTIVO'},
                  ],
                  vehicles: const [
                    {'estado': 'ACTIVO'},
                  ],
                  routes: const [],
                  onNewOrder: () => action = 'new',
                  onOrders: () => action = 'orders',
                  onRoutes: () => action = 'routes',
                  onTeam: () => action = 'team',
                  onFleet: () => action = 'fleet',
                  onOrderDetail: (_) => action = 'detail',
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(find.text('Registrar pedido'));
        await tester.tap(find.text('Registrar pedido'));
        expect(action, 'new');
        await tester.ensureVisible(find.text('Organizar rutas'));
        await tester.tap(find.text('Organizar rutas'));
        expect(action, 'routes');
        await tester.ensureVisible(find.text('Vehículos'));
        await tester.tap(find.text('Vehículos'));
        expect(action, 'fleet');
        await tester.ensureVisible(find.text('Cliente de prueba'));
        await tester.tap(find.text('Cliente de prueba'));
        expect(action, 'detail');
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('Resumen vacío y texto ampliado sin desbordamiento', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(Brightness.light),
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(360, 800),
            textScaler: TextScaler.linear(1.5),
          ),
          child: Scaffold(
            body: OperationOverview(
              orders: const [],
              drivers: const [],
              vehicles: const [],
              routes: const [],
              onNewOrder: () {},
              onOrders: () {},
              onRoutes: () {},
              onTeam: () {},
              onFleet: () {},
              onOrderDetail: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Sin pedidos pendientes'));
    expect(find.text('Sin pedidos pendientes'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
