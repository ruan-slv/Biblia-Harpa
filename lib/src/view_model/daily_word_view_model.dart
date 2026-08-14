/// Coordena o estado e as ações consumidos pela camada de apresentação.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'package:flutter/material.dart';
import '../model/daily_word.dart';
import 'service/daily_word_service.dart';

class DailyWordViewModel extends ChangeNotifier {
  DailyWordViewModel({DailyWordService? service})
      : _service = service ?? DailyWordService();

  final DailyWordService _service;

  DailyWord? currentWord;
  DateTime? lastDataUpdate;

  Future<void> loadDailyWord(BuildContext context) async {
    final (word, lastUpdate) = await _service.loadDailyWord(context);
    currentWord = word;
    lastDataUpdate = lastUpdate;
    notifyListeners();
  }

  Future<void> shareDailyWord() async {
    await _service.shareDailyWord(currentWord);
  }
}
