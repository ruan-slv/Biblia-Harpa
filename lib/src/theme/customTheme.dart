/// Define recursos de tema e aparência utilizados pela interface.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'package:flutter/material.dart';

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
