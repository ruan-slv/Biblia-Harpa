/// Define os modelos de dados utilizados por este recurso do aplicativo.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

class BibleAudioChapter {
  final String name;
  final String url;

  const BibleAudioChapter({required this.name, required this.url});

  factory BibleAudioChapter.fromJson(Map<String, dynamic> json) {
    return BibleAudioChapter(
      name: json["name"] as String,
      url: json["url"] as String,
    );
  }
}

class BibleAudioBook {
  final String title;
  final List<BibleAudioChapter> chapters;

  const BibleAudioBook({required this.title, required this.chapters});

  factory BibleAudioBook.fromJson(Map<String, dynamic> json) {
    final list = (json["chapters"] as List?) ?? const [];
    return BibleAudioBook(
      title: json["title"] as String,
      chapters: list
          .whereType<Map>()
          .map((e) => BibleAudioChapter.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}
