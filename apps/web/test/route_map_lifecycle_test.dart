import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:ecologistica/features/rutas/presentation/operational_route_map.dart';

class LocalTiles extends TileProvider {
  int disposed = 0;
  final image = MemoryImage(
    base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAC0lEQVR4nGP4DwQACfsD/fteaysAAAAASUVORK5CYII=',
    ),
  );
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      image;
  @override
  void dispose() {
    disposed++;
    super.dispose();
  }
}

void main() {
  for (final dark in [false, true]) {
    testWidgets('Trazado visible sobre OSM con borde en tema oscuro=$dark', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? ThemeData.dark() : ThemeData.light(),
          home: Scaffold(
            body: OperationalRouteMap(
              points: const [
                LatLng(-12.068, -75.210),
                LatLng(-12.049, -75.198),
              ],
              basePoints: const [],
              markers: const [],
              tileProvider: LocalTiles(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final line = tester
          .widget<PolylineLayer>(find.byType(PolylineLayer))
          .polylines
          .single;
      final contrast =
          (const Color(0xFFF0F0F0).computeLuminance() + 0.05) /
          (line.color.computeLuminance() + 0.05);
      expect(contrast, greaterThanOrEqualTo(3));
      expect(line.borderColor, Colors.white);
      expect(line.borderStrokeWidth, greaterThan(0));
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  }

  testWidgets(
    'Mapa conserva controlador al salir de la vista y admite una geometría nueva sin errores de ciclo de vida',
    (tester) async {
      final scroll = ScrollController();
      final tiles = LocalTiles();
      const key = ValueKey('route-map');
      Widget page(List<LatLng> points) => MaterialApp(
        home: Scaffold(
          body: ListView(
            controller: scroll,
            children: [
              OperationalRouteMap(
                key: key,
                points: points,
                basePoints: const [],
                markers: const [],
                tileProvider: tiles,
              ),
              const SizedBox(height: 2000),
              const Text('Última entrega'),
            ],
          ),
        ),
      );
      final original = [
        const LatLng(-12.068, -75.210),
        const LatLng(-12.049, -75.198),
      ];
      await tester.pumpWidget(page(original));
      await tester.pumpAndSettle();
      final state = tester.state(find.byKey(key));
      for (var i = 0; i < 3; i++) {
        scroll.jumpTo(1700);
        await tester.pumpAndSettle();
        expect(tiles.disposed, 0);
        scroll.jumpTo(0);
        await tester.pumpAndSettle();
        expect(identical(tester.state(find.byKey(key)), state), isTrue);
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(
        page([const LatLng(-12.049, -75.198), const LatLng(-12.071, -75.208)]),
      );
      await tester.pumpAndSettle();
      expect(identical(tester.state(find.byKey(key)), state), isTrue);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      expect(tiles.disposed, 1);
      expect(tester.takeException(), isNull);
      scroll.dispose();
    },
  );
}
