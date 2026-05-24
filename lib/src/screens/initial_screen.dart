import 'package:biblia_e_harpa/src/config.dart';
import 'package:biblia_e_harpa/src/controllers/day_word_controller.dart';
import 'package:biblia_e_harpa/src/screens/direitos_screen.dart';
import 'package:biblia_e_harpa/src/models/initial_model.dart';
import 'package:biblia_e_harpa/src/screens/privacidade_screen.dart';
import 'package:biblia_e_harpa/src/screens/propostas_screen.dart';
import 'package:biblia_e_harpa/src/screens/quiz_screen.dart';
import 'package:biblia_e_harpa/src/screens/about_project_screen.dart';
import 'package:biblia_e_harpa/src/screens/home_audio_screen.dart';
import 'package:biblia_e_harpa/src/screens/settings_screen.dart';
import 'package:biblia_e_harpa/src/services/initial_service.dart';
import 'package:flutter/material.dart';
import 'package:biblia_e_harpa/src/controllers/font_size_controller.dart';
import 'package:provider/provider.dart';
import '../components/app_bar_component.dart';
import '../components/build_menu_card.dart';
import 'bible_list_screen.dart';
import 'devocional_list_screen.dart';
import 'harpa_list_screen.dart';

class Initial extends StatefulWidget {
  const Initial({super.key});

  @override
  State<Initial> createState() => _InitialState();
}

class _InitialState extends State<Initial> {
  int currentPageIndex = 0;

  final InitialService _service = InitialService();
  late final DayWordController _dayWordController;

  @override
  void initState() {
    super.initState();
    _dayWordController = DayWordController(service: _service);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _dayWordController.loadDayWord(context);
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
          value: _dayWordController,
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
                    Consumer<DayWordController>(
                      builder: (context, controller, _) {
                        final currentWord = controller.currentWord;
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
                                ValueListenableBuilder<double>(
                                  valueListenable: FontSizeController.fontSizeNotifier,
                                  builder: (context, fontSize, _) {
                                    return Text(
                                      currentWord?.text ??
                                          "Palavra do dia não encontrada",
                                      style: TextStyle(
                                        fontSize: fontSize,
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
                                  onPressed: controller.shareDayWord,
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
                                        builder: (context) => const BibleList()),
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
                                      builder: (context) => const HarpaList()),
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
                                          const DevocionalList()),
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
                                          const Homeaudioscreen()),
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
                                  MaterialPageRoute(builder: (context) => const QuizScreen()),
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
                                      builder: (context) => const DireitosScreen()),
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
                                      builder: (context) => const PrivacidadeScreen()),
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
                                      builder: (context) => const Aboutprojectscreen()),
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
                                      builder: (context) => const PropostasScreen()),
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
      SettingsScreen(),
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
    _dayWordController.dispose();
    super.dispose();
  }
}
