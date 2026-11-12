/// Implementa a interface de monitoramento e controle de tarefas em segundo plano.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../controllers/settings_controller.dart';
import '../services/app_audio_handler.dart';
import '../l10n/app_localizations.dart';
import 'component/app_section_card.dart';
import 'home_audio_view.dart';

class BackgroundTasksView extends StatelessWidget {
  const BackgroundTasksView({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppAudioHandler?>(
      valueListenable: audioHandlerChanges,
      builder: (context, handler, _) {
        return ValueListenableBuilder<AppAudioTrack?>(
          valueListenable: handler?.currentTrack ?? ValueNotifier(null),
          builder: (context, track, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (handler != null && track != null)
                    _ActiveAudioPlayerCard(
                      handler: handler,
                      track: track,
                    )
                  else
                    _EmptyAudioExecutionCard(),
                  const SizedBox(height: 16),
                  const _BackgroundServicesCard(),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// Card de reprodução ativa com todos os controles do player global.
class _ActiveAudioPlayerCard extends StatelessWidget {
  const _ActiveAudioPlayerCard({
    required this.handler,
    required this.track,
  });

  final AppAudioHandler handler;
  final AppAudioTrack track;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder<PlayerState>(
      stream: sharedAudioPlayer.playerStateStream,
      initialData: sharedAudioPlayer.playerState,
      builder: (context, snapshot) {
        final state = snapshot.data;
        final playing = state?.playing ?? false;
        final loading = state?.processingState == ProcessingState.loading ||
            state?.processingState == ProcessingState.buffering;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cabeçalho do card: Status + Botão de Encerrar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: playing
                            ? colorScheme.primaryContainer
                            : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            playing
                                ? Icons.graphic_eq_rounded
                                : Icons.pause_circle_outline_rounded,
                            size: 16,
                            color: playing
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            playing
                                ? context.l10n.t('Em reprodução')
                                : context.l10n.t('Pausado'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: playing
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: context.l10n.t('Encerrar áudio'),
                      icon: const Icon(Icons.close_rounded),
                      color: colorScheme.onSurfaceVariant,
                      onPressed: () => handler.stop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Ícone e Detalhes da Faixa
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primaryContainer,
                            colorScheme.secondaryContainer,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.music_note_rounded,
                        size: 32,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            track.artist,
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (handler.trackCount > 1) ...[
                            const SizedBox(height: 2),
                            Text(
                              context.l10n.t(
                                  'Faixa {current} de {total}',
                                  {
                                    'current': '${handler.currentIndex + 1}',
                                    'total': '${handler.trackCount}',
                                  }),
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Barra de progresso com Slider
                StreamBuilder<Duration>(
                  stream: sharedAudioPlayer.positionStream,
                  initialData: sharedAudioPlayer.position,
                  builder: (context, positionSnapshot) {
                    final position = positionSnapshot.data ?? Duration.zero;
                    final duration =
                        sharedAudioPlayer.duration ?? Duration.zero;
                    final max = duration.inMilliseconds > 0
                        ? duration.inMilliseconds.toDouble()
                        : 1.0;
                    final current = position.inMilliseconds
                        .clamp(0, duration.inMilliseconds)
                        .toDouble();

                    return Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 4,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6,
                            ),
                          ),
                          child: Slider(
                            value: current,
                            max: max,
                            onChanged: duration.inMilliseconds <= 0
                                ? null
                                : (value) => handler.seek(
                                      Duration(milliseconds: value.toInt()),
                                    ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(position),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                              Text(
                                _formatDuration(duration),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Controles de reprodução
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      tooltip: context.l10n.t('Anterior'),
                      iconSize: 32,
                      icon: const Icon(Icons.skip_previous_rounded),
                      onPressed: handler.skipToPrevious,
                    ),
                    IconButton(
                      tooltip: context.l10n.t('Voltar 10s'),
                      iconSize: 26,
                      icon: const Icon(Icons.replay_10_rounded),
                      onPressed: () {
                        final target = sharedAudioPlayer.position -
                            const Duration(seconds: 10);
                        handler.seek(
                          target < Duration.zero ? Duration.zero : target,
                        );
                      },
                    ),
                    if (loading)
                      const SizedBox(
                        width: 56,
                        height: 56,
                        child: Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          ),
                        ),
                      )
                    else
                      IconButton.filled(
                        tooltip: playing
                            ? context.l10n.t('Pausar')
                            : context.l10n.t('Reproduzir'),
                        iconSize: 36,
                        icon: Icon(
                          playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                        ),
                        onPressed: () =>
                            playing ? handler.pause() : handler.play(),
                      ),
                    IconButton(
                      tooltip: context.l10n.t('Avançar 10s'),
                      iconSize: 26,
                      icon: const Icon(Icons.forward_10_rounded),
                      onPressed: () => handler.seek(
                        sharedAudioPlayer.position +
                            const Duration(seconds: 10),
                      ),
                    ),
                    IconButton(
                      tooltip: context.l10n.t('Próximo'),
                      iconSize: 32,
                      icon: const Icon(Icons.skip_next_rounded),
                      onPressed: handler.skipToNext,
                    ),
                  ],
                ),
                const Divider(height: 28),

                // Switch de Reprodução Contínua
                Consumer<SettingsController>(
                  builder: (context, settings, _) {
                    return SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      secondary: Icon(
                        Icons.repeat_rounded,
                        color: colorScheme.primary,
                      ),
                      title: Text(
                        context.l10n.t('Reprodução contínua'),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        context.l10n.t(
                            'Avançar automaticamente para o próximo áudio'),
                        style: const TextStyle(fontSize: 12),
                      ),
                      value: settings.continuousPlayback,
                      onChanged: (value) =>
                          settings.setContinuousPlayback(value),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return '${twoDigits(duration.inHours)}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }
}

/// Card exibido quando não há nenhum áudio tocando em segundo plano.
class _EmptyAudioExecutionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppSectionCard(
      title: context.l10n.t('Execução de áudio'),
      subtitle: context.l10n.t('Nenhum áudio em execução no momento'),
      icon: Icons.headphones_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.t(
                'Ao iniciar a reprodução de um capítulo da Bíblia ou de um hino da Harpa, os controles de reprodução em segundo plano aparecerão aqui.'),
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.tonalIcon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const HomeAudioView(),
                  ),
                );
              },
              icon: const Icon(Icons.play_circle_outline_rounded),
              label: Text(
                  context.l10n.t('Ouvir áudios da Bíblia e Harpa')),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card informativo dos serviços ativos em segundo plano.
class _BackgroundServicesCard extends StatelessWidget {
  const _BackgroundServicesCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppSectionCard(
      title: context.l10n.t('Serviços em segundo plano'),
      subtitle: context.l10n.t(
          'Recursos ativos fora da tela para melhorar sua experiência'),
      icon: Icons.miscellaneous_services_rounded,
      child: Column(
        children: [
          _ServiceStatusTile(
            icon: Icons.surround_sound_rounded,
            title: context.l10n.t('Áudio em segundo plano'),
            subtitle: context.l10n.t(
                'Reproduz com a tela apagada ou app minimizado, integrando à central de controle e fones de ouvido.'),
            status: context.l10n.t('Ativo'),
            statusColor: colorScheme.primary,
          ),
          const Divider(height: 24),
          _ServiceStatusTile(
            icon: Icons.notifications_active_outlined,
            title: context.l10n.t('Lembretes de leitura'),
            subtitle: context.l10n.t(
                'Notificações periódicas para incentivar a leitura diária da Palavra de Deus.'),
            status: context.l10n.t('Agendado'),
            statusColor: colorScheme.primary,
          ),
          const Divider(height: 24),
          _ServiceStatusTile(
            icon: Icons.offline_pin_outlined,
            title: context.l10n.t('Suporte offline'),
            subtitle: context.l10n.t(
                'Áudios baixados no aparelho continuam tocando normalmente sem conexão com a internet.'),
            status: context.l10n.t('Disponível'),
            statusColor: colorScheme.secondary,
          ),
        ],
      ),
    );
  }
}

class _ServiceStatusTile extends StatelessWidget {
  const _ServiceStatusTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.statusColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
