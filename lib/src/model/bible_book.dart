/// Define os modelos de dados utilizados por este recurso do aplicativo.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

class BibleBook {
  final String name;
  final String abbrev;
  final List<List<String>> chapters;

  const BibleBook({
    required this.name,
    required this.abbrev,
    required this.chapters,
  });

  factory BibleBook.fromJson(Map<String, dynamic> json) {
    final chaptersJson = (json["chapters"] as List?) ?? const [];
    return BibleBook(
      name: json["name"] as String,
      abbrev: (json["abbrev"] ?? "") as String,
      chapters: chaptersJson.map((chapter) {
        final verses = (chapter as List?) ?? const [];
        return verses.map((v) => v.toString()).toList();
      }).toList(),
    );
  }
}
