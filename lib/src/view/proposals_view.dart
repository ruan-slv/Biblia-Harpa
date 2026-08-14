/// Implementa a interface e os fluxos de apresentação deste recurso.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;


import 'package:biblia_e_harpa/src/view_model/settings_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'component/app_bar_component.dart';

class ProposalsView extends StatelessWidget {
  const ProposalsView({super.key});

  static const String _proposalText = '''
A proposta principal deste aplicativo é oferecer um ambiente amigável para leitura e apoio devocional, sem anúncios e sem produtos pagos que atrapalhem momentos importantes de reflexão, estudo e comunhão.

Este projeto segue com desenvolvimento voluntário e sem fins lucrativos. Ainda assim, a intenção é continuar melhorando o aplicativo de forma responsável, buscando alcançar o máximo possível de pessoas com uma experiência simples, respeitosa e funcional.

Além do Android, a intenção é fornecer versões multiplataforma (incluindo sistemas de desktop e iOS), tornando a ferramenta disponível onde você preferir estudar.

Para viabilizar essas mudanças de forma sustentável, a frequência de atualizações será organizada em duas edições anuais. Esse equilíbrio entre o tempo de desenvolvimento e a complexidade do app evita a sobrecarga na programação e permite mais atenção à otimização e à segurança, especialmente em aparelhos antigos, que representam 1/3 dos usuários.
''';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final settings = context.watch<SettingsViewModel>();

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
                    child: Column(
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
                            fontSize: settings.fontSize,
                            color: colorScheme.secondary,
                            height: 1.65,
                          ),
                        ),
                      ],
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
