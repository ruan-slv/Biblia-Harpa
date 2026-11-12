/// Camada de internacionalização do aplicativo.
///
/// As chaves de tradução são os próprios textos em português, o que permite
/// substituir o texto original por `context.l10n.t('Texto')` sem inventar
/// identificadores e mantendo o português como idioma de origem. Quando uma
/// tradução não existe, o texto original (português) é exibido; quando existe
/// em inglês e não no idioma escolhido, o inglês é usado como intermediário.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'translations_en.dart';
import 'translations_es.dart';
import 'translations_extra.dart';
import 'translations_extra2.dart';
import 'translations_common.dart';
import 'translations_ru.dart';

/// Um idioma disponível para a interface do aplicativo.
class AppLanguage {
  const AppLanguage({
    required this.code,
    required this.locale,
    required this.flag,
    required this.nativeName,
    required this.englishName,
  });

  /// Código curto persistido em SharedPreferences (ex.: `pt`, `en`).
  final String code;
  final Locale locale;
  final String flag;

  /// Nome do idioma no próprio idioma (ex.: `Русский`).
  final String nativeName;

  /// Nome em inglês, usado como apoio didático.
  final String englishName;

  bool get isRtl => code == 'ar';

  /// Código aceito pelo pacote `upgrader` para as mensagens nativas.
  String get upgraderCode {
    if (code == 'pt') return 'pt-br';
    if (code == 'eo') return 'en';
    return code;
  }
}

/// Idiomas suportados pela interface. A lista espelha as bandeiras e os
/// idiomas das versões da Bíblia disponíveis no aplicativo.
const List<AppLanguage> appLanguages = <AppLanguage>[
  AppLanguage(
    code: 'pt',
    locale: Locale('pt', 'BR'),
    flag: '🇧🇷',
    nativeName: 'Português (Brasil)',
    englishName: 'Portuguese (Brazil)',
  ),
  AppLanguage(
    code: 'en',
    locale: Locale('en'),
    flag: '🇬🇧',
    nativeName: 'English',
    englishName: 'English',
  ),
  AppLanguage(
    code: 'es',
    locale: Locale('es'),
    flag: '🇪🇸',
    nativeName: 'Español',
    englishName: 'Spanish',
  ),
  AppLanguage(
    code: 'de',
    locale: Locale('de'),
    flag: '🇩🇪',
    nativeName: 'Deutsch',
    englishName: 'German',
  ),
  AppLanguage(
    code: 'fr',
    locale: Locale('fr'),
    flag: '🇫🇷',
    nativeName: 'Français',
    englishName: 'French',
  ),
  AppLanguage(
    code: 'ru',
    locale: Locale('ru'),
    flag: '🇷🇺',
    nativeName: 'Русский',
    englishName: 'Russian',
  ),
  AppLanguage(
    code: 'zh',
    locale: Locale('zh'),
    flag: '🇨🇳',
    nativeName: '中文',
    englishName: 'Chinese',
  ),
  AppLanguage(
    code: 'ko',
    locale: Locale('ko'),
    flag: '🇰🇷',
    nativeName: '한국어',
    englishName: 'Korean',
  ),
  AppLanguage(
    code: 'vi',
    locale: Locale('vi'),
    flag: '🇻🇳',
    nativeName: 'Tiếng Việt',
    englishName: 'Vietnamese',
  ),
  AppLanguage(
    code: 'el',
    locale: Locale('el'),
    flag: '🇬🇷',
    nativeName: 'Ελληνικά',
    englishName: 'Greek',
  ),
  AppLanguage(
    code: 'ro',
    locale: Locale('ro'),
    flag: '🇷🇴',
    nativeName: 'Română',
    englishName: 'Romanian',
  ),
  AppLanguage(
    code: 'eo',
    locale: Locale('eo'),
    flag: '🌍',
    nativeName: 'Esperanto',
    englishName: 'Esperanto',
  ),
  AppLanguage(
    code: 'ar',
    locale: Locale('ar'),
    flag: '🇸🇦',
    nativeName: 'العربية',
    englishName: 'Arabic',
  ),
  AppLanguage(
    code: 'fi',
    locale: Locale('fi'),
    flag: '🇫🇮',
    nativeName: 'Suomi',
    englishName: 'Finnish',
  ),
];

/// Localiza um [AppLanguage] a partir do código persistido.
AppLanguage appLanguageForCode(String? code) {
  if (code == null || code.isEmpty) return appLanguages.first;
  for (final language in appLanguages) {
    if (language.code == code) return language;
  }
  // Também aceita códigos como `pt_BR` ou `pt-BR`.
  final normalized = code.toLowerCase().replaceAll('_', '-').split('-').first;
  for (final language in appLanguages) {
    if (language.code == normalized) return language;
  }
  return appLanguages.first;
}

/// Textos da interface para o idioma atual.
class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  /// Idioma usado por código fora da árvore de widgets (services/controllers).
  static AppLanguage currentLanguage = appLanguages.first;

  /// Localização atual, útil para mensagens em controladores e serviços.
  static AppLocalizations get current => AppLocalizations(currentLanguage.locale);

  static const List<Locale> supportedLocales = <Locale>[
    Locale('pt', 'BR'),
    Locale('en'),
    Locale('es'),
    Locale('de'),
    Locale('fr'),
    Locale('ru'),
    Locale('zh'),
    Locale('ko'),
    Locale('vi'),
    Locale('el'),
    Locale('ro'),
    Locale('eo'),
    Locale('ar'),
    Locale('fi'),
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(currentLanguage.locale);
  }

  /// Traduz [key] (o texto em português) e substitui os parâmetros `{nome}`.
  String t(String key, [Map<String, String>? params]) {
    final language = appLanguageForCode(locale.languageCode);
    // O português é o idioma de origem: as próprias chaves já são o texto em
    // português. Sem este atalho, a busca cairia no dicionário inglês.
    if (language.code == 'pt') {
      return _interpolate(key, params);
    }
    final translation = _translations[language.code]?[key] ??
        commonTranslations[language.code]?[key] ??
        _translations['en']?[key] ??
        commonTranslations['en']?[key] ??
        key;
    return _interpolate(translation, params);
  }

  String get languageName => appLanguageForCode(locale.languageCode).nativeName;

  static String _interpolate(
    String text,
    Map<String, String>? params,
  ) {
    if (params == null || params.isEmpty) return text;
    var result = text;
    for (final entry in params.entries) {
      result = result.replaceAll('{${entry.key}}', entry.value);
    }
    return result;
  }

  /// Idiomas com dicionário próprio.
  static const Map<String, Map<String, String>> _translations =
      <String, Map<String, String>>{
    'en': enTranslations,
    'es': esTranslations,
    'ru': ruTranslations,
    'de': deTranslations,
    'fr': frTranslations,
    'zh': zhTranslations,
    'ko': koTranslations,
    'vi': viTranslations,
    'el': elTranslations,
    'ro': roTranslations,
    'eo': eoTranslations,
    'ar': arTranslations,
    'fi': fiTranslations,  };
}

/// Atalho para traduzir textos em qualquer [BuildContext].
extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Tradução fora da árvore de widgets (controladores, serviços, notificações).
String tr(String key, [Map<String, String>? params]) =>
    AppLocalizations.current.t(key, params);

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return appLanguages.any((language) => language.code == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    AppLocalizations.currentLanguage =
        appLanguageForCode(locale.languageCode);
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => true;
}
