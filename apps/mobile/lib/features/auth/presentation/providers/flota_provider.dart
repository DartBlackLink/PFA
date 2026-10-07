import 'package:flutter/material.dart';

import '../../../../core/network/api_client.dart';
import '../../../../flota/data/models/vehiculo_model.dart';
import 'auth_provider.dart';

class FlotaProvider extends ChangeNotifier {
  FlotaProvider(AuthProvider auth) : _api = ApiClient(auth);
  final ApiClient _api;
  bool _estaCargando = false;
  List<VehiculoModel> _vehiculos = [];
  String? _error;
  String? get error => _error;
  bool get estaCargando => _estaCargando;
  List<VehiculoModel> get vehiculos => List.unmodifiable(_vehiculos);

  Future<void> cargarVehiculos() async {
    _error = null;
    _estaCargando = true;
    notifyListeners();
    try {
      final data = await _api.request('/vehicles/?limit=1000') as List;
      _vehiculos = data
          .map((e) => VehiculoModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _estaCargando = false;
      notifyListeners();
    }
  }

  Future<bool> guardarVehiculo(VehiculoModel vehiculo) async {
    _error = null;
    _estaCargando = true;
    notifyListeners();
    try {
      final edit = vehiculo.vehiculoId?.isNotEmpty ?? false;
      await _api.request(
        edit ? '/vehicles/${vehiculo.vehiculoId}' : '/vehicles/',
        method: edit ? 'PUT' : 'POST',
        body: vehiculo.toJson(),
      );
      await cargarVehiculos();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _estaCargando = false;
      notifyListeners();
    }
  }
}
