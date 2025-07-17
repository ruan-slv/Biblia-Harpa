import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:biblia_e_harpa/src/config.dart';

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

  @override
  void initState() {
    super.initState();
    _bibleData = _loadBibleData(widget.name);
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
      body: FutureBuilder<Map<String, dynamic>>(
        future: _bibleData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Nenhum texto foi encontrado"));
          }

          final Map<String, dynamic> bookData = snapshot.data!;
          final List chapters = bookData["chapters"] ?? [];

          if (chapters.isEmpty) {
            return const Center(child: Text('Nenhum capítulo encontrado.'));
          }

          return ListView.builder(
            itemCount: chapters.length,
            itemBuilder: (context, index) {
              final List verses = chapters[index];

              return ExpansionTile(
                title: Text(
                  'Capítulo ${index + 1}',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary),
                ),
                children: verses.asMap().entries.map((entry) {
                  final int verseIndex = entry.key + 1;
                  final String verseText = entry.value;

                  return ListTile(
                    title: Text(
                      "Versículo $verseIndex",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                    subtitle: Text(
                      verseText,
                      style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}
