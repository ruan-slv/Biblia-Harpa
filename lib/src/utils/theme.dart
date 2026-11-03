/// Reúne funções utilitárias compartilhadas por diferentes partes do aplicativo.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const corPrimaria = Color(0xFF00BFA6);
  static const corSecundaria = Color(0xFF7C6BFF);
  static const corVermelha = Color(0xFFFF6B6B);
  static const corDourada = Color(0xFFF5B93F);
  static const sucesso = Color(0xFF22C55E);
  static const informacao = Color(0xFF0EA5E9);
  static const erroSnackBar = Color(0xFFEF4444);

  static const gradienteMarca = [
    corPrimaria,
    corSecundaria,
  ];

  static const gradienteHero = [
    Color(0xFF008F7E),
    Color(0xFF5B4BD6),
  ];

  static Color superficie(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF141B23)
          : const Color(0xFFFFFFFF);

  static Color superficieSuave(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1A232D)
          : const Color(0xFFF7F9FC);

  static Color borda(BuildContext context) =>
      Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5);

  static Color textoSuave(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFFBEC9C5)
          : const Color(0xFF3F4946);
}

ThemeData _buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppTheme.corPrimaria,
    brightness: brightness,
  );
  final surface = isDark ? const Color(0xFF141B23) : const Color(0xFFFFFFFF);
  final softSurface =
      isDark ? const Color(0xFF1A232D) : const Color(0xFFF7F9FC);
  final border = colorScheme.outlineVariant.withValues(alpha: 0.5);
  final baseTextTheme = isDark
      ? Typography.material2021(colorScheme: colorScheme).white
      : Typography.material2021(colorScheme: colorScheme).black;

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor:
        isDark ? const Color(0xFF0B0F14) : const Color(0xFFF3F6FA),
    canvasColor: surface,
    cardColor: surface,
    dividerColor: border,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: colorScheme.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: IconThemeData(color: colorScheme.primary),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: isDark ? 0 : 1,
      shadowColor: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: border),
      ),
      margin: EdgeInsets.zero,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: border),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.error, width: 1.6),
      ),
    ),
    textTheme: baseTextTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    iconTheme: IconThemeData(color: colorScheme.primary),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: colorScheme.primary,
      linearTrackColor: softSurface,
    ),
  );
}

final ThemeData lightMode = _buildTheme(Brightness.light);
final ThemeData darkMode = _buildTheme(Brightness.dark);
