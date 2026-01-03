import 'package:flutter/material.dart';
import '../config.dart'; // Importa as constantes de cores e tamanhos

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool? centerTitle;
  final List<Widget>? actions;
  final bool? automaticallyImplyLeading;
  final PreferredSizeWidget? tabBar;

  const CustomAppBar(
      {super.key,
      required this.title,
      this.centerTitle,
      this.actions,
      this.automaticallyImplyLeading,
      this.tabBar});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      centerTitle: centerTitle ?? false,
      automaticallyImplyLeading: automaticallyImplyLeading ?? false,
      iconTheme: IconThemeData(
        color: Theme.of(context).colorScheme.secondary,
      ),
      title: Text(
        title,
        style: TextStyle(color: Theme.of(context).colorScheme.secondary),
      ),
      actions: actions,
      bottom: tabBar,
    );
  }

  @override
  Size get preferredSize {
    double height = kToolbarHeight;
    if (tabBar != null) {
      height += tabBar!.preferredSize.height;
    }
    return Size.fromHeight(height);
  }
}
