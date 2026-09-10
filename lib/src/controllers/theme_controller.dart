/// Centraliza o controle de estado e as ações deste recurso do aplicativo.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

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

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    background: Colors.grey.shade400,
    primary: Colors.grey.shade300,
    secondary: Colors.grey.shade900,
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    background: Colors.grey.shade800,
    primary: Colors.grey.shade900,
    secondary: Colors.white,
  ),
);

class Customtheme {
  final Color primary;
  final Color secondary;
  final Color background;
  final Brightness brightness;

  Customtheme({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.brightness,
  });

  ThemeData toThemeData() {
    return ThemeData(
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: brightness,
        primary: primary,
        secondary: secondary,
        background: background,
      ),
    );
  }
}

class ThemeStorage {
  static const _primaryKey = 'primary_color';
  static const _secondaryKey = 'secondary_color';
  static const _backgroundKey = 'background_color';
  static const _brightnessKey = 'brightness';

  static Future<void> saveTheme(Customtheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_primaryKey, theme.primary.value);
    prefs.setInt(_secondaryKey, theme.secondary.value);
    prefs.setInt(_backgroundKey, theme.background.value);
    prefs.setString(_brightnessKey, theme.brightness == Brightness.dark ? 'dark' : 'light');
  }

  static Future<Customtheme> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return Customtheme(
      primary: Color(prefs.getInt(_primaryKey) ?? Colors.grey.shade300.value),
      secondary: Color(prefs.getInt(_secondaryKey) ?? Colors.grey.shade900.value),
      background: Color(prefs.getInt(_backgroundKey) ?? Colors.grey.shade400.value),
      brightness: prefs.getString(_brightnessKey) == 'dark' ? Brightness.dark : Brightness.light,
    );
  }
}
