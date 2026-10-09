import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecologistica/core/theme/app_theme.dart';
import 'package:ecologistica/core/widgets/operation_sidebar.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('Menú expandido y contraído conserva navegación: $brightness', (
      tester,
    ) async {
      final theme = AppTheme.build(brightness);
      var collapsed = false;
      var selected = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: StatefulBuilder(
            builder: (context, setState) => Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  tooltip: collapsed ? 'Expandir menú' : 'Contraer menú',
                  onPressed: () => setState(() => collapsed = !collapsed),
                  icon: const Icon(Icons.menu),
                ),
              ),
              body: Row(
                children: [
                  SizedBox(
                    width: collapsed ? 80 : 248,
                    child: OperationSidebar(
                      collapsed: collapsed,
                      labels: const ['Resumen', 'Pedidos'],
                      icons: const [
                        Icons.dashboard_outlined,
                        Icons.inventory_2_outlined,
                      ],
                      selected: selected,
                      onSelected: (i) => setState(() => selected = i),
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                ],
              ),
            ),
          ),
        ),
      );
      expect(find.text('EcoLogística'), findsOneWidget);
      final sidebar = find.byType(OperationSidebar);
      expect(
        tester
            .widget<Material>(
              find
                  .descendant(of: sidebar, matching: find.byType(Material))
                  .first,
            )
            .color,
        theme.colorScheme.surface,
      );
      await tester.tap(find.text('Pedidos'));
      await tester.pumpAndSettle();
      expect(selected, 1);
      await tester.tap(find.byTooltip('Contraer menú'));
      await tester.pumpAndSettle();
      expect(tester.getSize(sidebar).width, 80);
      expect(find.text('EcoLogística'), findsNothing);
      expect(find.byTooltip('Pedidos'), findsOneWidget);
      await tester.tap(find.byTooltip('Resumen'));
      await tester.pumpAndSettle();
      expect(selected, 0);
      await tester.tap(find.byTooltip('Expandir menú'));
      await tester.pumpAndSettle();
      expect(tester.getSize(sidebar).width, 248);
      expect(find.text('EcoLogística'), findsOneWidget);
      expect(tester.takeException(), null);
    });
  }
}
