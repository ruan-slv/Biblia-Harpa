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

                return ListTile(
                  leading: IconButton(
                    onPressed: () => viewModel.play(originalIndex),
                    icon: Icon(
                      isCurrent && viewModel.player.playing
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  title: Text(
                    chapter.name,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: settings.fontSize,
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
                                  final path = await viewModel
                                      .prepareShareFilePath(originalIndex);
                                  if (path == null) throw Exception('Sem arquivo');
                                  await SharePlus.instance.share(
                                    ShareParams(
                                      text: 'Ouça este trecho da Bíblia: ${chapter.name} - ${book.title}',
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
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                )
                              : Icon(
                                  Icons.download_outlined,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          _PlayerBar(viewModel: viewModel),
        ],
      ),
    );
  }
}

class _PlayerBar extends StatelessWidget {
  final BibleAudioChaptersViewModel viewModel;
  const _PlayerBar({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final duration = viewModel.audioDuration;
    final position = viewModel.currentPosition;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: viewModel.playPrevious,
                icon: Icon(Icons.skip_previous,
                    color: Theme.of(context).colorScheme.secondary),
              ),
              IconButton(
                onPressed: viewModel.currentIndex == null
                    ? null
                    : () => viewModel.play(viewModel.currentIndex!),
                icon: Icon(
                  viewModel.player.playing ? Icons.pause : Icons.play_arrow,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              IconButton(
                onPressed: viewModel.playNext,
                icon: Icon(Icons.skip_next,
                    color: Theme.of(context).colorScheme.secondary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Slider(
                  value: position.inSeconds
                      .clamp(0, duration.inSeconds)
                      .toDouble(),
                  max: (duration.inSeconds == 0 ? 1 : duration.inSeconds)
                      .toDouble(),
                  onChanged: (value) {
                    viewModel.player.seek(Duration(seconds: value.toInt()));
                  },
                  activeColor: Theme.of(context).colorScheme.secondary,
                  inactiveColor: Colors.grey.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                viewModel.formatDuration(position),
                style: TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
            ],
          ),
          Row(
            children: [
              Icon(Icons.volume_up, color: Theme.of(context).colorScheme.secondary),
              Expanded(
                child: Slider(
                  value: viewModel.volume,
                  max: 1.0,
                  onChanged: viewModel.updateVolume,
                  activeColor: Theme.of(context).colorScheme.secondary,
                  inactiveColor: Colors.grey.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
