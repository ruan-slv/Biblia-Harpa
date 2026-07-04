import 'package:biblia_e_harpa/src/view_model/settings_view_model.dart';
import 'package:biblia_e_harpa/src/view_model/daily_word_view_model.dart';
import 'package:biblia_e_harpa/src/view/rights_view.dart';
import 'package:biblia_e_harpa/src/view/privacy_view.dart';
import 'package:biblia_e_harpa/src/view/proposals_view.dart';
import 'package:biblia_e_harpa/src/view/quiz_view.dart';
import 'package:biblia_e_harpa/src/view/about_view.dart';
import 'package:biblia_e_harpa/src/view/home_audio_view.dart';
import 'package:biblia_e_harpa/src/view/settings_view.dart';
import 'package:biblia_e_harpa/src/view_model/service/daily_word_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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
  static const String _trello_url = "https://trello.com/invite/b/6a257f7eb5d6c92e1ac39338/ATTIe26d78db57fb98d7a92c34ce273086d724E8BB99/biblia-e-harpa";
  final Uri _trello = Uri.parse(_trello_url);

  final DailyWordService _service = DailyWordService();
  late final DailyWordViewModel _dailyWordViewModel;

  Future<void> _openExternal(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception("Não foi possível abrir a página");
    }
  }

  @override
  void initState() {
    super.initState();
    _dailyWordViewModel = DailyWordViewModel(service: _service);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _dailyWordViewModel.loadDailyWord(context);
      }
    });
  }

  ColorScheme colorScheme(BuildContext context) => Theme.of(context).colorScheme;


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final List<Widget> pages = [
      SafeArea(
        child: ChangeNotifierProvider.value(
          value: _dailyWordViewModel,
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
                    Consumer<DailyWordViewModel>(
                      builder: (context, viewModel, _) {
                        final currentWord = viewModel.currentWord;
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  colorScheme.primary,
                                  colorScheme.surface,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.secondary.withValues(alpha: 0.08),
                                  blurRadius: 18,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 18),
                                Text(
                                  currentWord?.reference.isNotEmpty == true
                                      ? currentWord!.reference
                                      : "Versículo não encontrado",
                                  style: TextStyle(
                                    color: colorScheme.secondary,
                                    fontSize: 23,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Consumer<SettingsViewModel>(
                                  builder: (context, settings, _) {
                                    return Text(
                                      currentWord?.text ??
                                          "Palavra do dia não encontrada",
                                      style: TextStyle(
                                        fontSize: settings.fontSize,
                                        fontStyle: FontStyle.italic,
                                        color: colorScheme.secondary.withValues(alpha: 0.92),
                                        height: 1.55,
                                      ),
                                      textAlign: TextAlign.justify,
                                    );
                                  },
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton.icon(
                                  onPressed: viewModel.shareDailyWord,
                                  icon: const Icon(Icons.share_outlined),
                                  label: const Text("Compartilhar"),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Text(
                          "Atalhos principais",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.secondary,
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
                                        builder: (context) => BibleFeature.bibleList()),
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
                                      builder: (context) => const HarpListView()),
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
                                description: 'Acesse o atalho do quiz na próxima atualização.',
                                iconData: Icons.quiz_outlined,
                                gradientColors: gradienteAudios,
                                onPressed: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => const QuizView()),
                                ),
                                compact: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          "Atalhos informativos",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: buildMenuCard(
                                context,
                                title: 'Direitos',
                                iconData: Icons.priority_high_rounded,
                                gradientColors: gradienteBiblia,
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const RightsView()),
                                ),
                                compact: true,
                                centerContent: true,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: buildMenuCard(
                                context,
                                title: 'Privacidade',
                                iconData: Icons.security_rounded,
                                gradientColors: gradienteHarpa,
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const PrivacyView()),
                                ),
                                compact: true,
                                centerContent: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: buildMenuCard(
                                context,
                                title: 'Sobre',
                                iconData: Icons.info_outline_rounded,
                                gradientColors: gradienteDevocional,
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const AboutView()),
                                ),
                                compact: true,
                                centerContent: true,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: buildMenuCard(
                                context,
                                title: 'Propostas',
                                iconData: Icons.security_rounded,
                                gradientColors: gradienteAudios,
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const ProposalsView()),
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
              title: 'Acompanhar Sugestões',
              description: 'Acompanhe as sugestões aprovadas para próximas atualizações do aplicativo.',
              iconData: Icons.settings_suggest_outlined,
              gradientColors: gradienteAudios,
                onPressed: () async => await _openExternal(_trello),
              compact: true,
              ),
              ),
              ],
              ),
                        ],
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
      ),
      const SettingsView(),
    ];

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        title: "Bíblia e Harpa",
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
        indicatorColor: colorScheme.secondary,
        selectedIndex: currentPageIndex,
        destinations: <Widget>[
          NavigationDestination(
            selectedIcon: Icon(
              Icons.home,
              color: colorScheme.primary,
            ),
            icon: Icon(
              Icons.home_outlined,
              color: colorScheme.secondary,
            ),
            label: "Inicio",
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.settings,
              color: colorScheme.primary,
            ),
            icon: Icon(
              Icons.settings_outlined,
              color: colorScheme.secondary,
            ),
            label: "Configurações",
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _dailyWordViewModel.dispose();
    super.dispose();
  }
}
