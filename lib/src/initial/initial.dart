import 'package:biblia_e_harpa/src/config.dart'; // Certifique-se que suas cores como amberColor, etc., estão aqui ou defina-as abaixo
import 'package:biblia_e_harpa/src/content/doacao.dart';
import 'package:biblia_e_harpa/src/devocional/devocionalList.dart';
import 'package:biblia_e_harpa/src/screens/audiosScreen.dart';
import 'package:biblia_e_harpa/src/sizelist/biblelist.dart';
import 'package:biblia_e_harpa/src/sizelist/harpalist.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:biblia_e_harpa/src/initial/wallpaperSelectionScreen.dart';

import '../screens/palavraDiaScreen.dart'; // Se 'palavraDiaScreen.dart' estiver em '../screens/'

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

  @override
  void initState() {
    super.initState();
    _loadWallpaper();
  }

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

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final buttonSize = screenSize.width * 0.30;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: _pickWallpaper,
        tooltip: "Alterar papel de parede",
        child: const Icon(Icons.image, color: Colors.black87),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: backgroundImagePath != null && backgroundImagePath!.isNotEmpty
                ? AssetImage(backgroundImagePath!)
                : const AssetImage('assets/images/fundoOption9.jpeg'), // Imagem padrão
            fit: BoxFit.cover,
            colorFilter: const ColorFilter.mode(
              Colors.black45, // Escurece um pouco a imagem de fundo
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenSize.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  const Icon(
                    Icons.menu_book_rounded,
                    color: Colors.white,
                    size: 65.0,
                    shadows: [Shadow(blurRadius: 10.0, color: Colors.black54)],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Bíblia e Harpa",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(blurRadius: 8.0, color: Colors.black54)],
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Sua jornada espiritual diária",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                      shadows: [Shadow(blurRadius: 4.0, color: Colors.black54)],
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Desenvolvido por Ruan",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                      shadows: [Shadow(blurRadius: 4.0, color: Colors.black54)],
                    ),
                  ),
                  const SizedBox(height: 60), // Ajustado para dar mais espaço
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildMenuCard(
                              context,
                              'Bíblia',
                              Icons.menu_book_rounded,
                              gradienteBiblia, // Passando o gradiente
                                  () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const BibleList()),
                              ),
                              size: buttonSize,
                            ),
                            const SizedBox(width: 12),
                            _buildMenuCard(
                              context,
                              'Harpa',
                              Icons.music_note,
                              gradienteHarpa, // Passando o gradiente
                                  () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const HarpaList()),
                              ),
                              size: buttonSize,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildMenuCard(
                              context,
                              'Devocional',
                              Icons.auto_stories,
                              gradienteDevocional, // Passando o gradiente
                                  () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const DevocionalList()),
                              ),
                              size: buttonSize,
                            ),
                            const SizedBox(width: 12),
                            _buildMenuCard(
                              context,
                              'Palavra do Dia',
                              Icons.local_fire_department_rounded,
                              gradientePalavraDoDia, // Passando o gradiente
                                  () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const PalavraDoDia()),
                              ),
                              size: buttonSize,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildMenuCard(
                              context,
                              'Áudios',
                              Icons.headphones_outlined, // Ícone mais apropriado para áudios em geral
                              gradienteAudios, // Passando o gradiente
                                  () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AudioScreen()),
                              ),
                              size: buttonSize,
                            ),
                            const SizedBox(width: 12),
                            _buildMenuCard(
                              context,
                              'Apoio',
                              Icons.favorite_border_outlined, // Ícone de apoio/favorito
                              gradienteApoio, // Passando o gradiente
                                  () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const Doacao()),
                              ),
                              size: buttonSize,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40), // Espaço no final para o FAB não cobrir conteúdo
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
      BuildContext context,
      String title,
      IconData iconData,
      List<Color> gradientColors, // Recebe a lista de cores para o gradiente
      VoidCallback onPressed, {
        double? width,
        double? height,
        double? size,
      }) {
    final effectiveWidth = width ?? size ?? 100;
    final effectiveHeight = height ?? size ?? 100;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: effectiveWidth,
        height: effectiveHeight,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9), // Aumentei um pouco a opacidade para melhor leitura
          borderRadius: BorderRadius.circular(12), // Um pouco mais arredondado
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10), // Aumentado um pouco o padding do ícone
              decoration: BoxDecoration(
                  gradient: LinearGradient( // Aplicando o gradiente aqui
                    colors: gradientColors.length >= 2 ? gradientColors : [gradientColors.first, gradientColors.first], // Garante pelo menos 2 cores
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: gradientColors.length == 3 ? [0.0, 0.5, 1.0] : null, // Exemplo de stops para 3 cores
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [ // Sombra sutil no círculo do ícone
                    BoxShadow(
                        color: gradientColors.last.withOpacity(0.5),
                        blurRadius: 5,
                        offset: const Offset(0,2)
                    )
                  ]
              ),
              child: Icon(
                iconData,
                color: Colors.white, // Ícone branco para bom contraste com o gradiente
                size: effectiveWidth * 0.18, // Tamanho do ícone responsivo ao tamanho do botão
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: effectiveWidth * 0.13, // Tamanho da fonte responsivo
                  fontWeight: FontWeight.bold,
                  color: gradientColors.first.computeLuminance() > 0.5 // Escolhe cor do texto baseada na luminância da primeira cor do gradiente
                      ? cinzaEscuro // Se a cor do gradiente for clara, texto escuro
                      : mainColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

