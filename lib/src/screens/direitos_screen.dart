import 'package:biblia_e_harpa/src/components/app_bar_component.dart';
import 'package:biblia_e_harpa/src/controllers/font_size_controller.dart';
import 'package:flutter/material.dart';

class DireitosScreen extends StatelessWidget {
  const DireitosScreen({super.key});

  static const String _rightsText = '''
As traduções bíblicas deste projeto são de autoria e propriedade intelectual da: Sociedade Bíblica Internacional (NVI); Sociedade Bíblica Trinitariana (ACF); Imprensa Bíblica Brasileira (AA)
Todos os direitos reservados aos autores.
''';
  
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CustomAppBar(
        title: 'Direitos Autorais',
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
                            Icons.gavel_rounded,
                            color: colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Uso de traduções bíblicas',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.secondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Informações sobre autoria e propriedade intelectual das versões utilizadas no aplicativo.',
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
                                'Declaração',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.secondary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _rightsText,
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
