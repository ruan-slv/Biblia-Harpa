/// Define componentes visuais reutilizáveis da interface do aplicativo.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'package:flutter/material.dart';

class BibleVersionMenu extends StatelessWidget {
  final ValueChanged<String> onSelected;

  const BibleVersionMenu({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: Theme.of(context).colorScheme.secondary,
      ),
      onSelected: onSelected,
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem<String>(
            value: "ACF",
            child: Text(
              "Almeida Corrigida Fiel",
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
          ),
          PopupMenuItem<String>(
            value: "NVI",
            child: Text(
              "Nova Versão Internacional",
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
          ),
          PopupMenuItem<String>(
            value: "AA",
            child: Text(
              "Almeida Atualizada",
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
          ),
        ];
      },
    );
  }
}
