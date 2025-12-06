// lib/src/screens/initial_screen.dart

import 'dart:convert';
import 'dart:math';

import 'package:biblia_e_harpa/src/config.dart';
import 'package:biblia_e_harpa/src/models/carousel_item_model.dart';
import 'package:biblia_e_harpa/src/screens/StoreScreen.dart';
import 'package:biblia_e_harpa/src/screens/aboutProjectScreen.dart';
import 'package:biblia_e_harpa/src/screens/harpaAudioScreen.dart';
import 'package:biblia_e_harpa/src/screens/homeAudioScreen.dart';
import 'package:biblia_e_harpa/src/screens/informacaoScreen.dart';
import 'package:biblia_e_harpa/src/screens/informacaoWrapper.dart';
import 'package:biblia_e_harpa/src/screens/other_Screen.dart';
import 'package:biblia_e_harpa/src/screens/settingsScreen.dart';
// IMPORTANTE: Importe o serviço que criamos
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:biblia_e_harpa/src/controllers/fontSizeController.dart';
import '../screens/storeWrapper.dart';

import '../services/NotificationService.dart';
import 'bible_list_screen.dart';
import 'devocional_list_screen.dart';
import 'harpa_list_screen.dart';
import 'palavraDiaScreen.dart';

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
    // Inicializa o serviço de notificação
    NotificationService().init();
    _loadPalavraDoDia();
  }

  Widget _buildStyledDestination(int index) {
    // ... (Código mantido igual)
    final bool isSelected = currentPageIndex == index;
    final List<IconData> icons = [
      Icons.home_outlined,
      Icons.store_outlined,
      Icons.info_outline,
    ];
    final List<IconData> selectedIcons = [
      Icons.home,
      Icons.store,
      Icons.info,
    ];

    return NavigationDestination(
      icon: _animatedNavIcon(
        icon: icons[index],
        isSelected: false,
        index: index,
      ),
      selectedIcon: _animatedNavIcon(
        icon: selectedIcons[index],
        isSelected: true,
        index: index,
      ),
      label: '',
    );
  }

  Widget _animatedNavIcon({
    required IconData icon,
    required bool isSelected,
    required int index,
  }) {
    // ... (Código mantido igual)
    return AnimatedScale(
      scale: isSelected ? 1.0 : 1.0,
      duration: const Duration(milliseconds: 230),
      curve: Curves.easeOutCubic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(isSelected ? 12 : 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadiusGeometry.all(Radius.circular(20.0)),
          color: isSelected
              ? Theme.of(context).colorScheme.secondary.withOpacity(0.25)
              : Colors.transparent,
        ),
        child: Icon(
          icon,
          size: 26,
          color: isSelected
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
        ),
      ),
    );
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

      final randomIndex = Random().nextInt(jsonResponse.length - 1);
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
      await NotificationService().agendarNotificacaoParaAmanha();

    } catch (e) {
      //_mostrarErro("Erro ao carregar palavra salva: ${e.toString()}");
    }
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
      ),
    );
  }

  void _compartilharPalavra() {
    if (palavraAtual != null) {
      Share.share("${palavraAtual!.texto} \n ${palavraAtual!.versiculo}");
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (O resto do método build permanece exatamente o mesmo)
    final screenSize = MediaQuery.of(context).size;
    final List<Widget> pages = [
      SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final minContentHeight = 600.0;

            final content = ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 150),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Stack(
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Palavra do Dia",
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  ValueListenableBuilder<double>(
                                    valueListenable:
                                    FontSizeController.fontSizeNotifier,
                                    builder: (context, fontSize, _) {
                                      return Text(
                                        palavraAtual?.texto ??
                                            "Palavra do dia não encontrada",
                                        style: TextStyle(
                                          fontSize: fontSize,
                                          fontStyle: FontStyle.italic,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                        textAlign: TextAlign.center,
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    palavraAtual?.versiculo.isNotEmpty == true
                                        ? palavraAtual!.versiculo
                                        : "versiculo não encontrado",
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton.icon(
                                    onPressed: _compartilharPalavra,
                                    icon: Icon(
                                      Icons.share,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                    label: Text(
                                      "Compartilhar",
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme.background,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: _buildMenuCard(
                                context,
                                'Bíblia',
                                Icons.menu_book_rounded,
                                gradienteBiblia,
                                    () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const BibleList()),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildMenuCard(
                                context,
                                'Harpa',
                                Icons.music_note,
                                gradienteHarpa,
                                    () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const HarpaList()),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: _buildMenuCard(
                                context,
                                'Devocional',
                                Icons.auto_stories,
                                gradienteDevocional,
                                    () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                      const DevocionalList()),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildMenuCard(
                                context,
                                'Áudios',
                                Icons.headphones_outlined,
                                gradienteAudios,
                                    () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                      const Homeaudioscreen()),
                                ),
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

      OtherScreen(),
      OtherScreen(),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          "Bíblia e Harpa sem anúncios",
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Theme.of(context).colorScheme.secondary,
            ),
            tooltip: "Configurações",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: pages[currentPageIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Theme.of(context).colorScheme.secondary,
        selectedIndex: currentPageIndex,
        destinations: <Widget>[
          NavigationDestination(
            selectedIcon: Icon(
              Icons.home,
              color: Theme.of(context).colorScheme.primary,
            ),
            icon: Icon(
              Icons.home_outlined,
              color: Theme.of(context).colorScheme.secondary,
            ),
            label: "Inicio",
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.more_horiz_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            icon: Icon(
              Icons.more_horiz_rounded,
              color: Theme.of(context).colorScheme.secondary,
            ),
            label: "Outros",
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
      BuildContext context,
      String title,
      IconData iconData,
      List<Color> gradientColors,
      VoidCallback onPressed, {
        double? width,
        double? height,
        double? size,
      }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors.length >= 2
                          ? gradientColors
                          : [
                        gradientColors.first,
                        gradientColors.first
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: gradientColors.length == 3
                          ? [0.0, 0.5, 1.0]
                          : null,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: gradientColors.last.withOpacity(0.5),
                          blurRadius: 5,
                          offset: const Offset(0, 2))
                    ]),
                child: Icon(
                  iconData,
                  color: Colors
                      .white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
