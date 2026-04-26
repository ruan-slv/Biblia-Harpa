import 'package:biblia_e_harpa/src/config.dart';
import 'package:biblia_e_harpa/src/core/alert.dart';
import 'package:biblia_e_harpa/src/models/initial_model.dart';
import 'package:biblia_e_harpa/src/screens/homeAudioScreen.dart';
import 'package:biblia_e_harpa/src/screens/settingsScreen.dart';
import 'package:biblia_e_harpa/src/services/initial_service.dart';
import 'package:flutter/material.dart';
import 'package:biblia_e_harpa/src/controllers/fontSizeController.dart';
import '../components/appBarComponent.dart';
import '../components/buildMenuCard.dart';
import 'bible_list_screen.dart';
import 'devocional_list_screen.dart';
import 'harpa_list_screen.dart';

class Initial extends StatefulWidget {
  const Initial({super.key});

  @override
  State<Initial> createState() => _InitialState();
}

class _InitialState extends State<Initial> {
  DayWord? currentWord;
  DateTime? lastDataUpdate;
  int currentPageIndex = 0;

  final InitialService _service = InitialService();
  final Alert _alert = Alert();

  @override
  void initState() {
    super.initState();
    _loadDayWord();
  }

  Future<void> _loadDayWord() async {
    final (word, lastUpdate) = await _service.loadDayWord(context);
    setState(() {
      currentWord = word;
      lastDataUpdate = lastUpdate;
    });
  }

  ColorScheme colorScheme(BuildContext context) => Theme.of(context).colorScheme;


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
                  Padding(
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
                            onPressed: () => _service.shareDayWord(currentWord),
                            icon: const Icon(Icons.share_outlined),
                            label: const Text("Compartilhar"),
                          ),
                        ],
                      ),
                    ),
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
                                onPressed: () => _alert.alert(context),
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
}
