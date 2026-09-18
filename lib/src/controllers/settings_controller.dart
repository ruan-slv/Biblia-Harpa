/// Implementa o serviço que dá suporte à camada de apresentação.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _fontSizeKey = 'fontSize';

  ThemeMode _themeMode = ThemeMode.light;
  double _fontSize = 20.0;

  ThemeMode get themeMode => _themeMode;
  double get fontSize => _fontSize;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> initialize() async {
    await loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);
    if (savedTheme == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }
    _fontSize = prefs.getDouble(_fontSizeKey) ?? 20.0;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, _themeMode == ThemeMode.dark ? 'dark' : 'light');
  }

  Future<void> increaseFontSize() async {
    _fontSize += 1.0;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, _fontSize);
  }

  Future<void> decreaseFontSize() async {
    _fontSize -= 1.0;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, _fontSize);
  }
}
