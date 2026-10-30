import 'package:flutter/material.dart';

class OperationSidebar extends StatelessWidget {
  const OperationSidebar({
    super.key,
    required this.collapsed,
    required this.labels,
    required this.icons,
    required this.selected,
    required this.onSelected,
  });
  final bool collapsed;
  final List<String> labels;
  final List<IconData> icons;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Material(
      color: s.surface,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: s.outlineVariant)),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  collapsed ? 18 : 22,
                  28,
                  collapsed ? 18 : 20,
                  30,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: s.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.eco_rounded,
                        color: s.onPrimary,
                        size: 26,
                      ),
                    ),
                    if (!collapsed) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'EcoLogística',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -.6,
                                color: s.onSurface,
                              ),
                            ),
                            Text(
                              'HUANCAYO',
                              style: TextStyle(
                                fontSize: 10,
                                letterSpacing: 2,
                                color: s.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!collapsed)
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 0, 20, 14),
                  child: Text(
                    'ESPACIO DE TRABAJO',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1.3,
                      fontWeight: FontWeight.w700,
                      color: s.onSurfaceVariant,
                    ),
                  ),
                ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    for (var i = 0; i < labels.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 7),
                        child: Semantics(
                          selected: selected == i,
                          child: Material(
                            color: selected == i
                                ? s.primaryContainer
                                : Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: selected == i
                                    ? s.primary.withValues(alpha: .2)
                                    : Colors.transparent,
                              ),
                            ),
                            child: collapsed
                                ? IconButton(
                                    tooltip: labels[i],
                                    onPressed: () => onSelected(i),
                                    icon: Icon(
                                      icons[i],
                                      color: selected == i
                                          ? s.onPrimaryContainer
                                          : s.onSurfaceVariant,
                                    ),
                                  )
                                : ListTile(
                                    dense: true,
                                    minTileHeight: 52,
                                    selected: selected == i,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    leading: Icon(
                                      icons[i],
                                      size: 21,
                                      color: selected == i
                                          ? s.onPrimaryContainer
                                          : s.onSurfaceVariant,
                                    ),
                                    title: Text(
                                      labels[i],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: selected == i
                                            ? s.onPrimaryContainer
                                            : s.onSurfaceVariant,
                                        fontWeight: selected == i
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                      ),
                                    ),
                                    trailing: selected == i
                                        ? Icon(
                                            Icons.chevron_right,
                                            color: s.onPrimaryContainer,
                                            size: 18,
                                          )
                                        : null,
                                    onTap: () => onSelected(i),
                                  ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (!collapsed)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: s.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.route_outlined, size: 19, color: s.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Cada destino cuenta.\nOrganiza tus entregas desde aquí.',
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.55,
                              color: s.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Divider(height: 1, color: s.outlineVariant),
              Padding(
                padding: EdgeInsets.all(collapsed ? 18 : 20),
                child: Row(
                  children: [
                    Tooltip(
                      message: 'Administrador',
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: s.surfaceContainerHighest,
                        foregroundColor: s.onSurface,
                        child: const Icon(Icons.person_outline, size: 21),
                      ),
                    ),
                    if (!collapsed) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Administrador',
                              style: TextStyle(
                                color: s.onSurface,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Gestión de operaciones',
                              style: TextStyle(
                                color: s.onSurfaceVariant,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
