import 'dart:convert';
import 'package:biblia_e_harpa/src/controllers/bible_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _ChapterListScreenState extends State<ChapterListScreen>
    with SingleTickerProviderStateMixin {
  late Future<Map<String, dynamic>> _bibleData;
  final TextEditingController _searchController = TextEditingController();
  final BibleController _bibleController = BibleController();
  List<List<dynamic>> _allChapters = [];
  List<int> _filteredChapterNumbers = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _bibleData = _loadBibleData(widget.name);
    _searchController.addListener(_filterChapters);
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterChapters);
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.secondary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
          indicatorColor: Theme.of(context).colorScheme.secondary,
          tabs: const [
            Tab(text: "Todos"),
            Tab(text: "Marcados como Lido"),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Pesquisar Capítulo",
                labelStyle:
                TextStyle(color: Theme.of(context).colorScheme.secondary),
                border: const OutlineInputBorder(),
                prefixIcon: Icon(Icons.search,
                    color: Theme.of(context).colorScheme.secondary),
                suffixIcon: IconButton(
                  onPressed: () => _searchController.clear(),
                  icon: Icon(Icons.clear,
                      color: Theme.of(context).colorScheme.secondary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.secondary),
                ),
              ),
              style:
              TextStyle(color: Theme.of(context).colorScheme.secondary),
              cursorColor: Theme.of(context).colorScheme.secondary,
            ),
          ),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _bibleData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Nenhum texto foi encontrado"));
                }

                if (_allChapters.isEmpty && snapshot.data!.containsKey('chapters')) {
                  final chaptersData = snapshot.data!["chapters"] as List? ?? [];
                  _allChapters = chaptersData.map((c) => List<dynamic>.from(c as List)).toList();
                  _filteredChapterNumbers = List<int>.generate(_allChapters.length, (i) => i + 1);
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    // Aba "Todos"
                    _buildChapterGrid(_filteredChapterNumbers),

                    // Aba "Marcados como Lido"
                    ValueListenableBuilder<List<String>>(
                      valueListenable: _bibleController.textosLidosNotifier,
                      builder: (context, lidos, _) {
                        // Filtra os IDs de capítulos lidos que pertencem a este livro
                        final readChaptersForThisBook = lidos
                            .where((id) => id.startsWith("${widget.name}_"))
                            .map((id) {
                          // Extrai o número do capítulo do ID (ex: "Gênesis_1" -> 1)
                          return int.tryParse(id.split('_').last) ?? 0;
                        }).toList();

                        // Aplica o filtro de pesquisa também a esta lista
                        final filteredReadChapters = readChaptersForThisBook
                            .where((num) => _filteredChapterNumbers.contains(num))
                            .toList();

                        return _buildChapterGrid(filteredReadChapters);
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Função auxiliar para construir a grade de capítulos
  Widget _buildChapterGrid(List<int> chaptersToShow) {
    if (chaptersToShow.isEmpty) {
      return const Center(
        child: Text('Nenhum capítulo encontrado.'),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
          childAspectRatio: 1.0,
        ),
        itemCount: chaptersToShow.length,
        itemBuilder: (context, index) {
          final int chapterNumber = chaptersToShow[index];
          return ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Textbiblescreen(
                    bookName: widget.name,
                    jsonPath: widget.jsonPath,
                    initialChapterNumber: chapterNumber,
                    allBookChapters: _allChapters,
                  ),
                ),
              );
            },
            style: ButtonStyle(
              padding: WidgetStateProperty.all(EdgeInsets.zero),
              minimumSize: WidgetStateProperty.all(const Size(30, 30)),
              side: WidgetStateProperty.all(
                const BorderSide(color: Colors.blueGrey, width: 0.5),
              ),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.0)),
              ),
              backgroundColor:
              WidgetStateProperty.all(Theme.of(context).colorScheme.primary),
              foregroundColor:
              WidgetStateProperty.all(Theme.of(context).colorScheme.secondary),
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
  }
}
