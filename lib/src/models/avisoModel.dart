class Aviso {
  final int id;
  final String titulo;
  final String descricao;
  final String imagemURL;
  final String dataPublicacao;

  Aviso({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.imagemURL,
    required this.dataPublicacao,
  });

  factory Aviso.fromJson(Map<String, dynamic> json) {
    return Aviso(
      id: json['id'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      imagemURL: json['imagem'],
      dataPublicacao: json['dataPublicacao'],
    );
  }
}