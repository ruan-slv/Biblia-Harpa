/// Implementa o serviço que dá suporte à camada de apresentação.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/theme_model.dart';

class ThemeService {
  static const _primaryKey = 'primary_color';
  static const _secondaryKey = 'secondary_color';
  static const _backgroundKey = 'background_color';
  static const _brightnessKey = 'brightness';

  Future<void> saveCustomTheme(AppThemeModel theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_primaryKey, theme.primary.toARGB32());
    await prefs.setInt(_secondaryKey, theme.secondary.toARGB32());
    await prefs.setInt(_backgroundKey, theme.background.toARGB32());
    await prefs.setString(_brightnessKey, theme.brightness == Brightness.dark ? 'dark' : 'light');
  }

  Future<AppThemeModel?> loadCustomTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final primary = prefs.getInt(_primaryKey);
    if (primary == null) return null;

    return AppThemeModel(
      primary: Color(primary),
      secondary: Color(prefs.getInt(_secondaryKey) ?? Colors.grey.shade900.toARGB32()),
      background: Color(prefs.getInt(_backgroundKey) ?? Colors.grey.shade400.toARGB32()),
      brightness: prefs.getString(_brightnessKey) == 'dark' ? Brightness.dark : Brightness.light,
    );
  }
}
