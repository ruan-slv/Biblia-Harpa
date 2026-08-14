/// Tela que apresenta os capítulos de um livro bíblico.
///
/// Ela carrega os dados do livro a partir de um asset ou arquivo local, permite
/// filtrar os capítulos por número e separa a visualização entre todos os
/// capítulos e aqueles que já foram lidos.
library;

import 'dart:convert';
import 'dart:io';
import 'package:biblia_e_harpa/src/components/appBarComponent.dart';
import 'package:biblia_e_harpa/src/controllers/bible_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:biblia_e_harpa/src/screens/textBibleScreen.dart';
import 'package:biblia_e_harpa/src/controllers/fontSizeController.dart';

/// Widget de entrada da lista de capítulos de um livro.
///
/// O estado interno é necessário porque os dados são carregados
/// assincronamente e a lista exibida muda conforme a busca do usuário.
class ChapterListScreen extends StatefulWidget {
  /// Nome do livro usado no título, na busca do JSON e na chave de leitura.
  final String name;

  /// Caminho do arquivo JSON, seja um asset do app ou um arquivo no dispositivo.
  final String jsonPath;

  /// Capítulos com áudio disponíveis para encaminhar à tela de leitura.
  final List<AudioChapter>? audioChapters;

  /// Cria a tela para o livro e a fonte de dados informados.
  const ChapterListScreen({
    super.key,
    required this.name,
    required this.jsonPath,
    this.audioChapters,
  });

  @override
  State<ChapterListScreen> createState() => _ChapterListScreenState();
}

/// Estado que controla o carregamento, a busca e as abas da tela.
class _ChapterListScreenState extends State<ChapterListScreen> with SingleTickerProviderStateMixin {
  /// Operação assíncrona que obtém o objeto JSON do livro selecionado.
  late Future<Map<String, dynamic>> _bibleData;

  /// Fonte compartilhada dos capítulos marcados como lidos.
  final BibleController _bibleController = BibleController();

  /// Controla o texto digitado no campo de busca por capítulo.
  final TextEditingController _searchController = TextEditingController();

  /// Todos os capítulos do livro, preservados para a tela de leitura.
  List<List<dynamic>> _allChapters = [];

  /// Números de capítulos que atendem ao filtro de busca atual.
  List<int> _filteredChapterNumbers = [];

  /// Coordena a aba selecionada e o conteúdo do [TabBarView].
  late TabController _tabController;

  @override
  /// Inicializa os controladores e inicia o carregamento uma única vez.
  void initState() {
    super.initState();

    /// Inicia a leitura do livro antes da primeira renderização.
    _bibleData = _loadBibleData(widget.name);

    /// As abas representam todos os capítulos e os capítulos lidos.
    _tabController = TabController(length: 2, vsync: this);

    /// Atualiza a grade sempre que o usuário altera o texto de busca.
    _searchController.addListener(_filterChapters);
  }

  /// Filtra os números dos capítulos pelo texto digitado.
  ///
  /// Como a busca é numérica, cada número de capítulo é convertido para texto
  /// antes de ser comparado com a consulta informada.
  void _filterChapters() {
    final query = _searchController.text;
    setState(() {
      if (query.isEmpty) {
        /// Sem busca ativa, volta a mostrar todos os capítulos em ordem.
        _filteredChapterNumbers = List<int>.generate(_allChapters.length, (i) => i + 1);
      } else {
        /// Mantém somente os números que contêm o termo buscado.
        _filteredChapterNumbers = List<int>.generate(_allChapters.length, (i) => i + 1)
            .where((n) => n.toString().contains(query))
            .toList();
      }
    });
  }

  /// Carrega e retorna os dados de [bookName] a partir do JSON configurado.
  ///
  /// O caminho pode apontar para um asset empacotado pelo Flutter ou para um
  /// arquivo salvo localmente. Em caso de erro ou livro ausente, retorna um
  /// mapa vazio para que a interface exiba seu estado de erro.
  Future<Map<String, dynamic>> _loadBibleData(String bookName) async {
    try {
      String jsonString;
      if (widget.jsonPath.startsWith('assets/')) {
        /// Assets são lidos pelo bundle que acompanha o aplicativo.
        jsonString = await rootBundle.loadString(widget.jsonPath);
      } else {
        /// Caminhos externos exigem a verificação de existência do arquivo.
        final file = File(widget.jsonPath);
        if (await file.exists()) {
          /// Lê o conteúdo textual do JSON salvo no dispositivo.
          jsonString = await file.readAsString();
        } else {
          /// Interrompe o fluxo para ser tratado pelo bloco [catch].
          throw Exception("Ficheiro não encontrado.");
        }
      }

      /// Converte o JSON em lista e seleciona o objeto do livro solicitado.
      final List<dynamic> bibleData = json.decode(jsonString);
      final bookData = bibleData.firstWhere((book) => book['name'] == bookName, orElse: () => null);

      /// Garante o contrato de retorno mesmo quando o livro não estiver no arquivo.
      return bookData != null ? bookData as Map<String, dynamic> : {};
    } catch (e) {
      /// Registra o diagnóstico sem interromper a renderização da tela.
      debugPrint("Erro ao carregar capítulos: $e");
      return {};
    }
  }

  @override
  /// Constrói a estrutura visual da tela e reage ao resultado do carregamento.
  Widget build(BuildContext context) {
    return Scaffold(
      /// Usa a cor de fundo definida pelo tema ativo.
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: CustomAppBar(
        /// Exibe o nome do livro no cabeçalho.
        title: widget.name,
        centerTitle: true,
        automaticallyImplyLeading: true,
        tabBar: TabBar(
          /// Mantém a aba e a página de conteúdo sincronizadas.
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.secondary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
          indicatorColor: Theme.of(context).colorScheme.secondary,
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle:
          const TextStyle(fontWeight: FontWeight.normal),
          tabs: const [Tab(text: "Todos"), Tab(text: "Lidos")],
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        /// Observa o carregamento iniciado em [initState].
        future: _bibleData,
        builder: (context, snapshot) {
          /// Informa que os dados ainda estão sendo obtidos.
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          /// Impede o uso de dados ausentes ou inválidos.
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Erro ao carregar capítulos."));
          }

          /// Converte os capítulos para uma lista mutável na primeira leitura.
          if (_allChapters.isEmpty) {
            final chaptersData = snapshot.data!["chapters"] as List? ?? [];
            _allChapters = chaptersData.map((c) => List<dynamic>.from(c as List)).toList();

            /// Inicializa o filtro com todos os capítulos disponíveis.
            _filteredChapterNumbers = List<int>.generate(_allChapters.length, (i) => i + 1);
          }

          return Column(
            children: [
              /// Campo numérico para filtrar capítulos pelo respectivo número.
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Buscar capítulo",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.primary,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0), borderSide: BorderSide.none),
                  ),
                ),
              ),
              /// Ocupa o espaço restante com o conteúdo da aba selecionada.
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    /// Primeira aba: capítulos filtrados ou todos os capítulos.
                    _buildChapterGrid(_filteredChapterNumbers),

                    /// Segunda aba: somente capítulos registrados como lidos.
                    _buildReadChaptersTab(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Cria a aba que acompanha em tempo real os capítulos marcados como lidos.
  Widget _buildReadChaptersTab() {
    return ValueListenableBuilder<List<String>>(
      /// Reconstrói a aba quando o controlador altera a lista de leituras.
      valueListenable: _bibleController.textosLidosNotifier,
      builder: (context, lidos, _) {
        /// Filtra as chaves do livro atual e extrai seus números de capítulo.
        final readChapters = lidos
            .where((id) => id.startsWith("${widget.name}_"))
            .map((id) => int.tryParse(id.split('_').last) ?? 0)
            .where((n) => n > 0).toList();
        return _buildChapterGrid(readChapters);
      },
    );
  }

  /// Monta a grade de botões para os números em [chaptersToShow].
  ///
  /// A mesma grade é reutilizada pelas abas "Todos" e "Lidos".
  Widget _buildChapterGrid(List<int> chaptersToShow) {
    /// Evita a construção de uma grade vazia e fornece feedback ao usuário.
    if (chaptersToShow.isEmpty) return const Center(child: Text("Nenhum capítulo disponível."));

    return ValueListenableBuilder<List<String>>(
      /// Atualiza a aparência dos botões ao marcar ou desmarcar uma leitura.
      valueListenable: _bibleController.textosLidosNotifier,
      builder: (context, lidos, _) {
        return GridView.builder(
          padding: const EdgeInsets.all(10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: chaptersToShow.length,
          itemBuilder: (context, index) {
            /// Obtém o capítulo da posição atual da grade.
            final chapterNumber = chaptersToShow[index];

            /// A chave combina o livro e o capítulo, como no controlador de leitura.
            final bool isRead = lidos.contains("${widget.name}_$chapterNumber");

            return ElevatedButton(
              onPressed: () {
                /// Abre o conteúdo do capítulo, mantendo os dados já carregados.
                Navigator.push(context, MaterialPageRoute(builder: (context) => Textbiblescreen(
                  bookName: widget.name,
                  jsonPath: widget.jsonPath,
                  initialChapterNumber: chapterNumber,
                  allBookChapters: _allChapters,
                  audioChapters: widget.audioChapters,
                )));
              },
              style: ButtonStyle(
                /// Mantém os botões compactos e visualmente uniformes na grade.
                padding: WidgetStateProperty.all(EdgeInsets.zero),
                minimumSize: WidgetStateProperty.all(const Size(30, 30)),
                side: WidgetStateProperty.all(const BorderSide(color: Colors.blueGrey, width: 0.5)),
                shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.0))),
                backgroundColor: WidgetStateProperty.all(
                  /// Destaca capítulos lidos sem perder a cor do tema nos demais.
                  isRead ? Colors.blue.withOpacity(0.7) : Theme.of(context).colorScheme.primary,
                ),
                foregroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.secondary),
              ),
              child: ValueListenableBuilder<double>(
                /// Usa o tamanho de fonte escolhido nas configurações do app.
                valueListenable: FontSizeController.fontSizeNotifier,
                builder: (context, fontSize, _) {
                  return Text(
                    "$chapterNumber",
                    style: TextStyle(
                      /// Reforça visualmente a leitura concluída com negrito.
                      fontSize: fontSize,
                      fontWeight: isRead ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
