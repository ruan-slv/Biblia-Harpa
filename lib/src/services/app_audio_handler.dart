import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Uma faixa reproduzível pelo player global.
///
/// O [remoteUri] é usado como fallback online e o [localPath], quando
/// existir e o arquivo estiver no dispositivo, tem prioridade (modo offline).
/// Os [extras] viajam até o [MediaItem] para que as telas consigam identificar
/// qual fila originou a reprodução (ex.: `{'source': 'harp-audio', 'index': '3'}`).
class AppAudioTrack {
  const AppAudioTrack({
    required this.id,
    required this.title,
    required this.remoteUri,
    this.artist = 'Bíblia e Harpa',
    this.album = 'Bíblia e Harpa',
    this.localPath,
    this.headers = const {},
    this.extras = const {},
  });

  final String id;
  final String title;
  final String artist;
  final String album;
  final Uri remoteUri;
  final String? localPath;
  final Map<String, String> headers;
  final Map<String, String> extras;

  MediaItem toMediaItem() => MediaItem(
        id: id,
        title: title,
        artist: artist,
        album: album,
        extras: <String, dynamic>{
          ...extras,
          if (localPath != null) 'localPath': localPath,
          'remoteUri': remoteUri.toString(),
        },
      );
}

/// Player global único do aplicativo.
///
/// Mantém a fila, o modo contínuo, a notificação de mídia e o estado de
/// reprodução compartilhado por Bíblia, Harpa e "Outros". As telas não devem
/// criar [AudioPlayer] próprios: usam [sharedAudioPlayer] para a interface e
/// este handler para iniciar/avançar faixas.
class AppAudioHandler extends BaseAudioHandler with SeekHandler {
  static final AudioPlayer player = AudioPlayer();

  /// Fonte do modo contínuo. É ligada ao [SettingsController] em `main.dart`
  /// para que a troca do switch valha imediatamente, mesmo em segundo plano.
  static bool Function() continuousResolver = () => true;

  /// Fila atual e índice da faixa em reprodução.
  final List<AppAudioTrack> _tracks = <AppAudioTrack>[];
  int _index = -1;
  bool _queueAllowsContinuous = false;

  /// Faixa em reprodução. As telas escutam este notifier para refletir o
  /// avanço automático (inclusive o disparado pela notificação/fones).
  final ValueNotifier<AppAudioTrack?> currentTrack =
      ValueNotifier<AppAudioTrack?>(null);

  final List<StreamSubscription<dynamic>> _subscriptions =
      <StreamSubscription<dynamic>>[];
  final List<StreamSubscription<dynamic>> _sessionSubscriptions =
      <StreamSubscription<dynamic>>[];

  bool _handlingCompletion = false;
  bool _pausedForInterruption = false;
  bool _disposed = false;

  AppAudioHandler() {
    activeAudioHandler = this;
    _subscriptions.add(player.playerStateStream.listen(_broadcastState));
    _subscriptions.add(player.positionStream.listen((position) {
      if (_disposed) return;
      playbackState.add(
        playbackState.value.copyWith(updatePosition: position),
      );
    }));
    _subscriptions.add(player.durationStream.listen((duration) {
      if (_disposed) return;
      final item = mediaItem.value;
      if (item != null && duration != null) {
        mediaItem.add(item.copyWith(duration: duration));
      }
    }));
  }

  /// Configura o foco de áudio e os eventos de interrupção/fones.
  Future<void> configureSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    _sessionSubscriptions.add(
      session.interruptionEventStream.listen((event) {
        if (event.begin) {
          if (player.playing) {
            _pausedForInterruption = true;
            player.pause();
          }
        } else if (event.type == AudioInterruptionType.pause &&
            _pausedForInterruption) {
          _pausedForInterruption = false;
          player.play();
        }
      }),
    );
    // Fone desconectado: pausa em vez de tocar no alto-falante.
    _sessionSubscriptions.add(
      session.becomingNoisyEventStream.listen((_) {
        if (player.playing) player.pause();
      }),
    );
  }

  List<AppAudioTrack> get tracks => List<AppAudioTrack>.unmodifiable(_tracks);
  int get trackCount => _tracks.length;
  int get currentIndex => _index;
  bool get continuous => _queueAllowsContinuous && continuousResolver();

  /// Substitui a fila atual e começa a tocar a faixa de [index].
  Future<void> playTracks({
    required List<AppAudioTrack> tracks,
    int index = 0,
    bool continuous = true,
    bool autoPlay = true,
  }) async {
    if (tracks.isEmpty) return;

    _tracks
      ..clear()
      ..addAll(tracks);
    _index =
        index < 0 ? 0 : (index >= _tracks.length ? _tracks.length - 1 : index);
    _queueAllowsContinuous = continuous;

    await _loadCurrent(autoPlay: autoPlay);
  }

  /// Atalho para uma faixa avulsa (ex.: áudio de um capítulo da Bíblia).
  Future<void> playTrack(
    AppAudioTrack track, {
    bool continuous = false,
    bool autoPlay = true,
  }) =>
      playTracks(
        tracks: <AppAudioTrack>[track],
        index: 0,
        continuous: continuous,
        autoPlay: autoPlay,
      );

  Future<AudioSource> _sourceFor(AppAudioTrack track) async {
    final localPath = track.localPath;
    if (localPath != null && localPath.isNotEmpty) {
      try {
        if (await File(localPath).exists()) {
          return AudioSource.file(localPath);
        }
      } catch (_) {
        // Arquivo inacessível: segue para a fonte online.
      }
    }
    return AudioSource.uri(
      track.remoteUri,
      headers: track.headers.isEmpty ? null : track.headers,
    );
  }

  Future<void> _loadCurrent({bool autoPlay = true}) async {
    if (_index < 0 || _index >= _tracks.length) return;
    final track = _tracks[_index];

    mediaItem.add(track.toMediaItem());
    currentTrack.value = track;

    try {
      await player.setAudioSource(await _sourceFor(track));
      if (autoPlay) await player.play();
    } catch (_) {
      // Mantém a UI consistente (pausada) e deixa a tela mostrar o erro.
      await player.pause();
      rethrow;
    }
  }

  Future<void> _broadcastState(PlayerState state) async {
    if (state.processingState == ProcessingState.completed) {
      await _handleCompleted();
    }
    if (_disposed) return;

    final processing = switch (state.processingState) {
      ProcessingState.idle => AudioProcessingState.idle,
      ProcessingState.loading => AudioProcessingState.loading,
      ProcessingState.buffering => AudioProcessingState.buffering,
      ProcessingState.ready => AudioProcessingState.ready,
      ProcessingState.completed => AudioProcessingState.completed,
    };
    playbackState.add(
      PlaybackState(
        controls: <MediaControl>[
          MediaControl.skipToPrevious,
          state.playing ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToNext,
          MediaControl.stop,
        ],
        systemActions: const <MediaAction>{MediaAction.seek},
        androidCompactActionIndices: const <int>[0, 1, 2],
        processingState: processing,
        playing: state.playing,
        updatePosition: player.position,
        bufferedPosition: player.bufferedPosition,
        speed: player.speed,
        queueIndex: _index < 0 ? null : _index,
      ),
    );
  }

  /// Avança ao terminar a faixa. Com o modo contínuo ligado segue para a
  /// próxima (voltando ao início no fim da fila); desligado, encerra a
  /// reprodução atual.
  Future<void> _handleCompleted() async {
    if (_handlingCompletion || _tracks.isEmpty) return;
    _handlingCompletion = true;

    try {
      if (continuous) {
        _index = (_index + 1) % _tracks.length;
        await _loadCurrent(autoPlay: true);
        return;
      }
    } catch (_) {
      // Falha ao carregar a próxima faixa: cai no encerramento abaixo.
    } finally {
      _handlingCompletion = false;
    }

    if (player.playing) {
      await player.pause();
    }
    await player.seek(Duration.zero);
  }

  @override
  Future<void> play() => player.play();

  @override
  Future<void> pause() => player.pause();

  @override
  Future<void> stop() async {
    await player.stop();
    try {
      await player.seek(Duration.zero);
    } catch (_) {
      // Player sem fonte carregada: não há posição para reposicionar.
    }
    _tracks.clear();
    _index = -1;
    _queueAllowsContinuous = false;
    currentTrack.value = null;
    mediaItem.add(null);
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => player.seek(position);

  @override
  Future<void> skipToNext() async {
    if (_tracks.isEmpty) return;
    if (_index + 1 < _tracks.length) {
      _index += 1;
      await _loadCurrent(autoPlay: true);
    } else if (continuous) {
      _index = 0;
      await _loadCurrent(autoPlay: true);
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_tracks.isEmpty) return;
    if (_index > 0) {
      _index -= 1;
      await _loadCurrent(autoPlay: true);
    } else if (continuous) {
      _index = _tracks.length - 1;
      await _loadCurrent(autoPlay: true);
    } else {
      await player.seek(Duration.zero);
    }
  }

  /// Libera o player e as assinaturas. Chamado quando o app é encerrado.
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    for (final subscription in _sessionSubscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
    _sessionSubscriptions.clear();
    currentTrack.dispose();
    await player.dispose();
    if (identical(activeAudioHandler, this)) {
      activeAudioHandler = null;
    }
  }
}

AppAudioHandler? _activeAudioHandler;

/// Handler ativo. Fica nulo até o `audio_service` concluir a inicialização.
AppAudioHandler? get activeAudioHandler => _activeAudioHandler;
set activeAudioHandler(AppAudioHandler? value) {
  _activeAudioHandler = value;
  audioHandlerChanges.value = value;
}

/// Avisa a interface quando o handler global fica pronto.
final ValueNotifier<AppAudioHandler?> audioHandlerChanges =
    ValueNotifier<AppAudioHandler?>(null);

Future<AppAudioHandler>? _initialization;

/// Inicializa o serviço de mídia uma única vez.
Future<AppAudioHandler> initAppAudioHandler() =>
    _initialization ??= AudioService.init(
      builder: AppAudioHandler.new,
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.bibleAplication.app.audio',
        androidNotificationChannelName: 'Reprodução de áudio',
        // Mantém o serviço em primeiro plano durante a pausa: evita o
        // ForegroundServiceStartNotAllowedException (Android 12+) ao retomar
        // a partir da notificação/fone e garante a continuação em segundo
        // plano. (A notificação já fica fixa enquanto o serviço está ativo.)
        androidNotificationOngoing: false,
        androidStopForegroundOnPause: false,
      ),
    ).then((handler) async {
      await handler.configureSession();
      return handler;
    });

/// Garante o handler global, aguardando a inicialização se necessário.
///
/// Retorna `null` quando o serviço não está disponível (ex.: testes/desktop),
/// permitindo que as telas usem [sharedAudioPlayer] como fallback.
Future<AppAudioHandler?> ensureAudioHandler() async {
  if (_activeAudioHandler != null) return _activeAudioHandler;
  try {
    return await initAppAudioHandler();
  } catch (_) {
    return null;
  }
}

/// Player compartilhado por todas as telas (mesmo quando o serviço de mídia
/// não está disponível).
AudioPlayer get sharedAudioPlayer => AppAudioHandler.player;
