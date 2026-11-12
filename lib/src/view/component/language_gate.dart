/// Porta de entrada do idioma do aplicativo.
///
/// Depois que as preferências terminam de carregar, exibe o diálogo de idioma
/// no primeiro acesso. A escolha fica salva em SharedPreferences, então nas
/// próximas aberturas o diálogo não aparece novamente.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/settings_controller.dart';
import 'language_selection_dialog.dart';

class LanguageGate extends StatefulWidget {
  const LanguageGate({super.key, required this.child});

  final Widget child;

  @override
  State<LanguageGate> createState() => _LanguageGateState();
}

class _LanguageGateState extends State<LanguageGate> {
  bool _scheduled = false;

  void _scheduleDialog() {
    if (_scheduled) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await showLanguageSelectionDialog(context, firstRun: true);
      _scheduled = false;
      if (!mounted) return;
      // Se algo fechou o diálogo sem escolher (ex.: botão voltar em versões
      // antigas do Android), agenda novamente para não deixar o app sem
      // idioma definido.
      if (!context.read<SettingsController>().hasSelectedLanguage) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    if (settings.initialized && !settings.hasSelectedLanguage) {
      _scheduleDialog();
    }
    return widget.child;
  }
}
