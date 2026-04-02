// lib/src/screens/initial_screen.dart

import 'dart:convert';
import 'dart:math';

import 'package:biblia_e_harpa/src/components/action_info_card.dart';
import 'package:biblia_e_harpa/src/config.dart';
import 'package:biblia_e_harpa/src/screens/homeAudioScreen.dart';
import 'package:biblia_e_harpa/src/screens/settingsScreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:biblia_e_harpa/src/controllers/fontSizeController.dart';
import 'package:biblia_e_harpa/src/screens/text_devocional_Screen.dart';
import 'package:biblia_e_harpa/src/keys/devocionalkey.dart';
import '../components/buildMenuCard.dart';
import 'bible_list_screen.dart';
import 'devocional_list_screen.dart';
import 'harpa_list_screen.dart';

// Data class for Palavra do Dia
class Data {
  final int id;
  final String texto;
  final String versiculo;

  Data({required this.id, required this.texto, required this.versiculo});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json["id"] ?? 0,
      texto: json["texto"] ?? "Texto indisponível",
      versiculo: json["versiculo"] ?? "versiculo indisponível",
    );
  }
}

class Initial extends StatefulWidget {
  const Initial({super.key});

  @override
  State<Initial> createState() => _InitialState();
}

class _InitialState extends State<Initial> {
  Data? palavraAtual;
  DateTime? ultimaAtualizacao;
  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadPalavraDoDia();
  }

  Future<void> _loadPalavraDoDia() async {
    final prefs = await SharedPreferences.getInstance();
    final String? lastUpdate = prefs.getString("last_update");
    final String? palavraSalva = prefs.getString("palavra_atual");

    final now = DateTime.now();
    final precisaAtualizar = lastUpdate == null ||
        DateTime.parse(lastUpdate).difference(now).inDays.abs() >= 1;

    if (!precisaAtualizar && palavraSalva != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(palavraSalva);
        setState(() {
          palavraAtual = Data.fromJson(json);
          ultimaAtualizacao = DateTime.parse(lastUpdate);
        });
      } catch (e) {
        //_mostrarErro("Erro ao carregar palavra salva: ${e.toString()}");
      }
      return;
    }

    // --- AQUI COMEÇA A LÓGICA DE ATUALIZAÇÃO ---
    try {
      final String jsonString = await DefaultAssetBundle.of(context)
          .loadString("assets/json/palavraDoDia.json");
      final List<dynamic> jsonResponse = jsonDecode(jsonString)["palavraDoDia"];

      if (jsonResponse.isEmpty) {
        setState(() {
          palavraAtual = Data(
            id: 0,
            texto: "Nenhuma palavra disponível",
            versiculo: "",
          );
        });
        return;
      }

      final randomIndex = Random().nextInt(jsonResponse.length);
      final selectedPalavra = jsonResponse[randomIndex];

      setState(() {
        palavraAtual = Data.fromJson(selectedPalavra);
        ultimaAtualizacao = now;
      });

      await prefs.setString("last_update", now.toIso8601String());
      await prefs.setString("palavra_atual", jsonEncode(selectedPalavra));

      // --- NOVO: Agenda a notificação para o dia seguinte ---
      // Como a palavra acabou de mudar, agendamos um lembrete para amanhã
      // para avisar que haverá uma NOVA palavra novamente.
    } catch (e) {
      //_mostrarErro("Erro ao carregar palavra salva: ${e.toString()}");
    }
  }

  void _compartilharPalavra() {
    if (palavraAtual != null) {
      Share.share("${palavraAtual!.texto} \n ${palavraAtual!.versiculo}");
    }
  }

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
                            color: colorScheme.secondary.withOpacity(0.08),
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
                            palavraAtual?.versiculo.isNotEmpty == true
                                ? palavraAtual!.versiculo
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
                                palavraAtual?.texto ??
                                    "Palavra do dia não encontrada",
                                style: TextStyle(
                                  fontSize: fontSize,
                                  fontStyle: FontStyle.italic,
                                  color: colorScheme.secondary.withOpacity(0.92),
                                  height: 1.55,
                                ),
                                textAlign: TextAlign.justify,
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _compartilharPalavra,
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
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Bíblia e Harpa",
          style: TextStyle(
            color: colorScheme.secondary,
            fontWeight: FontWeight.w700,
          ),
        ),
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
