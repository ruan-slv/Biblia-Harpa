class AvisoModel {
  final String id;
  final String titulo;
  final String descricao;
  final String imagemURL;
  final String dataPublicacao;

  AvisoModel({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.imagemURL,
    required this.dataPublicacao,
  });

  factory AvisoModel.fromJson(Map<String, dynamic> json) {
    return AvisoModel(
      id: json['id'].toString() ?? "",
      titulo: json['titulo'] ?? "",
      descricao: json['descricao'] ?? "",
      imagemURL: json['imagem'] ?? "",
      dataPublicacao: json['dataPublicacao'] ?? "",
    );
  }
}