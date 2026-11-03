/// Tela que apresenta outros projetos do desenvolvedor.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'package:biblia_e_harpa/src/view/component/app_bar_component.dart';
import 'package:biblia_e_harpa/src/view/component/app_section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

/// Projeto exibido na tela "Outros projetos".
class _OtherProject {
  const _OtherProject({
    required this.title,
    required this.description,
    required this.icon,
    required this.envKey,
    required this.fallbackUrl,
  });

  final String title;
  final String description;
  final IconData icon;
  final String envKey;
  final String fallbackUrl;
}

class OtherProjectsView extends StatelessWidget {
  const OtherProjectsView({super.key});

  static const List<_OtherProject> _projects = [
    _OtherProject(
      title: 'Bíblia Lite - sem anúncios',
      description:
          'Uma versão extra leve do aplicativo Bíblia & Harpa com foco em reduzir funcionalidades para alcançar público com dispositivos antigos.',
      icon: Icons.menu_book_rounded,
      envKey: 'BIBLIA_LITE_URL',
      fallbackUrl: 'https://ruan-slv.github.io/biblia-lite/',
    ),
    _OtherProject(
      title: 'Não Informado',
      description:
          'Programa Desktop para o público de utilização do Windows e Linux. Este projeto ainda não será divulgado pois está em desenvolvimento sem previsões de conclusão.',
      //description: 'Organize a rotina da sua igreja: escalas, avisos, finanças e muito mais em um só lugar.',
      icon: Icons.church_rounded,
      envKey: 'CONTROLDESK_CHURCH_URL',
      fallbackUrl: 'https://ruan-slv.github.io/controlldesk/',
    ),
  ];

  String _resolveUrl(_OtherProject project) {
    final value = dotenv.env[project.envKey]?.trim();
    return (value == null || value.isEmpty) ? project.fallbackUrl : value;
  }

  Future<void> _open(BuildContext context, _OtherProject project) async {
    final url = _resolveUrl(project);
    try {
      if (!await launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication)) {
        throw Exception('link inválido');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Não foi possível abrir o link: $e'),
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
        title: 'Outros projetos',
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
                label: const Text('Visitar'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}
