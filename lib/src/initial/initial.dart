import 'package:biblia_e_harpa/screens/playlistScreen.dart';
import 'package:biblia_e_harpa/src/config.dart';
import 'package:biblia_e_harpa/src/content/doacao.dart';
import 'package:biblia_e_harpa/src/devocional/devocional.dart';
import 'package:biblia_e_harpa/src/sizelist/biblelist.dart';
import 'package:biblia_e_harpa/src/sizelist/harpalist.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:biblia_e_harpa/src/initial/wallpaperSelectionScreen.dart';

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
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive sizing
    final screenSize = MediaQuery.of(context).size;
    // Button size for regular buttons (30% of screen width)
    final buttonSize = screenSize.width * 0.30;
    // Button width for the "Músicas" button (width of two buttons + spacing)
    final musicButtonWidth = 2 * buttonSize + 12; // Two buttons + 12px spacing

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
            image: backgroundImagePath != null
                ? AssetImage(backgroundImagePath!)
                : const AssetImage('assets/images/Wall paperss.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black45,
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenSize.height - MediaQuery.of(context).padding.top,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  // App logo
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
                  // Restored tagline
                  const Text(
                    "Sua jornada espiritual diária",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                      shadows: [Shadow(blurRadius: 4.0, color: Colors.black54)],
                    ),
                  ),
                  const SizedBox(height: 70),
                  // Menu grid with smaller buttons
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
                              amberColor,
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
                              indigoColor,
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
                              tealColor,
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const DevocionalScreen()),
                              ),
                              size: buttonSize,
                            ),
                            const SizedBox(width: 12),
                            _buildMenuCard(
                              context,
                              'Doação',
                              Icons.favorite,
                              Colors.red.shade700,
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const Doacao()),
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
                              'Músicas',
                              Icons.music_note_outlined,
                              Colors.deepOrange,
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const PlaylistScreen()),
                              ),
                              width: musicButtonWidth, // Largura de dois botões + espaçamento
                              height: buttonSize, // Mesma altura dos outros botões
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
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
    IconData icon,
    Color color,
    VoidCallback onPressed, {
    double? width,
    double? height,
    double? size,
  }) {
    final effectiveWidth = width ?? size ?? 100; // Usa width, senão size, senão valor padrão
    final effectiveHeight = height ?? size ?? 100; // Usa height, senão size, senão valor padrão

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: effectiveWidth,
        height: effectiveHeight,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center, // Centraliza o conteúdo
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}