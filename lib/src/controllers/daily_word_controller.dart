/// Centraliza o controle de estado e as ações da Palavra do Dia.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/daily_word.dart';

class DailyWordController extends ChangeNotifier {
  DailyWord? _currentWord;
  DateTime? _lastDataUpdate;

  DailyWord? get currentWord => _currentWord;
  DateTime? get lastDataUpdate => _lastDataUpdate;

  Future<void> loadDailyWord() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedLastUpdate = prefs.getString("last_update");
    final String? savedWord = prefs.getString("palavra_atual");
    final now = DateTime.now();
    final needUpdate = savedLastUpdate == null ||
        DateTime.parse(savedLastUpdate).difference(now).inDays.abs() >= 1;

    if (!needUpdate && savedWord != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(savedWord);
        _currentWord = DailyWord.fromJson(json);
        _lastDataUpdate = DateTime.parse(savedLastUpdate);
        notifyListeners();
        return;
      } catch (_) {}
    }

    try {
      final String jsonString = await rootBundle
          .loadString("assets/json/outros/palavra_do_dia.json");
      final Map<String, dynamic> decoded = jsonDecode(jsonString);
      final List<dynamic> words = decoded["palavraDoDia"] ?? decoded["palavras"] ?? [];
      if (words.isEmpty) {
        _currentWord = DailyWord(id: 0, text: "", reference: "");
        _lastDataUpdate = now;
        notifyListeners();
        return;
      }
      final randomIndex = Random().nextInt(words.length);
      final selectedWord = words[randomIndex];
      _currentWord = DailyWord.fromJson(selectedWord);
      await prefs.setString("last_update", now.toIso8601String());
      await prefs.setString("palavra_atual", jsonEncode(selectedWord));
      _lastDataUpdate = now;
      notifyListeners();
    } catch (_) {
      notifyListeners();
    }
  }

  Future<void> shareDailyWord() async {
    if (_currentWord != null) {
      await SharePlus.instance.share(
        ShareParams(
          text: "${_currentWord!.text} \n ${_currentWord!.reference}",
        ),
      );
    }
  }
}
