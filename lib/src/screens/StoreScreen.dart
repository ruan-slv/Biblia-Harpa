// lib/src/screens/StoreScreen.dart

import 'package:flutter/material.dart';
import 'package:biblia_e_harpa/src/services/api_service.dart'; // Certifique-se que o import está correto
import '../models/produtoModel.dart';
import '../components/cardProduto.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Listas para gerenciar os produtos
  List<ProdutoModel> _allProdutos = [];
  List<ProdutoModel> _filteredProdutos = [];

  // Variáveis para controlar o estado do carregamento
  bool _isLoading = true;
  String? _error;

  final List<String> _categorias = ["Todos", "Livros", "Acessórios", "Roupas", "Presentes"];
  String _categoriaSelecionada = "Todos";

  @override
  void initState() {
    super.initState();
    // Inicia o carregamento dos produtos
    _fetchAndSetProdutos();
    _searchController.addListener(_applyFilters);
  }

  // Método para buscar os produtos da API
  Future<void> _fetchAndSetProdutos() async {
    try {
      final produtos = await ApiServiceProduto.fetchProdutos();
      if (mounted) {
        setState(() {
          _allProdutos = produtos;
          _filteredProdutos = produtos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erro ao carregar produtos. Verifique sua conexão.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilters);
    _searchController.dispose();
    super.dispose();
  }

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

  // Filtra os produtos com base na busca e na categoria
  void _applyFilters() {
    final query = _searchController.text;
    setState(() {
      _filteredProdutos = _allProdutos.where((produto) {
        final bool matchesCategory = _categoriaSelecionada == "Todos" ||
            _normalize(produto.categoria) == _normalize(_categoriaSelecionada);

        final bool matchesSearch = query.isEmpty ||
            _normalize(produto.nome).contains(_normalize(query)) ||
            _normalize(produto.descricao).contains(_normalize(query));

        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  // Seleciona uma categoria e aplica o filtro
  void _selectCategory(String categoria) {
    setState(() {
      _categoriaSelecionada = categoria;
    });
    _applyFilters();
  }

  // Constrói o corpo da tela (grid de produtos ou mensagens de estado)
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      );
    }

    if (_allProdutos.isEmpty) {
      return const Center(child: Text('Nenhum produto encontrado.'));
    }

    if (_filteredProdutos.isEmpty) {
      return const Center(child: Text('Nenhum produto corresponde à sua busca.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        childAspectRatio: 0.70,
      ),
      itemCount: _filteredProdutos.length,
      itemBuilder: (context, index) {
        final produto = _filteredProdutos[index];
        return CardProduto(produto: produto);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          // Barra de Pesquisa (no estado inicial, dentro do build)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Buscar na Loja",
                hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              ),
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
          ),

          // Barra de Categorias (no estado inicial, dentro do build)
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
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
                      if (selected) _selectCategory(categoria);
                    },
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    selectedColor: Theme.of(context).colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(
                        color: isSelected ? Colors.transparent : Colors.grey.shade300,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }
}
