import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../services/app_audio_handler.dart';

/// Chave do Navigator raiz, usada pelo mini-player (que fica acima das rotas)
/// para abrir a folha de "tocando agora".
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

/// Indicador persistente de "tocando agora".
///
/// Fica fora do Navigator (via `MaterialApp.builder`), portanto aparece em
/// qualquer tela e sobrevive à navegação. Tocar no cartão abre os controles
/// completos.
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppAudioHandler?>(
      valueListenable: audioHandlerChanges,
      builder: (context, handler, _) {
        if (handler == null) return const SizedBox.shrink();

        return ValueListenableBuilder<AppAudioTrack?>(
          valueListenable: handler.currentTrack,
          builder: (context, track, _) {
            if (track == null) return const SizedBox.shrink();
            return _MiniPlayerBar(handler: handler, track: track);
          },
        );
      },
    );
  }
}

class _MiniPlayerBar extends StatelessWidget {
  const _MiniPlayerBar({required this.handler, required this.track});

  final AppAudioHandler handler;
  final AppAudioTrack track;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHighest,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: InkWell(
          onTap: () => _showNowPlaying(context),
          child: StreamBuilder<PlayerState>(
            stream: sharedAudioPlayer.playerStateStream,
            initialData: sharedAudioPlayer.playerState,
            builder: (context, snapshot) {
              final state = snapshot.data;
              final playing = state?.playing ?? false;
              final loading =
                  state?.processingState == ProcessingState.loading ||
                      state?.processingState == ProcessingState.buffering;

              return SizedBox(
                height: 64,
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.music_note_rounded,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            track.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color:
                                  colorScheme.onSurface.withValues(alpha: .7),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _ProgressLine(colorScheme: colorScheme),
                        ],
                      ),
                    ),
                    if (loading)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    else
                      IconButton(
                        icon: Icon(
                          playing
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                        ),
                        iconSize: 34,
                        color: colorScheme.primary,
                        onPressed: () =>
                            playing ? handler.pause() : handler.play(),
                      ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      color: colorScheme.onSurface,
                      onPressed: handler.stop,
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showNowPlaying(BuildContext context) {
    final navigatorContext = appNavigatorKey.currentContext;
    if (navigatorContext == null) return;

    showModalBottomSheet<void>(
      context: navigatorContext,
      showDragHandle: true,
      backgroundColor: Theme.of(navigatorContext).colorScheme.surface,
      builder: (_) => _NowPlayingSheet(handler: handler),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: sharedAudioPlayer.positionStream,
      initialData: sharedAudioPlayer.position,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final duration = sharedAudioPlayer.duration ?? Duration.zero;
        final max = duration.inMilliseconds.toDouble();
        final value = max <= 0
            ? 0.0
            : position.inMilliseconds
                .clamp(0, duration.inMilliseconds)
                .toDouble();

        return ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: max <= 0 ? null : value / max,
            minHeight: 3,
            backgroundColor: colorScheme.onSurface.withValues(alpha: .12),
            color: colorScheme.primary,
          ),
        );
      },
    );
  }
}

class _NowPlayingSheet extends StatelessWidget {
  const _NowPlayingSheet({required this.handler});

  final AppAudioHandler handler;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder<PlayerState>(
      stream: sharedAudioPlayer.playerStateStream,
      initialData: sharedAudioPlayer.playerState,
      builder: (context, snapshot) {
        final state = snapshot.data;
        final playing = state?.playing ?? false;

        return ValueListenableBuilder<AppAudioTrack?>(
          valueListenable: handler.currentTrack,
          builder: (context, track, _) {
            if (track == null) return const SizedBox.shrink();

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Icon(
                        Icons.music_note_rounded,
                        size: 48,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      track.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      track.artist,
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: .7),
                      ),
                    ),
                    if (handler.trackCount > 1) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Faixa ${handler.currentIndex + 1} de ${handler.trackCount}',
                        style: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: .55),
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    StreamBuilder<Duration>(
                      stream: sharedAudioPlayer.positionStream,
                      initialData: sharedAudioPlayer.position,
                      builder: (context, positionSnapshot) {
                        final position = positionSnapshot.data ?? Duration.zero;
                        final duration =
                            sharedAudioPlayer.duration ?? Duration.zero;
                        return Column(
                          children: [
                            Slider(
                              value: position.inMilliseconds
                                  .clamp(0, duration.inMilliseconds)
                                  .toDouble(),
                              max: duration.inMilliseconds > 0
                                  ? duration.inMilliseconds.toDouble()
                                  : 1,
                              onChanged: duration.inMilliseconds <= 0
                                  ? null
                                  : (value) => handler.seek(
                                        Duration(milliseconds: value.toInt()),
                                      ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_format(position)),
                                Text(_format(duration)),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          tooltip: 'Anterior',
                          iconSize: 34,
                          onPressed: handler.skipToPrevious,
                          icon: const Icon(Icons.skip_previous_rounded),
                        ),
                        IconButton(
                          tooltip: 'Voltar 10s',
                          iconSize: 28,
                          onPressed: () {
                            final target = sharedAudioPlayer.position -
                                const Duration(seconds: 10);
                            handler.seek(target < Duration.zero
                                ? Duration.zero
                                : target);
                          },
                          icon: const Icon(Icons.replay_10_rounded),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          tooltip: playing ? 'Pausar' : 'Reproduzir',
                          iconSize: 42,
                          onPressed: () =>
                              playing ? handler.pause() : handler.play(),
                          icon: Icon(
                            playing
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: 'Avançar 10s',
                          iconSize: 28,
                          onPressed: () => handler.seek(
                            sharedAudioPlayer.position +
                                const Duration(seconds: 10),
                          ),
                          icon: const Icon(Icons.forward_10_rounded),
                        ),
                        IconButton(
                          tooltip: 'Próximo',
                          iconSize: 34,
                          onPressed: handler.skipToNext,
                          icon: const Icon(Icons.skip_next_rounded),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _format(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(duration.inMinutes.remainder(60))}:'
        '${twoDigits(duration.inSeconds.remainder(60))}';
  }
}
