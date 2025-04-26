import 'package:biblia_e_harpa/src/config.dart';
import 'package:flutter/material.dart';

class wallpaperselectionscreen extends StatelessWidget {
  const wallpaperselectionscreen(
      {super.key, required this.wallpapers, required this.onSelect});

  final List<String> wallpapers;
  final Function(String) onSelect;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        centerTitle: true,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: brancoNeve),
        title: const Text(
          "Plano de Fundo",
          style: TextStyle(color: brancoNeve),
        ),
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
  }
}
