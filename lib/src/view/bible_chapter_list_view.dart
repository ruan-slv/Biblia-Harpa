import 'package:biblia_e_harpa/src/view/component/app_bar_component.dart';
import 'package:biblia_e_harpa/src/view_model/settings_view_model.dart';
import 'package:biblia_e_harpa/src/model/bible_audio.dart';
import 'package:biblia_e_harpa/src/view_model/service/bible_text_assets_service.dart';
import 'package:biblia_e_harpa/src/view_model/bible_read_view_model.dart';
import 'package:biblia_e_harpa/src/view_model/chapter_list_view_model.dart';
import 'package:biblia_e_harpa/src/view/component/feature_search_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'bible_content_view.dart';

class BibleChapterListView extends StatelessWidget {
  final String name;
  final String jsonPath;
  final List<BibleAudioChapter>? audioChapters;

  const BibleChapterListView({
    super.key,
    required this.name,
    required this.jsonPath,
    this.audioChapters,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BibleChapterListViewModel>(
      create: (ctx) => BibleChapterListViewModel(
        textAssetsService: ctx.read<BibleTextAssetsService>(),
      )..load(bookName: name, jsonAssetPath: jsonPath),
      child: _ChapterListView(name: name, jsonPath: jsonPath, audioChapters: audioChapters),
    );
  }
}

class _ChapterListView extends StatefulWidget {
  final String name;
  final String jsonPath;
  final List<BibleAudioChapter>? audioChapters;

  const _ChapterListView({
    required this.name,
    required this.jsonPath,
    required this.audioChapters,
  });

  @override
  State<_ChapterListView> createState() => _ChapterListViewState();
}

class _ChapterListViewState extends State<_ChapterListView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BibleChapterListViewModel>();
    final readViewModel = context.watch<BibleReadViewModel>();
    final chaptersToShow = viewModel.filteredChapterNumbers();
    final readNumbers = viewModel.readChapterNumbersForBook(
      bookName: widget.name,
      readIds: readViewModel.readIds,
    );
    final filteredRead = readNumbers.where(chaptersToShow.contains).toList();

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
              child: FeatureSearchField(
                hintText: "Pesquisar Capítulo",
                keyboardType: TextInputType.number,
                onChanged: (v) => context.read<BibleChapterListViewModel>().setQuery(v),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: viewModel.loading
                  ? const Center(child: CircularProgressIndicator())
                  : viewModel.chapters.isEmpty
                      ? const Center(child: Text("Nenhum texto foi encontrado"))
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _ChapterGrid(
                              bookName: widget.name,
                              jsonPath: widget.jsonPath,
                              chapters: viewModel.chapters,
                              chapterNumbers: chaptersToShow,
                              audioChapters: widget.audioChapters,
                            ),
                            _ChapterGrid(
                              bookName: widget.name,
                              jsonPath: widget.jsonPath,
                              chapters: viewModel.chapters,
                              chapterNumbers: filteredRead,
                              audioChapters: widget.audioChapters,
                            ),
                          ],
                        ),
            ),
          ],
        ),

    );
  }
}

class _ChapterGrid extends StatelessWidget {
  final String bookName;
  final String jsonPath;
  final List<List<String>> chapters;
  final List<int> chapterNumbers;
  final List<BibleAudioChapter>? audioChapters;

  const _ChapterGrid({
    required this.bookName,
    required this.jsonPath,
    required this.chapters,
    required this.chapterNumbers,
    required this.audioChapters,
  });

  @override
  Widget build(BuildContext context) {
    final readViewModel = context.watch<BibleReadViewModel>();
    final settings = context.watch<SettingsViewModel>();
    if (chapterNumbers.isEmpty) {
      return const Center(child: Text("Nenhum capítulo disponível."));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: chapterNumbers.length,
      itemBuilder: (context, index) {
        final chapterNumber = chapterNumbers[index];
        final bool isRead = readViewModel.isRead("${bookName}_$chapterNumber");

        return ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BibleContentView(
                  bookName: bookName,
                  jsonPath: jsonPath,
                  initialChapterNumber: chapterNumber,
                  allBookChapters: chapters,
                  audioChapters: audioChapters,
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
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.0)),
            ),
            backgroundColor: WidgetStateProperty.all(
              isRead
                  ? Colors.blue.withValues(alpha: 0.7)
                  : Theme.of(context).colorScheme.primary,
            ),
            foregroundColor: WidgetStateProperty.all(
              Theme.of(context).colorScheme.secondary,
            ),
          ),
          child: Text(
            "$chapterNumber",
            style: TextStyle(
              fontSize: settings.fontSize,
              fontWeight: isRead ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        );
      },
    );
  }
}
