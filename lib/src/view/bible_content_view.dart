import 'package:biblia_e_harpa/src/view/component/app_bar_component.dart';
import 'package:biblia_e_harpa/src/view/component/bottombar.dart';
import 'package:biblia_e_harpa/src/view_model/settings_view_model.dart';
import 'package:biblia_e_harpa/src/model/bible_audio.dart';
import 'package:biblia_e_harpa/src/view_model/service/bible_share_service.dart';
import 'package:biblia_e_harpa/src/view_model/bible_read_view_model.dart';
import 'package:biblia_e_harpa/src/view_model/text_bible_view_model.dart';
import 'package:biblia_e_harpa/src/view/component/bible_audio_player_card.dart';
import 'package:biblia_e_harpa/src/view/component/controlled_search_field.dart';
import 'package:biblia_e_harpa/src/view/component/selection_limit_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BibleContentView extends StatelessWidget {
  final String bookName;
  final String jsonPath;
  final int initialChapterNumber;
  final List<List<String>> allBookChapters;
  final List<BibleAudioChapter>? audioChapters;

  const BibleContentView({
    super.key,
    required this.bookName,
    required this.jsonPath,
    required this.initialChapterNumber,
    required this.allBookChapters,
    this.audioChapters,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BibleContentViewModel>(
      create: (ctx) => BibleContentViewModel(
        readState: ctx.read<BibleReadViewModel>(),
        bookName: bookName,
        jsonPath: jsonPath,
        allBookChapters: allBookChapters,
        audioChapters: audioChapters,
        initialChapterNumber: initialChapterNumber,
      )..loadAudioForChapter(initialChapterNumber),
      child: const _TextBibleView(),
    );
  }
}

class _TextBibleView extends StatelessWidget {
  const _TextBibleView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BibleContentViewModel>();
    final readViewModel = context.watch<BibleReadViewModel>();
    final settings = context.watch<SettingsViewModel>();
    final colorScheme = Theme.of(context).colorScheme;

    if (viewModel.allBookChapters.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final chapterId = viewModel.chapterId;
    final chapterTitle = viewModel.chapterTitle;
    final isRead = readViewModel.isRead(chapterId) || readViewModel.isRead(chapterTitle);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(
        title: chapterTitle,
        centerTitle: false,
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            onPressed: () {
              viewModel.toggleAutoScroll();
              if (viewModel.isAutoScrollEnabled &&
                  !viewModel.audioPlayer.playing &&
                  viewModel.currentAudioChapter != null) {
                viewModel.audioPlayer.play();
              }
            },
            icon: Icon(
              viewModel.isAutoScrollEnabled
                  ? Icons.auto_stories
                  : Icons.auto_stories_outlined,
              color: viewModel.isAutoScrollEnabled
                  ? colorScheme.secondary
                  : colorScheme.secondary.withValues(alpha: 0.6),
            ),
          ),
          IconButton(
            onPressed:
                viewModel.selectedVerseIndices.isEmpty ? null : viewModel.clearSelections,
            icon: const Icon(Icons.close),
          ),
          IconButton(
            onPressed: () async {
              final chapterText = viewModel.buildShareText();
              await context.read<BibleShareService>().shareText(chapterText);
            },
            icon: Icon(
              viewModel.selectedVerseIndices.isEmpty ? Icons.share : Icons.send,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomBar(
        canGoBack: viewModel.currentChapterNumber > 1,
        canGoNext: viewModel.currentChapterNumber < viewModel.allBookChapters.length,
        onPrevious: viewModel.previousChapter,
        onNext: viewModel.nextChapter,
        topChild: InkWell(
          onTap: viewModel.toggleCurrentChapterRead,
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isRead
                  ? Colors.green.withValues(alpha: 0.16)
                  : colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isRead
                    ? Colors.green.withValues(alpha: 0.45)
                    : colorScheme.secondary.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              children: [
                Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: isRead ? Colors.green : colorScheme.secondary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isRead
                        ? Icons.check_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: isRead ? Colors.white : colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isRead ? "Capítulo concluído" : "Marcar como lido",
                        style: TextStyle(
                          color: colorScheme.secondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isRead
                            ? "Toque para marcar como não lido."
                            : "Toque para marcar como lido.",
                        style: TextStyle(
                          color: colorScheme.secondary.withValues(alpha: 0.72),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Center(
        child: CustomScrollView(
          controller: viewModel.scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ControlledSearchField(
                  controller: viewModel.keywordController,
                  hintText: "Pesquisar Palavra-chave",
                  onChanged: viewModel.setKeywordQuery,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: BibleAudioPlayerCard(
                audioPlayer: viewModel.audioPlayer,
                currentAudioChapter: viewModel.currentAudioChapter,
              ),
            ),
            if (viewModel.noFilterResults)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    'Nenhum versículo encontrado para "${viewModel.keywordController.text}" neste capítulo.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: settings.fontSize,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.all(6.0),
              sliver: viewModel.noFilterResults
                  ? const SliverToBoxAdapter(child: SizedBox.shrink())
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == viewModel.filteredVerseIndices.length) {
                            return const SizedBox(height: 24);
                          }

                          final originalIndex = viewModel.filteredVerseIndices[index];
                          final verseText = viewModel.currentVerses[originalIndex];
                          final verseNumber = originalIndex + 1;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: GestureDetector(
                              onTap: () async {
                                final ok = viewModel.toggleVerseSelection(originalIndex);
                                if (!ok) await SelectionLimitDialog.show(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: viewModel.selectedVerseIndices
                                          .contains(originalIndex)
                                      ? Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.9)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "$verseNumber",
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            fontSize: settings.fontSize,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            verseText,
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                              fontSize: settings.fontSize,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: viewModel.filteredVerseIndices.length + 1,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
