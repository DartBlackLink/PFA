import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeController() {
    ready = _restore();
  }
  ThemeMode _mode = ThemeMode.light;
  late final Future<void> ready;
  SharedPreferences? _preferences;
  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  Future<void> _restore() async {
    try {
      _preferences = await SharedPreferences.getInstance();
      _mode = _preferences!.getBool('ecologistica_dark_theme') == true
          ? ThemeMode.dark
          : ThemeMode.light;
      notifyListeners();
    } catch (_) {
      // La interfaz sigue disponible si el almacenamiento local no responde.
    }
  }

  void toggle() {
    _mode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    _persist();
  }

  Future<void> _persist() async {
    try {
      await _preferences?.setBool('ecologistica_dark_theme', isDark);
    } catch (_) {
      /* Preferencia opcional. */
    }
  }
}
