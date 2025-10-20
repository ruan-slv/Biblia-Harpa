// lib/src/models/produtoModel.dart

class ProdutoModel {
  final String id;
  final String nome;
  final String descricao;
  final String imagemURL;
  final String linkProduto;
  final String categoria; // <-- CAMPO ADICIONADO

  ProdutoModel({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.imagemURL,
    required this.linkProduto,
    required this.categoria, // <-- CAMPO ADICIONADO
  });

  factory ProdutoModel.fromJson(Map<String, dynamic> json) {
    return ProdutoModel(
      id: json['id'] ?? '',
      nome: json['nome'] ?? 'Nome indisponível',
      descricao: json['descricao'] ?? 'Descrição indisponível',
      imagemURL: json['imagemURL'] ?? '',
      linkProduto: json['linkProduto'] ?? '',
      categoria: json['categoria'] ?? 'Geral', // <-- CAMPO ADICIONADO
    );
  }
}
