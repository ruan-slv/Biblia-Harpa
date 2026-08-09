import 'package:flutter/material.dart';

const _lightPrimary = Color(0xFFF4E8D5);
const _lightSecondary = Color(0xFF3E2E22);
const _lightBackground = Color(0xFFFCF8F2);
const _lightSurface = Color(0xFFFFFCF7);
const _lightAccent = Color(0xFF9C6B3F);

const _darkPrimary = Color(0xFF1F2630);
const _darkSecondary = Color(0xFFF6E8D2);
const _darkBackground = Color(0xFF11161D);
const _darkSurface = Color(0xFF19212B);
const _darkAccent = Color(0xFFD6A56A);

ThemeData _buildTheme({
  required Brightness brightness,
  required Color primary,
  required Color secondary,
  required Color background,
  required Color surface,
  required Color accent,
}) {
  final colorScheme = ColorScheme(
    brightness: brightness,
    primary: primary,
    onPrimary: secondary,
    secondary: accent,
    onSecondary: brightness == Brightness.dark
        ? const Color(0xFF1A120B)
        : Colors.white,
    error: const Color(0xFFB3261E),
    onError: Colors.white,
    surface: surface,
    onSurface: secondary,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: background,
    canvasColor: background,
    cardColor: primary,
    dividerColor: accent.withValues(alpha:0.18),
    appBarTheme: AppBarTheme(
      backgroundColor: surface,
      foregroundColor: secondary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: secondary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: IconThemeData(color: accent),
    ),
    cardTheme: CardThemeData(
      color: primary,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha:brightness == Brightness.dark ? 0.3 : 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: surface,
        foregroundColor: secondary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    iconTheme: IconThemeData(color: accent),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? accent : primary,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? accent.withValues(alpha:0.35)
            : secondary.withValues(alpha:0.18),
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: accent,
      inactiveTrackColor: accent.withValues(alpha:0.22),
      thumbColor: accent,
      overlayColor: accent.withValues(alpha:0.14),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      hintStyle: TextStyle(color: secondary.withValues(alpha:0.55)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: accent.withValues(alpha:0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: accent, width: 1.4),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: accent.withValues(alpha:0.12)),
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: secondary, height: 1.45),
      bodyMedium: TextStyle(color: secondary, height: 1.4),
      titleLarge: TextStyle(
        color: secondary,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        color: secondary,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

final ThemeData lightMode = _buildTheme(
  brightness: Brightness.light,
  primary: _lightPrimary,
  secondary: _lightSecondary,
  background: _lightBackground,
  surface: _lightSurface,
  accent: _lightAccent,
);

final ThemeData darkMode = _buildTheme(
  brightness: Brightness.dark,
  primary: _darkPrimary,
  secondary: _darkSecondary,
  background: _darkBackground,
  surface: _darkSurface,
  accent: _darkAccent,
);
