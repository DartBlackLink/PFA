import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecologistica/core/theme/app_theme.dart';
import 'package:ecologistica/features/optimization/data/optimization_gateway.dart';
import 'package:ecologistica/features/optimization/presentation/optimization_screen.dart';

class FakeOptimization extends OptimizationGateway {
  bool empty = false;
  int previews = 0, confirmations = 0;
  Object? failure;
  Completer<Map<String, dynamic>>? pending;
  Map<String, dynamic>? request;
  Map<String, dynamic> plan(String state) => {
    'plan_id': 'plan-1', 'estado': state,
    'creado_en': '2030-01-01T14:00:00Z', 'vence_en': '2049-01-01T00:00:00Z',
    'ruta_ids': <String>[],
    'estadisticas': {'pedidos': 1, 'rutas': 1, 'distancia_km': 5,
      'combustible_l': .5, 'co2_kg': 1, 'seed': 42, 'generations': 40, 'elapsed_ms': 5},
    'rutas': [{'vehiculo_placa': 'QA-123', 'repartidor_nombre': 'Ana QA',
      'weight': 2, 'inicio_planificado': '2030-01-01T14:00:00Z',
      'fin_planificado': '2030-01-01T15:00:00Z',
      'entregas': [{'pedido_id': 'order-1', 'eta': '2030-01-01T14:10:00Z'}]}],
  };
  @override
  Future<Map<String, Records>> load() async => {
    'orders': empty ? [] : [{'pedido_id': 'order-1', 'estado': 'PENDIENTE',
      'cliente_nombre': 'Cliente QA', 'direccion': 'Av. Lima 123', 'peso_kg': 2,
      'ventana_inicio': '2030-01-01T13:00:00Z', 'ventana_fin': '2030-01-01T22:00:00Z'}],
    'drivers': [{'repartidor_id': 'driver-1', 'nombre': 'Ana QA', 'estado': 'ACTIVO'}],
    'vehicles': [{'vehiculo_id': 'vehicle-1', 'placa': 'QA-123', 'capacidad_kg': 10, 'estado': 'ACTIVO'}],
    'plans': [],
  };
  @override
  Future<Map<String, dynamic>> preview(Map<String, dynamic> payload) async {
    previews++; request = payload;
    if (failure != null) throw failure!;
    return pending == null ? plan('PREVISUALIZADO') : pending!.future;
  }
  @override
  Future<Map<String, dynamic>> confirm(String identifier) async {
    confirmations++;
    return plan('CONFIRMADO');
  }
  @override
  Future<Map<String, dynamic>> getPlan(String identifier) async => plan('PREVISUALIZADO');
}

Future<void> showScreen(WidgetTester tester, FakeOptimization api,
    {double width = 1000, Brightness brightness = Brightness.light}) async {
  tester.view.reset();
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
  await tester.pumpWidget(MaterialApp(theme: AppTheme.build(brightness),
    home: OptimizationScreen(gateway: api)));
  await tester.pumpAndSettle();
}

Future<void> press(WidgetTester tester, String key) async {
  final finder = find.byKey(ValueKey(key));
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  test('Lima se representa sin depender de la zona del dispositivo', () {
    expect(optimizationLimaDate('2030-01-02T02:30:00Z'), '01/01/2030 21:30');
    expect(optimizationLimaDate(null), 'Sin fecha');
  });
  for (final width in [360.0, 768.0, 1440.0]) {
    for (final brightness in Brightness.values) {
      testWidgets('GOLD selección, propuesta y confirmación $width $brightness', (tester) async {
        addTearDown(tester.view.reset);
        final api = FakeOptimization();
        await showScreen(tester, api, width: width, brightness: brightness);
        await press(tester, 'opt-select-all');
        await press(tester, 'opt-add-team');
        await press(tester, 'opt-preview');
        expect(api.previews, 1);
        expect(api.confirmations, 0);
        expect(api.request!['pedidos'], ['order-1']);
        expect(api.request!['equipos'], [{'repartidor_id': 'driver-1', 'vehiculo_id': 'vehicle-1'}]);
        expect(api.request!['inicio_planificado'], endsWith('14:00:00.000Z'));
        expect(find.byKey(const ValueKey('opt-confirm')), findsOneWidget);
        await press(tester, 'opt-confirm');
        expect(api.confirmations, 1);
        expect(find.byKey(const ValueKey('opt-confirm')), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('Sin pendientes no se envía una propuesta', (tester) async {
    addTearDown(tester.view.reset);
    final api = FakeOptimization()..empty = true;
    await showScreen(tester, api);
    final button = tester.widget<FilledButton>(find.byKey(const ValueKey('opt-preview')));
    expect(button.onPressed, isNull);
    expect(api.previews, 0);
  });
  testWidgets('Fallo de proveedor informa sin permitir confirmar', (tester) async {
    addTearDown(tester.view.reset);
    final api = FakeOptimization()..failure = Exception('Proveedor no disponible');
    await showScreen(tester, api);
    await press(tester, 'opt-select-all');
    await press(tester, 'opt-add-team');
    await press(tester, 'opt-preview');
    expect(find.text('Proveedor no disponible'), findsOneWidget);
    expect(find.byKey(const ValueKey('opt-confirm')), findsNothing);
    expect(api.confirmations, 0);
  });
  testWidgets('Validación impide tiempo de servicio cero', (tester) async {
    addTearDown(tester.view.reset);
    final api = FakeOptimization();
    await showScreen(tester, api);
    await press(tester, 'opt-select-all');
    await press(tester, 'opt-add-team');
    await tester.enterText(find.byKey(const ValueKey('opt-service')), '0');
    await press(tester, 'opt-preview');
    expect(api.previews, 0);
    expect(find.text('Usa un valor de 1 a 120'), findsOneWidget);
  });
}
