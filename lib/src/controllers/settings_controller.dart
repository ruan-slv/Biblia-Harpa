/// Implementa o serviço que dá suporte à camada de apresentação.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../utils/bible_version_defaults.dart';

class SettingsController extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _fontSizeKey = 'fontSize';
  static const String _continuousPlaybackKey = 'continuous_playback';
  static const String _languageKey = 'app_language';

  ThemeMode _themeMode = ThemeMode.light;
  double _fontSize = 20.0;

  /// Modo contínuo: ao terminar um áudio, passa automaticamente para o
  /// próximo hino, sem interrupção.
  bool _continuousPlayback = true;

  /// Código do idioma escolhido (ex.: `pt`, `en`). `null` até o usuário
  /// escolher no primeiro acesso.
  String? _languageCode;

  /// Versão sequencial de alterações no idioma, usada por controladores
  /// dependentes (como [BibleListController]) para recarregar recursos.
  int _languageVersion = 0;

  /// Indica que as preferências salvas já foram carregadas.
  bool _initialized = false;

  ThemeMode get themeMode => _themeMode;
  double get fontSize => _fontSize;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get continuousPlayback => _continuousPlayback;
  bool get initialized => _initialized;
  int get languageVersion => _languageVersion;

  /// Código do idioma atual; usa português enquanto nada foi escolhido.
  String get languageCode => _languageCode ?? 'pt';

  /// `true` quando o usuário já escolheu um idioma (primeiro acesso concluído).
  bool get hasSelectedLanguage => _languageCode != null;

  AppLanguage get language => appLanguageForCode(_languageCode);

  Locale get locale => language.locale;

  Future<void> initialize() async {
    await loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);
    if (savedTheme == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }
    _fontSize = prefs.getDouble(_fontSizeKey) ?? 20.0;
    _continuousPlayback = prefs.getBool(_continuousPlaybackKey) ?? true;
    _languageCode = prefs.getString(_languageKey);
    if (_languageCode != null) {
      // Normaliza códigos salvos por versões antigas (`pt_BR`, `pt-BR` etc.)
      // e códigos desconhecidos, garantindo um idioma válido na interface.
      _languageCode = appLanguageForCode(_languageCode).code;
      if (!prefs.containsKey(kBibleVersionPrefsKey)) {
        await _persistBibleVersionForLanguage(_languageCode!);
      }
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    final normalized = appLanguageForCode(code).code;
    _languageCode = normalized;
    _languageVersion++;
    if (!_initialized) {
      _initialized = true;
    }
    notifyListeners();
    await _persistLanguage(normalized);
    await _persistBibleVersionForLanguage(normalized);
  }

  Future<void> _persistLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, code);
  }

  /// Ao trocar o idioma, seleciona a versão da Bíblia correspondente.
  ///
  /// No português (Brasil), a versão padrão é a NVI. A escolha manual feita
  /// depois no seletor de versões continua sendo respeitada enquanto o idioma
  /// não mudar.
  Future<void> _persistBibleVersionForLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      kBibleVersionPrefsKey,
      bibleVersionFileForLanguage(languageCode),
    );
  }

  Future<void> setContinuousPlayback(bool value) async {
    if (_continuousPlayback == value) return;
    _continuousPlayback = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_continuousPlaybackKey, value);
  }

  Future<void> toggleContinuousPlayback() =>
      setContinuousPlayback(!_continuousPlayback);

  Future<void> toggleTheme() async {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _themeKey, _themeMode == ThemeMode.dark ? 'dark' : 'light');
  }

  Future<void> increaseFontSize() async {
    _fontSize += 1.0;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, _fontSize);
  }

  Future<void> decreaseFontSize() async {
    _fontSize -= 1.0;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, _fontSize);
  }
}
