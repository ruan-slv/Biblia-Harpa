/// View para seleção e download de conteúdos da Bíblia e Harpa.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'package:biblia_e_harpa/src/controllers/download_manager_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DownloadSelectionView extends StatelessWidget {
  const DownloadSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecionar Conteúdo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_done),
            onPressed: () {
              final downloadManager = context.read<DownloadManagerController>();
              final nvi = downloadManager.bibleVersions
                  .firstWhere((v) => v.key == 'pt_nvi');
              final harp = downloadManager.contentItems
                  .firstWhere((c) => c.key == 'harpa_crista_640_hinos');
              downloadManager.downloadFile(nvi);
              downloadManager.downloadFile(harp);
            },
            tooltip: 'Download recomendado (NVI + Harpa)',
          ),
        ],
      ),
      body: _DownloadSelectionContent(),
    );
  }
}

class _DownloadSelectionContent extends StatelessWidget {
  const _DownloadSelectionContent();

  String _getFlagEmoji(String language) {
    switch (language) {
      case 'Arabic':
        return '🇸🇦';
      case 'Chinese':
        return '🇨🇳';
      case 'German':
        return '🇩🇪';
      case 'Greek':
        return '🇬🇷';
      case 'English':
        return '🇬🇧';
      case 'Esperanto':
        return '🌍';
      case 'Spanish':
        return '🇪🇸';
      case 'Finnish':
        return '🇫🇮';
      case 'French':
        return '🇫🇷';
      case 'Korean':
        return '🇰🇷';
      case 'Portuguese':
        return '🇧🇷';
      case 'Romanian':
        return '🇷🇴';
      case 'Russian':
        return '🇷🇺';
      case 'Vietnamese':
        return '🇻🇳';
      default:
        return '🌐';
    }
  }

  @override
  Widget build(BuildContext context) {
    final downloadManager = context.watch<DownloadManagerController>();

    if (!downloadManager.isLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(title: '📖 Versões da Bíblia'),
            ...downloadManager.bibleVersions.map((version) {
              return _DownloadItemCard(
                item: version,
                flag: _getFlagEmoji(version.language),
                downloadManager: downloadManager,
              );
            }),
            const SizedBox(height: 24),
            _SectionHeader(title: '🎵 Áudios'),
            ...downloadManager.audios.map((audio) {
              return _DownloadItemCard(
                item: audio,
                flag: '🎧',
                downloadManager: downloadManager,
              );
            }),
            const SizedBox(height: 24),
            _SectionHeader(title: '📚 Outros Conteúdos'),
            ...downloadManager.contentItems.map((content) {
              String flag = '📄';
              if (content.type == 'harp') flag = '🎶';
              if (content.type == 'devotional') flag = '📖';
              if (content.type == 'quiz') flag = '❓';
              if (content.type == 'daily_word') flag = '☀️';
              return _DownloadItemCard(
                item: content,
                flag: flag,
                downloadManager: downloadManager,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _DownloadItemCard extends StatelessWidget {
  final DownloadItem item;
  final String flag;
  final DownloadManagerController downloadManager;

  const _DownloadItemCard({
    required this.item,
    required this.flag,
    required this.downloadManager,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: Text(flag, style: const TextStyle(fontSize: 24)),
        title: Text(item.name),
        subtitle: Text(item.language),
        trailing: IconButton(
          icon: const Icon(Icons.download),
          onPressed: () {
            downloadManager.downloadFile(item);
          },
        ),
      ),
    );
  }
}