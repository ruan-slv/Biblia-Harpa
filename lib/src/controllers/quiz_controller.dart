/// Centraliza o controle de estado e as ações do quiz bíblico.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'dart:convert';
import 'package:biblia_e_harpa/src/database/app_database.dart';
import 'package:biblia_e_harpa/src/model/quiz_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'continue_reading_controller.dart';

class QuizController extends ChangeNotifier {
  /// Cria o controlador do quiz.
  QuizController({int initialQuestionIndex = 0})
      : _currentQuestionIndex = initialQuestionIndex,
        _initialQuestionIndex = initialQuestionIndex,
        _score = 0,
        _selectedOptionIndex = -1;

  static const _assetPath = 'assets/json/quizz.json';
  List<QuizQuestion> _questions = [];
  bool _loading = true;
  String? _errorMessage;

  int _currentQuestionIndex;
  final int _initialQuestionIndex;
  int _score;
  int _selectedOptionIndex;
  bool _loadedOnce = false;
  static const _continueReadingController = ContinueReadingController();

  int get currentQuestionIndex => _currentQuestionIndex;
  int get score => _score;
  int get selectedOptionIndex => _selectedOptionIndex;

  /// Índice atual e opção marcada, expostos para a camada de apresentação.
  int get current => _currentQuestionIndex;
  int? get selected =>
      _selectedOptionIndex < 0 ? null : _selectedOptionIndex;

  bool get loading => _loading;
  String? get errorMessage => _errorMessage;

  List<QuizQuestion> get questions => _questions;

  QuizQuestion? get currentQuestion {
    if (_questions.isEmpty) return null;
    return _questions[_currentQuestionIndex];
  }

  bool get isLastQuestion {
    return _currentQuestionIndex >= _questions.length - 1;
  }

  bool get isCompleted {
    return _currentQuestionIndex >= _questions.length;
  }

  bool get completed => isCompleted;

  Future<void> loadQuestions() async {
    _loading = true;
    _errorMessage = null;
    _currentQuestionIndex = _loadedOnce ? 0 : _initialQuestionIndex;
    _score = 0;
    _selectedOptionIndex = -1;
    notifyListeners();

    try {
      final rawJson = await rootBundle.loadString(_assetPath);
      final decoded = jsonDecode(rawJson);

      if (decoded is! List) {
        throw const FormatException('O arquivo do quiz deve conter uma lista de perguntas.');
      }

      final questions = decoded
          .map((question) => QuizQuestion.fromJson(
                Map<String, dynamic>.from(question as Map),
              ))
          .toList(growable: false)
        ..shuffle();

      if (questions.isEmpty) {
        throw const FormatException('Nenhuma pergunta valida foi encontrada no quiz.');
      }

      final db = await AppDatabase.instance.database;
      await db.transaction((transaction) async {
        await transaction.delete('quiz_questions');
        final batch = transaction.batch();
        for (final question in questions) {
          batch.insert(
            'quiz_questions',
            question.toDatabase(jsonEncode(question.options
                .map((option) => option.toJson())
                .toList(growable: false))),
          );
        }
        await batch.commit(noResult: true);
      });

      _questions = await _loadQuestionsFromDatabase();
      _currentQuestionIndex =
          _currentQuestionIndex.clamp(0, _questions.length - 1).toInt();
      _loadedOnce = true;
      _saveContinueReading();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void selectOption(int index) => answer(index);

  void answer(int index) {
    final question = currentQuestion;
    if (question == null || _selectedOptionIndex >= 0 || index < 0 ||
        index >= question.options.length) {
      return;
    }

    _selectedOptionIndex = index;
    if (question.options[index].id == question.answer) _score++;
    _saveContinueReading();
    notifyListeners();
  }

  void confirmAnswer() {
    if (currentQuestion == null || _selectedOptionIndex < 0) return;

    _selectedOptionIndex = -1;
    _currentQuestionIndex++;
    _saveContinueReading();
    notifyListeners();
  }

  void next() => confirmAnswer();

  void reset() {
    _currentQuestionIndex = 0;
    _score = 0;
    _selectedOptionIndex = -1;
    notifyListeners();
  }

  void _saveContinueReading() {
    if (_questions.isEmpty) return;
    _continueReadingController.saveQuiz(
      currentQuestion: _currentQuestionIndex,
      totalQuestions: _questions.length,
      completed: isCompleted,
    );
  }

  Future<List<QuizQuestion>> _loadQuestionsFromDatabase() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('quiz_questions', orderBy: 'id ASC');
    return rows.map((row) {
      final options = (jsonDecode(row['options_json'] as String) as List)
          .map((option) => QuizOption.fromJson(
                Map<String, dynamic>.from(option as Map),
              ))
          .toList(growable: false);
      return QuizQuestion.fromDatabase(row, options);
    }).toList(growable: false);
  }
}
