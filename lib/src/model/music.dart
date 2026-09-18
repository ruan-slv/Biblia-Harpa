/// Define os modelos de dados utilizados por este recurso do aplicativo.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

class Music {
  const Music({
    this.id,
    required this.title,
    required this.filePath,
  });

  final int? id;
  final String title;
  final String filePath;

  factory Music.fromMap(Map<String, Object?> map) => Music(
        id: map['id'] as int?,
        title: map['title'] as String,
        filePath: map['file_path'] as String,
      );

  Map<String, Object?> toMap() => {
        'title': title,
        'file_path': filePath,
      };
}
