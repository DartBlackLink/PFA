import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/network/api_client.dart';
import '../../core/download/download.dart';
import '../auth/presentation/providers/auth_provider.dart';

String indicatorText(dynamic value, String unit) {
  final n = num.tryParse(value?.toString() ?? '');
  return n == null || !n.isFinite
      ? 'No disponible'
      : '${n.toStringAsFixed(2)} $unit';
}

class SustainabilityOverview extends StatefulWidget {
  const SustainabilityOverview({super.key, this.api});
  final ApiClient? api;
  @override
  State<SustainabilityOverview> createState() => _SustainabilityOverviewState();
}

class _SustainabilityOverviewState extends State<SustainabilityOverview> {
  Map<String, dynamic>? _data;
  String? _error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await (widget.api ?? ApiClient(context.read<AuthProvider>()))
          .request('/reports/summary');
      if (mounted) {
        setState(() {
          _data = Map<String, dynamic>.from(data);
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Indicadores operativos y ambientales',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                tooltip: 'Actualizar indicadores',
                onPressed: _load,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          if (_error != null)
            Text(_error!)
          else if (_data == null)
            const LinearProgressIndicator()
          else ...[
            Text(
              '${_data!['rutas']} rutas vigentes y finalizadas. Se excluyen las canceladas.',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 24,
              runSpacing: 12,
              children: [
                for (final m in [
                  ('distancia_km', 'Distancia', 'km'),
                  ('combustible_l', 'Combustible estimado', 'L'),
                  ('co2_kg', 'CO₂ estimado', 'kg'),
                ])
                  SizedBox(
                    width: 220,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.$2),
                        Text(
                          indicatorText(_data![m.$1]['valor'], m.$3),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (_data![m.$1]['rutas_sin_dato'] > 0)
                          Text(
                            '${_data![m.$1]['rutas_sin_dato']} rutas sin dato; total no disponible.',
                          ),
                      ],
                    ),
                  ),
                SizedBox(
                  width: 240,
                  child: Text(
                    'Ventanas previstas: ${indicatorText(_data!['ventanas']['cumplimiento_previsto_pct'], '%')}\nVentanas reales: ${indicatorText(_data!['ventanas']['cumplimiento_real_pct'], '%')}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Última versión por ruta; tras reoptimizar, métricas del tramo pendiente, no acumulado físico. Ventanas previstas por ETA + atención; reales por hora de entrega. Sin ahorro acreditado.',
            ),
          ],
        ],
      ),
    ),
  );
}

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key, this.api, this.download});
  final ApiClient? api;
  final Future<void> Function(Uint8List, String)? download;
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<Map<String, dynamic>> _routes = [];
  Map<String, dynamic>? _report;
  String? _selected, _error;
  int _skip = 0, _total = 0, _request = 0;
  bool _loading = true, _downloading = false;
  ApiClient get _api => widget.api ?? ApiClient(context.read<AuthProvider>());
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _selected = null;
      _report = null;
    });
    _request++;
    try {
      final data = await _api.request('/reports/routes?skip=$_skip&limit=25');
      if (mounted) {
        setState(() {
          _routes = (data['items'] as List).cast<Map<String, dynamic>>();
          _total = data['total'];
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _select(String? id) async {
    final request = ++_request;
    setState(() {
      _selected = id;
      _report = null;
      _error = null;
    });
    if (id == null) return;
    try {
      final data = await _api.request('/reports/routes/$id');
      if (mounted && request == _request) {
        setState(() => _report = Map<String, dynamic>.from(data));
      }
    } catch (e) {
      if (mounted && request == _request) setState(() => _error = e.toString());
    }
  }

  Future<void> _pdf() async {
    final id = _selected;
    if (id == null || _report == null || _downloading) return;
    final version = _report!['version'];
    setState(() {
      _downloading = true;
      _error = null;
    });
    try {
      final bytes = await _api.request(
        '/reports/routes/$id/pdf',
        binary: true,
      ) as Uint8List;
      await (widget.download ?? savePdf)(
        bytes,
        'ecologistica-$id-v$version.pdf',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF generado. Revisa las descargas del navegador.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Reportes de sostenibilidad',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const Text(
          'Selecciona una ruta confirmada para consultar sus indicadores y descargar su evidencia. No incluye propuestas sin confirmar ni rutas canceladas.',
        ),
        const SizedBox(height: 16),
        SustainabilityOverview(api: widget.api),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_loading)
                  const LinearProgressIndicator()
                else if (_routes.isEmpty)
                  const Text('No hay rutas confirmadas en esta página.')
                else
                  DropdownButtonFormField<String>(
                    key: ValueKey('route-page-$_skip-$_total'),
                    initialValue: _selected,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Planificación / ruta',
                    ),
                    items: _routes
                        .map(
                          (r) => DropdownMenuItem(
                            value: '${r['ruta_id']}',
                            child: Text(
                              '${r['estado']} · v${r['version']} · ${r['ruta_id']}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: _downloading ? null : _select,
                  ),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('Página ${_skip ~/ 25 + 1} · $_total rutas'),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Página anterior de rutas',
                          onPressed: _skip > 0 && !_loading && !_downloading
                              ? () {
                                  _skip -= 25;
                                  _load();
                                }
                              : null,
                          icon: const Icon(Icons.chevron_left),
                        ),
                        IconButton(
                          tooltip: 'Página siguiente de rutas',
                          onPressed:
                              _skip + 25 < _total && !_loading && !_downloading
                              ? () {
                                  _skip += 25;
                                  _load();
                                }
                              : null,
                          icon: const Icon(Icons.chevron_right),
                        ),
                        IconButton(
                          tooltip: 'Actualizar rutas de reportes',
                          onPressed: _loading || _downloading ? null : _load,
                          icon: const Icon(Icons.refresh),
                        ),
                      ],
                    ),
                  ],
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                if (_selected != null && _report == null && _error == null)
                  const LinearProgressIndicator(),
                if (_report != null) ...[
                  const Divider(),
                  Text(
                    'Ruta ${_report!['ruta_id']} · versión ${_report!['version']}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  for (final m in [
                    ('distancia_km', 'Distancia', 'km'),
                    ('tiempo_min', 'Tiempo de viaje estimado', 'min'),
                    ('combustible_l', 'Combustible estimado', 'L'),
                    ('co2_kg', 'CO₂ estimado', 'kg'),
                  ])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '${m.$2}: ${indicatorText(_report![m.$1], m.$3)}',
                      ),
                    ),
                  Text(
                    'Ventanas previstas: ${indicatorText(_report!['ventanas']['cumplimiento_previsto_pct'], '%')}\nVentanas reales: ${indicatorText(_report!['ventanas']['cumplimiento_real_pct'], '%')}',
                  ),
                  const SizedBox(height: 12),
                  if (_report!['equivalencia'] == null)
                    const Text(
                      'Equivalencia ambiental: no disponible. Configura un factor documentado; no se inventan resultados.',
                    )
                  else ...[
                    Text(
                      'Equivalencia: ${indicatorText(_report!['equivalencia']['valor'], _report!['equivalencia']['unidad'])}',
                    ),
                    Text(
                      'Factor: ${_report!['equivalencia']['factor_kg_por_unidad']} kg CO₂/unidad. Fuente: ${_report!['equivalencia']['fuente']}',
                    ),
                    Text(_report!['equivalencia']['advertencia']),
                  ],
                  const SizedBox(height: 16),
                  Text(_report!['metodologia']),
                ],
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _report == null || _downloading ? null : _pdf,
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: Text(
                    _downloading ? 'Generando PDF…' : 'Descargar PDF',
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _downloading
                      ? null
                      : () async {
                          final saved = await showDialog<bool>(
                            context: context,
                            builder: (_) => EnvironmentalDialog(api: _api),
                          );
                          if (saved == true && mounted && _selected != null) {
                            _select(_selected);
                          }
                        },
                  icon: const Icon(Icons.tune),
                  label: const Text('Configurar equivalencia ambiental'),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class EnvironmentalDialog extends StatefulWidget {
  const EnvironmentalDialog({super.key, required this.api});
  final ApiClient api;
  @override
  State<EnvironmentalDialog> createState() => _EnvironmentalDialogState();
}

class _EnvironmentalDialogState extends State<EnvironmentalDialog> {
  final _form = GlobalKey<FormState>();
  final _factor = TextEditingController(),
      _unit = TextEditingController(),
      _source = TextEditingController();
  bool _loading = true, _saving = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await widget.api.request('/reports/environment');
      if (mounted) {
        _factor.text = data['factor_kg_por_unidad']?.toString() ?? '';
        _unit.text = data['unidad'] ?? '';
        _source.text = data['fuente'] ?? '';
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save({bool clear = false}) async {
    if (!clear && !_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.api.request(
        '/reports/environment',
        method: 'PUT',
        body: clear
            ? {}
            : {
                'factor_kg_por_unidad': double.parse(
                  _factor.text.replaceAll(',', '.'),
                ),
                'unidad': _unit.text.trim(),
                'fuente': _source.text.trim(),
              },
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _factor.dispose();
    _unit.dispose();
    _source.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Equivalencia ambiental'),
    content: SizedBox(
      width: 520,
      child: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'División: kg CO₂ estimados ÷ kg CO₂ por unidad. Debes documentar el factor y su período. Esta equivalencia no certifica una compensación real.',
              ),
              const SizedBox(height: 16),
              if (_loading) const LinearProgressIndicator(),
              if (_error != null)
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              TextFormField(
                controller: _factor,
                enabled: !_loading && !_saving,
                decoration: const InputDecoration(
                  labelText: 'Factor (kg CO₂ por unidad)',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) {
                  final n = double.tryParse((v ?? '').replaceAll(',', '.'));
                  return n == null || !n.isFinite || n <= 0 || n > 100000000
                      ? 'Indica un factor positivo, máximo 100000000'
                      : null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _unit,
                enabled: !_loading && !_saving,
                maxLength: 80,
                decoration: const InputDecoration(
                  labelText: 'Unidad y período de equivalencia',
                ),
                validator: (v) =>
                    (v?.trim().length ?? 0) < 2 ? 'Indica la unidad' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _source,
                enabled: !_loading && !_saving,
                maxLength: 500,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Fuente y justificación del factor',
                ),
                validator: (v) => (v?.trim().length ?? 0) < 10
                    ? 'Documenta la procedencia, mínimo 10 caracteres'
                    : null,
              ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      TextButton(
        onPressed: _loading || _saving ? null : () => _save(clear: true),
        child: const Text('Desactivar equivalencia'),
      ),
      FilledButton(
        onPressed: _loading || _saving ? null : _save,
        child: const Text('Guardar factor'),
      ),
    ],
  );
}
