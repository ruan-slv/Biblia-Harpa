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
import 'package:biblia_e_harpa/src/utils/theme.dart';
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
  Map<String, String> _verseAnnotations = {};
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
    final verseAnnotations = <String, String>{};

    for (final entry in annotations.entries) {
      if (entry.key.startsWith('$chapterId:')) {
        final verseIndex = entry.key.split(':')[1];
        verseAnnotations[verseIndex] = entry.value;
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

  Color _getHighlightColor(BuildContext context, String colorKey) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final alpha = isDark ? 0.28 : 0.32;

    switch (colorKey.toLowerCase()) {
      case 'yellow':
        return isDark
            ? const Color(0xFFFFD54F).withValues(alpha: alpha)
            : const Color(0xFFFFE082).withValues(alpha: alpha);
      case 'green':
        return isDark
            ? const Color(0xFF66BB6A).withValues(alpha: alpha)
            : const Color(0xFFA5D6A7).withValues(alpha: alpha);
      case 'blue':
        return isDark
            ? const Color(0xFF42A5F5).withValues(alpha: alpha)
            : const Color(0xFF90CAF9).withValues(alpha: alpha);
      case 'pink':
        return isDark
            ? const Color(0xFFEC407A).withValues(alpha: alpha)
            : const Color(0xFFF48FB1).withValues(alpha: alpha);
      case 'orange':
        return isDark
            ? const Color(0xFFFFA726).withValues(alpha: alpha)
            : const Color(0xFFFFCC80).withValues(alpha: alpha);
      default:
        return isDark
            ? const Color(0xFFFFD54F).withValues(alpha: alpha)
            : const Color(0xFFFFE082).withValues(alpha: alpha);
    }
  }

  Color _getHighlightBorderColor(BuildContext context, String colorKey) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final alpha = isDark ? 0.45 : 0.40;

    switch (colorKey.toLowerCase()) {
      case 'yellow':
        return const Color(0xFFFFB300).withValues(alpha: alpha);
      case 'green':
        return const Color(0xFF43A047).withValues(alpha: alpha);
      case 'blue':
        return const Color(0xFF1E88E5).withValues(alpha: alpha);
      case 'pink':
        return const Color(0xFFD81B60).withValues(alpha: alpha);
      case 'orange':
        return const Color(0xFFFB8C00).withValues(alpha: alpha);
      default:
        return const Color(0xFFFFB300).withValues(alpha: alpha);
    }
  }

  Future<void> _showAnnotationMenu(
    BuildContext context,
    Offset offset,
    int verseIndex,
  ) async {
    final viewModel = context.read<BibleContentController>();
    final chapterId = viewModel.chapterId;
    final colorScheme = Theme.of(context).colorScheme;

    final options = [
      {'key': 'yellow', 'label': 'Amarelo', 'color': const Color(0xFFFFCA28)},
      {'key': 'green', 'label': 'Verde', 'color': const Color(0xFF66BB6A)},
      {'key': 'blue', 'label': 'Azul', 'color': const Color(0xFF42A5F5)},
      {'key': 'pink', 'label': 'Rosa', 'color': const Color(0xFFEC407A)},
      {'key': 'orange', 'label': 'Laranja', 'color': const Color(0xFFFFA726)},
    ];

    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy,
        offset.dx + 10,
        offset.dy + 10,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: colorScheme.surface,
      items: [
        ...options.map(
          (opt) => PopupMenuItem<String>(
            value: opt['key'] as String,
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: opt['color'] as Color,
                    shape: BoxShape.circle,
                  ),
                  margin: const EdgeInsets.only(right: 12),
                ),
                Text(
                  opt['label'] as String,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'clear',
          child: Row(
            children: [
              Icon(Icons.clear_rounded, color: colorScheme.onSurface, size: 20),
              const SizedBox(width: 12),
              Text(
                'Remover destaque',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (result != null) {
      if (result == 'clear') {
        await AnnotationService.removeAnnotation(
            chapterId, verseIndex.toString());
      } else {
        await AnnotationService.setAnnotation(
          chapterId,
          verseIndex.toString(),
          result,
        );
      }
      _loadAnnotations();
    }
  }

  Future<void> _handleShareOrSelection(
    BuildContext context,
    BibleContentController viewModel,
  ) async {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedCount = viewModel.selectedVerseIndices.length;

    if (selectedCount == 0) {
      final shouldShare = await showDialog<bool>(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          backgroundColor: colorScheme.surface,
          title: Text(
            'Compartilhar Capítulo',
            style: TextStyle(color: colorScheme.onSurface),
          ),
          content: Text(
            'Nenhum versículo foi selecionado. Deseja compartilhar os versículos deste capítulo (${viewModel.chapterTitle})?',
            style: TextStyle(color: colorScheme.onSurface),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: Text(
                'Cancelar',
                style: TextStyle(color: colorScheme.onSurface),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogCtx, true),
              child: const Text('Compartilhar'),
            ),
          ],
        ),
      );

      if (shouldShare == true && context.mounted) {
        final chapterText = viewModel.buildShareText();
        await context.read<BibleShareController>().shareText(chapterText);
      }
      return;
    }

    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                '$selectedCount versículo${selectedCount > 1 ? 's' : ''} selecionado${selectedCount > 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: Icon(Icons.share, color: colorScheme.onSurface),
                title: Text(
                  'Compartilhar versículos selecionados',
                  style: TextStyle(color: colorScheme.onSurface),
                ),
                onTap: () => Navigator.pop(sheetCtx, 'share'),
              ),
              ListTile(
                leading: Icon(Icons.close, color: colorScheme.onSurface),
                title: Text(
                  'Limpar seleção',
                  style: TextStyle(color: colorScheme.onSurface),
                ),
                onTap: () => Navigator.pop(sheetCtx, 'clear'),
              ),
            ],
          ),
        ),
      ),
    );

    if (!context.mounted) return;
    if (action == 'share') {
      final chapterText = viewModel.buildShareText();
      await context.read<BibleShareController>().shareText(chapterText);
      viewModel.clearSelections();
    } else if (action == 'clear') {
      viewModel.clearSelections();
    }
  }

  Future<void> _handleAutoScroll(
    BuildContext context,
    BibleContentController viewModel,
  ) async {
    if (!viewModel.isAutoScrollEnabled) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          title: const Text('Modo Leitura Automática'),
          content: const Text(
            'Devido a falta de base de dados para os áudios da Bíblia, '
            'esta funcionalidade funcionará com versões diferentes de '
            'leitura/escrita. Deseja prosseguir?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, true),
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
      try {
        await viewModel.audioPlayer.play();
      } catch (_) {}
    }
  }

  void _toggleHighlightMode() {
    setState(() {
      _highlightMode = !_highlightMode;
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _highlightMode
              ? 'Modo destaque ativado: toque em um versículo para colorir.'
              : 'Modo destaque desativado.',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
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
    final isRead =
        readViewModel.isRead(chapterId) || readViewModel.isRead(chapterTitle);

    _ensureAnnotationsLoaded(chapterId);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: chapterTitle,
        centerTitle: false,
        automaticallyImplyLeading: true,
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Opções',
            icon: Badge(
              isLabelVisible: viewModel.selectedVerseIndices.isNotEmpty,
              label: Text('${viewModel.selectedVerseIndices.length}'),
              child: Icon(
                Icons.more_vert,
                color: colorScheme.onSurface,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: colorScheme.surface,
            elevation: 4,
            onSelected: (action) async {
              switch (action) {
                case 'auto_scroll':
                  await _handleAutoScroll(context, viewModel);
                  break;
                case 'highlight':
                  _toggleHighlightMode();
                  break;
                case 'share':
                  await _handleShareOrSelection(context, viewModel);
                  break;
                case 'clear':
                  viewModel.clearSelections();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'auto_scroll',
                child: Row(
                  children: [
                    Icon(
                      viewModel.isAutoScrollEnabled
                          ? Icons.auto_stories
                          : Icons.auto_stories_outlined,
                      color: viewModel.isAutoScrollEnabled
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Leitura automática',
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            viewModel.isAutoScrollEnabled
                                ? 'Ativada'
                                : 'Desativada',
                            style: TextStyle(
                              color: viewModel.isAutoScrollEnabled
                                  ? AppTheme.sucesso
                                  : colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (viewModel.isAutoScrollEnabled)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppTheme.sucesso,
                        size: 18,
                      ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'highlight',
                child: Row(
                  children: [
                    Icon(
                      _highlightMode
                          ? Icons.colorize
                          : Icons.colorize_rounded,
                      color: _highlightMode
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Modo destaque',
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _highlightMode ? 'Ativado' : 'Desativado',
                            style: TextStyle(
                              color: _highlightMode
                                  ? AppTheme.sucesso
                                  : colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_highlightMode)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppTheme.sucesso,
                        size: 18,
                      ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'share',
                child: Row(
                  children: [
                    Icon(
                      viewModel.selectedVerseIndices.isEmpty
                          ? Icons.share_outlined
                          : Icons.share,
                      color: colorScheme.onSurface,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Compartilhar',
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            viewModel.selectedVerseIndices.isEmpty
                                ? 'Capítulo completo'
                                : '${viewModel.selectedVerseIndices.length} versículo(s) selecionado(s)',
                            style: TextStyle(
                              color: colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (viewModel.selectedVerseIndices.isNotEmpty)
                      Badge(
                        label: Text(
                          '${viewModel.selectedVerseIndices.length}',
                        ),
                      ),
                  ],
                ),
              ),
              if (viewModel.selectedVerseIndices.isNotEmpty)
                PopupMenuItem<String>(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(
                        Icons.close_rounded,
                        color: Theme.of(context).colorScheme.error,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Limpar seleção',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomBar(
        canGoBack: viewModel.currentChapterNumber > 1,
        canGoNext:
            viewModel.currentChapterNumber < viewModel.allBookChapters.length,
        onPrevious: viewModel.previousChapter,
        onNext: viewModel.nextChapter,
        topChild: InkWell(
          onTap: viewModel.toggleCurrentChapterRead,
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isRead
                  ? AppTheme.sucesso.withValues(alpha: 0.16)
                  : colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isRead
                    ? AppTheme.sucesso.withValues(alpha: 0.45)
                    : colorScheme.onSurface.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              children: [
                Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: isRead
                        ? AppTheme.sucesso
                        : colorScheme.primaryContainer,
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
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isRead
                            ? "Toque para marcar como não lido."
                            : "Toque para marcar como lido.",
                        style: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.72),
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
            if (viewModel.currentAudioChapter != null)
              SliverToBoxAdapter(
                child: BibleAudioPlayerCard(
                  audioPlayer: viewModel.audioPlayer,
                  currentAudioChapter: viewModel.currentAudioChapter,
                  onPlay: viewModel.playCurrentChapterAudio,
                  onStop: viewModel.stopChapterAudio,
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
                      color: Theme.of(context).colorScheme.onSurface,
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

                          final originalIndex =
                              viewModel.filteredVerseIndices[index];
                          final verseText =
                              viewModel.currentVerses[originalIndex];
                          final verseNumber = originalIndex + 1;
                          final isSelected = viewModel.selectedVerseIndices
                              .contains(originalIndex);
                          final colorScheme = Theme.of(context).colorScheme;

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
                                  final ok = viewModel
                                      .toggleVerseSelection(originalIndex);
                                  if (!ok) {
                                    await SelectionLimitDialog.show(context);
                                  }
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 8.0),
                                decoration: BoxDecoration(
                                  color: _verseAnnotations[
                                              originalIndex.toString()] !=
                                          null
                                      ? _getHighlightColor(
                                          context,
                                          _verseAnnotations[
                                              originalIndex.toString()]!)
                                      : (isSelected
                                          ? colorScheme.primary
                                              .withValues(alpha: 0.9)
                                          : Colors.transparent),
                                  borderRadius: BorderRadius.circular(16.0),
                                  border: _verseAnnotations[
                                              originalIndex.toString()] !=
                                          null
                                      ? Border.all(
                                          color: _getHighlightBorderColor(
                                            context,
                                            _verseAnnotations[
                                                originalIndex.toString()]!,
                                          ),
                                          width: 1.2,
                                        )
                                      : (isSelected
                                          ? Border.all(
                                              color: colorScheme.outlineVariant
                                                  .withValues(alpha: 0.25),
                                              width: 1.0,
                                            )
                                          : null),
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
                                            color: isSelected
                                                ? Colors.black
                                                : colorScheme.onSurface,
                                            fontSize: settings.fontSize,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            verseText,
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Colors.black
                                                  : colorScheme.onSurface,
                                              fontSize: settings.fontSize,
                                              fontWeight: _verseAnnotations[
                                                          originalIndex
                                                              .toString()] !=
                                                      null
                                                  ? FontWeight.w500
                                                  : FontWeight.normal,
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
