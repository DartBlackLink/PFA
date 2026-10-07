import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_client.dart';
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
                backgroundColor: const Color(0xFF167D62),
                child: Text(
                  '${s['secuencia']}',
                  style: const TextStyle(
                    color: Colors.white,
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
        Text(
          '${r['estado']} · ${r['distancia_km'] ?? '—'} km · ${r['tiempo_min'] ?? '—'} min estimados',
        ),
        const SizedBox(height: 8),
        Text(
          origin == null
              ? 'Este registro antiguo no tiene origen guardado.'
              : 'Partida: ${origin.latitude}, ${origin.longitude}',
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
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.ecologistica.web',
                  ),
                  if (points.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: points,
                          color: const Color(0xFF167D62),
                          strokeWidth: 5,
                        ),
                      ],
                    ),
                  MarkerLayer(markers: markers),
                  const SimpleAttributionWidget(
                    source: Text('OpenStreetMap contributors'),
                  ),
                ],
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
                      '${s['direccion']}\nReferencia: ${s['punto_referencia'] ?? 'Sin referencia'}\n${s['peso_kg']} kg · ${s['tipo_producto']} · ${s['prioridad']}\nEstado: ${s['estado_entrega']}\nVentana: ${s['ventana_inicio']} → ${s['ventana_fin']}',
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
