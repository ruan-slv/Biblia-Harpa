/// Define componentes visuais reutilizáveis da interface do aplicativo.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import "package:biblia_e_harpa/src/controllers/settings_controller.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";

class ListTileMd extends StatelessWidget {

  final String title;
  final String? subTitle;
  final IconData? icon;
  final VoidCallback? onTap;

  const ListTileMd({super.key, required this.title, this.subTitle, this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.secondary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
          fontSize: settings.fontSize,
        ),
      ),
      subtitle: Text(
        subTitle ?? "",
        style: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
          fontSize: settings.fontSize - 2,
        ),
      ),
      onTap: onTap,
    );
  }
}
