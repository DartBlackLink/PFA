import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/theme_controller.dart';
import '../../../../features/auth/presentation/providers/flota_provider.dart';
import '../../data/models/vehiculo_model.dart';
import '../widgets/modal_formulario_vehiculo.dart';

class FlotaScreen extends StatefulWidget {
  const FlotaScreen({super.key});

  @override
  State<FlotaScreen> createState() => _FlotaScreenState();
}

class _FlotaScreenState extends State<FlotaScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<FlotaProvider>().cargarVehiculos(),
    );
  }

  String _busqueda = '';
  String _tipoFiltro = 'Todos';
  String _estadoFiltro = 'Todos';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FlotaProvider>();
    final vehiculos = provider.vehiculos.where(_coincide).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Volver al centro de control',
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Gestión de Flota'),
        backgroundColor: const Color(0xFF102E29),
        foregroundColor: Colors.white,
        surfaceTintColor: const Color(0xFF102E29),
        actions: [
          IconButton(
            tooltip: context.watch<ThemeController>().isDark
                ? 'Activar modo claro'
                : 'Activar modo oscuro',
            onPressed: context.read<ThemeController>().toggle,
            icon: Icon(
              context.watch<ThemeController>().isDark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
          ),
          IconButton(
            tooltip: 'Actualizar flota',
            onPressed: () => context.read<FlotaProvider>().cargarVehiculos(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ModalFormularioVehiculo.mostrar(context),
        backgroundColor: const Color(0xFF167D62),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo vehículo'),
      ),
      body: provider.estaCargando && provider.vehiculos.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final compacto = constraints.maxWidth < 760;
                return ListView(
                  padding: EdgeInsets.fromLTRB(
                    compacto ? 16 : 30,
                    24,
                    compacto ? 16 : 30,
                    90,
                  ),
                  children: [
                    if (provider.error != null)
                      Card(
                        child: ListTile(
                          title: Text(provider.error!),
                          trailing: TextButton(
                            onPressed: provider.cargarVehiculos,
                            child: const Text('Reintentar'),
                          ),
                        ),
                      ),
                    _buildEncabezado(provider.vehiculos.length),
                    const SizedBox(height: 20),
                    _buildFiltros(compacto),
                    const SizedBox(height: 20),
                    if (vehiculos.isEmpty)
                      _buildVacio()
                    else
                      _buildVehiculos(vehiculos, compacto),
                  ],
                );
              },
            ),
    );
  }

  bool _coincide(VehiculoModel vehiculo) {
    final consulta = _busqueda.trim().toLowerCase();
    final texto =
        '${vehiculo.placa} ${vehiculo.tipo} ${vehiculo.anioFabricacion}'
            .toLowerCase();
    return (consulta.isEmpty || texto.contains(consulta)) &&
        (_tipoFiltro == 'Todos' || vehiculo.tipo == _tipoFiltro) &&
        (_estadoFiltro == 'Todos' || vehiculo.estado == _estadoFiltro);
  }

  Widget _buildEncabezado(int total) => Wrap(
    crossAxisAlignment: WrapCrossAlignment.end,
    alignment: WrapAlignment.spaceBetween,
    children: [
      const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tu flota',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF173D34),
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Vehículos disponibles para operar en Huancayo',
            style: TextStyle(color: Color(0xFF66736E)),
          ),
        ],
      ),
      Chip(
        avatar: const Icon(
          Icons.local_shipping_outlined,
          size: 18,
          color: Color(0xFF167D62),
        ),
        label: Text('$total registrados'),
        backgroundColor: const Color(0xFFEAF6F0),
        side: BorderSide.none,
      ),
    ],
  );

  Widget _buildFiltros(bool compacto) {
    final superficie = Theme.of(context).colorScheme.surface;
    final tipos = {
      'Todos',
      ...context.read<FlotaProvider>().vehiculos.map((v) => v.tipo),
    }.toList();
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        SizedBox(
          width: compacto ? double.infinity : 360,
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Buscar por placa, tipo o año',
              prefixIcon: Icon(Icons.search_rounded),
              border: OutlineInputBorder(),
              filled: true,
              fillColor: superficie,
            ),
            onChanged: (value) => setState(() => _busqueda = value),
          ),
        ),
        SizedBox(
          width: compacto ? double.infinity : 190,
          child: DropdownButtonFormField<String>(
            initialValue: _tipoFiltro,
            decoration: InputDecoration(
              labelText: 'Tipo',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: superficie,
            ),
            items: tipos
                .map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo)))
                .toList(),
            onChanged: (value) =>
                setState(() => _tipoFiltro = value ?? 'Todos'),
          ),
        ),
        SizedBox(
          width: compacto ? double.infinity : 190,
          child: DropdownButtonFormField<String>(
            initialValue: _estadoFiltro,
            decoration: InputDecoration(
              labelText: 'Estado',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: superficie,
            ),
            items: ['Todos', 'ACTIVO', 'INACTIVO']
                .map(
                  (estado) =>
                      DropdownMenuItem(value: estado, child: Text(estado)),
                )
                .toList(),
            onChanged: (value) =>
                setState(() => _estadoFiltro = value ?? 'Todos'),
          ),
        ),
      ],
    );
  }

  Widget _buildVehiculos(List<VehiculoModel> vehiculos, bool compacto) =>
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: vehiculos.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: compacto ? 1 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          mainAxisExtent: compacto ? 236 : 220,
        ),
        itemBuilder: (context, index) => _vehiculoCard(vehiculos[index]),
      );

  Widget _vehiculoCard(VehiculoModel vehiculo) {
    final color = _colorTipo(vehiculo.tipo);
    final estaActivo = vehiculo.estado == 'ACTIVO';
    final superficie = Theme.of(context).colorScheme.surface;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: superficie,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2EAE6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A173D34),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: color.withValues(alpha: .12),
                foregroundColor: color,
                child: Icon(_iconoTipo(vehiculo.tipo), size: 27),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehiculo.placa,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF173D34),
                      ),
                    ),
                    Text(
                      vehiculo.tipo,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Editar vehículo',
                onPressed: () => ModalFormularioVehiculo.mostrar(
                  context,
                  vehiculo: vehiculo,
                ),
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 18,
            runSpacing: 10,
            children: [
              _datoVehiculo(
                Icons.inventory_2_outlined,
                '${vehiculo.capacidadKg.toStringAsFixed(0)} kg',
                'capacidad',
              ),
              _datoVehiculo(
                Icons.local_gas_station_outlined,
                '${vehiculo.consumoKmL} km/L',
                'consumo',
              ),
              _datoVehiculo(
                Icons.co2_outlined,
                '${vehiculo.factorEmisionKgKm} kg/km',
                'emisión',
              ),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Fabricación ${vehiculo.anioFabricacion}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF66736E)),
              ),
              Chip(
                label: Text(
                  estaActivo ? 'ACTIVO' : 'DESACTIVADO',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: estaActivo
                        ? const Color(0xFF167D62)
                        : const Color(0xFF9A4B4B),
                  ),
                ),
                backgroundColor: estaActivo
                    ? const Color(0xFFEAF6F0)
                    : const Color(0xFFF9EAEA),
                side: BorderSide.none,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _datoVehiculo(IconData icon, String valor, String etiqueta) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 17, color: const Color(0xFF7A8B84)),
      const SizedBox(width: 5),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            valor,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          ),
          Text(
            etiqueta,
            style: const TextStyle(color: Color(0xFF8A9691), fontSize: 10),
          ),
        ],
      ),
    ],
  );

  Widget _buildVacio() {
    final superficie = Theme.of(context).colorScheme.surface;
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: superficie,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Column(
        children: [
          Icon(Icons.search_off_rounded, size: 44, color: Color(0xFF9AA9A2)),
          SizedBox(height: 10),
          Text(
            'No hay vehículos con esos filtros',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          Text(
            'Prueba otra placa, tipo o estado.',
            style: TextStyle(color: Color(0xFF66736E)),
          ),
        ],
      ),
    );
  }

  IconData _iconoTipo(String tipo) {
    final normalizado = tipo.toLowerCase();
    if (normalizado.contains('moto')) {
      return Icons.two_wheeler_rounded;
    }
    if (normalizado.contains('furg')) {
      return Icons.local_shipping_rounded;
    }
    if (normalizado.contains('carro') || normalizado.contains('auto')) {
      return Icons.directions_car_rounded;
    }
    return Icons.airport_shuttle_rounded;
  }

  Color _colorTipo(String tipo) {
    final normalizado = tipo.toLowerCase();
    if (normalizado.contains('moto')) {
      return const Color(0xFF8D5CB5);
    }
    if (normalizado.contains('furg')) {
      return const Color(0xFF3B6FB6);
    }
    if (normalizado.contains('carro') || normalizado.contains('auto')) {
      return const Color(0xFFC77B32);
    }
    return const Color(0xFF167D62);
  }
}
