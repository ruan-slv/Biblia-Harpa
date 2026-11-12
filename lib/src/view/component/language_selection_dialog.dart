/// Diálogo de seleção do idioma do aplicativo.
///
/// No primeiro acesso ele não pode ser fechado sem uma escolha. Depois, é
/// reutilizado pela tela de configurações para trocar o idioma a qualquer
/// momento.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/settings_controller.dart';
import '../../l10n/app_localizations.dart';

/// Exibe o diálogo de idioma.
///
/// [firstRun] verdadeiro impede o fechamento sem escolha (primeiro acesso).
Future<void> showLanguageSelectionDialog(
  BuildContext context, {
  bool firstRun = false,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: !firstRun,
    builder: (_) => LanguageSelectionDialog(firstRun: firstRun),
  );
}

class LanguageSelectionDialog extends StatelessWidget {
  const LanguageSelectionDialog({super.key, this.firstRun = false});

  final bool firstRun;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final settings = context.watch<SettingsController>();

    return PopScope(
      canPop: !firstRun,
      child: Dialog(
        backgroundColor: colorScheme.surface,
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440, maxHeight: 620),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 22, 16, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.language_rounded,
                        color: colorScheme.primary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.t('Idioma do aplicativo'),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.t('Escolha o idioma da interface'),
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.35,
                              color: colorScheme.onSurface
                                  .withValues(alpha: 0.72),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!firstRun)
                      IconButton(
                        tooltip: l10n.t('Fechar'),
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.close, color: colorScheme.onSurface),
                      ),
                  ],
                ),
              ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  itemCount: appLanguages.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: colorScheme.onSurface.withValues(alpha: 0.06),
                  ),
                  itemBuilder: (context, index) {
                    final language = appLanguages[index];
                    final selected = language.code == settings.languageCode;
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      selected: selected,
                      selectedTileColor:
                          colorScheme.primaryContainer.withValues(alpha: 0.45),
                      leading: Text(
                        language.flag,
                        style: const TextStyle(fontSize: 26),
                      ),
                      title: Text(
                        language.nativeName,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight:
                              selected ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                      subtitle: language.englishName == language.nativeName
                          ? null
                          : Text(
                              language.englishName,
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.65),
                              ),
                            ),
                      trailing: selected
                          ? Icon(
                              Icons.check_circle_rounded,
                              color: colorScheme.primary,
                            )
                          : null,
                      onTap: () async {
                        await settings.setLanguage(language.code);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 4, 22, 18),
                child: Text(
                  firstRun
                      ? l10n.t(
                          'O aplicativo será exibido no idioma escolhido. Você pode mudar depois nas configurações.',
                        )
                      : l10n.t(
                          'Você pode alterar o idioma a qualquer momento nas configurações.',
                        ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
