import 'package:biblia_e_harpa/src/controllers/font_size_controller.dart';
import 'package:biblia_e_harpa/src/controllers/theme_controller.dart';
import 'package:flutter/material.dart';

class SettingsController extends ChangeNotifier {
  SettingsController() {
    ThemeController.themeNotifier.addListener(_notifyListeners);
    FontSizeController.fontSizeNotifier.addListener(_notifyListeners);
  }

  ThemeMode get currentTheme => ThemeController.themeNotifier.value;
  double get fontSize => FontSizeController.fontSizeNotifier.value;
  bool get isDark => currentTheme == ThemeMode.dark;

  Future<void> decreaseFontSize() async {
    await FontSizeController.setFontSize((fontSize - 2).clamp(16.0, 30.0));
  }

  Future<void> increaseFontSize() async {
    await FontSizeController.setFontSize((fontSize + 2).clamp(16.0, 30.0));
  }

  Future<void> toggleTheme() async {
    await ThemeController.toggleTheme();
  }

  void _notifyListeners() {
    notifyListeners();
  }

  @override
  void dispose() {
    ThemeController.themeNotifier.removeListener(_notifyListeners);
    FontSizeController.fontSizeNotifier.removeListener(_notifyListeners);
    super.dispose();
  }
}
