import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/record_widgets.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../features/auth/presentation/providers/flota_provider.dart';
import '../../data/models/vehiculo_model.dart';
import '../widgets/modal_formulario_vehiculo.dart';

class FlotaScreen extends StatefulWidget {
  const FlotaScreen({super.key});
  @override
  State<FlotaScreen> createState() => _FlotaScreenState();
}

class _FlotaScreenState extends State<FlotaScreen> {
  final _query = TextEditingController();
  String _type = 'Todos', _state = 'Todos';
  bool _grid = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<FlotaProvider>().cargarVehiculos();
    });
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  bool _matches(VehiculoModel v, String type) =>
      '${v.placa} ${v.tipo} ${v.anioFabricacion}'.toLowerCase().contains(
        _query.text.trim().toLowerCase(),
      ) &&
      (type == 'Todos' || v.tipo == type) &&
      (_state == 'Todos' || v.estado == _state);
  void _edit([VehiculoModel? v]) =>
      ModalFormularioVehiculo.mostrar(context, vehiculo: v);
  String _number(double value) =>
      value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FlotaProvider>();
    final s = Theme.of(context).colorScheme;
    final theme = context.watch<ThemeController>();
    final effectiveType = provider.vehiculos.any((v) => v.tipo == _type)
        ? _type
        : 'Todos';
    final visible = provider.vehiculos
        .where((v) => _matches(v, effectiveType))
        .toList();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Volver al centro de control',
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Gestión de Flota'),
        actions: [
          IconButton(
            tooltip: theme.isDark
                ? 'Activar modo claro'
                : 'Activar modo oscuro',
            onPressed: theme.toggle,
            icon: Icon(
              theme.isDark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
          ),
          IconButton(
            tooltip: 'Actualizar flota',
            onPressed: provider.estaCargando ? null : provider.cargarVehiculos,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, viewport) {
          final narrow = viewport.maxWidth < 700;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1480),
              child: ListView(
                padding: EdgeInsets.all(narrow ? 16 : 32),
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tu flota, a la vista.',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Capacidad, consumo y estado de cada vehículo.',
                            style: TextStyle(color: s.onSurfaceVariant),
                          ),
                        ],
                      ),
                      FilledButton.icon(
                        onPressed: () => _edit(),
                        icon: const Icon(Icons.add),
                        label: const Text('Nuevo vehículo'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _summary(provider.vehiculos),
                  const SizedBox(height: 24),
                  _filters(provider.vehiculos, narrow),
                  const SizedBox(height: 20),
                  if (provider.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Icon(Icons.info_outline, color: s.error),
                              Text(provider.error!),
                              TextButton(
                                onPressed: provider.cargarVehiculos,
                                child: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          countLabel(
                            visible.length,
                            'vehículo encontrado',
                            'vehículos encontrados',
                          ),
                          style: TextStyle(
                            color: s.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (viewport.maxWidth >= 950) ...[
                        IconButton(
                          tooltip: 'Vista de tarjetas',
                          onPressed: () => setState(() => _grid = true),
                          style: IconButton.styleFrom(
                            backgroundColor: _grid
                                ? s.surfaceContainerHighest
                                : Colors.transparent,
                          ),
                          icon: const Icon(Icons.grid_view_outlined),
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          tooltip: 'Vista de tabla',
                          onPressed: () => setState(() => _grid = false),
                          style: IconButton.styleFrom(
                            backgroundColor: !_grid
                                ? s.surfaceContainerHighest
                                : Colors.transparent,
                          ),
                          icon: const Icon(Icons.view_list_outlined),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (provider.estaCargando && provider.vehiculos.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(64),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (visible.isEmpty)
                    _empty()
                  else if (!_grid && viewport.maxWidth >= 950)
                    _table(visible)
                  else
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = constraints.maxWidth >= 1120
                            ? 3
                            : constraints.maxWidth >= 660
                            ? 2
                            : 1;
                        final width =
                            (constraints.maxWidth - 18 * (columns - 1)) /
                            columns;
                        return Wrap(
                          spacing: 18,
                          runSpacing: 18,
                          children: [
                            for (final v in visible)
                              SizedBox(width: width, child: _vehicle(v)),
                          ],
                        );
                      },
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _summary(List<VehiculoModel> list) {
    final s = Theme.of(context).colorScheme;
    final active = list.where((v) => v.estado == 'ACTIVO').toList();
    final capacity = active.fold<double>(0, (sum, v) => sum + v.capacidadKg);
    final data = [
      (
        'Vehículos registrados',
        '${list.length}',
        Icons.local_shipping_outlined,
        s.onSurface,
      ),
      ('Activos', '${active.length}', Icons.check_circle_outline, s.primary),
      (
        'Inactivos',
        '${list.where((v) => v.estado == 'INACTIVO').length}',
        Icons.pause_circle_outline,
        s.secondary,
      ),
      (
        'Capacidad activa',
        '${_number(capacity)} kg',
        Icons.inventory_2_outlined,
        s.onSurface,
      ),
    ];
    return LayoutBuilder(
      builder: (context, c) {
        final columns = c.maxWidth >= 950
            ? 4
            : c.maxWidth >= 300
            ? 2
            : 1;
        final width = (c.maxWidth - 14 * (columns - 1)) / columns;
        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            for (final d in data)
              SizedBox(
                width: width,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(d.$3, color: d.$4, size: 22),
                        const SizedBox(height: 16),
                        Text(
                          d.$2,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -.6,
                            color: s.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          d.$1,
                          style: TextStyle(
                            color: s.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _filters(List<VehiculoModel> list, bool narrow) {
    final s = Theme.of(context).colorScheme;
    final types = {'Todos', ...list.map((v) => v.tipo)}.toList();
    // Si un tipo desaparece al actualizar, mostrar Todos sin perder el resto del filtro.
    final selected = types.contains(_type) ? _type : 'Todos';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _query,
              decoration: const InputDecoration(
                labelText: 'Buscar por placa, tipo o año',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: narrow ? double.infinity : 260,
                  child: DropdownButtonFormField<String>(
                    key: ValueKey('type-$selected'),
                    initialValue: selected,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de vehículo',
                    ),
                    items: types
                        .map(
                          (t) => DropdownMenuItem(
                            value: t,
                            child: Text(t, overflow: TextOverflow.ellipsis),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _type = v ?? 'Todos'),
                  ),
                ),
                SizedBox(
                  width: narrow ? double.infinity : 190,
                  child: DropdownButtonFormField<String>(
                    key: ValueKey('state-$_state'),
                    initialValue: _state,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Estado'),
                    items: ['Todos', 'ACTIVO', 'INACTIVO']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) => setState(() => _state = v ?? 'Todos'),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => setState(() {
                    _query.clear();
                    _type = 'Todos';
                    _state = 'Todos';
                  }),
                  icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                  label: const Text('Limpiar filtros'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'La capacidad activa suma la capacidad registrada; no representa disponibilidad por horario.',
              style: TextStyle(color: s.onSurfaceVariant, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  IconData _icon(String type) {
    final t = type.toLowerCase();
    if (t.contains('moto')) return Icons.two_wheeler_outlined;
    if (t.contains('camión') || t.contains('camion')) {
      return Icons.local_shipping_outlined;
    }
    if (t.contains('auto') || t.contains('carro')) {
      return Icons.directions_car_outlined;
    }
    return Icons.airport_shuttle_outlined;
  }

  Widget _vehicle(VehiculoModel v) {
    final s = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: s.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(_icon(v.tipo), color: s.onSurface, size: 28),
                ),
                const Spacer(),
                StatusBadge(v.estado),
              ],
            ),
            const SizedBox(height: 22),
            Text(
              v.placa,
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w800,
                letterSpacing: .5,
                color: s.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(v.tipo, style: TextStyle(color: s.onSurfaceVariant)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: s.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Wrap(
                spacing: 18,
                runSpacing: 16,
                children: [
                  _datum(
                    'Capacidad',
                    '${_number(v.capacidadKg)} kg',
                    Icons.inventory_2_outlined,
                  ),
                  _datum(
                    'Consumo',
                    '${_number(v.consumoKmL)} km/L',
                    Icons.local_gas_station_outlined,
                  ),
                  _datum(
                    'Factor de emisión',
                    '${v.factorEmisionKgKm} kg/km',
                    Icons.co2_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                Text(
                  'Año ${v.anioFabricacion}',
                  style: TextStyle(color: s.onSurfaceVariant, fontSize: 12),
                ),
                TextButton.icon(
                  onPressed: () => _edit(v),
                  icon: const Icon(Icons.edit_outlined, size: 17),
                  label: const Text('Editar vehículo'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _datum(String label, String value, IconData icon) {
    final s = Theme.of(context).colorScheme;
    return SizedBox(
      width: 136,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: s.onSurfaceVariant),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 11, color: s.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: s.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _table(List<VehiculoModel> list) => AdaptiveRecords(
    columns: const [
      DataColumn(label: Text('Vehículo')),
      DataColumn(label: Text('Capacidad')),
      DataColumn(label: Text('Consumo')),
      DataColumn(label: Text('Factor de emisión')),
      DataColumn(label: Text('Estado')),
      DataColumn(label: Text('Acciones')),
    ],
    rows: list
        .map(
          (v) => DataRow(
            cells: [
              DataCell(
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      v.placa,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text('${v.tipo} · ${v.anioFabricacion}'),
                  ],
                ),
              ),
              DataCell(Text('${_number(v.capacidadKg)} kg')),
              DataCell(Text('${_number(v.consumoKmL)} km/L')),
              DataCell(Text('${v.factorEmisionKgKm} kg/km')),
              DataCell(StatusBadge(v.estado)),
              DataCell(
                IconButton(
                  tooltip: 'Editar vehículo',
                  onPressed: () => _edit(v),
                  icon: const Icon(Icons.edit_outlined),
                ),
              ),
            ],
          ),
        )
        .toList(),
    cards: list.map(_vehicle).toList(),
  );

  Widget _empty() {
    final s = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 42, color: s.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              'No hay vehículos con esos filtros',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Prueba otra placa, tipo o estado.',
              style: TextStyle(color: s.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
