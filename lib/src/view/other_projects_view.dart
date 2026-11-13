/// Tela que apresenta outros projetos do desenvolvedor.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'package:biblia_e_harpa/src/view/component/app_bar_component.dart';
import 'package:biblia_e_harpa/src/view/component/app_section_card.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../utils/app_links.dart';

/// Projeto exibido na tela "Outros projetos".
class _OtherProject {
  const _OtherProject({
    required this.title,
    required this.description,
    required this.icon,
    required this.envKey,
  });

  final String title;
  final String description;
  final IconData icon;
  final String envKey;
}

class OtherProjectsView extends StatelessWidget {
  const OtherProjectsView({super.key});

  List<_OtherProject> get _projects => [
        _OtherProject(
          title: tr('Bíblia Lite - sem anúncios'),
          description: tr(
              'Uma versão extra leve do aplicativo Bíblia & Harpa com foco em reduzir funcionalidades para alcançar público com dispositivos antigos.'),
          icon: Icons.menu_book_rounded,
          envKey: 'BIBLIA_LITE_URL',
        ),
        _OtherProject(
          title: tr('Não Informado'),
          description: tr(
              'Programa Desktop para o público de utilização do Windows e Linux. Este projeto ainda não será divulgado pois está em desenvolvimento sem previsões de conclusão.'),
          //description: 'Organize a rotina da sua igreja: escalas, avisos, finanças e muito mais em um só lugar.',
          icon: Icons.church_rounded,
          envKey: 'CONTROLDESK_CHURCH_URL',
        ),
      ];

  Future<void> _open(BuildContext context, _OtherProject project) async {
    try {
      await AppLinks.load();
      final url = AppLinks.requireUri(project.envKey);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('link inválido');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                tr('Não foi possível abrir o link: {error}', {'error': '$e'})),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: context.l10n.t('Outros projetos'),
        centerTitle: false,
        automaticallyImplyLeading: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        children: [
          for (final project in _projects) ...[
            AppSectionCard(
              icon: project.icon,
              title: project.title,
              subtitle: project.description,
              child: ElevatedButton.icon(
                onPressed: () => _open(context, project),
                icon: const Icon(Icons.open_in_new_rounded),
                label: Text(context.l10n.t('Visitar')),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}
