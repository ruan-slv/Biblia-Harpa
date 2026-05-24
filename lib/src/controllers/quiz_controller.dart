import 'package:biblia_e_harpa/src/models/quiz_hive_model.dart';
import 'package:biblia_e_harpa/src/services/quiz_service.dart';
import 'package:flutter/material.dart';

class QuizController extends ChangeNotifier {
  QuizController({QuizService? service}) : _service = service ?? QuizService();

  final QuizService _service;

  List<QuizQuestionHive> _questions = [];
  int _current = 0;
  int? _selected;
  int _score = 0;
  bool _loading = true;
  bool _completed = false;
  String? _errorMessage;

  List<QuizQuestionHive> get questions => _questions;
  int get current => _current;
  int? get selected => _selected;
  int get score => _score;
  bool get loading => _loading;
  bool get completed => _completed;
  String? get errorMessage => _errorMessage;

  Future<void> loadQuestions() async {
    _loading = true;
    _errorMessage = null;
    _completed = false;
    _current = 0;
    _selected = null;
    _score = 0;
    notifyListeners();

    try {
      final questions = await _service.loadQuestions();
      questions.shuffle();
      _questions = questions;
      _loading = false;
      notifyListeners();
    } catch (_) {
      _questions = [];
      _loading = false;
      _errorMessage = 'Nao foi possivel carregar o quiz.';
      notifyListeners();
    }
  }

  void answer(int index) {
    if (_selected != null) return;

    _selected = index;
    if (_questions[_current].options[index].id == _questions[_current].answer) {
      _score++;
    }
    notifyListeners();
  }

  void next() {
    if (_current < _questions.length - 1) {
      _current++;
      _selected = null;
    } else {
      _completed = true;
    }
    notifyListeners();
  }
}
