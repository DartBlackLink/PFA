// Archivo: lib/features/flota/presentation/widgets/modal_formulario_vehiculo.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/vehiculo_model.dart';
import '../../../../features/auth/presentation/providers/flota_provider.dart';
import '../../../../core/widgets/modal_alerta.dart';

/// Modal para Crear o Editar un Vehículo sin recargar la página.
/// Cumple la directiva estricta de Modales UX/UI.
class ModalFormularioVehiculo extends StatefulWidget {
  final VehiculoModel? vehiculoExistente;

  const ModalFormularioVehiculo({super.key, this.vehiculoExistente});

  static void mostrar(BuildContext context, {VehiculoModel? vehiculo}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ModalFormularioVehiculo(vehiculoExistente: vehiculo),
    );
  }

  @override
  State<ModalFormularioVehiculo> createState() =>
      _ModalFormularioVehiculoState();
}

class _ModalFormularioVehiculoState extends State<ModalFormularioVehiculo> {
  final _llaveFormulario = GlobalKey<FormState>();

  late TextEditingController _placaCtrl;
  late TextEditingController _tipoCtrl;
  late TextEditingController _capacidadCtrl;
  late TextEditingController _consumoCtrl;
  late TextEditingController _emisionCtrl;
  late TextEditingController _anioCtrl;
  late String _estado;

  @override
  void initState() {
    super.initState();
    final v = widget.vehiculoExistente;
    _placaCtrl = TextEditingController(text: v?.placa ?? '');
    _tipoCtrl = TextEditingController(text: v?.tipo ?? 'Camioneta');
    _capacidadCtrl = TextEditingController(
      text: v?.capacidadKg.toString() ?? '',
    );
    _consumoCtrl = TextEditingController(text: v?.consumoKmL.toString() ?? '');
    _emisionCtrl = TextEditingController(
      text: v?.factorEmisionKgKm.toString() ?? '',
    );
    _anioCtrl = TextEditingController(
      text: v?.anioFabricacion.toString() ?? '',
    );
    _estado = v?.estado ?? 'ACTIVO';
  }

  @override
  void dispose() {
    _placaCtrl.dispose();
    _tipoCtrl.dispose();
    _capacidadCtrl.dispose();
    _consumoCtrl.dispose();
    _emisionCtrl.dispose();
    _anioCtrl.dispose();
    super.dispose();
  }

  String? _numero(String? value, {required bool positivo}) {
    final n = double.tryParse(value ?? '');
    if (n == null || !n.isFinite) return 'Ingresa un número válido';
    return positivo
        ? (n > 0 ? null : 'Debe ser mayor que cero')
        : (n >= 0 ? null : 'No puede ser negativo');
  }

  Future<void> _guardar(BuildContext context) async {
    if (!_llaveFormulario.currentState!.validate()) return;

    final provider = Provider.of<FlotaProvider>(context, listen: false);

    final nuevoVehiculo = VehiculoModel(
      vehiculoId: widget.vehiculoExistente?.vehiculoId,
      placa: _placaCtrl.text.trim().toUpperCase(),
      tipo: _tipoCtrl.text.trim(),
      capacidadKg: double.tryParse(_capacidadCtrl.text) ?? 0,
      consumoKmL: double.tryParse(_consumoCtrl.text) ?? 0,
      factorEmisionKgKm: double.tryParse(_emisionCtrl.text) ?? 0,
      anioFabricacion: int.tryParse(_anioCtrl.text) ?? 2020,
      estado: _estado,
    );

    final exito = await provider.guardarVehiculo(nuevoVehiculo);

    if (!context.mounted) return;

    if (exito) {
      Navigator.of(context).pop();
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(
          content: Text('Vehículo guardado correctamente'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ModalAlerta.mostrarError(
        context,
        'Error',
        provider.error ?? 'No se pudo guardar el vehículo.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final estaCargando = context.watch<FlotaProvider>().estaCargando;

    return AlertDialog(
      title: Text(
        widget.vehiculoExistente == null ? 'Nuevo Vehículo' : 'Editar Vehículo',
      ),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _llaveFormulario,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _placaCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Placa',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      RegExp(r'^[A-Za-z0-9-]{3,15}$').hasMatch(v?.trim() ?? '')
                      ? null
                      : 'Placa inválida',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _tipoCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tipo (Camioneta, Furgón, Moto)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v?.trim().length ?? 0) >= 2 ? null : 'Indica el tipo',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _capacidadCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Capacidad (kg)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) => _numero(v, positivo: true),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _anioCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Año Fabricación',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          final n = int.tryParse(v ?? '');
                          return n != null &&
                                  n >= 1950 &&
                                  n <= DateTime.now().year + 1
                              ? null
                              : 'Año inválido';
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _consumoCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Consumo (km/L)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) => _numero(v, positivo: true),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _emisionCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Factor CO2 (kg/km)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) => _numero(v, positivo: false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _estado,
                  decoration: const InputDecoration(
                    labelText: 'Estado operativo',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.toggle_on_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'ACTIVO', child: Text('Activo')),
                    DropdownMenuItem(
                      value: 'INACTIVO',
                      child: Text('Desactivado'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _estado = value);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: estaCargando
              ? null
              : () {
                  final messenger = ScaffoldMessenger.maybeOf(context);
                  Navigator.of(context).pop();
                  messenger?.showSnackBar(
                    const SnackBar(
                      content: Text('Operación cancelada'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: estaCargando ? null : () => _guardar(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E88E5),
            foregroundColor: Colors.white,
          ),
          child: estaCargando
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }
}
