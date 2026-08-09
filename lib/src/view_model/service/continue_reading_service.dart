import 'dart:convert';

import 'package:biblia_e_harpa/src/keys/devocional_key.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Identifica a funcionalidade associada a um item de continuidade.
enum ContinueReadingType {
  /// Um item de devocional.
  devotional,

  /// Um capítulo da Bíblia.
  bible,

  /// Um hino da Harpa.
  harp,

  /// Uma pergunta do quiz bíblico.
  quiz,
}

/// Representa um ponto persistido para retomar uma funcionalidade do app.
class ContinueReadingEntry {
  /// Cria um item de continuidade.
  const ContinueReadingEntry({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.position,
    required this.updatedAt,
    this.data = const {},
  });

  /// Identificador único do item dentro de sua funcionalidade.
  final String id;

  /// Funcionalidade que deve ser retomada.
  final ContinueReadingType type;

  /// Texto principal mostrado ao usuário.
  final String title;

  /// Texto complementar mostrado ao usuário.
  final String subtitle;

  /// Posição atual no conteúdo, indexada a partir de zero.
  final int position;

  /// Momento em que o progresso foi atualizado pela última vez.
  final DateTime updatedAt;

  /// Dados necessários para abrir novamente o conteúdo.
  final Map<String, dynamic> data;

  /// Converte o item para o formato persistido em preferências locais.
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'subtitle': subtitle,
        'position': position,
        'updatedAt': updatedAt.toIso8601String(),
        'data': data,
      };

  /// Restaura um item previamente persistido.
  factory ContinueReadingEntry.fromJson(Map<String, dynamic> json) {
    final type = ContinueReadingType.values.firstWhere(
      (value) => value.name == json['type'],
      orElse: () => ContinueReadingType.devotional,
    );

    return ContinueReadingEntry(
      id: json['id'] as String? ?? '',
      type: type,
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      position: json['position'] as int? ?? 0,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      data: Map<String, dynamic>.from(json['data'] as Map? ?? const {}),
    );
  }
}

/// Persiste e recupera os pontos de continuidade das funcionalidades do app.
class ContinueReadingService {
  /// Cria o serviço de continuidade usando as preferências locais do app.
  const ContinueReadingService();

  static const _storageKey = 'continue_reading_entries';
  static const _devotionalAssetPath = 'assets/json/newDevocionalModel.json';

  /// Retorna os itens recentes, do mais recente para o mais antigo.
  Future<List<ContinueReadingEntry>> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_storageKey);
    if (encoded == null) return const [];

    try {
      final rawEntries = jsonDecode(encoded) as List<dynamic>;
      final entries = rawEntries
          .whereType<Map>()
          .map((entry) => ContinueReadingEntry.fromJson(
                Map<String, dynamic>.from(entry),
              ))
          .where((entry) => entry.id.isNotEmpty)
          .toList();
      entries.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return entries;
    } catch (_) {
      return const [];
    }
  }

  /// Salva um item novo ou atualiza o item com o mesmo [ContinueReadingEntry.id].
  Future<void> save(ContinueReadingEntry entry) async {
    final entries = await loadEntries();
    entries.removeWhere((item) => item.id == entry.id);
    entries.add(entry);
    entries.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(entries.take(20).map((item) => item.toJson()).toList()),
    );
  }

  /// Registra a posição atual de um devocional.
  Future<void> saveDevotional({
    required String topic,
    required int index,
  }) {
    return save(
      ContinueReadingEntry(
        id: 'devotional:$topic',
        type: ContinueReadingType.devotional,
        title: topic,
        subtitle: 'Devocional ${index + 1}',
        position: index,
        updatedAt: DateTime.now(),
        data: {'topic': topic},
      ),
    );
  }

  /// Registra o capítulo atual da Bíblia e a versão usada na leitura.
  Future<void> saveBible({
    required String bookName,
    required String jsonPath,
    required int chapterNumber,
  }) {
    return save(
      ContinueReadingEntry(
        id: 'bible:$bookName:$jsonPath',
        type: ContinueReadingType.bible,
        title: bookName,
        subtitle: 'Capítulo $chapterNumber',
        position: chapterNumber - 1,
        updatedAt: DateTime.now(),
        data: {'bookName': bookName, 'jsonPath': jsonPath},
      ),
    );
  }

  /// Registra o último hino aberto na Harpa.
  Future<void> saveHarp({required String hymn}) {
    return save(
      ContinueReadingEntry(
        id: 'harp:$hymn',
        type: ContinueReadingType.harp,
        title: hymn,
        subtitle: 'Harpa Cristã',
        position: 0,
        updatedAt: DateTime.now(),
        data: {'hymn': hymn},
      ),
    );
  }

  /// Registra a posição da pergunta atual do quiz.
  Future<void> saveQuiz({
    required int currentQuestion,
    required int totalQuestions,
    required bool completed,
  }) {
    return save(
      ContinueReadingEntry(
        id: 'quiz',
        type: ContinueReadingType.quiz,
        title: 'Quiz bíblico',
        subtitle: completed
            ? 'Quiz concluído'
            : 'Pergunta ${currentQuestion + 1} de $totalQuestions',
        position: completed ? 0 : currentQuestion,
        updatedAt: DateTime.now(),
        data: {'completed': completed},
      ),
    );
  }

  /// Localiza o próximo devocional ainda não marcado como lido.
  Future<ContinueReadingEntry?> findNextUnreadDevotional() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final decoded =
          jsonDecode(await rootBundle.loadString(_devotionalAssetPath));
      final content = Map<String, dynamic>.from(decoded as Map);
      final lastTopic = prefs.getString('lastDevocionalTopic');
      final lastIndex = prefs.getInt('lastDevocionalIndex') ?? -1;

      final topics = <String>[
        if (lastTopic != null && content.containsKey(lastTopic)) lastTopic,
        ...topicos.where((topic) => topic != lastTopic),
      ];

      for (final topic in topics) {
        final items = List<dynamic>.from(content[topic] as List? ?? const []);
        final start = topic == lastTopic ? lastIndex + 1 : 0;
        for (var index = start; index < items.length; index++) {
          if (!(prefs.getBool('devocional_read_${topic}_$index') ?? false)) {
            return ContinueReadingEntry(
              id: 'devotional:$topic',
              type: ContinueReadingType.devotional,
              title: topic,
              subtitle: 'Devocional ${index + 1}',
              position: index,
              updatedAt: DateTime.now(),
              data: {'topic': topic},
            );
          }
        }
      }
    } catch (_) {
      return null;
    }

    return null;
  }
}
