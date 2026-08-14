/// Implementa a interface e os fluxos de apresentação deste recurso.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'package:biblia_e_harpa/src/view/component/app_bar_component.dart';
import 'package:biblia_e_harpa/src/view_model/settings_view_model.dart';
import 'package:biblia_e_harpa/src/model/bible_audio.dart';
import 'package:biblia_e_harpa/src/view_model/audio_book_chapters_view_model.dart';
import 'package:biblia_e_harpa/src/view/component/feature_search_field.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class BibleAudioChaptersView extends StatelessWidget {
  final BibleAudioBook book;
  const BibleAudioChaptersView({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BibleAudioChaptersViewModel>(
      create: (_) => BibleAudioChaptersViewModel(book: book),
      child: _AudioBookChaptersView(book: book),
    );
  }
}

class _AudioBookChaptersView extends StatelessWidget {
  final BibleAudioBook book;
  const _AudioBookChaptersView({required this.book});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BibleAudioChaptersViewModel>();
    final settings = context.watch<SettingsViewModel>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(
        title: book.title,
        centerTitle: false,
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FeatureSearchField(
              hintText: "Pesquisar capítulo",
              onChanged: viewModel.setQuery,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: viewModel.filteredChapters.length,
              itemBuilder: (context, index) {
                final chapter = viewModel.filteredChapters[index];
                final originalIndex = book.chapters.indexOf(chapter);
                final isCurrent = viewModel.currentIndex == originalIndex;
                final isDownloading = viewModel.isDownloading[originalIndex] == true;
                final isDownloaded = viewModel.downloadedChapters.contains(originalIndex);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  color: isCurrent ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5) : null,
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        leading: IconButton(
                          onPressed: () => viewModel.play(originalIndex),
                          icon: Icon(
                            isCurrent && viewModel.player.playing
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_filled,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        onTap: () => viewModel.play(originalIndex),
                        title: Text(
                          chapter.name,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: settings.fontSize,
                            fontWeight: isCurrent ? FontWeight.bold : null,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: "Compartilhar",
                              onPressed: kIsWeb
                                  ? null
                                  : () async {
                                      try {
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Preparando áudio para compartilhar...',
                                            ),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                        final path = await viewModel.prepareShareFilePath(originalIndex);
                                        if (path == null) throw Exception('Sem arquivo');
                                        await SharePlus.instance.share(
                                          ShareParams(
                                            text: 'Ouça este trecho da Bíblia: ${chapter.name} - ${book.title}',
                                            files: [
                                              XFile(path),
                                            ],
                                          ),
                                        );
                                      } catch (_) {
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Não foi possível compartilhar o áudio.",
                                            ),
                                          ),
                                        );
                                      }
                                    },
                              icon: Icon(
                                Icons.share_outlined,
                                color: Theme.of(context).colorScheme.secondary,
                                size: 20,
                              ),
                            ),
                            if (isDownloaded)
                              IconButton(
                                tooltip: "Remover",
                                onPressed: kIsWeb
                                    ? null
                                    : () async {
                                        final ok = await viewModel.delete(originalIndex);
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              ok
                                                  ? 'Áudio removido do dispositivo.'
                                                  : 'Não foi possível remover o áudio.',
                                            ),
                                          ),
                                        );
                                      },
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: Theme.of(context).colorScheme.secondary,
                                  size: 20,
                                ),
                              )
                            else
                              IconButton(
                                tooltip: "Baixar",
                                onPressed: kIsWeb || isDownloading
                                    ? null
                                    : () async {
                                        final ok = await viewModel.download(originalIndex);
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              ok
                                                  ? '${chapter.name} baixado com sucesso!'
                                                  : 'Erro ao baixar o áudio.',
                                            ),
                                          ),
                                        );
                                      },
                                icon: isDownloading
                                    ? SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Theme.of(context).colorScheme.secondary,
                                        ),
                                      )
                                    : Icon(
                                        Icons.download_outlined,
                                        color: Theme.of(context).colorScheme.secondary,
                                        size: 20,
                                      ),
                              ),
                          ],
                        ),
                      ),
                      if (isCurrent) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              Slider(
                                value: viewModel.currentPosition.inSeconds.toDouble(),
                                max: viewModel.audioDuration.inSeconds > 0 ? viewModel.audioDuration.inSeconds.toDouble() : 1.0,
                                onChanged: (value) => viewModel.player.seek(Duration(seconds: value.toInt())),
                                activeColor: Theme.of(context).colorScheme.secondary,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    viewModel.formatDuration(viewModel.currentPosition),
                                    style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 12),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.replay_10),
                                        color: Theme.of(context).colorScheme.secondary,
                                        onPressed: () => viewModel.player.seek(Duration(seconds: viewModel.currentPosition.inSeconds - 10)),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          viewModel.player.playing ? Icons.pause_circle_filled : Icons.play_circle_filled,
                                        ),
                                        iconSize: 40,
                                        color: Theme.of(context).colorScheme.secondary,
                                        onPressed: () => viewModel.player.playing ? viewModel.player.pause() : viewModel.player.play(),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.forward_10),
                                        color: Theme.of(context).colorScheme.secondary,
                                        onPressed: () => viewModel.player.seek(Duration(seconds: viewModel.currentPosition.inSeconds + 10)),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    viewModel.formatDuration(viewModel.audioDuration),
                                    style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
