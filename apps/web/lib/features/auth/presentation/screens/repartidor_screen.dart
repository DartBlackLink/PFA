import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../../../../core/network/api_client.dart';
import '../../../rutas/presentation/route_detail_screen.dart';

class RepartidorScreen extends StatefulWidget {
  const RepartidorScreen({super.key});
  @override
  State<RepartidorScreen> createState() => _RepartidorScreenState();
}

class _RepartidorScreenState extends State<RepartidorScreen> {
  Map<String, dynamic>? _profile;
  List<dynamic> _routes = [];
  String? _error;
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final api = ApiClient(context.read<AuthProvider>());
    try {
      final routes = await api.request('/routes/');
      Map<String, dynamic>? profile;
      try {
        profile = await api.request('/drivers/me');
      } catch (_) {
        profile = null;
      }
      if (mounted) {
        setState(() {
          _profile = profile;
          _routes = routes as List;
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

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Mi operación'),
      actions: [
        IconButton(
          tooltip: 'Actualizar',
          onPressed: _load,
          icon: const Icon(Icons.refresh),
        ),
        IconButton(
          tooltip: 'Cerrar sesión',
          onPressed: () => context.read<AuthProvider>().cerrarSesion(),
          icon: const Icon(Icons.logout),
        ),
      ],
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (_error != null)
                Card(
                  child: ListTile(
                    title: Text(_error!),
                    trailing: TextButton(
                      onPressed: _load,
                      child: const Text('Reintentar'),
                    ),
                  ),
                ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mi perfil',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _profile == null
                            ? 'Solicita al administrador completar tu perfil.'
                            : '${_profile!['nombre']}\nDNI: ${_profile!['dni']}\nLicencia: ${_profile!['licencia']}\nContacto: ${_profile!['contacto'] ?? 'Completar'}\nHorario: ${_profile!['disponible_desde'] ?? 'Completar'} — ${_profile!['disponible_hasta'] ?? 'Completar'}',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Mis rutas asignadas',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              if (_routes.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('Todavía no tienes rutas asignadas.'),
                ),
              ..._routes.map(
                (r) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.route),
                    title: Text('Ruta ${r['ruta_id']}'),
                    subtitle: Text(
                      '${r['estado']} · ${(r['entregas'] as List).length} entregas',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            RouteDetailScreen(routeId: r['ruta_id']),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
  );
}
