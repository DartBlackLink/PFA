// Archivo: lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'core/router/app_router.dart';
import 'core/theme/theme_controller.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/providers/flota_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeController = ThemeController();
  await themeController.ready;

  // Inyección global de dependencias (Múltiples Módulos)
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (context) => FlotaProvider(context.read<AuthProvider>()),
        ), // Inyección del módulo Flota
        ChangeNotifierProvider.value(value: themeController),
      ],
      child: const EcoLogisticaWebApp(),
    ),
  );
}

class EcoLogisticaWebApp extends StatefulWidget {
  const EcoLogisticaWebApp({super.key});

  @override
  State<EcoLogisticaWebApp> createState() => _EcoLogisticaWebAppState();
}

class _EcoLogisticaWebAppState extends State<EcoLogisticaWebApp> {
  GoRouter? _router;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _router ??= AppRouter.crearRouter(context.read<AuthProvider>());
  }

  @override
  void dispose() {
    _router?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();

    return MaterialApp.router(
      title: 'EcoLogística Huancayo',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: AppTheme.build(Brightness.light),
      darkTheme: AppTheme.build(Brightness.dark),
      themeMode: themeController.mode,
    );
  }
}
