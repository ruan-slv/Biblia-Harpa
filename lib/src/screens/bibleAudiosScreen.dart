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
  // Removido o player de áudio desta tela, pois a lógica de play não era usada aqui.

  // Variáveis para a lista e o filtro
  List<Book> _allBooks = [];
  List<Book> _filteredBooks = [];
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAudios();
    // Adiciona um listener para o controller da pesquisa
    _searchController.addListener(_filterBooks); // Agora vai encontrar o método
  }

  @override
  void dispose() {
    // Limpa o controller para evitar vazamentos de memória
    _searchController.removeListener(_filterBooks); // Agora vai encontrar o método
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

  // CORREÇÃO: Método renomeado e lógica interna ajustada
  void _filterBooks() {
    final query = _searchController.text;
    setState(() {
      _filteredBooks = _allBooks
          .where(
            (book) =>
        // Compara o título normalizado do livro com a busca normalizada
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
        _filteredBooks = books; // Inicialmente, a lista filtrada é igual à lista completa
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error =
        "Esta funcionalidade começou a ser desenvolvida no dia 03/09/2025\nAguarde só mais um pouco, tentaremos finalizar esta funcionalidade até Novembro";
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
          child: Text(
            _error!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    // A UI agora é uma Column que contém a barra de pesquisa e a lista
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController, // Conecta o controller
            decoration: InputDecoration(
              labelText: "Pesquisar livro", // Texto atualizado
              labelStyle:
              TextStyle(color: Theme.of(context).colorScheme.secondary),
              border: const OutlineInputBorder(),
              prefixIcon: Icon(
                Icons.search,
                color: Theme.of(context).colorScheme.secondary,
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  _searchController.clear(); // Limpa o campo de pesquisa
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
        // Adicionado Expanded para que a lista ocupe o resto da tela
        Expanded(
          child: ListView.builder(
            itemCount: _filteredBooks.length, // Usa a lista filtrada
            itemBuilder: (context, index) {
              final book = _filteredBooks[index]; // Usa a lista filtrada
              return ListTile(
                trailing: Icon(
                  Icons.list,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                title: Text(
                  book.title,
                  style:
                  TextStyle(color: Theme.of(context).colorScheme.secondary),
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
