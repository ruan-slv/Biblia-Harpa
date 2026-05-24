import 'dart:convert';
import 'dart:io';
import 'package:biblia_e_harpa/src/controllers/font_size_controller.dart';
import 'package:biblia_e_harpa/src/screens/audio_book_chapters_screen.dart';
import 'package:flutter/material.dart';
import "package:flutter/services.dart" show rootBundle;
import 'package:path_provider/path_provider.dart';

import '../components/app_bar_component.dart';

class AudioData {
  final String name;
  final String url;

  AudioData({required this.name, required this.url});

  factory AudioData.fromJson(Map<String, dynamic> json) {
    return AudioData(name: json["name"], url: json["url"]);
  }
}

class Book {
  final String title;
  final List<AudioData> chapters;

  Book({required this.title, required this.chapters});

  factory Book.fromJson(Map<String, dynamic> json) {
    var list = json["chapters"] as List;
    List<AudioData> chapterList =
    list.map((i) => AudioData.fromJson(i)).toList();
    return Book(title: json["title"], chapters: chapterList);
  }
}

class Bibleaudiosscreen extends StatefulWidget {
  final bool isOffline;

  const Bibleaudiosscreen({
    super.key,
    this.isOffline = false
  });

  @override
  State<Bibleaudiosscreen> createState() => _BibleaudiosscreenState();
}

class _BibleaudiosscreenState extends State<Bibleaudiosscreen> {
  List<Book> _allBooks = [];
  List<Book> _filteredBooks = [];
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAudios();
    _searchController.addListener(_filterBooks);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterBooks);
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

  void _filterBooks() {
    final query = _searchController.text;
    setState(() {
      _filteredBooks = _allBooks
          .where(
            (book) => _normalize(book.title).contains(_normalize(query)),
      )
          .toList();
    });
  }
  Future<void> _fetchAudios() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final String response =
      await rootBundle.loadString("assets/json/audios.json");
      final List data = json.decode(response);
      List<Book> books = data.map((book) => Book.fromJson(book)).toList();

      if (widget.isOffline) {
        List<Book> offlineBooks = [];
        for (var book in books) {
          bool hasDownloadedChapter = await _checkIfBookHasDownloads(book);
          if (hasDownloadedChapter) {
            offlineBooks.add(book);
          }
        }
        books = offlineBooks;
      }

      if (mounted) {
        setState(() {
          _allBooks = books;
          _filteredBooks = books;
          _isLoading = false;

          if (widget.isOffline && books.isEmpty) {
            _error = "Nenhum áudio foi baixado para ser acessado offline.";
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Erro ao listar áudios. Verifique os arquivos do aplicativo.";
          _isLoading = false;
        });
      }
    }
  }

  Future<String> _getLocalFilePath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${directory.path}/bible_audios');
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    final safeName = fileName.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_');
    return '${audioDir.path}/$safeName.mp3';
  }

  Future<bool> _checkIfBookHasDownloads(Book book) async {
    for (var chapter in book.chapters) {
      final path = await _getLocalFilePath(chapter.name);
      if (await File(path).exists()) {
        return true;
      }
    }
    return false;
  }
  PreferredSizeWidget? _showAppBarIfOffline() {
    if (widget.isOffline) {
      return CustomAppBar(
        automaticallyImplyLeading: true,
        centerTitle: false,
        title: "Áudios Baixados (Offline)",
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _showAppBarIfOffline(),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ValueListenableBuilder<double>(
            valueListenable: FontSizeController.fontSizeNotifier,
            builder: (context, fontSize, _) {
              return Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: fontSize,
                ),
              );
            },
          ),
        ),
      );
    }
    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Pesquisar livro",
                hintStyle:
                TextStyle(color: Theme.of(context).colorScheme.secondary),
                prefixIcon: Icon(Icons.search,
                    color: Theme.of(context).colorScheme.secondary),
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
                contentPadding:
                const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              ),
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
              cursorColor: Theme.of(context).colorScheme.secondary,
            )),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredBooks.length,
            itemBuilder: (context, index) {
              final book = _filteredBooks[index];
              return ListTile(
                trailing: Icon(
                  Icons.list,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                title: ValueListenableBuilder<double>(
                  valueListenable: FontSizeController.fontSizeNotifier,
                  builder: (context, fontSize, _) {
                    return Text(
                      book.title,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: fontSize,
                      ),
                    );
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Audiobookchaptersscreen(book: book),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
