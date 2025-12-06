// lib/src/screens/bible_list_screen.dart

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:biblia_e_harpa/src/components/appBarComponent.dart';
import 'package:biblia_e_harpa/src/config.dart';
import 'package:biblia_e_harpa/src/controllers/fontSizeController.dart';
import 'package:biblia_e_harpa/src/keys/biblekey.dart';
import 'package:biblia_e_harpa/src/screens/chapter_list_screen.dart';
import 'package:biblia_e_harpa/src/screens/textBibleScreen.dart'; // Importa o modelo AudioChapter
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BibleList extends StatefulWidget {
  const BibleList({super.key});

  @override
  _BibleListState createState() => _BibleListState();
}

class _BibleListState extends State<BibleList> {
  List<String> filteredBible = [];
  final TextEditingController _searchController = TextEditingController();
  String _jsonPath = 'assets/json/acf.json';

  // Lista para armazenar todos os livros em áudio
  List<Map<String, dynamic>> _audioBooks = [];

  @override
  void initState() {
    super.initState();
    _loadSelectedVersion();
    _loadAudioBooks(); // Carrega a lista de áudios
    filteredBible = books;
    _searchController.addListener(_filterBible);
  }

  Future<void> _loadSelectedVersion() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _jsonPath = 'assets/json/${prefs.getString('selectedVersion') ?? 'acf.json'}';
      });
    }
  }

  // Método para carregar a lista de áudios do JSON
  Future<void> _loadAudioBooks() async {
    try {
      final String response = await rootBundle.loadString("assets/json/audios.json");
      final List<dynamic> data = json.decode(response);
      if (mounted) {
        setState(() {
          _audioBooks = List<Map<String, dynamic>>.from(data);
        });
      }
    } catch (e) {
      // Erro ao carregar áudios, o app funcionará sem eles.
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterBible);
    _searchController.dispose();
    super.dispose();
  }

  String _normalize(String input) {
    return input.toLowerCase().replaceAll(RegExp(r'[áàâãä]'), 'a').replaceAll(RegExp(r'[éèêë]'), 'e').replaceAll(RegExp(r'[íìîï]'), 'i').replaceAll(RegExp(r'[óòôõö]'), 'o').replaceAll(RegExp(r'[úùûü]'), 'u').replaceAll(RegExp(r'[ç]'), 'c');
  }

  void _filterBible() {
    setState(() {
      filteredBible = books.where((book) => _normalize(book).contains(_normalize(_searchController.text))).toList();
    });
  }

  void _onMenuItemSelected(String value) async {
    final prefs = await SharedPreferences.getInstance();
    String newVersion = 'acf.json';
    switch (value) {
      case "ACF":
        newVersion = 'acf.json';
        break;
      case 'NVI':
        newVersion = 'nvi.json';
        break;
      case 'AA':
        newVersion = 'aa.json';
        break;
    }
    await prefs.setString('selectedVersion', newVersion);
    if (mounted) {
      setState(() {
        _jsonPath = 'assets/json/$newVersion';
      });
    }
  }

  // Método com a lógica de navegação centralizada
  void _navigateToBook(String bookName) {
    List<AudioChapter>? audioChaptersForBook;
    try {
      // Encontra o livro de áudio correspondente na lista _audioBooks
      final audioBookData = _audioBooks.firstWhere(
            (audioBook) => audioBook['title'] == bookName,
        orElse: () => {}, // Retorna um mapa vazio se não encontrar
      );

      if (audioBookData.isNotEmpty) {
        var chaptersList = audioBookData["chapters"] as List;
        audioChaptersForBook = chaptersList.map((c) => AudioChapter.fromJson(c)).toList();
      }
    } catch (e) {
      // Ignora erros, o app continuará sem áudio para este livro.
    }

    // Navega para a tela da lista de capítulos, passando os dados do áudio
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChapterListScreen(
          name: bookName,
          jsonPath: _jsonPath,
          audioChapters: audioChaptersForBook, // Passando os dados do áudio
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.secondary,
        ),
        title: Text(
          'Biblia Cristã',
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
        actions: [
          SizedBox(
            width: sizeBtnOptions[0],
            height: sizeBtnOptions[1],
            child: Theme(
              data: Theme.of(context).copyWith(
                popupMenuTheme: PopupMenuThemeData(
                  color: Theme.of(context).colorScheme.primary,
                  textStyle: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
              child: PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                onSelected: _onMenuItemSelected,
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem<String>(
                      value: "ACF",
                      child: Text(
                        "Almeida Corrigida Fiel",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: "NVI",
                      child: Text(
                        "Nova Versão Internacional",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: "AA",
                      child: Text(
                        "Almeida Atualizada",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                    ),
                  ];
                },
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Pesquisar livro",
                hintStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.secondary),
                suffixIcon: IconButton(
                  onPressed: () {
                    _searchController.clear();
                  },
                  icon: Icon(Icons.clear,
                      color: Theme.of(context).colorScheme.secondary),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.primary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              ),
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
              cursorColor: Theme.of(context).colorScheme.secondary,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredBible.length,
              itemBuilder: (context, index) {
                final bookName = filteredBible[index];
                return ListTile(
                  leading: Icon(Icons.menu_book_rounded,
                      color: Theme.of(context).colorScheme.secondary),
                  title: ValueListenableBuilder<double>(
                    valueListenable: FontSizeController.fontSizeNotifier,
                    builder: (context, fontSize, _) {
                      return Text(
                        bookName,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: fontSize,
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    // Chama o novo método de navegação
                    _navigateToBook(bookName);
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
