import 'package:flutter/material.dart';

/// Solo presenta los registros cargados: no calcula indicadores ambientales.
class OperationOverview extends StatelessWidget {
  const OperationOverview({
    super.key,
    required this.orders,
    required this.drivers,
    required this.vehicles,
    required this.routes,
    required this.onNewOrder,
    required this.onOrders,
    required this.onRoutes,
    required this.onTeam,
    required this.onFleet,
    required this.onOrderDetail,
  });
  final List<Map<String, dynamic>> orders, drivers, vehicles, routes;
  final VoidCallback onNewOrder, onOrders, onRoutes, onTeam, onFleet;
  final ValueChanged<Map<String, dynamic>> onOrderDetail;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final pending = orders.where((o) => o['estado'] == 'PENDIENTE').length;
    final activeDrivers = drivers.where((d) => d['estado'] == 'ACTIVO').length;
    final activeVehicles = vehicles
        .where((v) => v['estado'] == 'ACTIVO')
        .length;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 12,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Resumen de operaciones', style: text.headlineSmall),
                  const SizedBox(height: 6),
                  Text(
                    'Lo esencial para organizar tus próximas entregas.',
                    style: TextStyle(color: s.onSurfaceVariant),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: s.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: s.outlineVariant),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: s.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Huancayo, Perú',
                      style: TextStyle(fontSize: 12, color: s.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 650;
              return Container(
                padding: EdgeInsets.all(compact ? 24 : 30),
                decoration: BoxDecoration(
                  color: const Color(0xFF263449),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TU CENTRO DE OPERACIONES',
                            style: TextStyle(
                              color: Color(0xFFC9D5E6),
                              fontSize: 10,
                              letterSpacing: 1.7,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Planifica la próxima entrega.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: compact ? 26 : 32,
                              height: 1.15,
                              letterSpacing: -.7,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Del pedido al recorrido. Tu equipo y tus destinos, en un mismo espacio.',
                            style: TextStyle(
                              color: Color(0xFFD7DFEA),
                              fontSize: 14,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 22),
                          FilledButton.icon(
                            onPressed: onNewOrder,
                            icon: const Icon(Icons.add, size: 20),
                            label: const Text('Registrar pedido'),
                            style: FilledButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? s.primary
                                  : const Color(0xFFEAF4EF),
                              foregroundColor:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? s.onPrimary
                                  : const Color(0xFF204B39),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!compact) ...[
                      const SizedBox(width: 24),
                      ExcludeSemantics(
                        child: SizedBox(
                          width: constraints.maxWidth > 950 ? 240 : 170,
                          height: 150,
                          child: CustomPaint(painter: _RouteMotif()),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 900
                  ? 4
                  : constraints.maxWidth >= 450
                  ? 2
                  : 1;
              final width =
                  (constraints.maxWidth - 16 * (columns - 1)) / columns;
              final data = [
                (
                  'Pedidos',
                  orders.length,
                  'Total registrado',
                  Icons.inventory_2_outlined,
                ),
                (
                  'Repartidores',
                  activeDrivers,
                  'Perfiles activos',
                  Icons.badge_outlined,
                ),
                (
                  'Vehículos',
                  activeVehicles,
                  'Flota activa',
                  Icons.local_shipping_outlined,
                ),
                (
                  'Rutas',
                  routes.length,
                  'Recorridos registrados',
                  Icons.route_outlined,
                ),
              ];
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  for (final item in data)
                    SizedBox(
                      width: width,
                      child: Card(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: switch (item.$1) {
                            'Pedidos' => onOrders,
                            'Repartidores' => onTeam,
                            'Vehículos' => onFleet,
                            _ => onRoutes,
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(9),
                                      decoration: BoxDecoration(
                                        color: s.primaryContainer,
                                        borderRadius: BorderRadius.circular(11),
                                      ),
                                      child: Icon(
                                        item.$4,
                                        size: 20,
                                        color: s.onPrimaryContainer,
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(
                                      Icons.north_east,
                                      size: 16,
                                      color: s.onSurfaceVariant,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Text('${item.$2}', style: text.headlineLarge),
                                const SizedBox(height: 4),
                                Text(item.$1, style: text.titleMedium),
                                Text(
                                  item.$3,
                                  style: TextStyle(
                                    color: s.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final tasks = Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.pending_actions_outlined,
                            color: s.secondary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Por organizar',
                              style: text.titleLarge,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: s.secondaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$pending',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: s.onSecondaryContainer,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pending == 0
                                      ? 'Sin pedidos pendientes'
                                      : 'Pedidos por asignar',
                                  style: text.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  pending == 0
                                      ? 'Puedes consultar tus recorridos registrados.'
                                      : 'Revisa el destino y elige al repartidor y vehículo.',
                                  style: TextStyle(
                                    color: s.onSurfaceVariant,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: onRoutes,
                            icon: const Icon(Icons.alt_route, size: 18),
                            label: const Text('Organizar rutas'),
                          ),
                          TextButton(
                            onPressed: onTeam,
                            child: const Text('Ver equipo'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
              final distribution = Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Estado de los pedidos', style: text.titleLarge),
                      const SizedBox(height: 8),
                      Text(
                        'Distribución de los registros actuales',
                        style: TextStyle(
                          fontSize: 12,
                          color: s.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (orders.isEmpty)
                        const Text('Registra un pedido para empezar.')
                      else ...[
                        for (final state in [
                          'PENDIENTE',
                          'ASIGNADO',
                          'EN_RUTA',
                          'ENTREGADO',
                          'CANCELADO',
                        ])
                          if (orders.any((o) => o['estado'] == state))
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      state.replaceAll('_', ' '),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: s.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${orders.where((o) => o['estado'] == state).length}',
                                    style: text.titleMedium,
                                  ),
                                ],
                              ),
                            ),
                      ],
                    ],
                  ),
                ),
              );
              if (constraints.maxWidth < 820) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [tasks, const SizedBox(height: 16), distribution],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 6, child: tasks),
                  const SizedBox(width: 20),
                  Expanded(flex: 5, child: distribution),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text('Pedidos para consultar', style: text.titleLarge),
                      TextButton.icon(
                        onPressed: onOrders,
                        icon: const Icon(Icons.arrow_forward, size: 16),
                        label: const Text('Ver todos'),
                      ),
                    ],
                  ),
                  Text(
                    'Una vista rápida de tus registros y destinos.',
                    style: TextStyle(fontSize: 13, color: s.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  if (orders.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('Todavía no hay pedidos registrados.'),
                    ),
                  for (final order in orders.reversed.take(5))
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 6),
                        title: Text(
                          '${order['cliente_nombre'] ?? 'Cliente'}',
                          style: text.titleMedium,
                        ),
                        subtitle: Text(
                          '${order['direccion']}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => onOrderDetail(order),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'EcoLogística · Gestión de entregas',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: s.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// Ilustración de marca, no representa una ruta real ni seguimiento GPS.
class _RouteMotif extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = const Color(0xFF39485E)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 32) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += 32) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final path = Path()
      ..moveTo(18, size.height * .78)
      ..cubicTo(
        size.width * .65,
        size.height * .98,
        size.width * .2,
        -10,
        size.width - 15,
        size.height * .23,
      );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFE6BD7D)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke,
    );
    for (final p in [
      Offset(18, size.height * .78),
      Offset(size.width - 15, size.height * .23),
    ]) {
      canvas.drawCircle(p, 13, Paint()..color = const Color(0xFF49576B));
      canvas.drawCircle(p, 6, Paint()..color = const Color(0xFFF7D9A4));
    }
  }

  @override
  bool shouldRepaint(covariant _RouteMotif oldDelegate) => false;
}
