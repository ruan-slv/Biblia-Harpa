// lib/src/screens/StoreScreen.dart

import 'package:flutter/material.dart';
import 'package:biblia_e_harpa/src/services/api_service.dart';
import '../models/produtoModel.dart';
import '../components/cardProduto.dart';

// 1. Convertido para StatefulWidget
class StoreScreen extends StatefulWidget {
  final List<ProdutoModel> produtos;
  const StoreScreen({super.key, required this.produtos});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  // 2. Variáveis de estado para filtros e listas
  final TextEditingController _searchController = TextEditingController();
  Future<List<ProdutoModel>>? _produtosFuture;
  List<ProdutoModel> _allProdutos = [];
  List<ProdutoModel> _filteredProdutos = [];

  // Lista de categorias (pode vir da API no futuro)
  final List<String> _categorias = ["Todos", "Livros", "Acessórios", "Roupas", "Presentes", "Decoração", "Jogos"];
  String _categoriaSelecionada = "Todos";

  @override
  void initState() {
    super.initState();
    // Inicia o carregamento dos produtos
    _produtosFuture = ApiServiceProduto.fetchProdutos();
    // Adiciona listener para o campo de pesquisa
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilters);
    _searchController.dispose();
    super.dispose();
  }

  // Função para normalizar texto (ignorar acentos e maiúsculas)
  String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[áàâãä]'), 'a')
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[íìîï]'), 'i')
        .replaceAll(RegExp(r'[óòôõö]'), 'o')
        .replaceAll(RegExp(r'[úùûü]'), 'u')
        .replaceAll(RegExp(r'[ç]'), 'c');
  }

  // 3. Função central que aplica ambos os filtros (pesquisa e categoria)
  void _applyFilters() {
    final query = _searchController.text;
    setState(() {
      _filteredProdutos = _allProdutos.where((produto) {
        // Filtro de Categoria
        final bool matchesCategory = _categoriaSelecionada == "Todos" ||
            _normalize(produto.categoria) == _normalize(_categoriaSelecionada);

        // Filtro de Pesquisa (no nome e descrição)
        final bool matchesSearch = query.isEmpty ||
            _normalize(produto.nome).contains(_normalize(query)) ||
            _normalize(produto.descricao).contains(_normalize(query));

        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  // Função para mudar a categoria e reaplicar os filtros
  void _selectCategory(String categoria) {
    setState(() {
      _categoriaSelecionada = categoria;
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Barra de Pesquisa
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController, // Controller conectado
              decoration: InputDecoration(
                labelText: "Pesquisar produto",
                labelStyle:
                TextStyle(color: Theme.of(context).colorScheme.secondary),
                border: const OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                suffixIcon: IconButton(
                  onPressed: () => _searchController.clear(), // Função para limpar
                  icon: Icon(
                    Icons.clear,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
              cursorColor: Theme.of(context).colorScheme.secondary,
            ),
          ),

          // 4. Barra de Categorias
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              itemCount: _categorias.length,
              itemBuilder: (context, index) {
                final categoria = _categorias[index];
                final isSelected = categoria == _categoriaSelecionada;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(categoria),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        _selectCategory(categoria);
                      }
                    },
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    selectedColor: Theme.of(context).colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                );
              },
            ),
          ),

          // Lista de Produtos
          Expanded(
            child: FutureBuilder<List<ProdutoModel>>(
              future: _produtosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Erro ao carregar produtos. Verifique sua conexão e tente novamente.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Nenhum produto encontrado.'));
                }

                // Popula as listas apenas uma vez
                if (_allProdutos.isEmpty) {
                  _allProdutos = snapshot.data!;
                  _filteredProdutos = _allProdutos;
                }

                if (_filteredProdutos.isEmpty) {
                  return const Center(child: Text('Nenhum produto corresponde ao seu filtro.'));
                }

                // A lista agora usa a lista filtrada
                return ListView.builder(
                  itemCount: _filteredProdutos.length,
                  itemBuilder: (context, index) {
                    final produto = _filteredProdutos[index];
                    return CardProduto(produto: produto);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
