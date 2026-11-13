import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_client.dart';
import '../../../core/widgets/record_widgets.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import 'route_detail_screen.dart';

String replanningComparisonSummary(Map<String, dynamic> comparison) {
  final minutes = comparison['diferencia_min'];
  final distance = comparison['diferencia_km'];
  if (minutes is! num || distance is! num ||
      !minutes.isFinite || !distance.isFinite) {
    return 'No hay una estimación comparable de la ruta vigente.';
  }
  final timeChange = (minutes * 100).round();
  final distanceChange = (distance * 100).round();
  if (timeChange == 0 && distanceChange == 0) {
    return 'Sin mejora estimada: mismo tiempo y misma distancia.';
  }
  final timeLabel = timeChange < 0
      ? 'Menor tiempo estimado'
      : timeChange > 0
      ? 'Mayor tiempo estimado'
      : 'Mismo tiempo estimado';
  final distanceLabel = distanceChange < 0
      ? 'menor distancia'
      : distanceChange > 0
      ? 'mayor distancia'
      : 'misma distancia';
  return '$timeLabel y $distanceLabel.';
}

class ReplanningPanel extends StatefulWidget {
  const ReplanningPanel({
    super.key,
    required this.route,
    required this.incidents,
    required this.revisions,
    required this.onUpdated,
  });
  final Map<String, dynamic> route;
  final List<dynamic> incidents, revisions;
  final Future<void> Function() onUpdated;
  @override
  State<ReplanningPanel> createState() => _ReplanningPanelState();
}

class _ReplanningPanelState extends State<ReplanningPanel> {
  bool _busy = false;
  String? _error;
  Map<String, dynamic>? _proposal;
  Future<void> _calculate(Map<String, dynamic> incident) async {
    final lat = TextEditingController(text: '${incident['latitud'] ?? ''}');
    final lon = TextEditingController(text: '${incident['longitud'] ?? ''}');
    final reason = TextEditingController(
      text:
          'Evaluar alternativa por ${incident['tipo']}: ${incident['descripcion']}',
    );
    bool confirmedLocation = false;
    final form = GlobalKey<FormState>();
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialog) => StatefulBuilder(
        builder: (dialog, update) => AlertDialog(
          title: const Text('Evaluar reoptimización'),
          content: SizedBox(
            width: 460,
            child: SingleChildScrollView(
              child: Form(
                key: form,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Obtén la posición actual del conductor detenido. La ubicación del reporte puede haber cambiado. No uses tu GPS de administrador como posición del vehículo.',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: lat,
                      decoration: const InputDecoration(
                        labelText: 'Latitud actual confirmada',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      validator: (v) {
                        final n = double.tryParse(v ?? '');
                        return n == null || !n.isFinite || n < -90 || n > 90
                            ? 'Latitud entre −90 y 90'
                            : null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: lon,
                      decoration: const InputDecoration(
                        labelText: 'Longitud actual confirmada',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      validator: (v) {
                        final n = double.tryParse(v ?? '');
                        return n == null || !n.isFinite || n < -180 || n > 180
                            ? 'Longitud entre −180 y 180'
                            : null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: reason,
                      maxLength: 500,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Motivo del cambio',
                      ),
                      validator: (v) => (v?.trim().length ?? 0) < 10
                          ? 'Explica el motivo (mínimo 10 caracteres)'
                          : null,
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'El conductor confirmó ahora esta posición; no es una ubicación supuesta.',
                      ),
                      value: confirmedLocation,
                      onChanged: (v) =>
                          update(() => confirmedLocation = v ?? false),
                    ),
                    const Text(
                      'Se calcula una propuesta. La ruta vigente continúa hasta la aprobación administrativa.',
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialog, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: !confirmedLocation
                  ? null
                  : () {
                      if (form.currentState!.validate()) {
                        Navigator.pop(dialog, true);
                      }
                    },
              child: const Text('Calcular alternativa'),
            ),
          ],
        ),
      ),
    );
    if (accepted == true && mounted) {
      setState(() {
        _busy = true;
        _error = null;
      });
      try {
        final data =
            await ApiClient(
              context.read<AuthProvider>(),
              requestTimeout: const Duration(seconds: 35),
            ).request(
              '/operations/routes/${widget.route['ruta_id']}/replan',
              method: 'POST',
              body: {
                'evento_id': incident['evento_id'],
                'version': widget.route['version'] ?? 1,
                'latitud': double.parse(lat.text),
                'longitud': double.parse(lon.text),
                'ubicacion_en': DateTime.now().toUtc().toIso8601String(),
                'motivo': reason.text.trim(),
              },
            );
        if (mounted) setState(() => _proposal = data as Map<String, dynamic>);
        await widget.onUpdated();
      } catch (e) {
        if (mounted) setState(() => _error = '$e');
      } finally {
        if (mounted) setState(() => _busy = false);
      }
    }
    lat.dispose();
    lon.dispose();
    reason.dispose();
  }

  Future<void> _decide(Map<String, dynamic> item, String action) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(
          action == 'confirm' ? 'Aprobar nueva versión' : 'Rechazar propuesta',
        ),
        content: Text(
          action == 'confirm'
              ? 'Se actualizarán únicamente las entregas pendientes. El repartidor deberá confirmar la recepción de esta versión antes de continuar.'
              : 'La ruta actual seguirá vigente y la propuesta quedará en el historial.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: const Text('Volver'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: const Text('Confirmar decisión'),
          ),
        ],
      ),
    );
    if (accepted != true || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ApiClient(context.read<AuthProvider>()).request(
        '/operations/revisions/${item['revision_id']}/$action',
        method: 'POST',
      );
      if (mounted) setState(() => _proposal = null);
      await widget.onUpdated();
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resolve(Map<String, dynamic> incident) async {
    final text = TextEditingController();
    final form = GlobalKey<FormState>();
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('Gestionar incidencia'),
        content: Form(
          key: form,
          child: TextFormField(
            controller: text,
            maxLength: 1000,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Gestión realizada y motivo de resolución',
            ),
            validator: (v) => (v?.trim().length ?? 0) < 10
                ? 'Describe la gestión con al menos 10 caracteres'
                : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (form.currentState!.validate()) Navigator.pop(dialog, true);
            },
            child: const Text('Guardar resolución'),
          ),
        ],
      ),
    );
    if (accepted == true && mounted) {
      setState(() => _busy = true);
      try {
        await ApiClient(context.read<AuthProvider>()).request(
          '/operations/incidents/${incident['evento_id']}/resolve',
          method: 'POST',
          body: {'resolucion': text.text.trim()},
        );
        await widget.onUpdated();
      } catch (e) {
        if (mounted) setState(() => _error = '$e');
      } finally {
        if (mounted) setState(() => _busy = false);
      }
    }
    text.dispose();
  }

  void _map(Map<String, dynamic> item) {
    final p = item['propuesta'] as Map<String, dynamic>;
    final stops = (p['entregas'] as List).map((d) {
      final original = (widget.route['entregas'] as List).firstWhere(
        (s) => s['pedido_id'] == d['pedido_id'],
      );
      return {
        ...Map<String, dynamic>.from(original),
        ...Map<String, dynamic>.from(d),
      };
    }).toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RouteDetailScreen(
          routeId: 'propuesta-${item['revision_id']}',
          preview: {
            ...widget.route,
            ...p,
            'entregas': stops,
            'estado': 'PROPUESTA',
            'base_geometria': item['anterior']?['geometria'],
            'base_legend': item['estado'] == 'PROPUESTA'
                ? "Ruta vigente reportada · v${item['version_base']}"
                : "Ruta anterior reportada · v${item['version_base']}",
            'route_legend':
                "Alternativa · v${(item['version_base'] as num) + 1} · ${item['estado']}",
            'incident_markers': widget.incidents.where((incident) {
              final at = DateTime.tryParse('${incident['ocurrido_en']}');
              final cutoff = DateTime.tryParse('${item['creado_en']}');
              return at != null && cutoff != null && !at.isAfter(cutoff);
            }).toList(),
          },
        ),
      ),
    );
  }

  String _n(dynamic value) => value == null
      ? 'No disponible'
      : double.parse('$value').toStringAsFixed(2);
  @override
  Widget build(BuildContext context) {
    final admin = !context.watch<AuthProvider>().esRepartidor;
    final proposed = _proposal;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_busy) const LinearProgressIndicator(),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        if (admin)
          for (final i in widget.incidents.where(
            (i) => i['resuelto_en'] == null,
          ))
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Incidencia abierta: ${i['tipo']}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${i['descripcion']}\nDemora reportada: ${i['demora_min'] ?? 'No indicada'} min · ${i['afectacion']}',
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        if (widget.route['estado'] == 'EN_CURSO')
                          FilledButton.icon(
                            onPressed: _busy
                                ? null
                                : () =>
                                      _calculate(Map<String, dynamic>.from(i)),
                            icon: const Icon(Icons.alt_route),
                            label: const Text('Evaluar reoptimización'),
                          ),
                        OutlinedButton(
                          onPressed: _busy
                              ? null
                              : () => _resolve(Map<String, dynamic>.from(i)),
                          child: const Text('Gestionar incidencia'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        if (proposed != null) _proposalCard(proposed),
        if (widget.revisions.isNotEmpty)
          Text(
            'Historial de planificación',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        for (final raw in widget.revisions)
          if (proposed == null || raw['revision_id'] != proposed['revision_id'])
            _proposalCard(Map<String, dynamic>.from(raw)),
      ],
    );
  }

  Widget _proposalCard(Map<String, dynamic> item) {
    final c = item['propuesta']['comparacion'];
    final admin = !context.read<AuthProvider>().esRepartidor;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Versión ${item['version_base']} → ${(item['version_base'] as num) + 1} · ${item['estado']}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text('${item['motivo']}'),
            Text(
              "Pendientes: ${(item['propuesta']['entregas'] as List?)?.length ?? 0} · "
              "Demora manual: ${_n(item['propuesta']['demora_manual_min'])} min",
            ),
            if (item['estado'] == 'PROPUESTA')
              Text(
                'Vence: ${friendlyDate(item['vence_en'])} · hora Perú. Si transcurre el plazo, calcula otra propuesta.',
              ),
            Text(
              'Pendientes: vigente ${_n(c['vigente_km'])} km / ${_n(c['vigente_min'])} min; alternativa ${_n(c['alternativa_km'])} km / ${_n(c['alternativa_min'])} min.',
            ),
            Text(
              'Diferencia: ${_n(c['diferencia_km'])} km · ${_n(c['diferencia_min'])} min.\n${c['ventanas_alternativa']}\n${item['propuesta']['advertencia']}',
            ),
            Text(replanningComparisonSummary(Map<String, dynamic>.from(c))),
            if (item['estado'] == 'APROBADA')
              Text(
                item['recibido_en'] == null
                    ? 'Recepción del repartidor pendiente'
                    : 'Recepción confirmada: ${friendlyDate(item['recibido_en'])} · hora Perú',
              ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _map(item),
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Comparar en mapa'),
                ),
                if (admin && item['estado'] == 'PROPUESTA') ...[
                  FilledButton(
                    onPressed: _busy ? null : () => _decide(item, 'confirm'),
                    child: const Text('Aprobar y enviar ruta optimizada'),
                  ),
                  TextButton(
                    onPressed: _busy ? null : () => _decide(item, 'reject'),
                    child: const Text('Rechazar propuesta'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
