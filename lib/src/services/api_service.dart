import 'package:biblia_e_harpa/src/models/produtoModel.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiServiceProduto {
  static const String baseUrl = "https://bible-server-api.vercel.app/api/loja";
  static Future<List<ProdutoModel>> fetchProdutos() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data);
      final List produtos = [
        ...data['livros'],
        ...data['acessorios'],
        ...data['Roupas'],
        ...data['Presentes'],
        ...data['Decoração'],
        ...data['Jogos'],
      ];
      return produtos.map((item) => ProdutoModel.fromJson(item)).toList();
    } else {
      throw Exception("Erro ao carregar produtos da loja");
    }
  }
}