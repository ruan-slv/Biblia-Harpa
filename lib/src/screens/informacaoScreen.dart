// lib/src/screens/informacaoScreen.dart

import 'package:flutter/material.dart';
// Removemos o SharedPreferences e o NotificationService daqui
import 'package:biblia_e_harpa/src/models/avisoModel.dart';
import 'package:biblia_e_harpa/src/services/aviso_api_service.dart';
import '../components/card_aviso_component.dart';

class InformacaoScreen extends StatefulWidget {
  const InformacaoScreen({super.key});

  @override
  State<InformacaoScreen> createState() => _InformacaoScreenState();
}

class _InformacaoScreenState extends State<InformacaoScreen> {
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _error;
  List<AvisoModel> _allAvisos = [];
  List<AvisoModel> _filteredAvisos = [];

  late final Widget _searchBar;
  bool _widgetsInitialized = false;

  @override
  void initState() {
    super.initState();
    // Apenas busca os dados para exibir na tela
    _fetchAndSetAvisos();
    _searchController.addListener(_filterAvisos);
  }

  // Busca avisos apenas para popular a lista visual
  Future<void> _fetchAndSetAvisos() async {
    try {
      final avisos = await AvisoServiceAPI.fetchAvisos();

      if (mounted) {
        setState(() {
          _allAvisos = avisos;
          _filteredAvisos = avisos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erro ao carregar avisos. Verifique sua conexão.';
          _isLoading = false;
        });
      }
    }
  }

  // O método _verificarNovosAvisos foi removido pois agora roda no background_service.dart

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_widgetsInitialized) {
      _buildSearchBar();
      _widgetsInitialized = true;
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterAvisos);
    _searchController.dispose();
    super.dispose();
  }

  void _buildSearchBar() {
    final theme = Theme.of(context);
    _searchBar = Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Pesquisar Informação",
          hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.secondary),
          prefixIcon: Icon(Icons.search,
              color: Theme.of(context).colorScheme.secondary),
          suffixIcon: IconButton(
            onPressed: () => _searchController.clear(),
            icon: Icon(Icons.clear,
                color: Theme.of(context).colorScheme.secondary),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.primary,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
          contentPadding:
          const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        ),
        style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        cursorColor: Theme.of(context).colorScheme.secondary,
      ),
    );
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

  void _filterAvisos() {
    final query = _searchController.text;
    setState(() {
      _filteredAvisos = _allAvisos.where((aviso) {
        return query.isEmpty ||
            _normalize(aviso.titulo).contains(_normalize(query)) ||
            _normalize(aviso.descricao).contains(_normalize(query));
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_widgetsInitialized) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        automaticallyImplyLeading: true,
        iconTheme:
        IconThemeData(color: Theme.of(context).colorScheme.secondary),
        title: Text(
          "Informações e Avisos",
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _searchBar,
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildErrorWidget(context, _error!);
    }

    if (_allAvisos.isEmpty) {
      return _buildErrorWidget(context, "Nenhum aviso encontrado.");
    }

    if (_filteredAvisos.isEmpty && _searchController.text.isNotEmpty) {
      return _buildErrorWidget(context, "Nenhum aviso corresponde à sua busca.");
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8.0),
      itemCount: _filteredAvisos.length,
      itemBuilder: (context, index) {
        final aviso = _filteredAvisos[index];
        return CardAvisoComponent(aviso: aviso);
      },
    );
  }

  Widget _buildErrorWidget(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              message.contains("conexão") ? Icons.wifi_off : Icons.info_outline,
              size: 60,
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.7),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
