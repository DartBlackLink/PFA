import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'operation_overview.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/delivery_location_picker.dart';
import '../../../../core/widgets/record_widgets.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/operation_sidebar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../repartidores/presentation/repartidores_screen.dart';
import '../../../rutas/presentation/routes_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _section = 0;
  bool _menuCollapsed = false;
  bool _loading = true;
  String? _error;
  String _search = '';
  List<Map<String, dynamic>> _orders = [],
      _drivers = [],
      _vehicles = [],
      _routes = [];
  static const _sections = [
    'Resumen',
    'Pedidos',
    'Rutas',
    'Repartidores',
    'Flota',
    'Reportes',
  ];
  static const _icons = [
    Icons.dashboard_outlined,
    Icons.inventory_2_outlined,
    Icons.route_outlined,
    Icons.badge_outlined,
    Icons.local_shipping_outlined,
    Icons.description_outlined,
  ];

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
      final api = ApiClient(context.read<AuthProvider>());
      final data = await Future.wait(
        [
          '/orders/?limit=1000',
          '/drivers/?limit=1000',
          '/vehicles/?limit=1000',
          '/routes/?limit=1000',
        ].map(api.request),
      );
      if (mounted) {
        setState(() {
          _orders = (data[0] as List).cast<Map<String, dynamic>>();
          _drivers = (data[1] as List).cast<Map<String, dynamic>>();
          _vehicles = (data[2] as List).cast<Map<String, dynamic>>();
          _routes = (data[3] as List).cast<Map<String, dynamic>>();
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

  Future<void> _select(int index) async {
    if (index == 4) {
      await context.push('/flota');
      if (mounted) await _load();
      return;
    }
    setState(() {
      _section = index;
      _search = '';
    });
    if (index != 3 && index != 5) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 850;
    final theme = context.watch<ThemeController>();
    final content = Padding(
      padding: EdgeInsets.all(wide ? 28 : 16),
      child: _section == 3
          ? const SingleChildScrollView(child: RepartidoresScreen())
          : _content(),
    );
    final nav = OperationSidebar(
      collapsed: wide && _menuCollapsed,
      labels: _sections,
      icons: _icons,
      selected: _section,
      onSelected: (index) {
        if (!wide) Navigator.pop(context);
        _select(index);
      },
    );
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        leading: wide
            ? IconButton(
                tooltip: _menuCollapsed ? 'Expandir menú' : 'Contraer menú',
                icon: Icon(_menuCollapsed ? Icons.menu_open : Icons.menu),
                onPressed: () =>
                    setState(() => _menuCollapsed = !_menuCollapsed),
              )
            : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              wide
                  ? 'Operaciones / ${_sections[_section]}'
                  : _sections[_section],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            if (wide)
              const Text(
                'EcoLogística Huancayo',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar datos',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
          if (wide)
            IconButton(
              tooltip: 'Cambiar tema',
              onPressed: theme.toggle,
              icon: Icon(
                theme.isDark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
              ),
            ),
          PopupMenuButton<String>(
            tooltip: 'Opciones de cuenta',
            icon: const Icon(Icons.account_circle_outlined),
            onSelected: (value) {
              if (value == 'theme') {
                theme.toggle();
              } else {
                context.read<AuthProvider>().cerrarSesion();
              }
            },
            itemBuilder: (_) => [
              if (!wide)
                const PopupMenuItem(
                  value: 'theme',
                  child: Text('Cambiar tema'),
                ),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Cerrar sesión'),
              ),
            ],
          ),
          const SizedBox(width: 12),
        ],
      ),
      drawer: wide ? null : Drawer(child: nav),
      body: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AnimatedSize(
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 200),
                  alignment: Alignment.topLeft,
                  child: SizedBox(width: _menuCollapsed ? 80 : 248, child: nav),
                ),
                Expanded(child: content),
              ],
            )
          : content,
    );
  }

  Widget _content() {
    if (_section == 2) return const RoutesScreen(admin: true);
    if (_section == 5) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 580),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.description_outlined, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'Reportes de sostenibilidad',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Los reportes y la exportación PDF estarán disponibles al implementar los cálculos de rutas, emisiones y costos. Aún no hay resultados ambientales calculados.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: _load, child: const Text('Reintentar')),
          ],
        ),
      );
    }
    if (_section == 0) {
      return OperationOverview(
        orders: _orders,
        drivers: _drivers,
        vehicles: _vehicles,
        routes: _routes,
        onNewOrder: _newOrder,
        onOrders: () => _select(1),
        onRoutes: () => _select(2),
        onTeam: () => _select(3),
        onFleet: () => _select(4),
        onOrderDetail: _orderDetail,
      );
    }
    final items = _orders
        .where(
          (e) =>
              e.values.join(' ').toLowerCase().contains(_search.toLowerCase()),
        )
        .toList();
    Widget summary(Map<String, dynamic> e) => SizedBox(
      width: 240,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${e['cliente_nombre']}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          Text(
            '${e['direccion']}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 16,
          runSpacing: 12,
          children: [
            Text(
              'Pedidos registrados',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            FilledButton.icon(
              onPressed: _newOrder,
              icon: const Icon(Icons.add),
              label: const Text('Nuevo pedido'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Consulta los destinos y horarios antes de asignar una ruta.',
        ),
        const SizedBox(height: 20),
        TextField(
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            labelText: 'Buscar cliente, dirección o estado',
          ),
          onChanged: (v) => setState(() => _search = v),
        ),
        const SizedBox(height: 12),
        Text(
          countLabel(items.length, 'pedido encontrado', 'pedidos encontrados'),
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: items.isEmpty
              ? const Center(
                  child: Text('No hay pedidos que coincidan con tu búsqueda.'),
                )
              : SingleChildScrollView(
                  child: AdaptiveRecords(
                    columns: const [
                      DataColumn(label: Text('Cliente y destino')),
                      DataColumn(label: Text('Carga')),
                      DataColumn(label: Text('Horario de entrega')),
                      DataColumn(label: Text('Prioridad')),
                      DataColumn(label: Text('Estado')),
                      DataColumn(label: Text('Detalles')),
                    ],
                    rows: items
                        .map(
                          (e) => DataRow(
                            cells: [
                              DataCell(summary(e)),
                              DataCell(Text('${e['peso_kg']} kg')),
                              DataCell(
                                Text(
                                  '${friendlyDate(e['ventana_inicio'])}\n${friendlyDate(e['ventana_fin'])}',
                                ),
                              ),
                              DataCell(Text('${e['prioridad']}')),
                              DataCell(StatusBadge('${e['estado']}')),
                              DataCell(
                                IconButton(
                                  tooltip: 'Ver pedido',
                                  icon: const Icon(Icons.open_in_new),
                                  onPressed: () => _orderDetail(e),
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                    cards: items
                        .map(
                          (e) => Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 8,
                                    children: [
                                      Text(
                                        '${e['cliente_nombre']}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      StatusBadge('${e['estado']}'),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text('${e['direccion']}'),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${e['peso_kg']} kg · ${e['prioridad']}',
                                  ),
                                  Text(
                                    'Desde ${friendlyDate(e['ventana_inicio'])}\nHasta ${friendlyDate(e['ventana_fin'])}',
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton.icon(
                                    onPressed: () => _orderDetail(e),
                                    icon: const Icon(Icons.open_in_new),
                                    label: const Text('Ver detalles'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
        ),
      ],
    );
  }

  void _orderDetail(Map<String, dynamic> e) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const FormHeading(
        'Detalle del pedido',
        'Destino, carga y ventana de entrega.',
        Icons.inventory_2_outlined,
      ),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              StatusBadge('${e['estado']}'),
              const SizedBox(height: 20),
              Text(
                '${e['cliente_nombre']}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text('${e['direccion']}'),
              const SizedBox(height: 16),
              Text(
                'Referencia: ${e['punto_referencia'] ?? 'Sin referencia adicional'}',
              ),
              Text('Producto: ${e['tipo_producto']} · ${e['peso_kg']} kg'),
              Text('Prioridad: ${e['prioridad']}'),
              const SizedBox(height: 16),
              Text(
                'Desde: ${friendlyDate(e['ventana_inicio'])}\nHasta: ${friendlyDate(e['ventana_fin'])}',
              ),
              Text('Destino: ${e['latitud']}, ${e['longitud']}'),
            ],
          ),
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    ),
  );

  Future<void> _newOrder() async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _OrderForm(),
    );
    if (saved == true && mounted) await _load();
  }
}

class _OrderForm extends StatefulWidget {
  const _OrderForm();
  @override
  State<_OrderForm> createState() => _OrderFormState();
}

class _OrderFormState extends State<_OrderForm> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController(),
      _weight = TextEditingController(),
      _product = TextEditingController(),
      _reference = TextEditingController();
  DateTime _start = DateTime.now().toUtc().subtract(const Duration(hours: 5)),
      _end = DateTime.now().toUtc().subtract(const Duration(hours: 3));
  DeliveryLocation? _location;
  String _priority = 'ESTANDAR';
  String? _error;
  bool _saving = false;
  @override
  void dispose() {
    for (final c in [_name, _weight, _product, _reference]) {
      c.dispose();
    }
    super.dispose();
  }

  String _limaLabel(DateTime value) {
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${pad(value.day)}/${pad(value.month)}/${value.year} ${pad(value.hour)}:${pad(value.minute)}';
  }

  String _limaUtc(DateTime value) => DateTime.utc(
    value.year,
    value.month,
    value.day,
    value.hour + 5,
    value.minute,
  ).toIso8601String();

  Future<void> _date(bool start) async {
    final current = start ? _start : _end;
    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (time == null || !mounted) return;
    final value = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() {
      if (start) {
        _start = value;
        if (!_end.isAfter(value)) {
          _end = value.add(const Duration(hours: 2));
        }
      } else {
        _end = value;
      }
    });
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if (_location == null) {
      setState(
        () =>
            _error = 'Selecciona el punto y confirma la dirección de entrega.',
      );
      return;
    }
    if (!_end.isAfter(_start)) {
      setState(
        () => _error = 'El fin de la ventana debe ser posterior al inicio.',
      );
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ApiClient(context.read<AuthProvider>()).request(
        '/orders/',
        method: 'POST',
        body: {
          'cliente_nombre': _name.text.trim(),
          'direccion': _location!.address,
          'latitud': _location!.point.latitude,
          'longitud': _location!.point.longitude,
          'punto_referencia': _reference.text.trim().isEmpty
              ? null
              : _reference.text.trim(),
          'peso_kg': double.parse(_weight.text.replaceAll(',', '.')),
          'tipo_producto': _product.text.trim(),
          'prioridad': _priority,
          'ventana_inicio': _limaUtc(_start),
          'ventana_fin': _limaUtc(_end),
          'estado': 'PENDIENTE',
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
      'Nuevo pedido',
      'Completa el destino y horario para preparar su entrega.',
      Icons.inventory_2_outlined,
    ),
    insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
    content: SizedBox(
      width: 480,
      child: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const FormSection('Cliente y carga'),
              for (final field in [
                (_name, 'Cliente'),
                (_product, 'Tipo de producto'),
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextFormField(
                    controller: field.$1,
                    enabled: !_saving,
                    decoration: InputDecoration(labelText: field.$2),
                    validator: (v) {
                      final length = v?.trim().length ?? 0;
                      const min = 2;
                      final max = field.$1 == _product
                          ? 30
                          : field.$1 == _name
                          ? 160
                          : 255;
                      return length < min || length > max
                          ? 'Usa entre $min y $max caracteres'
                          : null;
                    },
                  ),
                ),
              TextFormField(
                controller: _weight,
                enabled: !_saving,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Peso (kg)'),
                validator: (v) {
                  final n = double.tryParse((v ?? '').replaceAll(',', '.'));
                  return n == null || !n.isFinite || n <= 0 || n > 99999999
                      ? 'Ingresa un peso entre 0 y 99999999 kg, mayor que cero'
                      : null;
                },
              ),
              const SizedBox(height: 12),
              const FormSection('Ubicación de entrega'),
              AbsorbPointer(
                absorbing: _saving,
                child: DeliveryLocationPicker(
                  onChanged: (value) {
                    setState(() {
                      _location = value;
                      if (value != null) _error = null;
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _reference,
                enabled: !_saving,
                maxLength: 500,
                decoration: const InputDecoration(
                  labelText: 'Punto de referencia (opcional)',
                ),
              ),
              const FormSection('Prioridad y horario de entrega'),
              const Text(
                'Horario de Lima (UTC−5). El fin debe ser posterior al inicio.',
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _priority,
                decoration: const InputDecoration(labelText: 'Prioridad'),
                items: ['ESTANDAR', 'ALTA', 'URGENTE']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: _saving
                    ? null
                    : (v) => setState(() => _priority = v!),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _saving ? null : () => _date(true),
                child: Text('Inicio: ${_limaLabel(_start)}'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _saving ? null : () => _date(false),
                child: Text('Fin: ${_limaLabel(_end)}'),
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
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: _saving ? null : _save,
        child: Text(_saving ? 'Guardando...' : 'Guardar'),
      ),
    ],
  );
}
