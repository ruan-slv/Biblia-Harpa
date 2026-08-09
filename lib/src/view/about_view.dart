
import 'package:biblia_e_harpa/src/view_model/settings_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'component/app_bar_component.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  static const String _aboutText = '''
Este aplicativo nasceu em dezembro de 2024 e foi publicado na Google Play Store em junho de 2025. Ele foi criado por um estudante de tecnologia que enfrentava interrupções ao usar aplicativos bíblicos em sua rotina, devido ao excesso de anúncios e ofertas de produtos pagos em momentos importantes.

Como forma de contornar essa situação, este app foi desenvolvido para oferecer uma experiência simples, funcional e totalmente gratuita. O foco principal é otimizar os custos de manutenção para garantir um espaço tranquilo, focado exclusivamente na leitura e reflexão de conteúdos sagrados. Por ser um projeto independente e focado na simplicidade, ele conta atualmente com poucas versões da Bíblia e apenas uma opção de áudio.
''';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final settings = context.watch<SettingsViewModel>();

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
