/// Define componentes visuais reutilizáveis da interface do aplicativo.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'package:flutter/material.dart';

class SelectionLimitDialog {
  static Future<void> show(BuildContext context) async {
    if (ModalRoute.of(context)?.isCurrent != true) return;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            "Aviso de Limite",
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
          content: Text(
            "Selecionar muitos versículos pode fazer com que o texto seja cortado ao compartilhar em algumas redes sociais. Considere compartilhar a quantidade máxima de versículos e depois realizar um novo compartilhamento com o restante dos versículos desejados!",
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                "Entendi",
                style: TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
