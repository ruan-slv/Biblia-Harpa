import 'dart:convert';
import 'dart:math';

import 'package:biblia_e_harpa/src/config.dart'; // Certifique-se que suas cores como amberColor, etc., estão aqui ou defina-as abaixo
import 'package:biblia_e_harpa/src/content/doacao.dart';
import 'package:biblia_e_harpa/src/devocional/devocionalList.dart';
import 'package:biblia_e_harpa/src/screens/aboutProjectScreen.dart';
import 'package:biblia_e_harpa/src/screens/audiosScreen.dart';
import 'package:biblia_e_harpa/src/screens/settingsScreen.dart';
import 'package:biblia_e_harpa/src/sizelist/biblelist.dart';
import 'package:biblia_e_harpa/src/sizelist/harpalist.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:biblia_e_harpa/src/initial/wallpaperSelectionScreen.dart';
import 'package:biblia_e_harpa/src/controllers/fontSizeController.dart';

import '../screens/palavraDiaScreen.dart'; // Se 'palavraDiaScreen.dart' estiver em '../screens/'

// Data class for Palavra do Dia
class Data {
  final int id;
  final String texto;
  final String versiculo;

  Data({required this.id, required this.texto, required this.versiculo});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json["id"],
      texto: json["texto"],
      versiculo: json["versiculo"],
    );
  }
}

class Initial extends StatefulWidget {
  const Initial({super.key});

  @override
  State<Initial> createState() => _InitialState();
}

class _InitialState extends State<Initial> {
  String? backgroundImagePath;

  final List<String> imagesWallpapers = [
    "assets/images/Wall paperss.jpg",
    "assets/images/fundoOption1.jpeg",
    "assets/images/fundoOption2.jpeg",
    "assets/images/fundoOption3.jpeg",
    "assets/images/fundoOption4.jpg",
    "assets/images/fundoOption5.jpeg",
    "assets/images/fundoOption6.jpeg",
    "assets/images/fundoOption7.jpeg",
    "assets/images/fundoOption8.jpeg",
    "assets/images/fundoOption9.jpeg",
    "assets/images/fundoOption10.jpeg",
    "assets/images/fundoOption11.jpeg",
    "assets/images/fundoOption12.jpeg",
    "assets/images/fundoOption13.jpeg",
  ];

  Future<void> _loadWallpaper() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString("backgroundImagePath");
    if (path != null && imagesWallpapers.contains(path)) {
      setState(() {
        backgroundImagePath = path;
      });
    }
  }

  void _pickWallpaper() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => wallpaperselectionscreen(
          wallpapers: imagesWallpapers,
          onSelect: (selectedPath) async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString("backgroundImagePath", selectedPath);
            setState(() {
              backgroundImagePath = selectedPath;
            });
            Navigator.pop(context); // Fecha a tela de seleção
          },
        ),
      ),
    );
  }

  Data? palavraAtual;
  DateTime? ultimaAtualizacao;

  @override
  void initState() {
    super.initState();
    _loadPalavraDoDia();
    _loadWallpaper();
  }

  Future<void> _loadPalavraDoDia() async {
    final prefs = await SharedPreferences.getInstance();
    final String? lastUpdate = prefs.getString("last_update");
    final String? palavraSalva = prefs.getString("palavra_atual");

    final now = DateTime.now();
    bool precisaAtualizar = lastUpdate == null ||
        DateTime.parse(lastUpdate).difference(now).inDays.abs() >= 1;

    if (!precisaAtualizar && palavraSalva != null) {
      setState(() {
        palavraAtual = Data.fromJson(jsonDecode(palavraSalva));
        ultimaAtualizacao = DateTime.parse(lastUpdate);
      });
      return;
    } else if (palavraSalva == null) {
      setState(() {
        palavraAtual =
            Data(id: 0, texto: "Nunhuma palavra encontrada", versiculo: "");
      });
      Future.delayed(const Duration(seconds: 1), () => _loadPalavraDoDia());
      return;
    }

    try {
      final String jsonString = await DefaultAssetBundle.of(context)
          .loadString("assets/json/palavraDoDia.json");
      final List<dynamic> jsonResponse = jsonDecode(jsonString)["palavraDoDia"];

      final randomIndex = Random().nextInt(jsonResponse.length);
      final selectedPalavra = jsonResponse[randomIndex];

      setState(() {
        palavraAtual = Data.fromJson(selectedPalavra);
        ultimaAtualizacao = now;
      });

      await prefs.setString("last_update", now.toIso8601String());
      await prefs.setString("palavra_atual", jsonEncode(selectedPalavra));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao carregar a palavra do dia: ${e.toString()}"),
        ),
      );
    }
  }

  void _compartilharPalavra() {
    if (palavraAtual != null) {
      Share.share("${palavraAtual!.texto} \n ${palavraAtual!.versiculo}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

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
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Aboutprojectscreen(),
            ),
          );
        },
        tooltip: "Alterar papel de parede",
        child: const Icon(Icons.info, color: Colors.black87),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Ajuste o valor de altura mínima conforme seu conteúdo
            final minContentHeight =
                600.0; // Exemplo: altura mínima do conteúdo

            final content = ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20),
                  //   child: Text(
                  //     "Palavra do Dia",
                  //     style: TextStyle(
                  //       color: Theme.of(context).colorScheme.secondary,
                  //       fontSize: 22,
                  //     ),
                  //   ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 100),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Stack(
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
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
                                          shadows: [
                                            Shadow(
                                              blurRadius: 4.0,
                                              color:
                                                  Colors.black.withOpacity(0.3),
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.center,
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  ValueListenableBuilder<double>(
                                    valueListenable:
                                        FontSizeController.fontSizeNotifier,
                                    builder: (context, fontSize, _) {
                                      return Text(
                                        palavraAtual?.versiculo ??
                                            "Versículo não encontrado",
                                        style: TextStyle(
                                          fontSize: fontSize,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                        textAlign: TextAlign.center,
                                      );
                                    },
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
                                                  .colorScheme
                                                  .brightness ==
                                              Brightness.light
                                          ? whiteColor
                                          : cinzaClaro,
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
                                gradienteBiblia, // gradiente antigo
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
                                gradienteHarpa, // gradiente antigo
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
                                gradienteDevocional, // gradiente antigo
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
                                gradienteAudios, // gradiente antigo
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const AudioScreen()),
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

            if (constraints.maxHeight > minContentHeight) {
              // Tela grande: sem scroll
              return content;
            } else {
              // Tela pequena: com scroll
              return SingleChildScrollView(child: content);
            }
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          "Desde 2024 - Desenvolvido por Ruan",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
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
        width: double.infinity, // Ocupa toda a largura disponível
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12), // Um pouco mais arredondado
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 16), // Espaço interno vertical
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      // Aplicando o gradiente aqui
                      colors: gradientColors.length >= 2
                          ? gradientColors
                          : [
                              gradientColors.first,
                              gradientColors.first
                            ], // Garante pelo menos 2 cores
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: gradientColors.length == 3
                          ? [0.0, 0.5, 1.0]
                          : null, // Exemplo de stops para 3 cores
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      // Sombra sutil no círculo do ícone
                      BoxShadow(
                          color: gradientColors.last.withOpacity(0.5),
                          blurRadius: 5,
                          offset: const Offset(0, 2))
                    ]),
                child: Icon(
                  iconData,
                  color: Colors
                      .white, // Ícone branco para bom contraste com o gradiente
                  size: 32, // Tamanho fixo ou responsivo, se quiser
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                //maxLines: avel,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18, // Tamanho fixo ou responsivo, se quiser
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
