// Archivo: lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/auth/presentation/screens/repartidor_screen.dart';
import '../../flota/presentation/screens/flota_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

class AppRouter {
  static GoRouter crearRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/login',
      refreshListenable: authProvider,
      redirect: (BuildContext context, GoRouterState state) {
        final bool estaAutenticado = authProvider.estaAutenticado;
        final bool estaEnLogin = state.matchedLocation == '/login';

        if (!estaAutenticado && !estaEnLogin) return '/login';
        if (estaAutenticado && estaEnLogin) {
          return authProvider.esRepartidor ? '/repartidor' : '/dashboard';
        }
        if (estaAutenticado &&
            authProvider.esRepartidor &&
            state.matchedLocation != '/repartidor') {
          return '/repartidor';
        }
        if (estaAutenticado &&
            authProvider.esAdministrador &&
            state.matchedLocation == '/repartidor') {
          return '/dashboard';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          name: 'dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/repartidor',
          name: 'repartidor',
          builder: (context, state) => const RepartidorScreen(),
        ),
        // NUEVA RUTA PROTEGIDA: Flota
        GoRoute(
          path: '/flota',
          name: 'flota',
          builder: (context, state) => const FlotaScreen(),
        ),
      ],
    );
  }
}
