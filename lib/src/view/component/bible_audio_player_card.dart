/// Define componentes visuais reutilizáveis da interface do aplicativo.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import '../../model/bible_audio.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class BibleAudioPlayerCard extends StatelessWidget {
  final AudioPlayer audioPlayer;
  final BibleAudioChapter? currentAudioChapter;

  const BibleAudioPlayerCard({
    super.key,
    required this.audioPlayer,
    required this.currentAudioChapter,
  });

  @override
  Widget build(BuildContext context) {
    if (currentAudioChapter == null) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.9),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.9),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            StreamBuilder<PlayerState>(
              stream: audioPlayer.playerStateStream,
              builder: (context, snapshot) {
                final playerState = snapshot.data;
                final processingState = playerState?.processingState;
                final playing = playerState?.playing;
                if (processingState == ProcessingState.loading ||
                    processingState == ProcessingState.buffering) {
                  return CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.secondary,
                  );
                }
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        (playing ?? false)
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                      ),
                      iconSize: 40.0,
                      color: Theme.of(context).colorScheme.secondary,
                      onPressed: () => (playing ?? false)
                          ? audioPlayer.pause()
                          : audioPlayer.play(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.stop_circle_outlined),
                      iconSize: 40.0,
                      color: Theme.of(context).colorScheme.secondary,
                      onPressed: () {
                        audioPlayer.stop();
                        audioPlayer.seek(Duration.zero);
                      },
                    ),
                  ],
                );
              },
            ),
            Expanded(
              child: StreamBuilder<Duration>(
                stream: audioPlayer.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final duration = audioPlayer.duration ?? Duration.zero;
                  return Slider(
                    value: position.inSeconds
                        .clamp(0, duration.inSeconds)
                        .toDouble(),
                    max: duration.inSeconds.toDouble(),
                    onChanged: (value) =>
                        audioPlayer.seek(Duration(seconds: value.toInt())),
                    activeColor: Theme.of(context).colorScheme.secondary,
                    inactiveColor: Colors.grey.withValues(alpha: 0.5),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
