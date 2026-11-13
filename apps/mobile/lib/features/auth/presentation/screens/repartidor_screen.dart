import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/operation_notifications.dart';

import '../providers/auth_provider.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/theme_controller.dart';
import 'courier_workspace.dart';
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
  String? _profileError;
  bool _loading = true;
  bool _refreshing = false;
  bool _loadedOnce = false;
  Timer? _refreshTimer;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted && (ModalRoute.of(context)?.isCurrent ?? false)) _load();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted || _refreshing) return;
    _refreshing = true;
    setState(() {
      _loading = !_loadedOnce;
      _error = null;
      _profileError = null;
    });
    final api = ApiClient(context.read<AuthProvider>());
    try {
      final routes = await api.request('/routes/');
      Map<String, dynamic>? profile;
      try {
        profile = await api.request('/drivers/me');
      } catch (error) {
        profile = null;
        _profileError = error.toString().replaceFirst('Exception: ', '');
      }
      if (mounted) {
        setState(() {
          _profile = profile ?? _profile;
          _routes = routes as List;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      _refreshing = false;
      _loadedOnce = true;
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Mi operación'),
      actions: [
        const OperationNotifications(),
        IconButton(
          tooltip: 'Cambiar tema',
          onPressed: context.read<ThemeController>().toggle,
          icon: Icon(
            context.watch<ThemeController>().isDark
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined,
          ),
        ),
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
        : CourierWorkspace(
            routes: _routes,
            profile: _profile,
            error: _error,
            profileError: _profileError,
            onRefresh: _load,
            onOpen: (route) async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RouteDetailScreen(routeId: route['ruta_id']),
                ),
              );
              if (mounted) await _load();
            },
          ),
  );
}
