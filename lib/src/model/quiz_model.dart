class QuizOption {
  const QuizOption({required this.id, required this.text});

  final String id;
  final String text;

  factory QuizOption.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] as String?)?.trim() ?? '';
    final text = (json['text'] as String?)?.trim() ?? '';
    if (id.isEmpty || text.isEmpty) {
      throw const FormatException('Opção do quiz inválida.');
    }
    return QuizOption(id: id, text: text);
  }

  Map<String, String> toJson() => {'id': id, 'text': text};
}

class QuizQuestion {
  const QuizQuestion({
    required this.question,
    required this.options,
    required this.answer,
    required this.reference,
  });

  final String question;
  final List<QuizOption> options;
  final String answer;
  final String reference;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    final question = (json['question'] as String?)?.trim() ?? '';
    final answer = (json['answer'] as String?)?.trim() ?? '';
    final reference = (json['reference'] as String?)?.trim() ?? '';
    final rawOptions = json['options'];
    if (question.isEmpty || answer.isEmpty || reference.isEmpty ||
        rawOptions is! List) {
      throw const FormatException('Pergunta do quiz inválida.');
    }

    final options = rawOptions
        .map((option) => QuizOption.fromJson(Map<String, dynamic>.from(option as Map)))
        .toList(growable: false);
    if (options.length != 4 || !options.any((option) => option.id == answer)) {
      throw const FormatException('Opções do quiz inválidas.');
    }
    return QuizQuestion(
      question: question,
      options: options,
      answer: answer,
      reference: reference,
    );
  }

  factory QuizQuestion.fromDatabase(Map<String, Object?> row, List<QuizOption> options) =>
      QuizQuestion(
        question: row['question'] as String,
        options: options,
        answer: row['answer'] as String,
        reference: row['reference'] as String,
      );

  Map<String, Object> toDatabase(String optionsJson) => {
        'question': question,
        'options_json': optionsJson,
        'answer': answer,
        'reference': reference,
      };
}
