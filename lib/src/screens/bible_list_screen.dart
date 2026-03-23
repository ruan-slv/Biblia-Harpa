// lib/src/screens/bible_list_screen.dart

import 'dart:convert';
import 'package:biblia_e_harpa/src/services/bible_download_service.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:biblia_e_harpa/src/components/appBarComponent.dart';
import 'package:biblia_e_harpa/src/config.dart';
import 'package:biblia_e_harpa/src/controllers/fontSizeController.dart';
import 'package:biblia_e_harpa/src/keys/biblekey.dart';
import 'package:biblia_e_harpa/src/screens/chapter_list_screen.dart';
import 'package:biblia_e_harpa/src/screens/textBibleScreen.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BibleList extends StatefulWidget {
  const BibleList({super.key});

  @override
  _BibleListState createState() => _BibleListState();
}

class _BibleListState extends State<BibleList> {
  final BibleDownloadService _downloadService = BibleDownloadService();
  bool _isDownloading = false;
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
    String version = prefs.getString("selectedVersion") ?? "acf.json";

    if (mounted) {
      if (BibleDownloadService.assetVersions.contains(version)) {
        setState(() {
          _jsonPath = "assets/json/$version";
        });
      } else {
        await _updateInternalPath(version);
      }
    }
  }

  Future<void> _updateInternalPath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    setState(() {
      _jsonPath = "${directory.path}/$fileName";
    });
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
    } catch (e) {
      debugPrint("Erro ao carregar áudios: $e");
    }
  }

  void _filterBible() {
    setState(() {
      filteredBible = books
          .where((book) => book.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  void _onMenuItemSelected(String value) async {
    final prefs = await SharedPreferences.getInstance();
    String fileName = value.contains(".json") ? value : "$value.json";

    if (!BibleDownloadService.assetVersions.contains(fileName)) {
      bool jaBaixado = await _downloadService.isDownloaded(fileName);
      if (!jaBaixado) {
        setState(() => _isDownloading = true);
        bool sucesso = await _downloadService.downloadVersion(fileName);
        if (mounted) setState(() => _isDownloading = false);

        if (!sucesso) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Erro ao descarregar do Drive. Verifique a internet.")),
            );
          }
          return;
        }
      }
    }

    await prefs.setString("selectedVersion", fileName);
    _loadSelectedVersion();
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
    } catch (e) {
      debugPrint("Erro ao processar áudio: $e");
    }

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
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: CustomAppBar(
        title: "Bíblia Cristã",
        centerTitle: true,
        automaticallyImplyLeading: true,
        actions: [
          if (_isDownloading)
            const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.secondary),
            onSelected: _onMenuItemSelected,
            itemBuilder: (context) => [
              const PopupMenuItem(enabled: false, child: Text("Português 🇧🇷", style: TextStyle(fontWeight: FontWeight.bold))),
              const PopupMenuItem(value: "acf", child: Text("Almeida Corrigida Fiel")),
              const PopupMenuItem(value: "nvi", child: Text("Nova Versão Internacional")),
              const PopupMenuItem(value: "aa", child: Text("Almeida Atualizada")),
              /*
              const PopupMenuDivider(),
              const PopupMenuItem(enabled: false, child: Text("English 🇺🇸", style: TextStyle(fontWeight: FontWeight.bold))),
              const PopupMenuItem(value: "en_kjv", child: Text("King James Version")),
              const PopupMenuItem(value: "en_bbe", child: Text("Bible in Basic English")),
              const PopupMenuDivider(),
              const PopupMenuItem(enabled: false, child: Text("Outros Idiomas", style: TextStyle(fontWeight: FontWeight.bold))),
              const PopupMenuItem(value: "es_rvr", child: Text("Español 🇪🇸")),
              const PopupMenuItem(value: "de_schlachter", child: Text("Deutsch 🇩🇪")),
              const PopupMenuItem(value: "fr_apee", child: Text("Français 🇫🇷")),
              */
            ],
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
                prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.secondary),
                filled: true,
                fillColor: Theme.of(context).colorScheme.primary,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0), borderSide: BorderSide.none),
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
                  leading: Icon(Icons.menu_book_rounded, color: Theme.of(context).colorScheme.secondary),
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
                  onTap: () => _navigateToBook(bookName),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}