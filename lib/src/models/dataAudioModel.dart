/// Define os modelos de dados utilizados por este recurso do aplicativo.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

class DataAudioModel {
  final String titulo;
  final String hinoURL;

  DataAudioModel({
    required this.titulo,
    required this.hinoURL,
  });

  factory DataAudioModel.fromJson(Map<String, dynamic> json) {
    return DataAudioModel(titulo: json["titulo"] ?? "", hinoURL: json["hinoURL"] ?? "");
  }
}
