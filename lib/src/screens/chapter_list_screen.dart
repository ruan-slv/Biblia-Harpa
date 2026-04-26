import 'dart:convert';
import 'package:biblia_e_harpa/src/components/appBarComponent.dart';
import 'package:biblia_e_harpa/src/controllers/bible_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:biblia_e_harpa/src/screens/textBibleScreen.dart';
import 'package:biblia_e_harpa/src/controllers/fontSizeController.dart';

class ChapterListScreen extends StatefulWidget {
  final String name;
  final String jsonPath;
  final List<AudioChapter>? audioChapters;

  const ChapterListScreen({
    super.key,
    required this.name,
    required this.jsonPath,
    this.audioChapters,
  });

  @override
  State<ChapterListScreen> createState() => _ChapterListScreenState();
}

class _ChapterListScreenState extends State<ChapterListScreen>
    with SingleTickerProviderStateMixin {
  late Future<Map<String, dynamic>> _bibleData;
  final TextEditingController _searchController = TextEditingController();
  final BibleController _bibleController = BibleController();
  List<List<dynamic>> _allChapters = [];
  List<int> _filteredChapterNumbers = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _bibleData = _loadBibleData(widget.name);
    _searchController.addListener(_filterChapters);
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterChapters);
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
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

  void _filterChapters() {
    final query = _searchController.text.trim();
    if (mounted) {
      setState(() {
        if (query.isEmpty) {
          _filteredChapterNumbers =
          List<int>.generate(_allChapters.length, (index) => index + 1);
        } else {
          final List<int> tempFilteredList = [];
          for (int i = 0; i < _allChapters.length; i++) {
            final chapterNumber = i + 1;
            if (chapterNumber.toString().contains(query)) {
              tempFilteredList.add(chapterNumber);
            }
          }
          _filteredChapterNumbers = tempFilteredList;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(
        title: widget.name,
        centerTitle: false,
        automaticallyImplyLeading: true,
        tabBar: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.secondary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
          indicatorColor: Theme.of(context).colorScheme.secondary,
          tabs: const [
            Tab(text: "Todos"),
            Tab(text: "Marcados como Lido"),
          ],
        ),
      ),
      body:  Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: _searchController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Pesquisar Capítulo",
                  hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.secondary),
                  prefixIcon: Icon(Icons.search,
                      color: Theme.of(context).colorScheme.secondary),
                  suffixIcon: IconButton(
                    onPressed: () => _searchController.clear(),
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
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
              future: _bibleData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text("Nenhum texto foi encontrado"));
                }

                if (_allChapters.isEmpty &&
                    snapshot.data!.containsKey('chapters')) {
                  final chaptersData =
                      snapshot.data!["chapters"] as List? ?? [];
                  _allChapters = chaptersData
                      .map((c) => List<dynamic>.from(c as List))
                      .toList();
                  _filteredChapterNumbers =
                  List<int>.generate(_allChapters.length, (i) => i + 1);
                }

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildChapterGrid(_filteredChapterNumbers),
                      ValueListenableBuilder<List<String>>(
                        valueListenable: _bibleController.textosLidosNotifier,
                        builder: (context, lidos, _) {
                          final readChaptersForThisBook = lidos
                              .where((id) => id.startsWith("${widget.name}_"))
                              .map((id) {
                            return int.tryParse(id.split('_').last) ?? 0;
                          }).where((num) => num > 0).toList();

                          final filteredReadChapters = readChaptersForThisBook
                              .where(
                                  (num) => _filteredChapterNumbers.contains(num))
                              .toList();

                          return _buildChapterGrid(filteredReadChapters);
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),

    );
  }

  Widget _buildChapterGrid(List<int> chaptersToShow) {
    if (chaptersToShow.isEmpty) return const Center(child: Text("Nenhum capítulo disponível."));

    return ValueListenableBuilder<List<String>>(
      valueListenable: _bibleController.textosLidosNotifier,
      builder: (context, lidos, _) {
        return GridView.builder(
          padding: const EdgeInsets.all(10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: chaptersToShow.length,
          itemBuilder: (context, index) {
            final chapterNumber = chaptersToShow[index];
            final bool isRead = lidos.contains("${widget.name}_$chapterNumber");

            return ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Textbiblescreen(
                  bookName: widget.name,
                  jsonPath: widget.jsonPath,
                  initialChapterNumber: chapterNumber,
                  allBookChapters: _allChapters,
                  audioChapters: widget.audioChapters,
                )));
              },
              style: ButtonStyle(
                padding: WidgetStateProperty.all(EdgeInsets.zero),
                minimumSize: WidgetStateProperty.all(const Size(30, 30)),
                side: WidgetStateProperty.all(const BorderSide(color: Colors.blueGrey, width: 0.5)),
                shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.0))),
                backgroundColor: WidgetStateProperty.all(
                  isRead ? Colors.blue.withValues(alpha:0.7) : Theme.of(context).colorScheme.primary,
                ),
                foregroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.secondary),
              ),
              child: ValueListenableBuilder<double>(
                valueListenable: FontSizeController.fontSizeNotifier,
                builder: (context, fontSize, _) {
                  return Text(
                    "$chapterNumber",
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: isRead ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
