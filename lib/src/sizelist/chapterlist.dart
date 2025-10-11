import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Removido 'config.dart' se não for usado, ou certifique-se que existe.
// import 'package:biblia_e_harpa/src/config.dart';
import 'package:biblia_e_harpa/src/screens/textBibleScreen.dart';
import 'package:biblia_e_harpa/src/controllers/fontSizeController.dart';

class ChapterListScreen extends StatefulWidget {
  final String name;
  final String jsonPath;

  const ChapterListScreen({
    super.key,
    required this.name,
    required this.jsonPath,
  });

  @override
  State<ChapterListScreen> createState() => _ChapterListScreenState();
}

class _ChapterListScreenState extends State<ChapterListScreen> {
  late Future<Map<String, dynamic>> _bibleData;
  final TextEditingController _searchController = TextEditingController();
  List<List<dynamic>> _allChapters = [];
  List<int> _filteredChapterNumbers = [];

  @override
  void initState() {
    super.initState();
    _bibleData = _loadBibleData(widget.name);
    _searchController.addListener(_filterChapters);
  }

  @override
  void dispose() {
    // CORREÇÃO: A ordem importa. Primeiro remova listeners e dê dispose nos controllers.
    _searchController.removeListener(_filterChapters);
    _searchController.dispose();
    super.dispose(); // CORREÇÃO: super.dispose() deve ser chamado por último.
  }

  Future<Map<String, dynamic>> _loadBibleData(String name) async {
    try {
      String jsonString = await rootBundle.loadString(widget.jsonPath);
      final List<dynamic> bibleData = json.decode(jsonString);

      final bookData = bibleData.firstWhere(
            (book) => book['name'] == name,
        orElse: () => null,
      );

      if (bookData != null) {
        return bookData as Map<String, dynamic>;
      } else {
        throw Exception("Livro com a abreviação '$name' não encontrado.");
      }
    } catch (e) {
      // Em um app de produção, seria bom logar o erro 'e'
      return {};
    }
  }

  void _filterChapters() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _filteredChapterNumbers =
        List<int>.generate(_allChapters.length, (index) => index + 1);
      });
    } else {
      final List<int> tempFilteredList = [];
      for (int i = 0; i < _allChapters.length; i++) {
        final chapterNumber = i + 1;
        if (chapterNumber.toString().contains(query)) {
          tempFilteredList.add(chapterNumber);
        }
      }
      setState(() {
        _filteredChapterNumbers = tempFilteredList;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        automaticallyImplyLeading: true,
        iconTheme:
        IconThemeData(color: Theme.of(context).colorScheme.secondary),
        title: Text(
          widget.name,
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              keyboardType: TextInputType.number, // Melhora a experiência para pesquisar números
              decoration: InputDecoration(
                labelText: "Pesquisar Capítulo",
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
                border: const OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    _searchController.clear();
                  },
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
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              ),
              cursorColor: Theme.of(context).colorScheme.secondary,
            ),
          ),
          // CORREÇÃO: Adicionado Expanded para dar um tamanho à GridView.
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _bibleData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text("Nenhum texto foi encontrado"));
                }

                final Map<String, dynamic> bookData = snapshot.data!;

                // Apenas popula as listas se elas estiverem vazias.
                // Isso evita que o filtro seja resetado a cada rebuild (ex: ao digitar no TextField).
                if (_allChapters.isEmpty && bookData.containsKey('chapters')) {
                  final chaptersData = bookData["chapters"] as List? ?? [];
                  _allChapters =
                      chaptersData.map((c) => List<dynamic>.from(c as List)).toList();
                  _filteredChapterNumbers =
                  List<int>.generate(_allChapters.length, (i) => i + 1);
                }

                if (_allChapters.isEmpty) {
                  return const Center(
                      child: Text('Nenhum capítulo encontrado.'));
                }

                // Mensagem para quando a pesquisa não retorna resultados
                if (_filteredChapterNumbers.isEmpty) {
                  return const Center(
                    child: Text('Nenhum capítulo corresponde à sua pesquisa.'),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: GridView.builder(
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      crossAxisSpacing: 4.0,
                      mainAxisSpacing: 4.0,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: _filteredChapterNumbers.length,
                    itemBuilder: (context, index) {
                      // CORREÇÃO: Pegue o número do capítulo da lista filtrada.
                      final int chapterNumber = _filteredChapterNumbers[index];
                      return ElevatedButton(
                        onPressed: () {
                          // A lógica de navegação agora usa a lista `_allChapters` que já está em memória.
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Textbiblescreen(
                                bookName: widget.name,
                                jsonPath: widget.jsonPath,
                                initialChapterNumber: chapterNumber,
                                allBookChapters: _allChapters, // Usa a lista já carregada
                              ),
                            ),
                          );
                        },
                        style: ButtonStyle(
                          padding:
                          WidgetStateProperty.all(EdgeInsets.zero),
                          minimumSize:
                          WidgetStateProperty.all(const Size(30, 30)),
                          side: WidgetStateProperty.all(
                            const BorderSide(
                                color: Colors.blueGrey, width: 0.5),
                          ),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7.0),
                            ),
                          ),
                          backgroundColor: WidgetStateProperty.all(
                              Theme.of(context).colorScheme.primary),
                          foregroundColor: WidgetStateProperty.all(
                              Theme.of(context).colorScheme.secondary),
                        ),
                        child: ValueListenableBuilder<double>(
                          valueListenable: FontSizeController.fontSizeNotifier,
                          builder: (context, fontSize, _) {
                            return Text(
                              "$chapterNumber",
                              style: TextStyle(
                                fontSize: fontSize,
                                fontWeight: FontWeight.normal,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
