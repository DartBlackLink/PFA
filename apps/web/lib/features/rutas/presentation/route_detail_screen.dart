import 'package:flutter/material.dart';

import 'dart:math';
import 'dart:async';

import '../../../core/location/current_location.dart';
import '../../../core/config/operation_area.dart';
import 'replanning_panel.dart';
import 'operational_route_map.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_client.dart';
import '../../../core/widgets/record_widgets.dart';
import '../../auth/presentation/providers/auth_provider.dart';

class RouteDetailScreen extends StatefulWidget {
  const RouteDetailScreen({super.key, required this.routeId, this.preview});
  final String routeId;
  final Map<String, dynamic>? preview;
  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  Map<String, dynamic>? _route;
  String? _error;
  bool _busy = false;
  List<dynamic> _incidents = [];
  List<dynamic> _revisions = [];
  Timer? _timer;
  bool _loadingRoute = false;
  @override
  void initState() {
    super.initState();
    if (widget.preview != null) {
      _route = widget.preview;
      _incidents = (widget.preview?['incident_markers'] as List?) ?? [];
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _load());
      _timer = Timer.periodic(const Duration(seconds: 10), (_) {
        if (!_busy) _load();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted || _loadingRoute) return;
    _loadingRoute = true;
    setState(() => _error = null);
    final api = ApiClient(context.read<AuthProvider>());
    try {
      final data = await api.request('/routes/${widget.routeId}');
      if (mounted) setState(() => _route = data as Map<String, dynamic>);
      final incidents = await api.request(
        '/routes/${widget.routeId}/incidentes',
      );
      final revisions = await api.request(
        '/operations/routes/${widget.routeId}/revisions',
      );
      if (mounted) {
        setState(() {
          _incidents = incidents as List;
          _revisions = revisions as List;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      _loadingRoute = false;
    }
  }

  double _number(dynamic n) => double.parse(n.toString());
  Future<void> _operate(String action, String question) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('Confirmar operación'),
        content: Text(question),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    if (accepted != true || !mounted || _busy) return;
    setState(() => _busy = true);
    try {
      final updated = await ApiClient(context.read<AuthProvider>()).request(
        '/routes/${widget.routeId}/$action?version=${_route?['version'] ?? 1}',
        method: 'POST',
      );
      if (!mounted) return;
      setState(() => _route = updated as Map<String, dynamic>);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Operación guardada correctamente.')),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reportIncident() async {
    final controller = TextEditingController();
    final form = GlobalKey<FormState>();
    final random = Random.secure();
    final bytes = List.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 15) | 64;
    bytes[8] = (bytes[8] & 63) | 128;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    final event =
        '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
    String type = 'CONGESTION';
    String impact = 'MEDIA';
    final lat = TextEditingController();
    final lon = TextEditingController();
    final delay = TextEditingController();
    final occurred = DateTime.now().toUtc().toIso8601String();
    bool locating = false;
    String? error;
    bool saving = false;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialog) => StatefulBuilder(
        builder: (dialog, update) => PopScope(
          canPop: !saving,
          child: AlertDialog(
            title: const Text('Reportar incidencia de tráfico'),
            content: SizedBox(
              width: 440,
              child: SingleChildScrollView(
                child: Form(
                  key: form,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: type,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Tipo'),
                        items: const [
                          DropdownMenuItem(
                            value: 'CONGESTION',
                            child: Text('Congestión'),
                          ),
                          DropdownMenuItem(
                            value: 'VIA_CERRADA',
                            child: Text('Vía cerrada'),
                          ),
                          DropdownMenuItem(
                            value: 'AVERIA',
                            child: Text('Avería'),
                          ),
                          DropdownMenuItem(
                            value: 'ACCIDENTE',
                            child: Text('Accidente'),
                          ),
                          DropdownMenuItem(
                            value: 'ENTREGA_FALLIDA',
                            child: Text('Entrega fallida'),
                          ),
                          DropdownMenuItem(value: 'OTRO', child: Text('Otro')),
                        ],
                        onChanged: saving
                            ? null
                            : (v) => update(() => type = v!),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: controller,
                        enabled: !saving,
                        maxLength: 1000,
                        minLines: 3,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: 'Describe lo ocurrido',
                        ),
                        validator: (v) => (v?.trim().length ?? 0) < 10
                            ? 'Escribe al menos 10 caracteres.'
                            : null,
                      ),
                      const Text(
                        'Reporta únicamente cuando estés detenido en un lugar seguro. La ruta y el conductor se obtienen de tu sesión.',
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: saving || locating
                            ? null
                            : () async {
                                update(() {
                                  locating = true;
                                  error = null;
                                });
                                try {
                                  final gps = await currentLocation();
                                  if (dialog.mounted) {
                                    update(() {
                                      lat.text = gps['latitud']!
                                          .toStringAsFixed(6);
                                      lon.text = gps['longitud']!
                                          .toStringAsFixed(6);
                                      if (gps['precision_m']! > 100) {
                                        error =
                                            'Precisión GPS aproximada de ${gps['precision_m']!.round()} m. Verifica la ubicación antes de registrar.';
                                      }
                                    });
                                  }
                                } catch (e) {
                                  if (dialog.mounted) {
                                    update(() => error = '$e');
                                  }
                                } finally {
                                  if (dialog.mounted) {
                                    update(() => locating = false);
                                  }
                                }
                              },
                        icon: const Icon(Icons.my_location),
                        label: Text(
                          locating
                              ? 'Obteniendo ubicación…'
                              : 'Usar mi GPS (solicitar permiso)',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: lat,
                        enabled: !saving,
                        decoration: const InputDecoration(
                          labelText:
                              'Latitud opcional, GPS o confirmada manualmente',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        validator: (v) {
                          if ((v ?? '').trim().isEmpty) {
                            return lon.text.trim().isEmpty
                                ? null
                                : 'Completa ambas coordenadas';
                          }
                          final n = double.tryParse(v!);
                          return n == null || !n.isFinite || n < -90 || n > 90
                              ? 'Latitud inválida'
                              : null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: lon,
                        enabled: !saving,
                        decoration: const InputDecoration(
                          labelText: 'Longitud opcional',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        validator: (v) {
                          if ((v ?? '').trim().isEmpty) {
                            return lat.text.trim().isEmpty
                                ? null
                                : 'Completa ambas coordenadas';
                          }
                          final n = double.tryParse(v!);
                          return n == null || !n.isFinite || n < -180 || n > 180
                              ? 'Longitud inválida'
                              : null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: delay,
                        enabled: !saving,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText:
                              'Demora estimada por ti (minutos, opcional)',
                        ),
                        validator: (v) {
                          if ((v ?? '').trim().isEmpty) return null;
                          final n = int.tryParse(v!);
                          return n == null || n < 0 || n > 240
                              ? 'Entre 0 y 240 minutos'
                              : null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: impact,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Nivel de afectación',
                        ),
                        items: const [
                          DropdownMenuItem(value: 'BAJA', child: Text('Baja')),
                          DropdownMenuItem(
                            value: 'MEDIA',
                            child: Text('Media'),
                          ),
                          DropdownMenuItem(value: 'ALTA', child: Text('Alta')),
                          DropdownMenuItem(
                            value: 'NO_INDICADA',
                            child: Text('No indicada'),
                          ),
                        ],
                        onChanged: saving
                            ? null
                            : (v) => update(() => impact = v!),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Reporte manual. No representa tráfico en vivo del proveedor ni cambia la ruta sin aprobación. Si falla la conexión, reintenta aquí: se conserva el identificador del evento.',
                      ),
                      if (error != null)
                        Text(
                          error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: saving ? null : () => Navigator.pop(dialog),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: saving
                    ? null
                    : () async {
                        if (!form.currentState!.validate()) return;
                        update(() {
                          saving = true;
                          error = null;
                        });
                        try {
                          final saved =
                              await ApiClient(context.read<AuthProvider>())
                                  .request(
                                    '/routes/${widget.routeId}/incidentes',
                                    method: 'POST',
                                    body: {
                                      'evento_id': event,
                                      'tipo': type,
                                      'descripcion': controller.text.trim(),
                                      'latitud': double.tryParse(lat.text),
                                      'longitud': double.tryParse(lon.text),
                                      'demora_min': int.tryParse(delay.text),
                                      'afectacion': impact,
                                      'ocurrido_en': occurred,
                                    },
                                  );
                          if (!mounted || !dialog.mounted) return;
                          setState(() {
                            if (!_incidents.any(
                              (i) => i['evento_id'] == saved['evento_id'],
                            )) {
                              _incidents.add(saved);
                            }
                          });
                          Navigator.pop(dialog);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Incidencia registrada.'),
                            ),
                          );
                        } catch (e) {
                          if (dialog.mounted) {
                            update(() {
                              error = e.toString().replaceFirst(
                                'Exception: ',
                                '',
                              );
                              saving = false;
                            });
                          }
                        }
                      },
                child: Text(saving ? 'Guardando…' : 'Registrar incidencia'),
              ),
            ],
          ),
        ),
      ),
    );
    controller.dispose();
    lat.dispose();
    lon.dispose();
    delay.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = _route;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recorrido de entrega'),
        actions: [
          IconButton(
            tooltip: 'Actualizar ruta',
            onPressed: widget.preview == null && !_busy ? _load : null,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _error != null && r == null
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
    final outside =
        r['fuera_zona'] == true ||
        stops.any(
          (s) =>
              s['latitud'] != null &&
              !OperationArea.contains(s['latitud'], s['longitud']),
        );
    final courier =
        !outside &&
        widget.preview == null &&
        context.watch<AuthProvider>().esRepartidor;
    final pending = stops
        .where((s) => s['estado_entrega'] != 'ENTREGADO')
        .toList();
    final points =
        (outside
                ? <dynamic>[]
                : ((r['geometria']?['coordinates'] as List?) ?? []))
            .map((p) => LatLng(_number(p[1]), _number(p[0])))
            .toList();
    final origin = outside || r['origen_latitud'] == null
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
        if (!outside && s['latitud'] != null && s['longitud'] != null)
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
                  s['estado_entrega'] == 'ENTREGADO'
                      ? '✓'
                      : '${s['secuencia']}',
                  style: TextStyle(
                    color: dark ? scheme.onPrimary : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
    ];
    for (final i in _incidents) {
      if (!outside && i['latitud'] != null && i['longitud'] != null) {
        markers.add(
          Marker(
            point: LatLng(_number(i['latitud']), _number(i['longitud'])),
            width: 44,
            height: 44,
            child: Tooltip(
              message: 'Reporte manual: ${i['tipo']} · ${i['descripcion']}',
              child: Icon(
                Icons.warning_amber_rounded,
                color: scheme.error,
                size: 36,
              ),
            ),
          ),
        );
      }
    }
    final basePoints =
        (outside
                ? <dynamic>[]
                : ((r['base_geometria']?['coordinates'] as List?) ?? []))
            .map((p) => LatLng(_number(p[1]), _number(p[0])))
            .toList();
    final mapPoints = [
      ...points,
      ...basePoints,
      ...markers.map((m) => m.point),
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (outside)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'El recorrido sale de la zona operativa de Huancayo. Se conserva para consulta y su operación está deshabilitada.',
              ),
            ),
          ),
        if (_error != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'No se pudo sincronizar: $_error. Se muestran los últimos datos recibidos; reintentamos cada 10 s.',
              ),
            ),
          ),
        if (widget.preview != null)
          const Text('Vista previa de la propuesta')
        else
          Text(
            'Planificación versión ${r['version'] ?? 1} · recibida: '
            '${r['version_recibida'] ?? 0}',
          ),
        if (courier && (r['version'] ?? 1) != (r['version_recibida'] ?? 1))
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hay una nueva versión. Revisa el mapa y confirma su recepción estando detenido antes de continuar.',
                  ),
                  FilledButton(
                    onPressed: _busy
                        ? null
                        : () async {
                            setState(() => _busy = true);
                            try {
                              final data =
                                  await ApiClient(
                                    context.read<AuthProvider>(),
                                  ).request(
                                    '/operations/routes/${widget.routeId}/ack',
                                    method: 'POST',
                                    body: {'version': r['version']},
                                  );
                              if (mounted) {
                                setState(
                                  () => _route = data as Map<String, dynamic>,
                                );
                              }
                              await _load();
                            } catch (e) {
                              if (mounted) setState(() => _error = '$e');
                            } finally {
                              if (mounted) setState(() => _busy = false);
                            }
                          },
                    child: const Text('Confirmar recepción de nueva ruta'),
                  ),
                ],
              ),
            ),
          ),
        Text(
          '${r['repartidor_nombre']} · ${r['vehiculo_placa']}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        if (courier)
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              if (r['estado'] == 'PLANIFICADA')
                FilledButton.icon(
                  onPressed: _busy
                      ? null
                      : () => _operate(
                          'iniciar',
                          '¿Iniciar este recorrido? Se registrará la hora real de inicio.',
                        ),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Iniciar recorrido'),
                ),
              if (r['estado'] == 'EN_CURSO')
                OutlinedButton.icon(
                  onPressed: _busy ? null : _reportIncident,
                  icon: const Icon(Icons.report_outlined),
                  label: const Text('Reportar incidencia de tráfico'),
                ),
            ],
          ),
        if (widget.preview == null &&
            context.watch<AuthProvider>().esAdministrador &&
            r['estado'] == 'PLANIFICADA')
          OutlinedButton.icon(
            onPressed: _busy ? null : () => _operate(
              'cancelar',
              '¿Cancelar esta ruta planificada? Se conserva el historial y sus pedidos vuelven a pendientes.',
            ),
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('Cancelar ruta planificada'),
          ),
        if (_busy) const LinearProgressIndicator(),
        if (r['iniciado_en'] != null)
          Text('Inicio real: ${friendlyDate(r['iniciado_en'])}'),
        if (r['finalizado_en'] != null)
          Text('Finalización real: ${friendlyDate(r['finalizado_en'])}'),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            StatusBadge('${r['estado']}'),
            Chip(
              avatar: const Icon(Icons.route_outlined),
              label: Text(
                '${r['distancia_km'] == null ? '—' : _number(r['distancia_km']).toStringAsFixed(2)} km',
              ),
            ),
            Chip(
              avatar: const Icon(Icons.schedule_outlined),
              label: Text(
                '${r['tiempo_min'] == null ? '—' : _number(r['tiempo_min']).toStringAsFixed(1)} min estimados',
              ),
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
              ? (r['origen_latitud'] == null ? 'Este registro no tiene origen guardado.' : 'Punto de partida disponible en los datos de la ruta.')
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
          OperationalRouteMap(
            key: ValueKey(widget.routeId),
            points: points,
            basePoints: basePoints,
            markers: markers,
            baseLabel: r['base_legend'] as String?,
            routeLabel: r['route_legend'] as String? ??
                (widget.preview == null && _number(r['version']) > 1
                    ? "Ruta optimizada activa · v${r['version']}"
                    : null),
            optimized: widget.preview == null && _number(r['version']) > 1,
          ),
        if (points.isEmpty && !outside)
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
          'Recorrido vial estimado; no es seguimiento GPS ni tráfico en vivo. Los avisos del mapa son reportes manuales. En comparación, el rojo identifica el recorrido reportado y el marcador indica la ubicación informada. La línea roja no delimita la extensión de la congestión. El mapa base requiere internet.',
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
                      '${s['direccion']}\nReferencia: ${s['punto_referencia'] ?? 'Sin referencia'}\n${s['peso_kg']} kg · ${s['tipo_producto'] ?? 'Sin tipo registrado'} · ${s['prioridad'] ?? 'Sin prioridad registrada'}\nEstado: ${s['estado_entrega']}\nVentana: ${friendlyDate(s['ventana_inicio'])} → ${friendlyDate(s['ventana_fin'])}',
                    ),
                    if (s['eta'] != null)
                      Text('Entrega prevista: ${friendlyDate(s['eta'])}'),
                    if (s['entregado_en'] != null)
                      Text(
                        'Entrega confirmada: ${friendlyDate(s['entregado_en'])}',
                      ),
                    if (courier &&
                        r['estado'] == 'EN_CURSO' &&
                        (r['version'] ?? 1) == (r['version_recibida'] ?? 1) &&
                        pending.isNotEmpty &&
                        pending.first['pedido_id'] == s['pedido_id'])
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: FilledButton.icon(
                          onPressed: _busy
                              ? null
                              : () => _operate(
                                  'entregas/${s['pedido_id']}/confirmar',
                                  '¿Confirmar la entrega a ${s['cliente']}? Se registrará la hora real. La última entrega finalizará la ruta.',
                                ),
                          icon: const Icon(Icons.task_alt),
                          label: const Text('Confirmar entrega'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        if (widget.preview == null && !outside)
          ReplanningPanel(
            route: r,
            incidents: _incidents,
            revisions: _revisions,
            onUpdated: _load,
          ),
        if (_incidents.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            'Incidencias registradas',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          for (final item in _incidents)
            Card(
              child: ListTile(
                title: Text(
                  '${item['tipo']} · ${friendlyDate(item['ocurrido_en'])}',
                ),
                subtitle: Text(
                  '${item['descripcion']}\nReporte manual · Demora: ${item['demora_min'] ?? 'No indicada'} min · ${item['resuelto_en'] == null ? 'Abierta' : 'Resuelta: ${item['resolucion']}'}',
                ),
              ),
            ),
        ],
      ],
    );
  }
}
