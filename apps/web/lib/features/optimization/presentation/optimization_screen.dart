import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/theme_controller.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../rutas/presentation/route_detail_screen.dart';
import '../data/optimization_gateway.dart';

String optimizationLimaDate(dynamic value) {
  final parsed = DateTime.tryParse(value?.toString() ?? '');
  if (parsed == null) return 'Sin fecha';
  final date = parsed.toUtc().subtract(const Duration(hours: 5));
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(date.day)}/${two(date.month)}/${date.year} ${two(date.hour)}:${two(date.minute)}';
}

class OptimizationScreen extends StatefulWidget {
  const OptimizationScreen({super.key, this.gateway});
  final OptimizationGateway? gateway;
  @override
  State<OptimizationScreen> createState() => _OptimizationScreenState();
}

class _OptimizationScreenState extends State<OptimizationScreen> {
  final _form = GlobalKey<FormState>();
  final _selected = <String>{};
  final _teams = <Map<String, String>>[];
  final _fields = <String, TextEditingController>{
    for (final item in {
      'service': 5,
      'work': 480,
      'breakAfter': 240,
      'break': 30,
      'seed': 42,
      'population': 24,
      'generations': 40,
    }.entries)
      item.key: TextEditingController(text: '${item.value}'),
  };
  late OptimizationGateway _api;
  Records _orders = [], _drivers = [], _vehicles = [], _history = [];
  Map<String, dynamic>? _plan;
  String? _driver, _vehicle, _error;
  String _search = '';
  bool _loading = true, _working = false, _return = true;
  late DateTime _start;

  @override
  void initState() {
    super.initState();
    final lima = DateTime.now().toUtc().subtract(const Duration(hours: 5));
    _start = DateTime(lima.year, lima.month, lima.day, 9);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _api =
          widget.gateway ??
          HttpOptimizationGateway(
            ApiClient(
              context.read<AuthProvider>(),
              requestTimeout: const Duration(seconds: 45),
            ),
          );
      _load();
    });
  }

  @override
  void dispose() {
    for (final controller in _fields.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _invalidate() => setState(() {
    _plan = null;
    _error = null;
  });
  double _number(dynamic value) => double.tryParse('$value') ?? 0;

  Future<void> _load({bool keepPlan = false}) async {
    setState(() {
      _loading = true;
      _error = null;
      if (!keepPlan) _plan = null;
    });
    try {
      final values = await _api.load();
      if (!mounted) return;
      setState(() {
        _orders = values['orders']!
            .where((row) => row['estado'] == 'PENDIENTE')
            .toList();
        _drivers = values['drivers']!
            .where((row) => row['estado'] == 'ACTIVO')
            .toList();
        _vehicles = values['vehicles']!
            .where((row) => row['estado'] == 'ACTIVO')
            .toList();
        _history = values['plans']!;
        _selected.retainAll(_orders.map((row) => '${row['pedido_id']}'));
        _teams.removeWhere(
          (team) =>
              !_drivers.any(
                (d) => d['repartidor_id'] == team['repartidor_id'],
              ) ||
              !_vehicles.any((v) => v['vehiculo_id'] == team['vehiculo_id']),
        );
        _driver = _drivers.isEmpty
            ? null
            : '${_drivers.first['repartidor_id']}';
        _vehicle = _vehicles.isEmpty
            ? null
            : '${_vehicles.first['vehiculo_id']}';
      });
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickStart() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: DateTime(2020),
      lastDate: DateTime(2050),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_start),
    );
    if (time == null || !mounted) return;
    setState(() {
      _start = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      _plan = null;
    });
  }

  Future<void> _preview() async {
    if (!_form.currentState!.validate() || _selected.isEmpty || _teams.isEmpty) {
      return;
    }
    setState(() {
      _working = true;
      _error = null;
      _plan = null;
    });
    try {
      final utc = DateTime.utc(
        _start.year,
        _start.month,
        _start.day,
        _start.hour,
        _start.minute,
      ).add(const Duration(hours: 5));
      final result = await _api.preview({
        'pedidos': _selected.toList(),
        'equipos': _teams.map(Map<String, String>.from).toList(),
        'inicio_planificado': utc.toIso8601String(),
        'servicio_min_por_entrega': int.parse(_fields['service']!.text),
        'jornada_max_min': int.parse(_fields['work']!.text),
        'descanso_cada_min': int.parse(_fields['breakAfter']!.text),
        'descanso_min': int.parse(_fields['break']!.text),
        'regresar_al_origen': _return,
        'semilla': int.parse(_fields['seed']!.text),
        'poblacion': int.parse(_fields['population']!.text),
        'generaciones': int.parse(_fields['generations']!.text),
      });
      if (mounted) setState(() => _plan = result);
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _confirm() async {
    setState(() {
      _working = true;
      _error = null;
    });
    try {
      final result = await _api.confirm('${_plan!['plan_id']}');
      if (!mounted) return;
      setState(() => _plan = result);
      await _load(keepPlan: true);
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _openPlan(String identifier) async {
    setState(() {
      _working = true;
      _error = null;
    });
    try {
      final result = await _api.getPlan(identifier);
      if (mounted) setState(() => _plan = result);
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Widget _card(String title, String help, Widget child) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            help,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    ),
  );

  Widget _numeric(String name, String label, int min, int max) => TextFormField(
    key: ValueKey('opt-$name'),
    controller: _fields[name],
    enabled: !_working,
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    decoration: InputDecoration(labelText: label, helperText: '$min a $max'),
    onChanged: (_) => _invalidate(),
    validator: (value) {
      final number = int.tryParse(value ?? '');
      return number == null || number < min || number > max
          ? 'Usa un valor de $min a $max'
          : null;
    },
  );

  Widget _ordersCard() {
    final visible = _orders
        .where(
          (o) => '${o['cliente_nombre']} ${o['direccion']}'
              .toLowerCase()
              .contains(_search.toLowerCase()),
        )
        .toList();
    final weight = _orders
        .where((o) => _selected.contains('${o['pedido_id']}'))
        .fold<double>(0, (sum, o) => sum + _number(o['peso_kg']));
    return _card(
      '1. Pedidos para planificar',
      '${_selected.length}/150 seleccionados · ${weight.toStringAsFixed(2)} kg',
      Column(
        children: [
          TextField(
            enabled: !_working,
            decoration: const InputDecoration(
              labelText: 'Buscar cliente o dirección',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) => setState(() => _search = value),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              TextButton(
                key: const ValueKey('opt-select-all'),
                onPressed: _working || visible.isEmpty
                    ? null
                    : () => setState(() {
                        _selected
                          ..clear()
                          ..addAll(
                            visible.take(150).map((o) => '${o['pedido_id']}'),
                          );
                        _plan = null;
                      }),
                child: const Text('Seleccionar hasta 150'),
              ),
              TextButton(
                onPressed: _working || _selected.isEmpty
                    ? null
                    : () => setState(() {
                        _selected.clear();
                        _plan = null;
                      }),
                child: const Text('Limpiar'),
              ),
            ],
          ),
          if (_orders.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No hay pedidos pendientes. Registra pedidos con ubicación y ventana de entrega para comenzar.',
              ),
            ),
          if (_orders.isNotEmpty && visible.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No hay coincidencias con la búsqueda.'),
            ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: visible.length,
              itemBuilder: (context, index) {
                final order = visible[index],
                    id = '${visible[index]['pedido_id']}';
                return CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _selected.contains(id),
                  title: Text(
                    '${order['cliente_nombre'] ?? 'Cliente'} · ${order['direccion']}',
                  ),
                  subtitle: Text(
                    '${order['peso_kg']} kg · ${optimizationLimaDate(order['ventana_inicio'])} a ${optimizationLimaDate(order['ventana_fin'])}',
                  ),
                  onChanged: _working
                      ? null
                      : (value) => setState(() {
                          if (value == true && _selected.length < 150) {
                            _selected.add(id);
                          }
                          if (value != true) _selected.remove(id);
                          _plan = null;
                        }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _teamsCard() => _card(
    '2. Equipos disponibles',
    'Combina un repartidor y un vehículo. Cada recurso se usa una sola vez; el servidor comprueba turnos y cruces de horario.',
    Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth < 720
                ? constraints.maxWidth
                : (constraints.maxWidth - 12) / 2;
            return Wrap(
              spacing: 12,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: width,
                  child: DropdownButtonFormField<String>(
                    key: ValueKey('opt-driver-$_driver'),
                    initialValue: _driver,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Repartidor'),
                    items: _drivers
                        .map(
                          (d) => DropdownMenuItem(
                            value: '${d['repartidor_id']}',
                            child: Text(
                              '${d['nombre']}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: _working
                        ? null
                        : (value) => setState(() => _driver = value),
                  ),
                ),
                SizedBox(
                  width: width,
                  child: DropdownButtonFormField<String>(
                    key: ValueKey('opt-vehicle-$_vehicle'),
                    initialValue: _vehicle,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Vehículo'),
                    items: _vehicles
                        .map(
                          (v) => DropdownMenuItem(
                            value: '${v['vehiculo_id']}',
                            child: Text(
                              '${v['placa']} · ${v['capacidad_kg']} kg',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: _working
                        ? null
                        : (value) => setState(() => _vehicle = value),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            key: const ValueKey('opt-add-team'),
            onPressed:
                _working ||
                    _driver == null ||
                    _vehicle == null ||
                    _teams.length >= 15 ||
                    _teams.any(
                      (t) =>
                          t['repartidor_id'] == _driver ||
                          t['vehiculo_id'] == _vehicle,
                    )
                ? null
                : () => setState(() {
                    _teams.add({
                      'repartidor_id': _driver!,
                      'vehiculo_id': _vehicle!,
                    });
                    _plan = null;
                  }),
            icon: const Icon(Icons.group_add_outlined),
            label: const Text('Agregar equipo'),
          ),
        ),
        for (var i = 0; i < _teams.length; i++)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(child: Text('${i + 1}')),
            title: Text(
              '${_drivers.firstWhere((d) => d['repartidor_id'] == _teams[i]['repartidor_id'])['nombre']}',
            ),
            subtitle: Text(
              '${_vehicles.firstWhere((v) => v['vehiculo_id'] == _teams[i]['vehiculo_id'])['placa']}',
            ),
            trailing: IconButton(
              tooltip: 'Quitar equipo ${i + 1}',
              onPressed: _working
                  ? null
                  : () => setState(() {
                      _teams.removeAt(i);
                      _plan = null;
                    }),
              icon: const Icon(Icons.close),
            ),
          ),
        if (_drivers.isEmpty || _vehicles.isEmpty)
          const Text(
            'Registra un repartidor y un vehículo activos antes de planificar.',
          ),
        if (_teams.isEmpty && _drivers.isNotEmpty && _vehicles.isNotEmpty)
          const Text('Agrega al menos un equipo. Puedes incluir hasta 15.'),
      ],
    ),
  );

  Widget _settingsCard() => _card(
    '3. Salida y condiciones',
    'Horario de Lima (UTC−05). La propuesta respeta la ventana completa de cada entrega.',
    Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: _working ? null : _pickStart,
          icon: const Icon(Icons.schedule),
          label: Text(
            'Salida: ${_start.day}/${_start.month}/${_start.year} ${_start.hour.toString().padLeft(2, '0')}:${_start.minute.toString().padLeft(2, '0')} · Lima',
          ),
        ),
        const SizedBox(height: 16),
        _numeric('service', 'Atención por entrega (min)', 1, 120),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Regresar al punto de partida'),
          value: _return,
          onChanged: _working
              ? null
              : (value) => setState(() {
                  _return = value;
                  _plan = null;
                }),
        ),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: const Text('Restricciones y parámetros del cálculo'),
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                'Las pausas se planifican en las paradas. Revisa que estas condiciones correspondan a tu operación. La semilla permite repetir una búsqueda con los mismos datos.',
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth < 600
                    ? constraints.maxWidth
                    : (constraints.maxWidth - 16) / 2;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: width,
                      child: _numeric('work', 'Jornada máxima (min)', 1, 480),
                    ),
                    SizedBox(
                      width: width,
                      child: _numeric(
                        'breakAfter',
                        'Conducción antes de pausa (min)',
                        1,
                        480,
                      ),
                    ),
                    SizedBox(
                      width: width,
                      child: _numeric(
                        'break',
                        'Duración de pausa (min)',
                        1,
                        120,
                      ),
                    ),
                    SizedBox(
                      width: width,
                      child: _numeric('seed', 'Semilla', 0, 4294967295),
                    ),
                    SizedBox(
                      width: width,
                      child: _numeric('population', 'Población', 4, 64),
                    ),
                    SizedBox(
                      width: width,
                      child: _numeric('generations', 'Generaciones', 1, 150),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          key: const ValueKey('opt-preview'),
          onPressed: _working || _selected.isEmpty || _teams.isEmpty
              ? null
              : _preview,
          icon: const Icon(Icons.auto_awesome_outlined),
          label: const Text('Generar propuesta'),
        ),
        const SizedBox(height: 8),
        const Text(
          'Generar una propuesta no asigna pedidos. Podrás revisar el resultado antes de confirmar.',
        ),
      ],
    ),
  );

  Widget _planCard() {
    final plan = _plan!, stats = plan['estadisticas'] as Map;
    final confirmed = plan['estado'] == 'CONFIRMADO';
    final expired =
        DateTime.tryParse('${plan['vence_en']}')?.isBefore(DateTime.now()) ??
        true;
    final routeIds = (plan['ruta_ids'] as List?) ?? [];
    return _card(
      confirmed ? '4. Plan confirmado' : '4. Revisa la propuesta',
      confirmed
          ? 'Las rutas ya están guardadas y los pedidos fueron asignados.'
          : 'Disponible hasta ${optimizationLimaDate(plan['vence_en'])}, hora de Lima.',
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text('${stats['pedidos']} pedidos')),
              Chip(label: Text('${stats['rutas']} rutas')),
              Chip(
                label: Text(
                  '${_number(stats['distancia_km']).toStringAsFixed(2)} km',
                ),
              ),
              Chip(
                label: Text(
                  '${_number(stats['combustible_l']).toStringAsFixed(2)} L estimados',
                ),
              ),
              Chip(
                label: Text(
                  '${_number(stats['co2_kg']).toStringAsFixed(2)} kg CO₂ estimados',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Recorridos estimados sin tráfico en tiempo real. El algoritmo genético busca una propuesta factible; no garantiza el óptimo global.',
          ),
          for (final item in (plan['rutas'] as List))
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item['vehiculo_placa']} · ${item['repartidor_nombre']}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${(item['entregas'] as List).length} entregas · ${item['weight']} kg · ${optimizationLimaDate(item['inicio_planificado'])} a ${optimizationLimaDate(item['fin_planificado'])}',
                  ),
                  for (var i = 0; i < (item['entregas'] as List).length; i++)
                    Text(
                      '${i + 1}. ${item['entregas'][i]['direccion'] ?? 'Destino registrado'}\nEntrega prevista: ${optimizationLimaDate(item['entregas'][i]['eta'])}',
                    ),
                ],
              ),
            ),
          const SizedBox(height: 18),
          if (!confirmed)
            FilledButton.icon(
              key: const ValueKey('opt-confirm'),
              onPressed: _working || expired ? null : _confirm,
              icon: const Icon(Icons.check_circle_outline),
              label: Text(
                expired
                    ? 'Propuesta vencida: vuelve a generar'
                    : 'Confirmar y asignar pedidos',
              ),
            ),
          if (confirmed)
            for (var i = 0; i < routeIds.length; i++)
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        RouteDetailScreen(routeId: '${routeIds[i]}'),
                  ),
                ),
                icon: const Icon(Icons.map_outlined),
                label: Text('Ver recorrido ${i + 1}'),
              ),
          ExpansionTile(
            title: const Text('Detalle del cálculo'),
            children: [
              Text(
                'Algoritmo genético · semilla ${stats['seed']} · ${stats['generations']} generaciones · ${stats['elapsed_ms']} ms de búsqueda',
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController?>();
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planificar entregas'),
        actions: [
          if (theme != null)
            IconButton(
              tooltip: 'Cambiar tema',
              onPressed: theme.toggle,
              icon: const Icon(Icons.brightness_6_outlined),
            ),
          IconButton(
            tooltip: 'Actualizar datos',
            onPressed: _working ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _form,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'De pedidos pendientes a rutas factibles',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Selecciona pedidos y equipos, genera una propuesta y confirma cuando estés conforme.',
                          ),
                          const SizedBox(height: 20),
                          if (_error != null)
                            Semantics(
                              liveRegion: true,
                              child: Card(
                                color: scheme.errorContainer,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    _error!,
                                    style: TextStyle(
                                      color: scheme.onErrorContainer,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (_working)
                            Semantics(
                              liveRegion: true,
                              child: const Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    LinearProgressIndicator(),
                                    SizedBox(height: 8),
                                    Text(
                                      'Procesando la planificación. Puedes revisar el resultado al terminar.',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          _ordersCard(),
                          const SizedBox(height: 16),
                          _teamsCard(),
                          const SizedBox(height: 16),
                          _settingsCard(),
                          if (_plan != null) ...[
                            const SizedBox(height: 16),
                            _planCard(),
                          ],
                          if (_history.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _card(
                              'Planes recientes',
                              'Consulta las propuestas guardadas y sus rutas.',
                              Column(
                                children: [
                                  for (final item in _history)
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text(
                                        '${item['estado']} · ${optimizationLimaDate(item['creado_en'])}',
                                      ),
                                      subtitle: Text(
                                        '${item['estadisticas']['pedidos']} pedidos',
                                      ),
                                      trailing: const Icon(Icons.chevron_right),
                                      onTap: _working
                                          ? null
                                          : () =>
                                                _openPlan('${item['plan_id']}'),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
