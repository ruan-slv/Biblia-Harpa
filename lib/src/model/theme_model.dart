import 'package:flutter/material.dart';

class AppThemeModel {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color? surface;
  final Color? accent;
  final Brightness brightness;

  AppThemeModel({
    required this.primary,
    required this.secondary,
    required this.background,
    this.surface,
    this.accent,
    required this.brightness,
  });

  ThemeData toThemeData() {
    final baseSurface = surface ??
        (brightness == Brightness.dark
            ? Color.alphaBlend(Colors.white.withValues(alpha: 0.03), background)
            : Colors.white);
    final baseAccent = accent ??
        Color.lerp(primary, secondary, brightness == Brightness.dark ? 0.7 : 0.5)!;
    final onAccent =
        brightness == Brightness.dark ? const Color(0xFF1A120B) : Colors.white;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: background,
      cardColor: primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: baseAccent,
        brightness: brightness,
        primary: primary,
        onPrimary: secondary,
        secondary: baseAccent,
        onSecondary: onAccent,
        surface: baseSurface,
        onSurface: secondary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: baseSurface,
        foregroundColor: secondary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: baseAccent),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: baseSurface,
          foregroundColor: secondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}
