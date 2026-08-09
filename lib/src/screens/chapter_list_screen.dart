// lib/src/screens/chapter_list_screen.dart

import 'dart:convert';
import 'dart:io';
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

class _ChapterListScreenState extends State<ChapterListScreen> with SingleTickerProviderStateMixin {
  late Future<Map<String, dynamic>> _bibleData;
  final BibleController _bibleController = BibleController();
  final TextEditingController _searchController = TextEditingController();
  List<List<dynamic>> _allChapters = [];
  List<int> _filteredChapterNumbers = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _bibleData = _loadBibleData(widget.name);
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(_filterChapters);
  }

  void _filterChapters() {
    final query = _searchController.text;
    setState(() {
      if (query.isEmpty) {
        _filteredChapterNumbers = List<int>.generate(_allChapters.length, (i) => i + 1);
      } else {
        _filteredChapterNumbers = List<int>.generate(_allChapters.length, (i) => i + 1)
            .where((n) => n.toString().contains(query))
            .toList();
      }
    });
  }

  Future<Map<String, dynamic>> _loadBibleData(String bookName) async {
    try {
      String jsonString;
      if (widget.jsonPath.startsWith('assets/')) {
        jsonString = await rootBundle.loadString(widget.jsonPath);
      } else {
        final file = File(widget.jsonPath);
        if (await file.exists()) {
          jsonString = await file.readAsString();
        } else {
          throw Exception("Ficheiro não encontrado.");
        }
      }

      final List<dynamic> bibleData = json.decode(jsonString);
      final bookData = bibleData.firstWhere((book) => book['name'] == bookName, orElse: () => null);
      return bookData != null ? bookData as Map<String, dynamic> : {};
    } catch (e) {
      debugPrint("Erro ao carregar capítulos: $e");
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: CustomAppBar(
        title: widget.name,
        centerTitle: true,
        automaticallyImplyLeading: true,
        tabBar: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.secondary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
          indicatorColor: Theme.of(context).colorScheme.secondary,
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle:
          const TextStyle(fontWeight: FontWeight.normal),
          tabs: const [Tab(text: "Todos"), Tab(text: "Lidos")],
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _bibleData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Erro ao carregar capítulos."));
          }

          if (_allChapters.isEmpty) {
            final chaptersData = snapshot.data!["chapters"] as List? ?? [];
            _allChapters = chaptersData.map((c) => List<dynamic>.from(c as List)).toList();
            _filteredChapterNumbers = List<int>.generate(_allChapters.length, (i) => i + 1);
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Buscar capítulo",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.primary,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0), borderSide: BorderSide.none),
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildChapterGrid(_filteredChapterNumbers),
                    _buildReadChaptersTab(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReadChaptersTab() {
    return ValueListenableBuilder<List<String>>(
      valueListenable: _bibleController.textosLidosNotifier,
      builder: (context, lidos, _) {
        final readChapters = lidos
            .where((id) => id.startsWith("${widget.name}_"))
            .map((id) => int.tryParse(id.split('_').last) ?? 0)
            .where((n) => n > 0).toList();
        return _buildChapterGrid(readChapters);
      },
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
                  isRead ? Colors.blue.withOpacity(0.7) : Theme.of(context).colorScheme.primary,
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