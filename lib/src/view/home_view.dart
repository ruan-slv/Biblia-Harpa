/// Implementa a interface e os fluxos de apresentação deste recurso.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'package:biblia_e_harpa/src/view/quiz_view.dart';
import 'package:biblia_e_harpa/src/view/home_audio_view.dart';
import 'package:biblia_e_harpa/src/view/settings_view.dart';
import 'package:biblia_e_harpa/src/controllers/bible_text_assets_controller.dart';
import 'package:biblia_e_harpa/src/controllers/bible_list_controller.dart';
import 'package:biblia_e_harpa/src/controllers/continue_reading_controller.dart';
import 'package:biblia_e_harpa/src/view/bible_content_view.dart';
import 'package:biblia_e_harpa/src/view/devotional_content_view.dart';
import 'package:biblia_e_harpa/src/view/harp_content_view.dart';
import 'package:biblia_e_harpa/src/view/notes_view.dart';
import 'background_tasks_view.dart';
import 'package:biblia_e_harpa/src/services/app_audio_handler.dart';
import 'component/daily_word_card.dart';
import 'other_projects_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'component/app_bar_component.dart';
import 'component/build_menu_card.dart';
import 'devotional_list_view.dart';
import 'harp_list_view.dart';
import 'bible_feature.dart';
import 'package:biblia_e_harpa/src/utils/config.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int currentPageIndex = 0;

  static const _continueReadingController = ContinueReadingController();

  Future<void> _resume(ContinueReadingEntry entry) async {
    switch (entry.type) {
      case ContinueReadingType.devotional:
        final topic = entry.data['topic'] as String?;
        if (topic == null) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DevotionalContentView(
              devo: topic,
              initialIndex: entry.position,
            ),
          ),
        );
        return;
      case ContinueReadingType.bible:
        final bookName = entry.data['bookName'] as String?;
        final jsonPath = entry.data['jsonPath'] as String?;
        if (bookName == null || jsonPath == null) return;

        final book = await context.read<BibleTextAssetsController>().loadBook(
              bookName: bookName,
              jsonAssetPath: jsonPath,
            );
        if (!mounted || book == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Não foi possível retomar a Bíblia.')),
            );
          }
          return;
        }

        final audioChapters = context
            .read<BibleListController>()
            .findAudioChaptersForBook(bookName);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BibleContentView(
              bookName: bookName,
              jsonPath: jsonPath,
              initialChapterNumber: entry.position + 1,
              allBookChapters: book.chapters,
              audioChapters: audioChapters,
            ),
          ),
        );
        return;
      case ContinueReadingType.harp:
        final hymn = entry.data['hymn'] as String?;
        if (hymn == null) return;
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => HarpContentView(harp: hymn)),
        );
        return;
      case ContinueReadingType.quiz:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => QuizView(initialQuestionIndex: entry.position),
          ),
        );
        return;
    }
  }

  IconData _continueIcon(ContinueReadingType type) {
    return switch (type) {
      ContinueReadingType.devotional => Icons.auto_stories_rounded,
      ContinueReadingType.bible => Icons.menu_book_rounded,
      ContinueReadingType.harp => Icons.music_note_rounded,
      ContinueReadingType.quiz => Icons.quiz_outlined,
    };
  }

  Future<void> _showContinueReading() async {
    final entries = await _continueReadingController.loadEntries();
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        final colorScheme = Theme.of(sheetContext).colorScheme;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(sheetContext).height * .7,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: .22),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading:
                      Icon(Icons.auto_fix_high, color: colorScheme.onSurface),
                  title: Text(
                    'Próximo devocional não lido',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    'Avança para a próxima leitura disponível',
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: .72),
                    ),
                  ),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    final entry = await _continueReadingController
                        .findNextUnreadDevotional();
                    if (!mounted) return;
                    if (entry == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Nenhum devocional não lido encontrado.'),
                        ),
                      );
                      return;
                    }
                    await _resume(entry);
                  },
                ),
                Divider(
                  height: 1,
                  color: colorScheme.onSurface.withValues(alpha: .08),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Continuar de onde parou',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                if (entries.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: Text(
                      'Nenhuma leitura ou atividade recente.',
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: .72),
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: entries.length,
                      itemBuilder: (_, index) {
                        final entry = entries[index];
                        return ListTile(
                          leading: Icon(
                            _continueIcon(entry.type),
                            color: colorScheme.onSurface,
                          ),
                          title: Text(
                            entry.title,
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            entry.subtitle,
                            style: TextStyle(
                              color:
                                  colorScheme.onSurface.withValues(alpha: .72),
                            ),
                          ),
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            color: colorScheme.onSurface.withValues(alpha: .55),
                          ),
                          onTap: () {
                            Navigator.of(sheetContext).pop();
                            _resume(entry);
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  ColorScheme colorScheme(BuildContext context) =>
      Theme.of(context).colorScheme;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final List<Widget> pages = [
      SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final content = ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: DailyWordCard(),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: buildMenuCard(
                      context,
                      title: 'Continuar lendo',
                      description:
                          'Retome Devocional, Bíblia, Harpa ou Quiz de onde parou.',
                      iconData: Icons.read_more_rounded,
                      gradientColors: gradienteDevocional,
                      onPressed: _showContinueReading,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Atalhos principais",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: buildMenuCard(
                                context,
                                title: 'Bíblia',
                                iconData: Icons.menu_book_rounded,
                                gradientColors: gradienteBiblia,
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          BibleFeature.bibleList()),
                                ),
                                compact: true,
                                centerContent: true,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: buildMenuCard(
                                context,
                                title: 'Harpa',
                                iconData: Icons.music_note_rounded,
                                gradientColors: gradienteHarpa,
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const HarpListView()),
                                ),
                                compact: true,
                                centerContent: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: buildMenuCard(
                                context,
                                title: 'Devocional',
                                iconData: Icons.auto_stories_rounded,
                                gradientColors: gradienteDevocional,
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const DevotionalListView()),
                                ),
                                compact: true,
                                centerContent: true,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: buildMenuCard(
                                context,
                                title: 'Áudios',
                                iconData: Icons.headphones_outlined,
                                gradientColors: gradienteAudios,
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const HomeAudioView()),
                                ),
                                compact: true,
                                centerContent: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: buildMenuCard(
                                context,
                                title: 'Quiz bíblico',
                                iconData: Icons.quiz_outlined,
                                gradientColors: gradienteAudios,
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const QuizView()),
                                ),
                                compact: true,
                                centerContent: true,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: buildMenuCard(
                                context,
                                title: 'Anotações',
                                iconData: Icons.edit_note_outlined,
                                gradientColors: gradienteApoio,
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const NotesView()),
                                ),
                                compact: true,
                                centerContent: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: buildMenuCard(
                      context,
                      title: 'Outros projetos',
                      description:
                          'Descubra outros projetos em que estamos preparando para você',
                      iconData: Icons.apps_rounded,
                      gradientColors: gradienteOutros,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OtherProjectsView(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
            return SingleChildScrollView(
              child: content,
            );
          },
        ),
      ),
      const BackgroundTasksView(),
      const SettingsView(),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: currentPageIndex == 1
            ? "Segundo plano"
            : currentPageIndex == 2
                ? "Configurações"
                : "Bíblia e Harpa",
        centerTitle: false,
      ),
      body: pages[currentPageIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: colorScheme.surface,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: colorScheme.surfaceContainerHighest,
        selectedIndex: currentPageIndex,
        destinations: <Widget>[
          NavigationDestination(
            selectedIcon: Icon(
              Icons.home,
              color: colorScheme.brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
            icon: Icon(
              Icons.home_outlined,
              color: colorScheme.onSurface,
            ),
            label: "Inicio",
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.play_circle_rounded,
              color: colorScheme.brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
            icon: ValueListenableBuilder<AppAudioHandler?>(
              valueListenable: audioHandlerChanges,
              builder: (context, handler, _) {
                final trackNotifier = handler?.currentTrack;
                return ValueListenableBuilder<AppAudioTrack?>(
                  valueListenable: trackNotifier ?? ValueNotifier(null),
                  builder: (context, track, _) {
                    final icon = Icon(
                      Icons.play_circle_outline_rounded,
                      color: colorScheme.onSurface,
                    );
                    if (track == null) return icon;
                    return Badge(
                      smallSize: 8,
                      backgroundColor: colorScheme.primary,
                      child: icon,
                    );
                  },
                );
              },
            ),
            label: "Segundo plano",
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.settings,
              color: colorScheme.brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
            icon: Icon(
              Icons.settings_outlined,
              color: colorScheme.onSurface,
            ),
            label: "Configurações",
          ),
        ],
      ),
    );
  }
}
