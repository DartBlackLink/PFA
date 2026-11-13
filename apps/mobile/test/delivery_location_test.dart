import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecologistica/core/widgets/delivery_location_picker.dart';

void main() {
  const result = {
    'direccion': 'Parque de la Identidad, Huancayo, Perú',
    'latitud': -12.054,
    'longitud': -75.195,
  };
  testWidgets(
    'Seleccionar resultado exige confirmar y editar dirección invalida',
    (tester) async {
      DeliveryLocation? selected;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DeliveryLocationPicker(
                showMap: false,
                onChanged: (p) => selected = p,
                lookup: (_) async => [result],
              ),
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField).first, 'Parque Huancayo');
      await tester.tap(find.text('Buscar en el mapa'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(result['direccion'] as String));
      await tester.pumpAndSettle();
      expect(selected, isNull);
      await tester.ensureVisible(find.byType(CheckboxListTile));
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();
      expect(selected!.point.latitude, result['latitud']);
      expect(selected!.address, result['direccion']);
      await tester.ensureVisible(find.byType(TextFormField));
      await tester.enterText(
        find.byType(TextFormField),
        'Av. Nueva 123, Huancayo',
      );
      await tester.pump();
      expect(selected, isNull);
      expect(
        tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
        false,
      );
    },
  );

  testWidgets(
    'Sin resultados permite dirección y coordenadas manuales válidas',
    (tester) async {
      DeliveryLocation? selected;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DeliveryLocationPicker(
                showMap: false,
                onChanged: (p) => selected = p,
                lookup: (_) async => [],
              ),
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField).first, 'Sin resultado');
      await tester.tap(find.text('Buscar en el mapa'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Sin coincidencias.'), findsOneWidget);
      await tester.enterText(
        find.byType(TextFormField),
        'Av. Manual 100, Huancayo',
      );
      await tester.ensureVisible(find.byType(ExpansionTile));
      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'Latitud'), '91');
      await tester.enterText(
        find.widgetWithText(TextField, 'Longitud'),
        '-75.21',
      );
      await tester.ensureVisible(find.text('Aplicar coordenadas'));
      await tester.tap(find.text('Aplicar coordenadas'));
      await tester.pump();
      expect(selected, isNull);
      expect(find.textContaining('Latitud entre'), findsOneWidget);
      await tester.enterText(
        find.widgetWithText(TextField, 'Latitud'),
        '-12,07',
      );
      await tester.tap(find.text('Aplicar coordenadas'));
      await tester.pump();
      await tester.ensureVisible(find.byType(CheckboxListTile));
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();
      expect(selected!.point.latitude, -12.07);
      expect(selected!.point.longitude, -75.21);
    },
  );

  testWidgets('Fallo de búsqueda informa sin romper el formulario', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: DeliveryLocationPicker(
              showMap: false,
              onChanged: (_) {},
              lookup: (_) async => throw Exception('Servicio no disponible'),
            ),
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField).first, 'Huancayo');
    await tester.tap(find.text('Buscar en el mapa'));
    await tester.pumpAndSettle();
    expect(find.text('Servicio no disponible'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final dark in [false, true]) {
    testWidgets('Ubicación adaptable 360 px tema oscuro $dark', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: dark ? Brightness.dark : Brightness.light,
          ),
          home: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: DeliveryLocationPicker(
                  showMap: false,
                  onChanged: (_) {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
