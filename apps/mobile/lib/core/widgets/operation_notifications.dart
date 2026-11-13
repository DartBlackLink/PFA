import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../network/api_client.dart';
import 'record_widgets.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/rutas/presentation/route_detail_screen.dart';

/// Durable inbox; reading a notification is deliberately separate from route ACK.
class OperationNotifications extends StatefulWidget {
  const OperationNotifications({super.key});
  @override
  State<OperationNotifications> createState() => _OperationNotificationsState();
}

class _OperationNotificationsState extends State<OperationNotifications> {
  Timer? _timer;
  List<dynamic> _items = [];
  String? _error;
  bool _loading = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted || _loading || context.read<AuthProvider>().token == null) {
      return;
    }
    _loading = true;
    try {
      final items = await ApiClient(context.read<AuthProvider>())
          .request('/operations/notifications');
      if (mounted) {
        setState(() {
          _items = items as List;
          _error = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Sin conexión con notificaciones. Reintentamos cada 10 s; los avisos se conservan.',
        );
      }
    } finally {
      _loading = false;
    }
  }

  Future<void> _open() async {
    await _load();
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('Notificaciones de operación'),
        content: SizedBox(
          width: 520,
          height: 380,
          child: ListView(
            children: [
              if (_error != null) Text(_error!),
              if (_items.isEmpty)
                const Text('No hay notificaciones registradas.'),
              for (final item in _items)
                ListTile(
                  leading: Icon(
                    item['leida'] == true
                        ? Icons.notifications_none
                        : Icons.notifications_active_outlined,
                  ),
                  title: Text('${item['tipo']}'.replaceAll('_', ' ')),
                  subtitle: Text(
                    'Ruta ${item['ruta_id'].toString().substring(0, 8)} · ${friendlyDate(item['creado_en'])} · hora Perú',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final api = ApiClient(context.read<AuthProvider>());
                    try {
                      await api.request(
                        '/operations/notifications/${item['id']}/read',
                        method: 'POST',
                      );
                      if (!mounted || !dialog.mounted) return;
                      Navigator.pop(dialog);
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              RouteDetailScreen(routeId: item['ruta_id']),
                        ),
                      );
                      await _load();
                    } catch (e) {
                      if (dialog.mounted) {
                        ScaffoldMessenger.of(dialog)
                            .showSnackBar(SnackBar(content: Text('$e')));
                      }
                    }
                  },
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: _error ?? 'Notificaciones de operación',
    onPressed: _open,
    icon: Badge.count(
      count: _items.where((i) => i['leida'] != true).length,
      isLabelVisible: _items.any((i) => i['leida'] != true),
      child: const Icon(Icons.notifications_outlined),
    ),
  );
}
