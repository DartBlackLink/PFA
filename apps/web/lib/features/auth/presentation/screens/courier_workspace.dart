import 'package:flutter/material.dart';

import '../../../../core/widgets/record_widgets.dart';

/// Presentation of the authenticated courier's server-filtered resources.
class CourierWorkspace extends StatefulWidget {
  const CourierWorkspace({
    super.key,
    required this.routes,
    required this.profile,
    required this.onOpen,
    required this.onRefresh,
    this.error,
    this.profileError,
  });
  final List<dynamic> routes;
  final Map<String, dynamic>? profile;
  final Future<void> Function(Map<String, dynamic>) onOpen;
  final Future<void> Function() onRefresh;
  final String? error, profileError;

  @override
  State<CourierWorkspace> createState() => _CourierWorkspaceState();
}

class _CourierWorkspaceState extends State<CourierWorkspace> {
  String _filter = 'Todas';
  bool _active(Map route) =>
      ['PLANIFICADA', 'EN_CURSO'].contains(route['estado']);

  Widget _metric(
    BuildContext context,
    String label,
    int value,
    IconData icon,
  ) => SizedBox(
    width: 220,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$value',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(label),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final routes = widget.routes
        .map((r) => Map<String, dynamic>.from(r as Map))
        .toList();
    final visible = routes
        .where(
          (r) =>
              _filter == 'Todas' ||
              (_filter == 'Activas' ? _active(r) : !_active(r)),
        )
        .toList();
    final pending = routes
        .where(_active)
        .expand((r) => (r['entregas'] as List? ?? const []))
        .where((e) => e['estado_entrega'] != 'ENTREGADO')
        .length;
    final updates = routes
        .where(
          (r) =>
              (r['version'] as num? ?? 1) >
              (r['version_recibida'] as num? ?? 0),
        )
        .length;
    final profile = widget.profile;
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Tu jornada de entregas',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Huancayo y alrededores · Consulta tu planificación y opera cuando estés detenido en un lugar seguro.',
                  ),
                  if (widget.error != null) ...[
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'No se pudieron actualizar los datos. Se conserva la última consulta disponible.',
                            ),
                            Text(widget.error!),
                            TextButton(
                              onPressed: widget.onRefresh,
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _metric(
                        context,
                        'Rutas activas',
                        routes.where(_active).length,
                        Icons.alt_route,
                      ),
                      _metric(
                        context,
                        'Entregas pendientes',
                        pending,
                        Icons.inventory_2_outlined,
                      ),
                      _metric(
                        context,
                        'Versiones por recibir',
                        updates,
                        Icons.mark_email_unread_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Card(
                    child: ExpansionTile(
                      leading: const Icon(Icons.badge_outlined),
                      title: const Text('Mi perfil'),
                      subtitle: Text(
                        profile?['nombre']?.toString() ?? 'Datos de tu jornada',
                      ),
                      childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (profile != null) ...[
                          StatusBadge('${profile['estado']}'),
                          const SizedBox(height: 12),
                          Text(
                            'DNI: ${profile['dni']} · Licencia: ${profile['licencia']}',
                          ),
                          Text(
                            'Contacto: ${profile['contacto'] ?? 'Completar'}',
                          ),
                          Text(
                            'Turno configurado: ${profile['disponible_desde'] ?? 'Completar'} — ${profile['disponible_hasta'] ?? 'Completar'} · hora Perú',
                          ),
                        ],
                        if (widget.profileError != null)
                          Text(widget.profileError!),
                        if (profile == null && widget.profileError == null)
                          const Text(
                            'Solicita al administrador completar tu perfil.',
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Mis rutas asignadas',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['Todas', 'Activas', 'Historial']
                        .map(
                          (label) => ChoiceChip(
                            label: Text(label),
                            selected: _filter == label,
                            onSelected: (_) => setState(() => _filter = label),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    countLabel(
                      visible.length,
                      'recorrido disponible',
                      'recorridos disponibles',
                    ),
                  ),
                  if (visible.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        routes.isEmpty
                            ? 'Todavía no tienes rutas asignadas. Las nuevas asignaciones aparecerán aquí.'
                            : 'No hay recorridos en esta vista. Puedes consultar las otras opciones.',
                      ),
                    ),
                  ...visible.map(
                    (r) => Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: const Icon(Icons.route_outlined),
                          title: Text(
                            'Recorrido · ${r['vehiculo_placa'] ?? 'Vehículo asignado'}',
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                StatusBadge('${r['estado']}'),
                                const SizedBox(height: 8),
                                Text(
                                  '${countLabel((r['entregas'] as List? ?? const []).length, 'entrega', 'entregas')} · ${r['distancia_km'] ?? '—'} km · ${r['tiempo_min'] ?? '—'} min estimados',
                                ),
                                if (r['inicio_planificado'] != null)
                                  Text(
                                    'Salida: ${friendlyDate(r['inicio_planificado'])}',
                                  ),
                                Text(
                                  'Versión ${r['version'] ?? 1} · recibida: ${r['version_recibida'] ?? 0}',
                                ),
                              ],
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => widget.onOpen(r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
