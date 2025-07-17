import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController {
  static final ValueNotifier<ThemeMode> themeNotifier =
  ValueNotifier(ThemeMode.light);

  static const _themeKey = 'theme_mode';

  // Chame isso no início do app para carregar o tema salvo
  static Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);

    if (savedTheme == 'dark') {
      themeNotifier.value = ThemeMode.dark;
    } else if (savedTheme == 'light') {
      themeNotifier.value = ThemeMode.light;
    } else {
      themeNotifier.value = ThemeMode.light; // default
    }
  }

  // Alterna e salva
  static Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();

    if (themeNotifier.value == ThemeMode.dark) {
      themeNotifier.value = ThemeMode.light;
      await prefs.setString(_themeKey, 'light');
    } else {
      themeNotifier.value = ThemeMode.dark;
      await prefs.setString(_themeKey, 'dark');
    }
  }
}
