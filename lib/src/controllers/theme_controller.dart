import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController {
  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.light);

  static final ValueNotifier<ThemeData> customThemeNotifier =
      ValueNotifier(_defaultLightTheme);

  static const _themeKey = 'theme_mode';
  static const _primaryKey = 'primary_color';
  static const _secondaryKey = 'secondary_color';
  static const _backgroundKey = 'background_color';

  static ThemeData get _defaultLightTheme => ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.light(
          background: Colors.grey.shade400,
          primary: Colors.grey.shade300,
          secondary: Colors.grey.shade900,
        ),
      );

  static ThemeData get _defaultDarkTheme => ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          background: Colors.grey.shade800,
          primary: Colors.grey.shade900,
          secondary: Colors.white,
        ),
      );

  /// Carrega o modo claro/escuro e as cores personalizadas
  static Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);

    if (savedTheme == 'dark') {
      themeNotifier.value = ThemeMode.dark;
    } else {
      themeNotifier.value = ThemeMode.light;
    }

    final primary = prefs.getInt(_primaryKey);
    final secondary = prefs.getInt(_secondaryKey);
    final background = prefs.getInt(_backgroundKey);

    if (primary != null && secondary != null && background != null) {
      customThemeNotifier.value = ThemeData(
        brightness: themeNotifier.value == ThemeMode.dark
            ? Brightness.dark
            : Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(primary),
          brightness: themeNotifier.value == ThemeMode.dark
              ? Brightness.dark
              : Brightness.light,
          primary: Color(primary),
          secondary: Color(secondary),
          background: Color(background),
        ),
      );
    } else {
      customThemeNotifier.value = themeNotifier.value == ThemeMode.dark
          ? _defaultDarkTheme
          : _defaultLightTheme;
    }
  }

  /// Alterna entre claro e escuro e atualiza o tema
  static Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();

    if (themeNotifier.value == ThemeMode.dark) {
      themeNotifier.value = ThemeMode.light;
      await prefs.setString(_themeKey, 'light');
    } else {
      themeNotifier.value = ThemeMode.dark;
      await prefs.setString(_themeKey, 'dark');
    }

    await loadTheme(); // recarrega com o novo brightness
  }

  /// Atualiza as cores personalizadas
  static Future<void> updateCustomColors({
    required Color primary,
    required Color secondary,
    required Color background,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_primaryKey, primary.value);
    await prefs.setInt(_secondaryKey, secondary.value);
    await prefs.setInt(_backgroundKey, background.value);

    await loadTheme(); // aplica as novas cores
  }
}