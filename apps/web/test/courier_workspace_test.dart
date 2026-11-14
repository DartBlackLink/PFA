import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecologistica/core/theme/app_theme.dart';
import 'package:ecologistica/features/auth/presentation/screens/courier_workspace.dart';

final routes = [
  {
    'ruta_id': 'active',
    'vehiculo_placa': 'HYO-ACTIVA',
    'estado': 'PLANIFICADA',
    'version': 2,
    'version_recibida': 1,
    'entregas': [
      {'estado_entrega': 'PENDIENTE'},
    ],
  },
  {
    'ruta_id': 'done',
    'vehiculo_placa': 'HYO-HISTORICA',
    'estado': 'FINALIZADA',
    'version': 2,
    'version_recibida': 2,
    'entregas': [
      {'estado_entrega': 'ENTREGADO'},
    ],
  },
];
Widget subject({
  Brightness brightness = Brightness.light,
  double scale = 1,
  List<dynamic>? data,
}) => MaterialApp(
  theme: AppTheme.build(brightness),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: child!,
  ),
  home: Scaffold(
    body: CourierWorkspace(
      routes: data ?? routes,
      profile: {
        'nombre': 'Conductor QA Huancayo',
        'estado': 'ACTIVO',
        'dni': '99001104',
        'licencia': 'QA',
      },
      onOpen: (_) async {},
      onRefresh: () async {},
    ),
  ),
);
void main() {
  testWidgets('El contador excluye versiones no recibidas de rutas cerradas', (tester) async {
    await tester.pumpWidget(subject(data: [
      {...routes[0], 'estado': 'CANCELADA', 'version': 3, 'version_recibida': 0},
      {...routes[1], 'version': 2, 'version_recibida': 0},
    ]));
    await tester.pumpAndSettle();
    final metric = find.ancestor(of: find.text('Versiones por recibir'), matching: find.byType(Card)).first;
    expect(find.descendant(of: metric, matching: find.text('0')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final width in [360.0, 768.0, 1440.0]) {
    for (final brightness in [Brightness.light, Brightness.dark]) {
      testWidgets(
        'Panel repartidor $width $brightness texto200% sin desbordamiento',
        (tester) async {
          tester.view.physicalSize = Size(width, 1100);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await tester.pumpWidget(subject(brightness: brightness, scale: 2));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(find.text('Entregas pendientes'), findsOneWidget);
          expect(find.text('Versiones por recibir'), findsOneWidget);
        },
      );
    }
  }
  testWidgets(
    'Filtros distinguen operación vigente e historial sin ocultar datos del servidor',
    (tester) async {
      await tester.pumpWidget(subject());
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Historial'));
      await tester.tap(find.text('Historial'));
      await tester.pumpAndSettle();
      expect(find.text('Recorrido · HYO-HISTORICA'), findsOneWidget);
      expect(find.text('Recorrido · HYO-ACTIVA'), findsNothing);
      await tester.tap(find.text('Activas'));
      await tester.pumpAndSettle();
      expect(find.text('Recorrido · HYO-ACTIVA'), findsOneWidget);
      expect(find.text('Recorrido · HYO-HISTORICA'), findsNothing);
    },
  );
}
