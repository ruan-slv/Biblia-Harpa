import 'package:biblia_e_harpa/src/controllers/theme_controller.dart';
import 'package:flutter/material.dart';

class wallpaperselectionscreen extends StatelessWidget {
  const wallpaperselectionscreen({
    super.key,
    required this.wallpapers,
    required this.onSelect,
  });

  final List<String> wallpapers;
  final Function(String) onSelect;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeNotifier,
      builder: (context, currentTheme, _) {
        final isDark = currentTheme == ThemeMode.dark;

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            centerTitle: true,
            automaticallyImplyLeading: true,
            iconTheme: IconThemeData(
              color: Theme.of(context).colorScheme.secondary,
            ),
            title: Text(
              "Plano de Fundo",
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            actions: [
              IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return RotationTransition(
                      turns: Tween(begin: 0.0, end: 1.0).animate(animation),
                      child: child,
                    );
                  },
                  child: isDark
                      ? const Icon(
                          Icons.sunny,
                          key: Key("sunny"),
                          color: Colors.yellow,
                          size: 30,
                        )
                      : Icon(
                          Icons.brightness_4,
                          key: const Key("moon"),
                          color: Colors.grey[800],
                          size: 30,
                        ),
                ),
                onPressed: () {
                  ThemeController.toggleTheme();
                },
              ),
            ],
          ),
          body: GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.7,
            ),
            itemCount: wallpapers.length,
            itemBuilder: (context, index) {
              final wallpaper = wallpapers[index];
              return GestureDetector(
                onTap: () => onSelect(wallpaper),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: AssetImage(wallpaper),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
