// lib/src/screens/informacaoScreen.dart

import 'package:biblia_e_harpa/src/models/avisoModel.dart';
import 'package:flutter/material.dart';

import '../components/card_aviso_component.dart';

class InformacaoScreen extends StatefulWidget {
  final List<AvisoModel> avisos;

  const InformacaoScreen({super.key, required this.avisos});

  @override
  State<InformacaoScreen> createState() => _InformacaoScreenState();
}

class _InformacaoScreenState extends State<InformacaoScreen> {
  // 1. Adiciona o controller e as listas para o filtro
  final TextEditingController _searchController = TextEditingController();
  List<AvisoModel> _allAvisos = [];
  List<AvisoModel> _filteredAvisos = [];

  @override
  void initState() {
    super.initState();
    // 2. Popula as listas com os dados recebidos e adiciona o listener
    _allAvisos = widget.avisos;
    _filteredAvisos = widget.avisos;
    _searchController.addListener(_filterAvisos);
  }

  @override
  void dispose() {
    // 3. Limpa o controller para evitar vazamentos de memória
    _searchController.removeListener(_filterAvisos);
    _searchController.dispose();
    super.dispose();
  }

  // 4. Função para normalizar o texto (remover acentos e converter para minúsculas)
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

  // 5. Função que filtra a lista de avisos com base na busca
  void _filterAvisos() {
    final query = _searchController.text;
    setState(() {
      _filteredAvisos = _allAvisos.where((aviso) {
        // Busca no título e no corpo do aviso
        final bool matchesSearch = query.isEmpty ||
            _normalize(aviso.titulo).contains(_normalize(query)) ||
            _normalize(aviso.descricao).contains(_normalize(query));
        return matchesSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            // 6. Conecta o TextField ao controller e habilita o botão de limpar
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Pesquisar informação",
                labelStyle:
                TextStyle(color: Theme.of(context).colorScheme.secondary),
                border: const OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                suffixIcon: IconButton(
                  onPressed: () => _searchController.clear(),
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
          Expanded(
            // 7. Remove o FutureBuilder e constrói a lista com base na lista filtrada
            child: _filteredAvisos.isEmpty
                ? const Center(child: Text('Nenhum aviso corresponde à sua busca.'))
                : ListView.builder(
              itemCount: _filteredAvisos.length,
              itemBuilder: (context, index) {
                final aviso = _filteredAvisos[index];
                return CardAvisoComponent(aviso: aviso);
              },
            ),
          ),
        ],
      ),
    );
  }
}
