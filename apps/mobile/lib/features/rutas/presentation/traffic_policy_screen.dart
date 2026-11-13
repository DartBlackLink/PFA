import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_client.dart';
import '../../auth/presentation/providers/auth_provider.dart';

class TrafficPolicyScreen extends StatefulWidget {
  const TrafficPolicyScreen({super.key});
  @override
  State<TrafficPolicyScreen> createState() => _TrafficPolicyScreenState();
}

class _TrafficPolicyScreenState extends State<TrafficPolicyScreen> {
  Map<String, dynamic>? _policy;
  List<dynamic> _references = [];
  String? _error;
  bool _busy = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      final api = ApiClient(context.read<AuthProvider>());
      final responses = await Future.wait([
        api.request('/operations/traffic'),
        api.request('/operations/traffic/references'),
      ]);
      final data = responses[0], references = responses[1];
      if (mounted) {
        setState(() {
          _policy = data as Map<String, dynamic>;
          _references = references as List;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  Future<void> _save(List<dynamic> rules) async {
    setState(() => _busy = true);
    try {
      final data = await ApiClient(context.read<AuthProvider>()).request(
        '/operations/traffic',
        method: 'PUT',
        body: {'revision': _policy!['revision'], 'reglas': rules},
      );
      if (mounted) {
        setState(() {
          _policy = data as Map<String, dynamic>;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _edit({int? index, Map<String, dynamic>? reference}) async {
    final rules = List<dynamic>.from(_policy!['reglas']);
    final previous = index == null
        ? (reference == null
              ? <String, dynamic>{}
              : {
                  ...Map<String, dynamic>.from(
                    reference['envolvente_configuracion'],
                  ),
                  'nombre': 'El Tambo 08–09 — referencia histórica',
                  'inicio_min': reference['inicio_min'],
                  'fin_min': reference['fin_min'],
                  'dias': <int>[],
                  'fundamento':
                      'Franja histórica local, estudio ${reference['estudio_anio']}, ${reference['fuente']}. Factor manual por calibrar; no tráfico en vivo.',
                })
        : Map<String, dynamic>.from(rules[index]);
    final names = [
      'nombre',
      'sur',
      'norte',
      'oeste',
      'este',
      'inicio_min',
      'fin_min',
      'factor',
      'fundamento',
    ];
    final labels = [
      'Nombre de zona',
      'Latitud sur',
      'Latitud norte',
      'Longitud oeste',
      'Longitud este',
      'Inicio (minuto del día: 0–1439)',
      'Fin (minuto del día: 1–1440)',
      'Factor estimado de tiempo (1–5)',
      'Fundamento y procedencia de la aproximación',
    ];
    final controls = {
      for (final name in names)
        name: TextEditingController(text: '${previous[name] ?? ''}'),
    };
    final days = Set<int>.from(previous['dias'] ?? <int>[]);
    final form = GlobalKey<FormState>();
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialog) => StatefulBuilder(
        builder: (dialog, update) => AlertDialog(
          title: Text(
            index == null ? 'Nueva franja estimada' : 'Editar franja estimada',
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Form(
                key: form,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'America/Lima · Lunes=0. Horas en minutos: 08:00=480; 09:00=540. Para cruzar medianoche usa dos reglas. Los factores son supuestos manuales; la referencia histórica no acredita tráfico actual.',
                    ),
                    const SizedBox(height: 12),
                    for (var n = 0; n < names.length; n++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TextFormField(
                          controller: controls[names[n]],
                          maxLength: n == 0
                              ? 80
                              : n == 8
                              ? 400
                              : null,
                          minLines: n == 8 ? 2 : 1,
                          maxLines: n == 8 ? 4 : 1,
                          decoration: InputDecoration(labelText: labels[n]),
                          keyboardType: n == 0 || n == 8
                              ? TextInputType.text
                              : const TextInputType.numberWithOptions(
                                  decimal: true,
                                  signed: true,
                                ),
                          validator: (v) {
                            if (n == 0 || n == 8) {
                              return (v?.trim().length ?? 0) < (n == 0 ? 3 : 10)
                                  ? 'Completa este dato'
                                  : null;
                            }
                            final number = double.tryParse(v ?? '');
                            if (number == null || !number.isFinite) {
                              return 'Indica un número válido';
                            }
                            if ((n == 5 || n == 6) &&
                                int.tryParse(v ?? '') == null) {
                              return 'Indica minutos enteros';
                            }
                            return null;
                          },
                        ),
                      ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (var day = 0; day < 7; day++)
                          FilterChip(
                            label: Text(
                              const [
                                'Lun',
                                'Mar',
                                'Mié',
                                'Jue',
                                'Vie',
                                'Sáb',
                                'Dom',
                              ][day],
                            ),
                            selected: days.contains(day),
                            onSelected: (v) => update(() {
                              if (v) {
                                days.add(day);
                              } else {
                                days.remove(day);
                              }
                            }),
                          ),
                      ],
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
              onPressed: days.isEmpty
                  ? null
                  : () {
                      if (form.currentState!.validate()) {
                        Navigator.pop(dialog, true);
                      }
                    },
              child: const Text('Guardar franja'),
            ),
          ],
        ),
      ),
    );
    if (accepted == true && mounted) {
      final rule = <String, dynamic>{'dias': days.toList()..sort()};
      for (final name in names) {
        rule[name] = name == 'nombre' || name == 'fundamento'
            ? controls[name]!.text.trim()
            : name == 'inicio_min' || name == 'fin_min'
            ? int.parse(controls[name]!.text)
            : double.parse(controls[name]!.text);
      }
      if (index == null) {
        rules.add(rule);
      } else {
        rules[index] = rule;
      }
      await _save(rules);
    }
    for (final controller in controls.values) {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Estimación de tráfico por zonas'),
      actions: [
        IconButton(
          tooltip: 'Recargar configuración',
          onPressed: _busy ? null : _load,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Aproximaciones manuales por zona y horario',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Text(
          'No hay una fuente de tráfico en vivo conectada. Los factores se aplican a trayectos con origen o destino dentro del rectángulo configurado. No representan cada calle. Sin franjas se usa la estimación base de OSRM. Las reglas superpuestas usan el mayor factor, sin multiplicarlas.',
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        if (_busy) const LinearProgressIndicator(),
        if (_policy != null) ...[
          for (final raw in _references)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Referencia local: ${raw['titulo']}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '08:00–09:00 · estudio ${raw['estudio_anio']} · publicado ${raw['publicacion_anio']}\n${raw['alcance']}\n${raw['fuente']}\n${raw['nota_factor']}',
                    ),
                    OutlinedButton.icon(
                      onPressed: _busy
                          ? null
                          : () => _edit(
                              reference: Map<String, dynamic>.from(raw),
                            ),
                      icon: const Icon(Icons.fact_check_outlined),
                      label: const Text('Configurar desde referencia local'),
                    ),
                  ],
                ),
              ),
            ),
          Text('Revisión ${_policy!['revision']} · America/Lima'),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: _busy || (_policy!['reglas'] as List).length >= 40
                  ? null
                  : () => _edit(),
              icon: const Icon(Icons.add),
              label: const Text('Agregar franja'),
            ),
          ),
          for (var i = 0; i < (_policy!['reglas'] as List).length; i++)
            Card(
              child: ListTile(
                title: Text(
                  '${_policy!['reglas'][i]['nombre']} · factor ${_policy!['reglas'][i]['factor']}',
                ),
                subtitle: Text(
                  'Días ${_policy!['reglas'][i]['dias']} · minutos ${_policy!['reglas'][i]['inicio_min']}–${_policy!['reglas'][i]['fin_min']}\n${_policy!['reglas'][i]['fundamento']}',
                ),
                onTap: _busy ? null : () => _edit(index: i),
                trailing: IconButton(
                  tooltip: 'Retirar franja de la configuración vigente',
                  onPressed: _busy
                      ? null
                      : () async {
                          final accepted = await showDialog<bool>(
                            context: context,
                            builder: (dialog) => AlertDialog(
                              title: const Text('Retirar franja'),
                              content: const Text(
                                'Las propuestas anteriores conservan el perfil utilizado. Esta franja dejará de afectar nuevos cálculos.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(dialog, false),
                                  child: const Text('Cancelar'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(dialog, true),
                                  child: const Text('Retirar'),
                                ),
                              ],
                            ),
                          );
                          if (accepted == true && mounted) {
                            final rules = List<dynamic>.from(
                              _policy!['reglas'],
                            );
                            rules.removeAt(i);
                            await _save(rules);
                          }
                        },
                  icon: const Icon(Icons.delete_outline),
                ),
              ),
            ),
        ],
      ],
    ),
  );
}
