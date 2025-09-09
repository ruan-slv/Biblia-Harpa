import 'package:biblia_e_harpa/src/controllers/fontSizeController.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

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
  final ScrollController _scrollController = ScrollController();
  List<int> _selectedVerseIndices = [];

  @override
  void initState() {
    super.initState();
    currentChapterNumber = widget.initialChapterNumber;
    if (currentChapterNumber < 1) currentChapterNumber = 1;
    if (currentChapterNumber > widget.allBookChapters.length &&
        widget.allBookChapters.isNotEmpty) {
      currentChapterNumber = widget.allBookChapters.length;
    }

    if (widget.allBookChapters.isNotEmpty &&
        currentChapterNumber - 1 < widget.allBookChapters.length) {
      currentVerses = widget.allBookChapters[currentChapterNumber - 1];
    } else {
      currentVerses = [];
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _navigateToChapter(int newChapterNumber) {
    if (newChapterNumber >= 1 &&
        newChapterNumber <= widget.allBookChapters.length) {
      setState(() {
        currentChapterNumber = newChapterNumber;
        currentVerses = widget.allBookChapters[currentChapterNumber - 1];
        _selectedVerseIndices = [];
      });
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _nextChapter() {
    if (currentChapterNumber < widget.allBookChapters.length) {
      _navigateToChapter(currentChapterNumber + 1);
    }
  }

  void _previousChapter() {
    if (currentChapterNumber > 1) {
      _navigateToChapter(currentChapterNumber - 1);
    }
  }

  void _toggleVerseSelection(int index) {
    setState(() {
      if (_selectedVerseIndices.contains(index)) {
        _selectedVerseIndices.remove(index);
      } else {
        _selectedVerseIndices.add(index);
      }
    });
  }

  void _clearSelections() {
    setState(() {
      _selectedVerseIndices = [];
    });
  }

  String _getDataForSharing() {
    StringBuffer shareText = StringBuffer();
    shareText.writeln("${widget.bookName} - Capítulo $currentChapterNumber");
    shareText.writeln();

    if (_selectedVerseIndices.isNotEmpty) {
      List<int> sortedIndices = List.from(_selectedVerseIndices)..sort();
      for (int index in sortedIndices) {
        final String verseText = currentVerses[index].toString();
        final int verseNumber = index + 1;
        shareText.writeln("$verseNumber. $verseText");
      }
    } else {
      for (int i = 0; i < currentVerses.length; i++) {
        final String verseText = currentVerses[i].toString();
        final int verseNumber = i + 1;
        shareText.writeln("$verseNumber. $verseText");
      }
    }
    return shareText.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.allBookChapters.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          // 🔒 AppBar.title NÃO muda
          title: Text(widget.bookName),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.secondary,
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Center(
          child: ValueListenableBuilder<double>(
            valueListenable: FontSizeController.fontSizeNotifier,
            builder: (context, fontSize, _) {
              return Text(
                'Nenhum capítulo disponível para este livro.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: fontSize,
                ),
                textAlign: TextAlign.center,
              );
            },
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        // 🔒 Título do AppBar fixo
        title: Text('${widget.bookName} - Cap. $currentChapterNumber'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.secondary,
        actions: [
          if (_selectedVerseIndices.isNotEmpty)
            IconButton(
              onPressed: _clearSelections,
              icon: const Icon(Icons.clear),
              tooltip: 'Limpar seleções',
            ),
          IconButton(
            onPressed: () {
              if (currentVerses.isNotEmpty) {
                final String chapterText = _getDataForSharing();
                Share.share(
                  chapterText,
                  subject:
                      "${widget.bookName} - Capítulo $currentChapterNumber",
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Não há versiculos para compartilhar neste capítulo.'),
                  ),
                );
              }
            },
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: currentVerses.isEmpty
          ? Center(
              child: ValueListenableBuilder<double>(
                valueListenable: FontSizeController.fontSizeNotifier,
                builder: (context, fontSize, _) {
                  return Text(
                    'Nenhum versiculo encontrado para este capítulo.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: fontSize,
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),
            )
          : ListView.builder(
              controller: _scrollController,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              itemCount: currentVerses.length,
              itemBuilder: (context, index) {
                final String verseText = currentVerses[index].toString();
                final int verseNumber = index + 1;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: GestureDetector(
                    onTap: () => _toggleVerseSelection(index),
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: _selectedVerseIndices.contains(index)
                            ? Colors.green.withOpacity(0.3)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ValueListenableBuilder<double>(
                            valueListenable:
                                FontSizeController.fontSizeNotifier,
                            builder: (context, fontSize, _) {
                              return Text(
                                "$verseNumber ",
                                style: TextStyle(
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withOpacity(0.9),
                                ),
                              );
                            },
                          ),
                          Expanded(
                            child: ValueListenableBuilder<double>(
                              valueListenable:
                                  FontSizeController.fontSizeNotifier,
                              builder: (context, fontSize, _) {
                                return Text(
                                  verseText,
                                  style: TextStyle(
                                    fontSize: fontSize,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    height: 1.4,
                                  ),
                                  textAlign: TextAlign.left,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        color: Theme.of(context).colorScheme.background.withOpacity(0.95),
        child: ValueListenableBuilder<double>(
          valueListenable: FontSizeController.fontSizeNotifier,
          builder: (context, fontSize, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: currentChapterNumber > 1 ? _previousChapter : null,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(14),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                    elevation: 2,
                  ),
                  child: Icon(Icons.arrow_back_ios_new,
                      size: fontSize * 0.9,
                      color: Theme.of(context).colorScheme.secondary),
                ),
                Text(
                  "Capítulo $currentChapterNumber de ${widget.allBookChapters.length}",
                  style: TextStyle(
                    fontSize: fontSize * 0.85,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                ElevatedButton(
                  onPressed:
                      currentChapterNumber < widget.allBookChapters.length
                          ? _nextChapter
                          : null,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(14),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                    elevation: 2,
                  ),
                  child: Icon(Icons.arrow_forward_ios,
                      size: fontSize * 0.9,
                      color: Theme.of(context).colorScheme.secondary),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
