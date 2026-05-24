import 'package:biblia_e_harpa/src/components/app_bar_component.dart';
import 'package:biblia_e_harpa/src/controllers/font_size_controller.dart';
import 'package:flutter/material.dart';

class PropostasScreen extends StatelessWidget {
  const PropostasScreen({super.key});

  static const String _proposalText = '''
A proposta principal deste aplicativo é oferecer um ambiente amigável para leitura e apoio devocional, sem anúncios e sem produtos pagos que atrapalhem momentos importantes de reflexão, estudo e comunhão.

Este projeto segue com desenvolvimento voluntário, sem rede financeira fixa e sem apoio externo permanente. Ainda assim, a intenção é continuar melhorando o aplicativo de forma responsável, buscando alcançar o máximo possível de pessoas com uma experiência simples, respeitosa e funcional.

As melhorias serão entregues por atualização, sempre com foco em estabilidade, utilidade prática e cuidado com quem utiliza o app no dia a dia. A partir desta atualização de setembro, o número de atualizações anuais será reduzido para uma por ano, evitando sobrecarga no desenvolvimento e permitindo mais atenção à otimização e à segurança, especialmente em aparelhos antigos, que representam parte importante dos usuários.

Este aplicativo também foi desenvolvido como parte de aprendizado e pesquisa por um estudante de Sistemas de Informação, unindo estudo técnico com a intenção de entregar uma ferramenta acessível e útil para o público cristão.
''';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CustomAppBar(
        title: 'Propostas do App',
        centerTitle: false,
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 52,
                          width: 52,
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.lightbulb_outline_rounded,
                            color: colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Direção do projeto',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.secondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Visão geral sobre propósito, manutenção e evolução planejada para o aplicativo.',
                                style: TextStyle(
                                  color: colorScheme.secondary.withValues(alpha: 0.74),
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: ValueListenableBuilder<double>(
                      valueListenable: FontSizeController.fontSizeNotifier,
                      builder: (context, fontSize, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'Proposta',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.secondary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _proposalText,
                              textAlign: TextAlign.justify,
                              style: TextStyle(
                                fontSize: fontSize,
                                color: colorScheme.secondary,
                                height: 1.65,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
