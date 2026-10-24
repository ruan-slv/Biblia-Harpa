/// Define o modelo de dados do "Devocional do Dia".
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

class DevotionalOfTheDay {
  final String topic;
  final int index;
  final String versiculo;
  final String texto;
  final String oracao;

  const DevotionalOfTheDay({
    required this.topic,
    required this.index,
    required this.versiculo,
    required this.texto,
    required this.oracao,
  });

  Map<String, dynamic> toJson() {
    return {
      'topic': topic,
      'index': index,
      'versiculo': versiculo,
      'texto': texto,
      'oracao': oracao,
    };
  }

  factory DevotionalOfTheDay.fromJson(Map<String, dynamic> json) {
    return DevotionalOfTheDay(
      topic: json['topic'] as String? ?? '',
      index: json['index'] as int? ?? 0,
      versiculo: json['versiculo'] as String? ?? '',
      texto: json['texto'] as String? ?? '',
      oracao: json['oracao'] as String? ?? '',
    );
  }
}
