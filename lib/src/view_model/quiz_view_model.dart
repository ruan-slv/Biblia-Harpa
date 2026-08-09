import 'package:biblia_e_harpa/src/model/quiz_hive_model.dart';
import 'package:biblia_e_harpa/src/view_model/service/quiz_service.dart';
import 'package:biblia_e_harpa/src/view_model/service/continue_reading_service.dart';
import 'package:flutter/material.dart';

/// Gerencia as perguntas do quiz e persiste a pergunta atual para retomada.
class QuizViewModel extends ChangeNotifier {
  /// Cria o modelo, iniciando em [initialQuestionIndex] na primeira carga.
  QuizViewModel({
    QuizService? service,
    ContinueReadingService? continueReadingService,
    this.initialQuestionIndex = 0,
  })  : _service = service ?? QuizService(),
        _continueReadingService =
            continueReadingService ?? const ContinueReadingService();

  final QuizService _service;
  final ContinueReadingService _continueReadingService;
  final int initialQuestionIndex;

  List<QuizQuestionHive> _questions = [];
  int _current = 0;
  int? _selected;
  int _score = 0;
  bool _loading = true;
  bool _completed = false;
  String? _errorMessage;
  var _loadedOnce = false;

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
    _current = _loadedOnce ? 0 : initialQuestionIndex;
    _selected = null;
    _score = 0;
    notifyListeners();

    try {
      final questions = await _service.loadQuestions();
      questions.shuffle();
      _questions = questions;
      _current = _current.clamp(0, _questions.length - 1).toInt();
      _loadedOnce = true;
      _loading = false;
      _saveContinueReading();
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
    _saveContinueReading();
    notifyListeners();
  }

  void next() {
    if (_current < _questions.length - 1) {
      _current++;
      _selected = null;
    } else {
      _completed = true;
    }
    _saveContinueReading();
    notifyListeners();
  }

  void _saveContinueReading() {
    if (_questions.isEmpty) return;
    _continueReadingService.saveQuiz(
      currentQuestion: _current,
      totalQuestions: _questions.length,
      completed: _completed,
    );
  }
}
