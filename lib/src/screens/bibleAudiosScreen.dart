import 'dart:convert';
import 'package:biblia_e_harpa/src/controllers/fontSizeController.dart';
import 'package:biblia_e_harpa/src/screens/audioBookChaptersScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import "package:flutter/services.dart" show rootBundle;

class AudioData {
  final String name;
  final String url;

  AudioData({
    required this.name,
    required this.url,
  });

  factory AudioData.fromJson(Map<String, dynamic> json) {
    return AudioData(name: json["name"], url: json["url"]);
  }
}

class Book {
  final String title;
  final List<AudioData> chapters;

  Book({
    required this.title,
    required this.chapters,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    var list = json["chapters"] as List;
    List<AudioData> chapterList =
    list.map((i) => AudioData.fromJson(i)).toList();
    return Book(title: json["title"], chapters: chapterList);
  }
}

class Bibleaudiosscreen extends StatefulWidget {
  const Bibleaudiosscreen({super.key});

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
            (book) =>
            _normalize(book.title).contains(_normalize(query)),
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

      setState(() {
        _allBooks = books;
        _filteredBooks = books;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error =
        "Erro ao listar áudios. Tente novamente mais tarde ou entre em contato com o desenvolvedor para relatar o ocorrido.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
              labelText: "Pesquisar livro",
              labelStyle:
              TextStyle(color: Theme.of(context).colorScheme.secondary),
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
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            cursorColor: Theme.of(context).colorScheme.secondary,
          ),
        ),
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
                      style:
                      TextStyle(
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
