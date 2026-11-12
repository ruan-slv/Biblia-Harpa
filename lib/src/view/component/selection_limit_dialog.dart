/// Define componentes visuais reutilizáveis da interface do aplicativo.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class SelectionLimitDialog {
  static Future<void> show(BuildContext context) async {
    if (ModalRoute.of(context)?.isCurrent != true) return;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            context.l10n.t("Aviso de Limite"),
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          content: Text(
            context.l10n.t(
                "Selecionar muitos versículos pode fazer com que o texto seja cortado ao compartilhar em algumas redes sociais. Considere compartilhar a quantidade máxima de versículos e depois realizar um novo compartilhamento com o restante dos versículos desejados!"),
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                context.l10n.t("Entendi"),
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
