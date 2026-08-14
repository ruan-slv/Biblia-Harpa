/// Centraliza o controle de estado e as ações deste recurso do aplicativo.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontSizeController {
  static ValueNotifier<double> fontSizeNotifier = ValueNotifier(16.0);

  static Future<void> loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    double size = prefs.getDouble("fontSize") ?? 16.0;
    fontSizeNotifier.value = size;
  }

  static Future<void> setFontSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble("fontSize", size);
    fontSizeNotifier.value = size;
  }
}
