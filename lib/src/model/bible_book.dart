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
