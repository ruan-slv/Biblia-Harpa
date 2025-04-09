import 'package:biblia_e_harpa/src/config.dart';
import 'package:biblia_e_harpa/src/content/doacao.dart';
import 'package:biblia_e_harpa/src/devocional/devocional.dart';
import 'package:biblia_e_harpa/src/sizelist/biblelist.dart';
import 'package:biblia_e_harpa/src/sizelist/harpalist.dart';
import 'package:flutter/material.dart';

class Initial extends StatelessWidget {
  const Initial({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive sizing
    final screenSize = MediaQuery.of(context).size;
    // Reduced button size to 30% of screen width (smaller than before)
    final buttonSize = screenSize.width * 0.30;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fotoleaologo.jpg'),
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
    required double size,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
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