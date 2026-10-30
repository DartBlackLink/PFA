import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_client.dart';
import '../../../core/widgets/record_widgets.dart';
import '../../auth/presentation/providers/auth_provider.dart';

class RouteDetailScreen extends StatefulWidget {
  const RouteDetailScreen({super.key, required this.routeId});
  final String routeId;
  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  Map<String, dynamic>? _route;
  String? _error;
  final _map = MapController();
  bool _tileError = false;
  int _mapRevision = 0;
  NetworkTileProvider _tileProvider = NetworkTileProvider(
    httpClient: _TileHttpClient(),
  );
  void _retryMap() => setState(() {
    _tileError = false;
    _mapRevision++;
    _tileProvider = NetworkTileProvider(httpClient: _TileHttpClient());
  });
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _map.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _error = null);
    try {
      final data = await ApiClient(context.read<AuthProvider>())
          .request('/routes/${widget.routeId}');
      if (mounted) setState(() => _route = data as Map<String, dynamic>);
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  double _number(dynamic n) => double.parse(n.toString());
  @override
  Widget build(BuildContext context) {
    final r = _route;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recorrido de entrega'),
        actions: [
          IconButton(
            tooltip: 'Actualizar ruta',
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!, textAlign: TextAlign.center),
                  TextButton(onPressed: _load, child: const Text('Reintentar')),
                ],
              ),
            )
          : r == null
          ? const Center(child: CircularProgressIndicator())
          : _details(r),
    );
  }

  Widget _details(Map<String, dynamic> r) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final stops = (r['entregas'] as List).cast<Map<String, dynamic>>();
    final points = ((r['geometria']?['coordinates'] as List?) ?? [])
        .map((p) => LatLng(_number(p[1]), _number(p[0])))
        .toList();
    final origin = r['origen_latitud'] == null
        ? null
        : LatLng(_number(r['origen_latitud']), _number(r['origen_longitud']));
    final markers = <Marker>[
      if (origin != null)
        Marker(
          point: origin,
          width: 48,
          height: 48,
          child: const Tooltip(
            message: 'Punto de partida',
            child: Icon(Icons.trip_origin, color: Colors.blue, size: 38),
          ),
        ),
      for (final s in stops)
        if (s['latitud'] != null && s['longitud'] != null)
          Marker(
            point: LatLng(_number(s['latitud']), _number(s['longitud'])),
            width: 44,
            height: 44,
            child: Tooltip(
              message: '${s['secuencia']}. ${s['direccion']}',
              child: CircleAvatar(
                backgroundColor: dark
                    ? scheme.primary
                    : const Color(0xFF167D62),
                child: Text(
                  '${s['secuencia']}',
                  style: TextStyle(
                    color: dark ? scheme.onPrimary : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
    ];
    final mapPoints = [...points, ...markers.map((m) => m.point)];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          '${r['repartidor_nombre']} · ${r['vehiculo_placa']}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            StatusBadge('${r['estado']}'),
            Chip(
              avatar: const Icon(Icons.route_outlined),
              label: Text('${r['distancia_km'] ?? '—'} km'),
            ),
            Chip(
              avatar: const Icon(Icons.schedule_outlined),
              label: Text('${r['tiempo_min'] ?? '—'} min estimados'),
            ),
            Chip(
              avatar: const Icon(Icons.inventory_2_outlined),
              label: Text('${stops.length} entregas'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          origin == null
              ? 'Este registro antiguo no tiene origen guardado.'
              : 'Partida: ${origin.latitude}, ${origin.longitude}',
        ),
        const SizedBox(height: 12),
        Text(
          r['inicio_planificado'] == null
              ? 'Horario por registrar por administración.'
              : 'Salida: ${friendlyDate(r['inicio_planificado'])}\nFin estimado: ${friendlyDate(r['fin_planificado'])}\nAtención: ${r['servicio_min_por_entrega']} min por entrega',
        ),
        const SizedBox(height: 16),
        if (mapPoints.length >= 2)
          SizedBox(
            height: MediaQuery.sizeOf(context).width < 600 ? 320 : 450,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: FlutterMap(
                key: ValueKey(widget.routeId),
                mapController: _map,
                options: MapOptions(
                  interactionOptions: const InteractionOptions(
                    flags:
                        InteractiveFlag.all & ~InteractiveFlag.scrollWheelZoom,
                  ),
                  initialCameraFit: CameraFit.bounds(
                    bounds: LatLngBounds.fromPoints(mapPoints),
                    padding: const EdgeInsets.all(48),
                  ),
                  onMapReady: () => _map.fitCamera(
                    CameraFit.bounds(
                      bounds: LatLngBounds.fromPoints(mapPoints),
                      padding: const EdgeInsets.all(48),
                    ),
                  ),
                ),
                children: [
                  TileLayer(
                    key: ValueKey(_mapRevision),
                    tileProvider: _tileProvider,
                    errorTileCallback: (tile, error, stack) {
                      if (mounted && !_tileError) {
                        setState(() => _tileError = true);
                      }
                    },
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.ecologistica.web',
                  ),
                  if (points.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: points,
                          color: dark
                              ? scheme.primary
                              : const Color(0xFF167D62),
                          strokeWidth: 5,
                        ),
                      ],
                    ),
                  MarkerLayer(markers: markers),
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
                              onPressed: () => _map.fitCamera(
                                CameraFit.bounds(
                                  bounds: LatLngBounds.fromPoints(mapPoints),
                                  padding: const EdgeInsets.all(48),
                                ),
                              ),
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
                      onPressed: _retryMap,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar mapa'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (points.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Este registro antiguo no tiene recorrido calculado. Las nuevas asignaciones guardan la geometría vial.',
              ),
            ),
          ),
        const SizedBox(height: 12),
        const Text(
          'Recorrido planificado por calles. No muestra la ubicación actual del repartidor ni tráfico en tiempo real. El mapa base requiere conexión a internet.',
        ),
        const SizedBox(height: 24),
        const Text(
          'Detalles de las entregas',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        for (final s in stops)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${s['secuencia']}. ${s['cliente']}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${s['direccion']}\nReferencia: ${s['punto_referencia'] ?? 'Sin referencia'}\n${s['peso_kg']} kg · ${s['tipo_producto']} · ${s['prioridad']}\nEstado: ${s['estado_entrega']}\nVentana: ${friendlyDate(s['ventana_inicio'])} → ${friendlyDate(s['ventana_fin'])}',
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

/// Evita dejar solicitudes del mapa pendientes indefinidamente.
class _TileHttpClient extends http.BaseClient {
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
