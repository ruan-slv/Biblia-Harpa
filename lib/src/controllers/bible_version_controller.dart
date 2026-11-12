/// Implementa o serviço que dá suporte à camada de apresentação.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'package:shared_preferences/shared_preferences.dart';

import '../utils/bible_version_defaults.dart';

class BibleVersionController {
  static const _prefsKey = kBibleVersionPrefsKey;

  Future<String> getSelectedVersionFileName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefsKey) ?? kDefaultPortugueseBibleFile;
  }

  Future<void> setSelectedVersionFileName(String fileName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, fileName);
  }
}
