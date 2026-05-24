import 'package:biblia_e_harpa/src/components/app_bar_component.dart';
import 'package:biblia_e_harpa/src/controllers/font_size_controller.dart';
import 'package:flutter/material.dart';

class Aboutprojectscreen extends StatelessWidget {
  const Aboutprojectscreen({super.key});

  static const String _aboutText = '''
Este app surgiu em dezembro de 2024 e publicado na playstore em junho de 2025, criado por um estudante de tecnologia que frequentemente enfrentava problemas ao utilizar aplicativos biblicos durante a rotina por conta de muitos anúncios e produtos pagos que chegavam em momentos importantes.

Como forma de contornar esta situação foi criado este app, onde foi pensado em fornecer um executável com diversas ferramentas improvisadas a fim de reduzir custo e permitir que seja disponibilizado um aplicativo sincero, onde possuem poucas versões de bíblia e somente uma versão de áudio entre outros, porém disponibilizando ao mesmo tempo um ambiente onde é prezado pelo momento de leitura de conteúdos sagrados.

Nesta atualização de Abril será removida a área de doações, pois com muito esforço e apoio de outros usuários deste aplicativo, conseguimos cobrir o custo ao decorrer deste projeto e o desenvolvimento será continuado de forma voluntária.

Este é um aplicativo simples, mas entregue de coração ao evangelho de Deus.

Somente um aviso: Nem todas as sugestões dadas pelos usuários serão possível inserir no app, mas faremos o melhor possível para que gostem deste projeto. Amém!
''';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CustomAppBar(
        title: 'Sobre o App',
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
                            Icons.auto_stories_rounded,
                            color: colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'História do projeto',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.secondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Contexto, propósito e direção do aplicativo dentro da proposta geral do projeto.',
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
                                'Apresentação',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.secondary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _aboutText,
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
