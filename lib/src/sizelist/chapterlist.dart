import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:biblia_e_harpa/src/config.dart';
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
      backgroundColor: Theme.of(context).colorScheme.surface,
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
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return const Center(child: Text("Nenhum texto foi encontrado"));
          }

          final Map<String, dynamic> bookData = snapshot.data!;
          final List chapters = bookData["chapters"] ?? [];

          if (chapters.isEmpty) {
            return const Center(child: Text('Nenhum capítulo encontrado.'));
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
              itemCount: chapters.length,
              itemBuilder: (context, index) {
                final int chapterNumber = index + 1;
                return ElevatedButton(
                  onPressed: () {
                    final List<List<dynamic>> allChapterrForBook = (bookData[
                            "chapters"] as List)
                        .map((chapter) => List<dynamic>.from(chapter as List))
                        .toList();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Textbiblescreen(
                          bookName: widget.name,
                          jsonPath: widget.jsonPath,
                          initialChapterNumber: chapterNumber,
                          allBookChapters: allChapterrForBook,
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
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7.0),
                      ),
                    ),
                    backgroundColor: WidgetStateProperty.all(
                        Theme.of(context).colorScheme.primary),
                    foregroundColor: WidgetStateProperty.all(
                        Theme.of(context).colorScheme.secondary),
                    //overlayColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondary),
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
    );
  }
}
