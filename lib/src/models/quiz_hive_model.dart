import 'package:hive/hive.dart';

part 'quiz_hive_model.g.dart';

@HiveType(typeId: 1)
class QuizOptionHive extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String text;

  QuizOptionHive({
    required this.id,
    required this.text,
  });

  factory QuizOptionHive.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] as String?)?.trim() ?? '';
    final text = (json['text'] as String?)?.trim() ?? '';

    if (id.isEmpty || text.isEmpty) {
      throw const FormatException('Opcao do quiz invalida.');
    }

    return QuizOptionHive(
      id: id,
      text: text,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
    };
  }
}

@HiveType(typeId: 2)
class QuizQuestionHive extends HiveObject {
  @HiveField(0)
  final String question;

  @HiveField(1)
  final List<QuizOptionHive> options;

  @HiveField(2)
  final String answer;

  @HiveField(3)
  final String reference;

  QuizQuestionHive({
    required this.question,
    required this.options,
    required this.answer,
    required this.reference,
  });

  factory QuizQuestionHive.fromJson(Map<String, dynamic> json) {
    final question = (json['question'] as String?)?.trim() ?? '';
    final answer = (json['answer'] as String?)?.trim() ?? '';
    final reference = (json['reference'] as String?)?.trim() ?? '';
    final rawOptions = json['options'];

    if (question.isEmpty || answer.isEmpty || reference.isEmpty || rawOptions is! List) {
      throw const FormatException('Pergunta do quiz invalida.');
    }

    final options = rawOptions
        .map((option) => QuizOptionHive.fromJson(option as Map<String, dynamic>))
        .toList();

    if (options.length != 4) {
      throw const FormatException('Cada pergunta do quiz deve possuir 4 opcoes.');
    }

    if (!options.any((option) => option.id == answer)) {
      throw const FormatException('Resposta correta nao encontrada nas opcoes.');
    }

    return QuizQuestionHive(
      question: question,
      options: options,
      answer: answer,
      reference: reference,
    );
  }

  static List<QuizQuestionHive> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((item) => QuizQuestionHive.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options.map((option) => option.toJson()).toList(),
      'answer': answer,
      'reference': reference,
    };
  }
}
