import 'package:flutter/material.dart';
import 'service/settings_service.dart';

class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel({SettingsService? service})
      : _service = service ?? SettingsService();

  final SettingsService _service;

  ThemeMode _themeMode = ThemeMode.light;
  double _fontSize = 16.0;

  ThemeMode get themeMode => _themeMode;
  double get fontSize => _fontSize;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> initialize() async {
    _themeMode = await _service.loadTheme();
    _fontSize = await _service.loadFontSize();
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await _service.saveTheme(_themeMode);
    notifyListeners();
  }

  Future<void> increaseFontSize() async {
    if (_fontSize < 30.0) {
      _fontSize += 2.0;
      await _service.saveFontSize(_fontSize);
      notifyListeners();
    }
  }

  Future<void> decreaseFontSize() async {
    if (_fontSize > 16.0) {
      _fontSize -= 2.0;
      await _service.saveFontSize(_fontSize);
      notifyListeners();
    }
  }

  Future<void> setFontSize(double size) async {
    _fontSize = size.clamp(16.0, 30.0);
    await _service.saveFontSize(_fontSize);
    notifyListeners();
  }
}
