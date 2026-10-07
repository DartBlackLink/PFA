import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/config/env.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({http.Client? client, this.apiUrl})
    : _client = client ?? http.Client() {
    ready = _restaurarSesion();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_bloqueoHasta != null) {
        if (segundosRestantes == 0) _bloqueoHasta = null;
        _notify();
      }
    });
  }
  final http.Client _client;
  final String? apiUrl;
  String get _base => apiUrl ?? EntornoConfig.apiBaseUrl;
  late final Future<void> ready;
  late final Timer _timer;
  bool _disposed = false, _estaCargando = false, _restaurando = true;
  String? _token, _rol, _error;
  String _correo = '';
  DateTime? _bloqueoHasta;
  bool get estaCargando => _estaCargando;
  bool get restaurando => _restaurando;
  bool get estaAutenticado => _token != null && _rol != null;
  bool get esAdministrador => _rol == 'ADMIN';
  bool get esRepartidor => _rol == 'REPARTIDOR';
  String? get token => _token;
  String? get rol => _rol;
  String? get error => _error;
  int get segundosRestantes {
    final ms = _bloqueoHasta?.difference(DateTime.now()).inMilliseconds ?? 0;
    return ms <= 0 ? 0 : (ms / 1000).ceil();
  }

  bool get bloqueado => segundosRestantes > 0;
  String get contador {
    final s = segundosRestantes;
    return s < 60
        ? '$s segundos'
        : '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> actualizarCorreo(String value) async {
    final email = value.trim().toLowerCase();
    if (_correo == email) return;
    _correo = email;
    _error = null;
    _bloqueoHasta = null;
    final prefs = await SharedPreferences.getInstance();
    if (_correo != email || _disposed) return;
    final saved = prefs.getInt('login_wait_$email');
    if (saved != null) {
      _bloqueoHasta = DateTime.fromMillisecondsSinceEpoch(saved);
    }
    _notify();
  }

  Future<void> _restaurarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('auth_token');
    try {
      if (saved != null) {
        final response = await _client
            .get(
              Uri.parse('$_base/auth/me'),
              headers: {'Authorization': 'Bearer $saved'},
            )
            .timeout(const Duration(seconds: 12));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (['ADMIN', 'REPARTIDOR'].contains(data['rol'])) {
            _token = saved;
            _rol = data['rol'];
          }
        }
      }
    } catch (_) {
      _error = 'No se pudo verificar la sesión. Inicia sesión nuevamente.';
    }
    if (_token == null) {
      await prefs.remove('auth_token');
      await prefs.remove('auth_role');
    }
    _restaurando = false;
    _notify();
  }

  Future<bool> iniciarSesion(String correo, String contrasena) async {
    if (_estaCargando) return false;
    await ready;
    await actualizarCorreo(correo);
    if (bloqueado || _estaCargando || _disposed) return false;
    _estaCargando = true;
    _error = null;
    _notify();
    final email = correo.trim().toLowerCase();
    final prefs = await SharedPreferences.getInstance();
    try {
      final response = await _client
          .post(
            Uri.parse('$_base/auth/login'),
            body: {'username': email, 'password': contrasena},
          )
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 429) {
        final seconds =
            int.tryParse(response.headers['retry-after'] ?? '') ?? 300;
        final until = DateTime.now().add(Duration(seconds: seconds));
        await prefs.setInt('login_wait_$email', until.millisecondsSinceEpoch);
        if (_correo == email) _bloqueoHasta = until;
        _error = 'Acceso temporalmente bloqueado. Espera antes de volver a intentar.';
        return false;
      }
      if (response.statusCode != 200) {
        _error = response.statusCode >= 500
            ? 'El servicio no está disponible.'
            : 'Correo o contraseña incorrectos.';
        return false;
      }
      final data = jsonDecode(response.body);
      if (!['ADMIN', 'REPARTIDOR'].contains(data['rol']) ||
          data['access_token'] is! String) {
        throw const FormatException('Respuesta inválida');
      }
      _token = data['access_token'];
      _rol = data['rol'];
      await prefs.setString('auth_token', _token!);
      await prefs.setString('auth_role', _rol!);
      await prefs.remove('login_wait_$email');
      _bloqueoHasta = null;
      return true;
    } on TimeoutException {
      _error = 'La API tarda en responder. Comprueba la conexión.';
      return false;
    } catch (_) {
      _error = 'No se pudo conectar. Comprueba que el backend esté activo.';
      return false;
    } finally {
      _estaCargando = false;
      _notify();
    }
  }

  Future<void> cerrarSesion({String? mensaje}) async {
    _token = null;
    _rol = null;
    _error = mensaje;
    _notify();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_role');
  }

  @override
  void dispose() {
    _disposed = true;
    _timer.cancel();
    _client.close();
    super.dispose();
  }
}
