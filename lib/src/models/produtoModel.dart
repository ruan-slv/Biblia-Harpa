class ProdutoModel {
  final String? id;
  final String nome;
  final String descricao;
  final String imagemURL;
  final String linkProduto;

  ProdutoModel({this.id, required this.nome, required this.descricao, required this.imagemURL, required this.linkProduto});

  factory ProdutoModel.fromJson(Map<String, dynamic> json) {
    return ProdutoModel(
        id: json['id']?.toString() ?? "",
        nome: json['nome'] ?? "",
        descricao: json['descricao'] ?? "",
        imagemURL: json['imagemURL'] ?? "",
        linkProduto: json['linkProduto'] ?? "",
    );
  }
}