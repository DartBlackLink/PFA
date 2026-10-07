import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/theme/theme_controller.dart';
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
    final nav = SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 28, 24, 8),
            child: Row(
              children: [
                Icon(Icons.eco_rounded, color: Color(0xFF54C79C), size: 32),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'EcoLogística',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Text(
              'PANEL ADMINISTRATIVO',
              style: TextStyle(
                color: Color(0xFFA8C7BA),
                fontSize: 11,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (var i = 0; i < _sections.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: ListTile(
                      selected: _section == i,
                      selectedTileColor: const Color(0xFF216550),
                      selectedColor: Colors.white,
                      textColor: const Color(0xFFCCE0D7),
                      iconColor: const Color(0xFFCCE0D7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      leading: Icon(_icons[i], size: 22),
                      title: Text(_sections[i]),
                      onTap: () {
                        if (!wide) Navigator.pop(context);
                        _select(i);
                      },
                    ),
                  ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(24),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(0xFF216550),
                  child: Icon(Icons.person_outline, color: Colors.white),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Administrador\nGestión de operaciones',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              wide ? 'Centro de operaciones' : _sections[_section],
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
              icon: const Icon(Icons.brightness_6_outlined),
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
      drawer: wide
          ? null
          : Drawer(backgroundColor: const Color(0xFF123E32), child: nav),
      body: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 248,
                  color: const Color(0xFF123E32),
                  child: Material(color: const Color(0xFF123E32), child: nav),
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
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen de registros',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Datos consultados en la base de datos. Actualiza después de realizar cambios.',
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 1050
                    ? 4
                    : constraints.maxWidth >= 580
                    ? 2
                    : 1;
                final width =
                    (constraints.maxWidth - 16 * (columns - 1)) / columns;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _metric(
                      'Pedidos',
                      _orders.length,
                      Icons.inventory_2_outlined,
                      width,
                    ),
                    _metric(
                      'Repartidores activos',
                      _drivers.where((e) => e['estado'] == 'ACTIVO').length,
                      Icons.badge_outlined,
                      width,
                    ),
                    _metric(
                      'Vehículos activos',
                      _vehicles.where((e) => e['estado'] == 'ACTIVO').length,
                      Icons.local_shipping_outlined,
                      width,
                    ),
                    _metric(
                      'Rutas registradas',
                      _routes.length,
                      Icons.route_outlined,
                      width,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Comienza registrando la flota y los repartidores con sus datos completos. Los pedidos y las rutas constituyen los siguientes módulos de la operación.',
                ),
              ),
            ),
          ],
        ),
      );
    }
    final orders = _section == 1;
    final items = (orders ? _orders : _routes)
        .where(
          (e) =>
              e.values.join(' ').toLowerCase().contains(_search.toLowerCase()),
        )
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 16,
          runSpacing: 12,
          children: [
            Text(
              orders ? 'Pedidos registrados' : 'Rutas registradas',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (orders)
              FilledButton.icon(
                onPressed: _newOrder,
                icon: const Icon(Icons.add),
                label: const Text('Nuevo pedido'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (!orders)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Se muestran las asignaciones guardadas. La planificación automática y el mapa de entregas requieren implementar el optimizador y las coordenadas de los pedidos.',
            ),
          ),
        TextField(
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            labelText: 'Buscar',
            border: OutlineInputBorder(),
          ),
          onChanged: (v) => setState(() => _search = v),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: items.isEmpty
              ? const Center(child: Text('No hay registros para mostrar.'))
              : ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 8),
                  itemBuilder: (_, index) {
                    final e = items[index];
                    final driver = _drivers
                        .where((d) => d['repartidor_id'] == e['repartidor_id'])
                        .firstOrNull;
                    final vehicle = _vehicles
                        .where((v) => v['vehiculo_id'] == e['vehiculo_id'])
                        .firstOrNull;
                    return Card(
                      child: ListTile(
                        isThreeLine: true,
                        leading: Icon(
                          orders
                              ? Icons.inventory_2_outlined
                              : Icons.route_outlined,
                        ),
                        title: Text(
                          orders
                              ? '${e['cliente_nombre']} — ${e['estado']}'
                              : '${driver?['nombre'] ?? e['repartidor_id']} — ${e['estado']}',
                        ),
                        subtitle: Text(
                          orders
                              ? '${e['direccion']}\n${e['peso_kg']} kg · ${e['prioridad']} · ${e['ventana_inicio']} → ${e['ventana_fin']}'
                              : 'Vehículo: ${vehicle?['placa'] ?? e['vehiculo_id']}\nAlgoritmo: ${e['algoritmo']} · ${e['creado_en']}',
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _metric(String title, int value, IconData icon, double width) =>
      SizedBox(
        width: width,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 12),
                Text(
                  '$value',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(title),
              ],
            ),
          ),
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
      _address = TextEditingController(),
      _weight = TextEditingController(),
      _product = TextEditingController(),
      _latitude = TextEditingController(),
      _longitude = TextEditingController(),
      _reference = TextEditingController();
  DateTime _start = DateTime.now(),
      _end = DateTime.now().add(const Duration(hours: 2));
  String _priority = 'ESTANDAR';
  String? _error;
  bool _saving = false;
  @override
  void dispose() {
    for (final c in [
      _name,
      _address,
      _weight,
      _product,
      _latitude,
      _longitude,
      _reference,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

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
      } else {
        _end = value;
      }
    });
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
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
          'direccion': _address.text.trim(),
          'latitud': double.parse(_latitude.text.replaceAll(',', '.')),
          'longitud': double.parse(_longitude.text.replaceAll(',', '.')),
          'punto_referencia': _reference.text.trim().isEmpty
              ? null
              : _reference.text.trim(),
          'peso_kg': double.parse(_weight.text.replaceAll(',', '.')),
          'tipo_producto': _product.text.trim(),
          'prioridad': _priority,
          'ventana_inicio': _start.toUtc().toIso8601String(),
          'ventana_fin': _end.toUtc().toIso8601String(),
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
    title: const Text('Nuevo pedido'),
    content: SizedBox(
      width: 480,
      child: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final field in [
                (_name, 'Cliente'),
                (_address, 'Dirección'),
                (_product, 'Tipo de producto'),
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextFormField(
                    controller: field.$1,
                    enabled: !_saving,
                    decoration: InputDecoration(labelText: field.$2),
                    validator: (v) => (v?.trim().length ?? 0) < 2
                        ? 'Completa este campo'
                        : null,
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
                  return n == null || !n.isFinite || n <= 0
                      ? 'Ingresa un peso mayor que cero'
                      : null;
                },
              ),
              const SizedBox(height: 12),
              const Text(
                'Ubicación de entrega. Ingresa coordenadas verificadas del destino; la dirección sola no calcula el mapa.',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _latitude,
                enabled: !_saving,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Latitud de entrega',
                ),
                validator: (v) {
                  final n = double.tryParse((v ?? '').replaceAll(',', '.'));
                  return n == null || !n.isFinite || n < -90 || n > 90
                      ? 'Latitud válida entre -90 y 90'
                      : null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _longitude,
                enabled: !_saving,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Longitud de entrega',
                ),
                validator: (v) {
                  final n = double.tryParse((v ?? '').replaceAll(',', '.'));
                  return n == null || !n.isFinite || n < -180 || n > 180
                      ? 'Longitud válida entre -180 y 180'
                      : null;
                },
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
                child: Text('Inicio: ${_start.toString().substring(0, 16)}'),
              ),
              OutlinedButton(
                onPressed: _saving ? null : () => _date(false),
                child: Text('Fin: ${_end.toString().substring(0, 16)}'),
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
