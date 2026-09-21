/// Define componentes visuais reutilizáveis da interface do aplicativo.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'package:flutter/material.dart';
import 'bible_version_selector_dialog.dart';

class BibleVersionMenu extends StatelessWidget {
  final String currentVersionKey;
  final ValueChanged<String> onSelected;

  const BibleVersionMenu({
    super.key,
    required this.currentVersionKey,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: Theme.of(context).colorScheme.secondary,
      ),
      onSelected: (String value) async {
        if (value == 'SELECT_VERSION') {
          await showDialog(
            context: context,
            builder: (context) => BibleVersionSelectorDialog(
              currentVersionKey: currentVersionKey,
              onSelected: (version) {
                onSelected(version.key);
              },
            ),
          );
        } else {
          onSelected(value);
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem<String>(
            value: "SELECT_VERSION",
            child: Row(
              children: [
                Icon(Icons.translate, color: Theme.of(context).colorScheme.secondary),
                SizedBox(width: 8),
                Text(
                  "Selecionar versão",
                  style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: "ACF",
            child: Row(
              children: [
                Text("🇧🇷", style: TextStyle(fontSize: 16)),
                SizedBox(width: 8),
                Text(
                  "Almeida Corrigida Fiel",
                  style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: "NVI",
            child: Row(
              children: [
                Text("🇧🇷", style: TextStyle(fontSize: 16)),
                SizedBox(width: 8),
                Text(
                  "Nova Versão Internacional",
                  style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: "AA",
            child: Row(
              children: [
                Text("🇧🇷", style: TextStyle(fontSize: 16)),
                SizedBox(width: 8),
                Text(
                  "Almeida Atualizada",
                  style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: "KJV",
            child: Row(
              children: [
                Text("🇬🇧", style: TextStyle(fontSize: 16)),
                SizedBox(width: 8),
                Text(
                  "King James Version",
                  style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: "RVR",
            child: Row(
              children: [
                Text("🇪🇸", style: TextStyle(fontSize: 16)),
                SizedBox(width: 8),
                Text(
                  "Reina-Valera (Español)",
                  style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
              ],
            ),
          ),
        ];
      },
    );
  }
}
