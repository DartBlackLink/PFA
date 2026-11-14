import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecologistica/core/theme/app_theme.dart';
import 'package:ecologistica/features/auth/presentation/providers/auth_provider.dart';
import 'package:ecologistica/features/rutas/presentation/replanning_panel.dart';

class AdminTestSession extends AuthProvider {
  AdminTestSession()
    : super(client: MockClient((_) async => http.Response('{}', 401)));
  @override
  bool get esRepartidor => false;
}

Map<String, dynamic> revision(String state) => {
  'revision_id': 'revision-qa',
  'version_base': 1,
  'estado': state,
  'vence_en': DateTime.now().toUtc().add(const Duration(minutes: 2)).toIso8601String(),
  'motivo': 'Cambio solicitado por congestión reportada por el conductor.',
  'recibido_en': null,
  'propuesta': {
    'comparacion': {
      'vigente_km': 10,
      'vigente_min': 40,
      'alternativa_km': 9,
      'alternativa_min': 35,
      'diferencia_km': -1,
      'diferencia_min': -5,
      'ventanas_alternativa': 'Todas factibles bajo la estimación',
    },
    'advertencia': 'Aproximación manual; no es tráfico en vivo.',
  },
};
void main() {
  test('No se decide una propuesta vencida, de otra versión o ruta terminada', () {
    final now = DateTime.utc(2026, 11, 13, 18);
    final route = <String, dynamic>{'estado': 'EN_CURSO', 'version': 1};
    final proposal = <String, dynamic>{'estado': 'PROPUESTA', 'version_base': 1,
      'vence_en': now.add(const Duration(minutes: 2)).toIso8601String()};
    expect(canDecideReplanning(route, proposal, now), isTrue);
    expect(canDecideReplanning(route, proposal, now.add(const Duration(minutes: 2))), isFalse);
    expect(canDecideReplanning({...route, 'version': 2}, proposal, now), isFalse);
    expect(canDecideReplanning({...route, 'estado': 'FINALIZADA'}, proposal, now), isFalse);
    expect(canDecideReplanning(route, {...proposal, 'vence_en': null}, now), isFalse);
    expect(canDecideReplanning(route, {...proposal, 'estado': 'APROBADA'}, now), isFalse);
  });

  test('La comparación informa empate y distingue tiempo de distancia', () {
    expect(
      replanningComparisonSummary({'diferencia_min': 0, 'diferencia_km': 0}),
      'Sin mejora estimada: mismo tiempo y misma distancia.',
    );
    expect(
      replanningComparisonSummary({'diferencia_min': -5, 'diferencia_km': 1}),
      'Menor tiempo estimado y mayor distancia.',
    );
    expect(
      replanningComparisonSummary({'diferencia_min': 1, 'diferencia_km': -2}),
      'Mayor tiempo estimado y menor distancia.',
    );
    expect(
      replanningComparisonSummary({'diferencia_min': null, 'diferencia_km': null}),
      'No hay una estimación comparable de la ruta vigente.',
    );
  });
  for (final width in [360.0, 768.0, 1440.0]) {
    for (final brightness in [Brightness.light, Brightness.dark]) {
      testWidgets(
        'Reoptimización legible $width $brightness y sin recepción ficticia',
        (tester) async {
          SharedPreferences.setMockInitialValues({});
          tester.view.physicalSize = Size(width, 900);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          final auth = AdminTestSession();
          await auth.ready;
          await tester.pumpWidget(
            ChangeNotifierProvider<AuthProvider>.value(
              value: auth,
              child: MaterialApp(
                theme: AppTheme.build(brightness),
                home: Scaffold(
                  body: SingleChildScrollView(
                    child: ReplanningPanel(
                      route: const {
                        'ruta_id': 'route-qa',
                        'estado': 'EN_CURSO',
                        'version': 2,
                      },
                      incidents: const [],
                      revisions: [revision('APROBADA')],
                      onUpdated: () async {},
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(
            find.text('Recepción del repartidor pendiente'),
            findsOneWidget,
          );
          expect(find.text('Aprobar y enviar ruta optimizada'), findsNothing);
          expect(tester.takeException(), null);
          await tester.pumpWidget(const SizedBox.shrink());
          auth.dispose();
        },
      );
    }
  }
  testWidgets(
    'Confirmación explica alcance y cancelar no ejecuta actualización',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final auth = AdminTestSession();
      await auth.ready;
      var updates = 0;
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: auth,
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ReplanningPanel(
                  route: const {
                    'ruta_id': 'route-qa',
                    'estado': 'EN_CURSO',
                    'version': 1,
                  },
                  incidents: const [],
                  revisions: [revision('PROPUESTA')],
                  onUpdated: () async {
                    updates++;
                  },
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Aprobar y enviar ruta optimizada'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('únicamente las entregas pendientes'),
        findsOneWidget,
      );
      await tester.tap(find.text('Volver'));
      await tester.pumpAndSettle();
      expect(updates, 0);
      expect(find.text('PROPUESTA'), findsNothing);
      expect(tester.takeException(), null);
      await tester.pumpWidget(const SizedBox.shrink());
      auth.dispose();
    },
  );
}
