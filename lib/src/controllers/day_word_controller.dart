import 'package:biblia_e_harpa/src/models/initial_model.dart';
import 'package:biblia_e_harpa/src/services/initial_service.dart';
import 'package:flutter/material.dart';

class DayWordController extends ChangeNotifier {
  DayWordController({InitialService? service})
      : _service = service ?? InitialService();

  final InitialService _service;

  DayWord? currentWord;
  DateTime? lastDataUpdate;

  Future<void> loadDayWord(BuildContext context) async {
    final (word, lastUpdate) = await _service.loadDayWord(context);
    currentWord = word;
    lastDataUpdate = lastUpdate;
    notifyListeners();
  }

  Future<void> shareDayWord() async {
    await _service.shareDayWord(currentWord);
  }
}
