import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Textbiblescreen extends StatefulWidget {
  final String bookName;
  final String jsonPath;
  final int initialChapterNumber;
  final List<List<dynamic>> allBookChapters;

  const Textbiblescreen({
    super.key,
    required this.bookName,
    required this.jsonPath,
    required this.initialChapterNumber,
    required this.allBookChapters,
  });

  @override
  State<Textbiblescreen> createState() => _TextbiblescreenState();
}

class _TextbiblescreenState extends State<Textbiblescreen> {

  late int currentChapterNumber;
  late List<dynamic> currentVerses;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentChapterNumber = widget.initialChapterNumber;
    currentVerses = widget.allBookChapters[currentChapterNumber - 1];
  }

  void _navigateToChapter(int newChapterNumber) {
    if (newChapterNumber >= 1 && newChapterNumber <= widget.allBookChapters.length) {
      setState(() {
        currentChapterNumber = newChapterNumber;
        currentVerses = widget.allBookChapters[currentChapterNumber - 1];
      });
    }
  }

  void _nextChapter() {
    if (currentChapterNumber < widget.allBookChapters.length) {
      _navigateToChapter(currentChapterNumber + 1);
    }
  }

  void _previusChapter() {
    if (currentChapterNumber > 1) {
      _navigateToChapter(currentChapterNumber - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('${widget.bookName} - Capítulo $currentChapterNumber'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.secondary,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: currentVerses.isEmpty
          ? Center(
        child: Text(
          'Nenhum versículo encontrado para este capítulo.',
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: currentVerses.length,
        itemBuilder: (context, index) {
          final String verseText = currentVerses[index].toString();
          final int verseNumber = index + 1;
          return
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    Text(
                      "$verseNumber",
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "$verseText",
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 0.5,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => _previusChapter(),
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(12),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.secondary,
                ),
                child: Icon(Icons.arrow_back, size: 24, color: Theme.of(context).colorScheme.secondary),
              ),
            ),
            const SizedBox(width: 20),
            Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 0.5,
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ]
              ),
              child: ElevatedButton(
                onPressed: () => _nextChapter(),
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(12),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.secondary,
                ),
                child: Icon(Icons.arrow_forward, size: 24, color: Theme.of(context).colorScheme.secondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
