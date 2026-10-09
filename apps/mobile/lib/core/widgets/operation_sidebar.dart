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
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: scheme.outlineVariant)),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  collapsed ? 16 : 24,
                  28,
                  collapsed ? 16 : 24,
                  24,
                ),
                child: collapsed
                    ? Icon(Icons.eco_rounded, color: scheme.primary, size: 32)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.eco_rounded,
                                color: scheme.primary,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'EcoLogística',
                                  style: TextStyle(
                                    color: scheme.onSurface,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'PANEL ADMINISTRATIVO',
                            style: TextStyle(
                              color: scheme.onSurfaceVariant,
                              fontSize: 11,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    for (var i = 0; i < labels.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Semantics(
                          selected: selected == i,
                          child: Material(
                            color: selected == i
                                ? scheme.surfaceContainerHighest
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            child: collapsed
                                ? IconButton(
                                    tooltip: labels[i],
                                    onPressed: () => onSelected(i),
                                    icon: Icon(
                                      icons[i],
                                      color: selected == i
                                          ? scheme.primary
                                          : scheme.onSurfaceVariant,
                                    ),
                                  )
                                : ListTile(
                                    selected: selected == i,
                                    selectedColor: scheme.onSurface,
                                    textColor: scheme.onSurfaceVariant,
                                    iconColor: scheme.onSurfaceVariant,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 4,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    leading: Icon(
                                      icons[i],
                                      color: selected == i
                                          ? scheme.primary
                                          : scheme.onSurfaceVariant,
                                      size: 22,
                                    ),
                                    title: Text(
                                      labels[i],
                                      style: TextStyle(
                                        fontWeight: selected == i
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                      ),
                                    ),
                                    onTap: () => onSelected(i),
                                  ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(collapsed ? 16 : 24),
                child: Row(
                  children: [
                    Tooltip(
                      message: 'Administrador',
                      child: CircleAvatar(
                        backgroundColor: scheme.surfaceContainerHighest,
                        foregroundColor: scheme.onSurface,
                        child: const Icon(Icons.person_outline),
                      ),
                    ),
                    if (!collapsed) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Administrador\nGestión de operaciones',
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontSize: 12,
                            height: 1.6,
                          ),
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
