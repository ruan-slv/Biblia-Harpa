import 'package:biblia_e_harpa/src/theme/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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