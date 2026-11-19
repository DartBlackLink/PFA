import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

/// Owns the map resources and survives scrolling out of a lazy route list.
class OperationalRouteMap extends StatefulWidget {
  const OperationalRouteMap({
    super.key,
    required this.points,
    required this.basePoints,
    required this.markers,
    this.tileProvider,
    this.baseLabel,
    this.routeLabel,
    this.optimized = false,
  });
  final List<LatLng> points, basePoints;
  final List<Marker> markers;
  final TileProvider? tileProvider;
  final String? baseLabel, routeLabel;
  final bool optimized;
  @override
  State<OperationalRouteMap> createState() => _OperationalRouteMapState();
}

class _OperationalRouteMapState extends State<OperationalRouteMap>
    with AutomaticKeepAliveClientMixin {
  final _map = MapController();
  bool _tileError = false;
  int _revision = 0;
  late TileProvider _provider;
  @override
  bool get wantKeepAlive => true;
  List<LatLng> get _bounds => [
    ...widget.points,
    ...widget.basePoints,
    ...widget.markers.map((m) => m.point),
  ];
  TileProvider _newProvider() =>
      widget.tileProvider ??
      NetworkTileProvider(httpClient: _RouteTileClient());
  @override
  void initState() {
    super.initState();
    _provider = _newProvider();
  }

  void _fit() {
    if (mounted && _bounds.length >= 2) {
      _map.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(_bounds),
          padding: const EdgeInsets.all(48),
        ),
      );
    }
  }

  void _scheduleFit() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) _fit();
  });
  @override
  void didUpdateWidget(covariant OperationalRouteMap old) {
    super.didUpdateWidget(old);
    if (!listEquals(old.points, widget.points) ||
        !listEquals(old.basePoints, widget.basePoints)) {
      _scheduleFit();
    }
  }

  @override
  void dispose() {
    _map.dispose();
    super.dispose();
  }

  Widget _legend(Color color, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.horizontal_rule, color: color, size: 24),
      const SizedBox(width: 6),
      Flexible(child: Text(label)),
    ],
  );

  @override
  Widget build(BuildContext context) {
    super.build(context);
    const affectedColor = Color(0xFFC62828);
    final routeColor = widget.optimized || widget.basePoints.isNotEmpty
        ? const Color(0xFF087D3C)
        : const Color(0xFF1565C0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: MediaQuery.sizeOf(context).width < 600 ? 320 : 450,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: FlutterMap(
              mapController: _map,
              options: MapOptions(
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.scrollWheelZoom,
                ),
                initialCameraFit: CameraFit.bounds(
                  bounds: LatLngBounds.fromPoints(_bounds),
                  padding: const EdgeInsets.all(48),
                ),
                onMapReady: _scheduleFit,
              ),
              children: [
                TileLayer(
                  key: ValueKey(_revision),
                  tileProvider: _provider,
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.ecologistica.app',
                  errorTileCallback: (tile, error, stack) {
                    if (mounted && !_tileError) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted && !_tileError) {
                          setState(() => _tileError = true);
                        }
                      });
                    }
                  },
                ),
                if (widget.basePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: widget.basePoints,
                        color: affectedColor,
                        strokeWidth: 10,
                      ),
                    ],
                  ),
                if (widget.points.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: widget.points,
                        color: routeColor,
                        strokeWidth: 5,
                        borderStrokeWidth: 2,
                        borderColor: Colors.white,
                      ),
                    ],
                  ),
                MarkerLayer(markers: widget.markers),
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Card(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Acercar mapa',
                            onPressed: () => _map.move(
                              _map.camera.center,
                              (_map.camera.zoom + 1).clamp(2, 19).toDouble(),
                            ),
                            icon: const Icon(Icons.add),
                          ),
                          IconButton(
                            tooltip: 'Alejar mapa',
                            onPressed: () => _map.move(
                              _map.camera.center,
                              (_map.camera.zoom - 1).clamp(2, 19).toDouble(),
                            ),
                            icon: const Icon(Icons.remove),
                          ),
                          IconButton(
                            tooltip: 'Centrar recorrido',
                            onPressed: _fit,
                            icon: const Icon(Icons.center_focus_strong),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SimpleAttributionWidget(
                  source: Text(
                    'OpenStreetMap contributors',
                    style: TextStyle(color: Color(0xFF1B2B3B)),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (widget.baseLabel != null || widget.routeLabel != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                if (widget.baseLabel != null && widget.basePoints.isNotEmpty)
                  _legend(affectedColor, widget.baseLabel!),
                if (widget.routeLabel != null && widget.points.isNotEmpty)
                  _legend(routeColor, widget.routeLabel!),
              ],
            ),
          ),
        if (_tileError)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'No se pudo cargar el fondo de calles. El recorrido y las entregas siguen disponibles.',
                    ),
                    TextButton.icon(
                      onPressed: () => setState(() {
                        _tileError = false;
                        _revision++;
                        _provider = _newProvider();
                      }),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar mapa'),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _RouteTileClient extends http.BaseClient {
  final http.Client _client = http.Client();
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      _client.send(request).timeout(const Duration(seconds: 12));
  @override
  void close() {
    _client.close();
    super.close();
  }
}
