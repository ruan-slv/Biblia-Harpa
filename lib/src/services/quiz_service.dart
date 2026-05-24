import 'package:biblia_e_harpa/src/models/quiz_hive_model.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

class QuizService {
  static const _assetPath = 'assets/json/quizz.json';
  static const _boxName = 'quiz';

  Future<List<QuizQuestionHive>> loadQuestions() async {
    final box = await _openBox();
    final rawJson = await rootBundle.loadString(_assetPath);
    final decoded = jsonDecode(rawJson);

    if (decoded is! List) {
      throw const FormatException('O arquivo do quiz deve conter uma lista de perguntas.');
    }

    final questions = QuizQuestionHive.fromJsonList(decoded);

    if (questions.isEmpty) {
      throw const FormatException('Nenhuma pergunta valida foi encontrada no quiz.');
    }

    await box.clear();
    await box.addAll(questions);

    return box.values.toList(growable: false);
  }

  Future<Box<QuizQuestionHive>> _openBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<QuizQuestionHive>(_boxName);
    }

    return Hive.openBox<QuizQuestionHive>(_boxName);
  }
}
