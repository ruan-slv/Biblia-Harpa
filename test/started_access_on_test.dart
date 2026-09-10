import 'package:biblia_e_harpa/src/view/component/started_access_on.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    // Sem valor salvo => primeiro acesso.
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('exibe o cabeçalho, as primeiras opções e as ações',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: StartedAccessOn()),
    );

    expect(find.text('Bem-vindo!'), findsOneWidget);
    expect(find.text('Bíblia ACF'), findsOneWidget);
    expect(find.text('Bíblia NVI'), findsOneWidget);
    expect(find.text('Iniciar download e começar'), findsOneWidget);
    expect(find.text('Pular e usar os arquivos já no app'), findsOneWidget);
  });

  testWidgets('a Bíblia ACF vem selecionada por padrão (obrigatória)',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: StartedAccessOn()),
    );

    // Como a ACF é obrigatória, já começa selecionada => "1 de 9".
    expect(find.text('1 de 9'), findsOneWidget);
    // Itens obrigatórios exibem um cadeado em vez de checkbox.
    expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
  });

  testWidgets('alternar uma opção atualiza a contagem', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: StartedAccessOn()),
    );

    // Por padrão só a ACF (obrigatória) está selecionada.
    expect(find.text('1 de 9'), findsOneWidget);

    // Toca na linha da Harpa para selecioná-la.
    await tester.tap(find.text('Harpa Cristã'));
    await tester.pump();

    expect(find.text('2 de 9'), findsOneWidget);
  });

  testWidgets('"Selecionar todos" marca todas as opções', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: StartedAccessOn()),
    );

    await tester.tap(find.text('Selecionar todos'));
    await tester.pump();

    expect(find.text('9 de 9'), findsOneWidget);
  });

  testWidgets('"Limpar" mantém apenas a obrigatória', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: StartedAccessOn()),
    );

    await tester.tap(find.text('Selecionar todos'));
    await tester.pump();
    await tester.tap(find.text('Limpar'));
    await tester.pump();

    expect(find.text('1 de 9'), findsOneWidget);
  });

  testWidgets('StartupGate mostra o app quando o download já foi feito',
      (tester) async {
    SharedPreferences.setMockInitialValues({'download_done': true});

    await tester.pumpWidget(
      const MaterialApp(
        home: StartupGate(child: Scaffold(body: Text('TELA PRINCIPAL'))),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('TELA PRINCIPAL'), findsOneWidget);
    expect(find.text('Bem-vindo!'), findsNothing);
  });

  testWidgets('StartupGate mostra o popup no primeiro acesso', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const MaterialApp(
        home: StartupGate(child: Scaffold(body: Text('TELA PRINCIPAL'))),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Bem-vindo!'), findsOneWidget);
    expect(find.text('TELA PRINCIPAL'), findsNothing);
  });
}
