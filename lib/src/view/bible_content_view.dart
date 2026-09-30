/// Implementa a interface e os fluxos de apresentação deste recurso.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'package:biblia_e_harpa/src/view/component/app_bar_component.dart';
import 'package:biblia_e_harpa/src/view/component/bottombar.dart';
import 'package:biblia_e_harpa/src/controllers/settings_controller.dart';
import 'package:biblia_e_harpa/src/model/bible_audio.dart';
import 'package:biblia_e_harpa/src/controllers/bible_share_controller.dart';
import 'package:biblia_e_harpa/src/controllers/bible_read_controller.dart';
import 'package:biblia_e_harpa/src/controllers/bible_content_controller.dart';
import 'package:biblia_e_harpa/src/view/component/bible_audio_player_card.dart';
import 'package:biblia_e_harpa/src/view/component/controlled_search_field.dart';
import 'package:biblia_e_harpa/src/view/component/selection_limit_dialog.dart';
import 'package:biblia_e_harpa/src/services/annotation_service.dart';
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
    return ChangeNotifierProvider<BibleContentController>(
      create: (ctx) => BibleContentController(
        readState: ctx.read<BibleReadController>(),
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

class _TextBibleView extends StatefulWidget {
  const _TextBibleView();

  @override
  State<_TextBibleView> createState() => _TextBibleViewState();
}

class _TextBibleViewState extends State<_TextBibleView> {
  Map<String, Color> _verseAnnotations = {};
  bool _highlightMode = false;
  String? _loadedChapterId;

  @override
  void initState() {
    super.initState();
    _loadAnnotations();
  }

  Future<void> _loadAnnotations() async {
    final viewModel = context.read<BibleContentController>();
    final annotations = await AnnotationService.getAnnotations();
    final chapterId = viewModel.chapterId;
    final verseAnnotations = <String, Color>{};

    for (final entry in annotations.entries) {
      if (entry.key.startsWith('$chapterId:')) {
        final verseIndex = entry.key.split(':')[1];
        final color = _colorFromHex(entry.value);
        verseAnnotations[verseIndex] = color;
      }
    }

    if (!mounted) return;
    setState(() {
      _verseAnnotations = verseAnnotations;
      _loadedChapterId = chapterId;
    });
  }

  void _ensureAnnotationsLoaded(String chapterId) {
    if (_loadedChapterId != chapterId) {
      _loadAnnotations();
    }
  }

  Color _colorFromHex(String hex) {
    final colors = {
      'yellow': Colors.yellow,
      'green': Colors.green,
      'blue': Colors.blue,
      'pink': Colors.pink,
      'orange': Colors.orange,
    };
    return colors[hex] ?? Colors.yellow;
  }

  String _hexFromColor(Color color) {
    final colors = {
      Colors.yellow: 'yellow',
      Colors.green: 'green',
      Colors.blue: 'blue',
      Colors.pink: 'pink',
      Colors.orange: 'orange',
    };
    return colors[color] ?? 'yellow';
  }

  Future<void> _showAnnotationMenu(
    BuildContext context,
    Offset offset,
    int verseIndex,
  ) async {
    final viewModel = context.read<BibleContentController>();
    final chapterId = viewModel.chapterId;
    
    final result = await showMenu<Color>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx, offset.dy, offset.dx + 10, offset.dy + 10,
      ),
      items: [
        PopupMenuItem(
          value: Colors.yellow,
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                color: Colors.yellow,
                margin: const EdgeInsets.only(right: 8),
              ),
              const Text('Amarelo'),
            ],
          ),
        ),
        PopupMenuItem(
          value: Colors.green,
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                color: Colors.green,
                margin: const EdgeInsets.only(right: 8),
              ),
              const Text('Verde'),
            ],
          ),
        ),
        PopupMenuItem(
          value: Colors.blue,
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                color: Colors.blue,
                margin: const EdgeInsets.only(right: 8),
              ),
              const Text('Azul'),
            ],
          ),
        ),
        PopupMenuItem(
          value: Colors.pink,
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                color: Colors.pink,
                margin: const EdgeInsets.only(right: 8),
              ),
              const Text('Rosa'),
            ],
          ),
        ),
        PopupMenuItem(
          value: Colors.orange,
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                color: Colors.orange,
                margin: const EdgeInsets.only(right: 8),
              ),
              const Text('Laranja'),
            ],
          ),
        ),
        PopupMenuItem(
          value: Colors.transparent,
          child: const Row(
            children: [
              Icon(Icons.clear),
              SizedBox(width: 8),
              Text('Remover'),
            ],
          ),
        ),
      ],
    );
    
    if (result != null) {
      if (result == Colors.transparent) {
        await AnnotationService.removeAnnotation(chapterId, verseIndex.toString());
      } else {
        await AnnotationService.setAnnotation(
          chapterId,
          verseIndex.toString(),
          _hexFromColor(result),
        );
      }
      _loadAnnotations();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BibleContentController>();
    final readViewModel = context.watch<BibleReadController>();
    final settings = context.watch<SettingsController>();
    final colorScheme = Theme.of(context).colorScheme;

    if (viewModel.allBookChapters.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final chapterId = viewModel.chapterId;
    final chapterTitle = viewModel.chapterTitle;
    final isRead = readViewModel.isRead(chapterId) || readViewModel.isRead(chapterTitle);

    _ensureAnnotationsLoaded(chapterId);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(
        title: chapterTitle,
        centerTitle: false,
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            onPressed: () async {
              if (!viewModel.isAutoScrollEnabled) {
                // Show confirmation dialog when enabling
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Modo Leitura Automática'),
                    content: const Text(
                      'Devido a falta de base de dados para os áudios da Bíblia, '
                      'esta funcionalidade funcionará com versões diferentes de '
                      'leitura/escrita. Deseja prosseguir?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Prosseguir'),
                      ),
                    ],
                  ),
                );
                if (confirmed != true) return;
              }
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
            tooltip: 'Limpar seleção',
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _highlightMode = !_highlightMode;
              });
              if (_highlightMode) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Modo destaque ativado: toque em um versículo para colorir.',
                    ),
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
            icon: Icon(
              _highlightMode ? Icons.highlight_rounded : Icons.highlight_outlined,
              color: _highlightMode
                  ? colorScheme.secondary
                  : colorScheme.secondary.withValues(alpha: 0.6),
            ),
            tooltip: _highlightMode ? 'Modo destaque ativado' : 'Modo destaque',
          ),
          IconButton(
            onPressed: () async {
              final chapterText = viewModel.buildShareText();
              await context.read<BibleShareController>().shareText(chapterText);
            },
            icon: Icon(
              viewModel.selectedVerseIndices.isEmpty ? Icons.share : Icons.send,
            ),
            tooltip: 'Compartilhar',
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
                                if (_highlightMode) {
                                  _showAnnotationMenu(
                                    context,
                                    Offset.zero,
                                    originalIndex,
                                  );
                                } else {
                                  final ok = viewModel.toggleVerseSelection(originalIndex);
                                  if (!ok) await SelectionLimitDialog.show(context);
                                }
                              },
                              onLongPress: () {
                                _showAnnotationMenu(
                                  context,
                                  Offset.zero,
                                  originalIndex,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: _verseAnnotations[originalIndex.toString()] ??
                                      (viewModel.selectedVerseIndices
                                              .contains(originalIndex)
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withValues(alpha: 0.9)
                                          : Colors.transparent),
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
                                            textAlign: TextAlign.justify,
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
