// Archivo: lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'core/router/app_router.dart';
import 'core/theme/theme_controller.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/providers/flota_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Inyección global de dependencias (Múltiples Módulos)
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (context) => FlotaProvider(context.read<AuthProvider>()),
        ), // Inyección del módulo Flota
        ChangeNotifierProvider(create: (_) => ThemeController()),
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
      title: 'EcoLogística Huancayo - Administrador',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: themeController.mode,
    );
  }

  ThemeData _theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF167D62),
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: dark
          ? const Color(0xFF0D1F1C)
          : const Color(0xFFF5F7FA),
      appBarTheme: AppBarTheme(
        backgroundColor: dark ? const Color(0xFF132C26) : Colors.white,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: dark ? const Color(0xFF17342D) : Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: dark ? const Color(0xFF315044) : const Color(0xFFE0E7E3),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF132C26) : const Color(0xFFF9FBFA),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant),
    );
  }
}
