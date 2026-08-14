/// Define componentes visuais reutilizáveis da interface do aplicativo.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'package:flutter/material.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      backgroundColor: colorScheme.surface,
      centerTitle: centerTitle ?? true,
      automaticallyImplyLeading: automaticallyImplyLeading ?? false,
      iconTheme: IconThemeData(
        color: colorScheme.secondary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: colorScheme.secondary,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: actions,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
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
