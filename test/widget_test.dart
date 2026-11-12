// Testes da porta de entrada do idioma do aplicativo.
//
// O diálogo aparece somente no primeiro acesso e a escolha fica salva em
// SharedPreferences.

import 'package:biblia_e_harpa/src/controllers/settings_controller.dart';
import 'package:biblia_e_harpa/src/view/component/language_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _buildApp(SettingsController settings) {
  return ChangeNotifierProvider<SettingsController>.value(
    value: settings,
    child: const MaterialApp(
      home: LanguageGate(
        child: Scaffold(body: Text('TELA PRINCIPAL')),
      ),
    ),
  );
}

void main() {
  testWidgets('mostra o seletor de idioma no primeiro acesso', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final settings = SettingsController();
    await settings.initialize();

    await tester.pumpWidget(_buildApp(settings));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Idioma do aplicativo'), findsOneWidget);
    expect(find.text('Português (Brasil)'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Русский'),
      120,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Русский'), findsOneWidget);

    await tester.tap(find.text('Русский'));
    await tester.pumpAndSettle();

    expect(settings.languageCode, 'ru');
    expect(settings.hasSelectedLanguage, isTrue);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('selectedVersion'), 'ru_synodal.json');

    expect(find.text('Idioma do aplicativo'), findsNothing);
    expect(find.text('TELA PRINCIPAL'), findsOneWidget);
  });

  testWidgets('não mostra o seletor quando o idioma já foi escolhido',
      (tester) async {
    SharedPreferences.setMockInitialValues({'app_language': 'es'});
    final settings = SettingsController();
    await settings.initialize();

    await tester.pumpWidget(_buildApp(settings));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Idioma do aplicativo'), findsNothing);
    expect(find.text('TELA PRINCIPAL'), findsOneWidget);
  });
}
