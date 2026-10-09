import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_client.dart';
import '../../../core/widgets/record_widgets.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import 'route_detail_screen.dart';
import 'route_schedule_input.dart';

class RoutesScreen extends StatefulWidget {
  const RoutesScreen({super.key, this.admin = false});
  final bool admin;
  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  List<Map<String, dynamic>> _routes = [];
  String? _error;
  String _search = '';
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ApiClient(context.read<AuthProvider>())
          .request('/routes/?limit=1000');
      if (mounted) {
        setState(() => _routes = (data as List).cast<Map<String, dynamic>>());
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _assign() async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _AssignmentForm(),
    );
    if (saved == true && mounted) await _load();
  }

  Future<void> _schedule(Map<String, dynamic> route) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ScheduleForm(route: route),
    );
    if (saved == true && mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final rows = _routes
        .where(
          (r) =>
              '${r['repartidor_nombre']} ${r['vehiculo_placa']} ${r['estado']} ${r['entregas']}'
                  .toLowerCase()
                  .contains(_search.toLowerCase()),
        )
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 12,
          runSpacing: 12,
          children: [
            Text(
              widget.admin ? 'Asignación y rutas' : 'Mis rutas de entrega',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (widget.admin)
              FilledButton.icon(
                onPressed: _assign,
                icon: const Icon(Icons.add_road),
                label: const Text('Asignar pedidos'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          widget.admin
              ? 'Selecciona pedidos, repartidor y vehículo. Consulta el punto de partida, las entregas y el recorrido guardado.'
              : 'Abre una asignación para ver tu recorrido y los detalles de cada entrega.',
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            labelText: 'Buscar repartidor, placa o entrega',
          ),
          onChanged: (s) => setState(() => _search = s),
        ),
        const SizedBox(height: 12),
        if (_error != null)
          Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : rows.isEmpty
              ? Center(
                  child: Text(
                    _error == null
                        ? 'Todavía no hay rutas asignadas.'
                        : 'No se pudieron cargar las rutas.',
                  ),
                )
              : ListView.separated(
                  itemCount: rows.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final r = rows[i];
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primaryContainer,
                          foregroundColor: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer,
                          child: const Icon(Icons.route),
                        ),
                        title: Text(
                          '${r['repartidor_nombre'] ?? 'Repartidor'} · ${r['vehiculo_placa'] ?? 'Vehículo'}',
                        ),
                        subtitle: Text(
                          '${countLabel((r['entregas'] as List).length, 'entrega', 'entregas')} · ${r['estado']}\n${r['distancia_km'] ?? '—'} km · ${r['tiempo_min'] ?? '—'} min de viaje\n${r['inicio_planificado'] == null ? 'Horario por registrar' : '${friendlyDate(r['inicio_planificado'])} → ${friendlyDate(r['fin_planificado'])}'}',
                        ),
                        trailing: widget.admin && r['estado'] == 'PLANIFICADA'
                            ? IconButton(
                                tooltip: 'Registrar o cambiar horario',
                                icon: const Icon(Icons.edit_calendar_outlined),
                                onPressed: () => _schedule(r),
                              )
                            : const Icon(Icons.chevron_right),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                RouteDetailScreen(routeId: r['ruta_id']),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
            label: const Text('Actualizar'),
          ),
        ),
      ],
    );
  }
}

class _AssignmentForm extends StatefulWidget {
  const _AssignmentForm();
  @override
  State<_AssignmentForm> createState() => _AssignmentFormState();
}

class _AssignmentFormState extends State<_AssignmentForm> {
  List<Map<String, dynamic>> _drivers = [], _vehicles = [], _orders = [];
  final List<String> _selected = [];
  String? _driver, _vehicle, _error;
  final _schedule = RouteScheduleDraft();
  bool _loading = true, _saving = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      final api = ApiClient(context.read<AuthProvider>());
      final data = await Future.wait(
        [
          '/drivers/?limit=1000',
          '/vehicles/?limit=1000',
          '/orders/?limit=1000',
        ].map(api.request),
      );
      if (mounted) {
        setState(() {
          _drivers = (data[0] as List)
              .cast<Map<String, dynamic>>()
              .where((r) => r['estado'] == 'ACTIVO')
              .toList();
          _vehicles = (data[1] as List)
              .cast<Map<String, dynamic>>()
              .where((r) => r['estado'] == 'ACTIVO')
              .toList();
          _orders = (data[2] as List)
              .cast<Map<String, dynamic>>()
              .where((r) => r['estado'] == 'PENDIENTE')
              .toList();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (_driver == null || _vehicle == null || _selected.isEmpty) {
      setState(
        () => _error = 'Selecciona repartidor, vehículo y al menos un pedido.',
      );
      return;
    }
    if (_schedule.error != null) {
      setState(() => _error = _schedule.error);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ApiClient(context.read<AuthProvider>()).request(
        '/routes/',
        method: 'POST',
        body: {
          'repartidor_id': _driver,
          'vehiculo_id': _vehicle,
          'pedidos': _selected,
          ..._schedule.payload,
        },
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const FormHeading(
      'Asignar pedidos',
      'Elige equipo y entregas para generar el recorrido.',
      Icons.add_road,
    ),
    insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
    content: SizedBox(
      width: 600,
      child: _loading
          ? const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Repartidor y punto de partida',
                    ),
                    items: _drivers
                        .map(
                          (r) => DropdownMenuItem(
                            value: r['repartidor_id'] as String,
                            child: Text(
                              '${r['nombre']} · ${r['disponible_desde'] ?? 'sin turno'}–${r['disponible_hasta'] ?? ''} ${r['origen_latitud'] == null ? '(completar origen)' : ''}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: _saving
                        ? null
                        : (v) => setState(() => _driver = v),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Vehículo'),
                    items: _vehicles
                        .map(
                          (v) => DropdownMenuItem(
                            value: v['vehiculo_id'] as String,
                            child: Text(
                              '${v['placa']} · ${v['capacidad_kg']} kg',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: _saving
                        ? null
                        : (v) => setState(() => _vehicle = v),
                  ),
                  const SizedBox(height: 16),
                  RouteScheduleInput(draft: _schedule, enabled: !_saving),
                  const SizedBox(height: 20),
                  const Text(
                    'Selecciona las entregas en el orden del recorrido (máximo 20).',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (_drivers.isEmpty || _vehicles.isEmpty)
                    const Text(
                      'Primero registra un repartidor y un vehículo activos.',
                    ),
                  if (_orders.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No hay pedidos pendientes. Registra pedidos con coordenadas de entrega.',
                      ),
                    ),
                  for (final o in _orders)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _selected.contains(o['pedido_id']),
                      onChanged:
                          _saving ||
                              o['latitud'] == null ||
                              o['longitud'] == null
                          ? null
                          : (v) => setState(() {
                              if (v == true) {
                                if (_selected.length < 20) {
                                  _selected.add(o['pedido_id']);
                                }
                              } else {
                                _selected.remove(o['pedido_id']);
                              }
                            }),
                      title: Text(
                        '${_selected.contains(o['pedido_id']) ? '${_selected.indexOf(o['pedido_id']) + 1}. ' : ''}${o['cliente_nombre']}',
                      ),
                      subtitle: Text(
                        '${o['direccion']} · ${o['peso_kg']} kg${o['latitud'] == null ? '\nFaltan coordenadas de entrega' : ''}',
                      ),
                    ),
                  const SizedBox(height: 8),
                  const Text(
                    'Revisa el orden de las entregas antes de guardar. El tiempo del recorrido es estimado y no incluye tráfico en tiempo real.',
                  ),
                  if (_saving)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: LinearProgressIndicator(),
                    ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                ],
              ),
            ),
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.pop(context, false),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: _loading || _saving ? null : _save,
        child: Text(_saving ? 'Calculando…' : 'Guardar asignación'),
      ),
    ],
  );
}

class _ScheduleForm extends StatefulWidget {
  const _ScheduleForm({required this.route});
  final Map<String, dynamic> route;
  @override
  State<_ScheduleForm> createState() => _ScheduleFormState();
}

class _ScheduleFormState extends State<_ScheduleForm> {
  late final RouteScheduleDraft _draft = RouteScheduleDraft(
    initial: widget.route['inicio_planificado'],
    serviceMinutes: widget.route['servicio_min_por_entrega'],
  );
  bool _saving = false;
  String? _error;
  Future<void> _save() async {
    if (_draft.error != null) {
      setState(() => _error = _draft.error);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ApiClient(context.read<AuthProvider>()).request(
        '/routes/${widget.route['ruta_id']}/horario',
        method: 'PUT',
        body: _draft.payload,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const FormHeading(
      'Horario de ruta',
      'Programa la ocupación del equipo.',
      Icons.edit_calendar_outlined,
    ),
    insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
    content: SizedBox(
      width: 480,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${widget.route['repartidor_nombre']} · ${widget.route['vehiculo_placa']}',
            ),
            const SizedBox(height: 16),
            RouteScheduleInput(draft: _draft, enabled: !_saving),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.pop(context, false),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: _saving ? null : _save,
        child: Text(_saving ? 'Guardando…' : 'Guardar horario'),
      ),
    ],
  );
}
