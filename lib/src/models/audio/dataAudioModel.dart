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