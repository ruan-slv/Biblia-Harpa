import 'package:biblia_e_harpa/src/controllers/fontSizeController.dart';
import 'package:flutter/material.dart';

class TransparenciaScreen extends StatelessWidget {
  const TransparenciaScreen({super.key});

  final _transparencyPolicy = '''
No Bíblia & Harpa, acreditamos que a fé se expressa também por meio de ações concretas. Por isso, além de oferecer conteúdo bíblico de qualidade, destinamos parte dos recursos recebidos para ajudar quem mais precisa.

Divisão dos valores recebidos:

- Contribuição Social: 30%
  Doações de alimentos, roupas, apoio a instituições e ações comunitárias.

- Desenvolvedor: 25%
  Remuneração pelo trabalho de criação, manutenção e suporte do app.

- Terceiros e Prestadores: 15%
  Pagamento de serviços como design, programação, atendimento, etc.

- Crescimento do App: 30%
  Investimentos em tráfego pago, divulgação, melhorias e expansão geral.

Esses percentuais podem variar conforme campanhas específicas ou necessidades emergenciais, mas sempre com prestação de contas clara.
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        automaticallyImplyLeading: true,
        title: Text("Transparência",
            style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(20.0),
        child: SingleChildScrollView(
          child: ValueListenableBuilder<double>(
            valueListenable: FontSizeController.fontSizeNotifier,
            builder: (context, fontSize, _) {
              return Text(
                _transparencyPolicy,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: fontSize,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
