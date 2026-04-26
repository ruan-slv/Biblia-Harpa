import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:biblia_e_harpa/src/components/appBarComponent.dart';
import 'package:biblia_e_harpa/src/config.dart';
import 'package:biblia_e_harpa/src/controllers/fontSizeController.dart';
import 'package:biblia_e_harpa/src/keys/biblekey.dart';
import 'package:biblia_e_harpa/src/screens/chapter_list_screen.dart';
import 'package:biblia_e_harpa/src/screens/textBibleScreen.dart';
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

  List<Map<String, dynamic>> _audioBooks = [];

  @override
  void initState() {
    super.initState();
    _loadSelectedVersion();
    _loadAudioBooks();
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

  Future<void> _loadAudioBooks() async {
    try {
      final String response = await rootBundle.loadString("assets/json/audios.json");
      final List<dynamic> data = json.decode(response);
      if (mounted) {
        setState(() {
          _audioBooks = List<Map<String, dynamic>>.from(data);
        });
      }
    } catch (_) {}
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

  void _navigateToBook(String bookName) {
    List<AudioChapter>? audioChaptersForBook;
    try {
      final audioBookData = _audioBooks.firstWhere(
            (audioBook) => audioBook['title'] == bookName,
        orElse: () => {},
      );

      if (audioBookData.isNotEmpty) {
        var chaptersList = audioBookData["chapters"] as List;
        audioChaptersForBook = chaptersList.map((c) => AudioChapter.fromJson(c)).toList();
      }
    } catch (_) {}

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChapterListScreen(
          name: bookName,
          jsonPath: _jsonPath,
          audioChapters: audioChaptersForBook,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(
        title: "Biblia Cristã",
        centerTitle: false,
        automaticallyImplyLeading: true,
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
              padding: const EdgeInsets.all(10.0),
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
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 10, bottom: 4, left: 10, right: 10),
                itemCount: filteredBible.length,
                itemBuilder: (context, index) {
                  final bookName = filteredBible[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
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
                        _navigateToBook(bookName);
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
