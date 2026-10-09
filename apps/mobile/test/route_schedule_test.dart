import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecologistica/features/rutas/presentation/route_schedule_input.dart';

void main() {
  test('Horario de Lima se envía como instante UTC y conserva servicio', () {
    final draft = RouteScheduleDraft(
      initial: '2026-10-10T13:00:00Z',
      serviceMinutes: 7,
    );
    expect(draft.start.hour, 8);
    expect(draft.payload['inicio_planificado'], '2026-10-10T13:00:00.000Z');
    expect(draft.payload['servicio_min_por_entrega'], 7);
    draft.serviceMinutes = 121;
    expect(draft.error, isNotNull);
  });
  testWidgets(
    'El formulario permite editar servicio y muestra el error de rango',
    (tester) async {
      final draft = RouteScheduleDraft();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RouteScheduleInput(draft: draft),
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextFormField), '10');
      expect(draft.payload['servicio_min_por_entrega'], 10);
      await tester.enterText(find.byType(TextFormField), '121');
      await tester.pump();
      expect(
        find.text('Indica entre 0 y 120 minutos de atención por entrega.'),
        findsOneWidget,
      );
      await tester.enterText(find.byType(TextFormField), '');
      expect(draft.error, isNotNull);
    },
  );
}
