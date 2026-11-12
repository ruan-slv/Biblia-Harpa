/// Implementa a interface e os fluxos de apresentação deste recurso.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:biblia_e_harpa/src/model/data_audio_model.dart';
import 'package:biblia_e_harpa/src/controllers/settings_controller.dart';
import 'package:biblia_e_harpa/src/controllers/continue_reading_controller.dart';
import 'package:biblia_e_harpa/src/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'component/app_bar_component.dart';
import 'component/bottombar.dart';
import '../services/app_audio_handler.dart';

class HarpTextModel {
  final String hino;
  final String coro;
  final Map<String, String> verses;

  HarpTextModel({required this.hino, required this.coro, required this.verses});

  factory HarpTextModel.fromJson(Map<String, dynamic> json) {
    return HarpTextModel(
      hino: json['hino'] ?? 'Hino não encontrado',
      coro: json['coro'] ?? 'Não possui coro',
      verses: Map<String, String>.from(json['verses'] ?? {}),
    );
  }
}

class HarpContentView extends StatefulWidget {
  const HarpContentView({
    super.key,
    required this.harp,
    this.audioUrl,
    this.audioHymns = const [],
    this.autoPlay = false,
  });

  final String harp;
  final String? audioUrl;
  final List<DataAudioModel> audioHymns;

  /// Inicia a reprodução automaticamente ao abrir (usado quando o modo
  /// contínuo avança para o próximo hino).
  final bool autoPlay;

  @override
  State<HarpContentView> createState() => _HarpContentViewState();
}

class _HarpContentViewState extends State<HarpContentView> {
  static const continueReadingController = ContinueReadingController();
  AudioPlayer get _audioPlayer => sharedAudioPlayer;
  bool _isLoadingAudio = false;
  late final Future<List<HarpTextModel>> _textsFuture;
  AppAudioHandler? _handler;
  bool _isNavigating = false;
  String? _audioDirPath;

  List<HarpTextModel> _hymns = const [];

  /// Fila do hino atual, guardada para poder iniciar a reprodução sob demanda
  /// sem interromper outro áudio apenas por abrir o texto do hino.
  List<AppAudioTrack>? _queueTracks;
  int _queueIndex = 0;

  @override
  void initState() {
    super.initState();
    _textsFuture = loadTexts();
    _textsFuture.then((hymns) {
      if (!mounted) return;
      setState(() {
        _hymns = hymns;
      });
    });

    continueReadingController.saveHarp(hymn: widget.harp);
    unawaited(_bindHandler());
    _loadAudio();
  }

  @override
  void dispose() {
    _handler?.currentTrack.removeListener(_onTrackChanged);
    super.dispose();
  }

  Future<void> _bindHandler() async {
    final handler = await ensureAudioHandler();
    if (!mounted) return;
    _attachHandler(handler);
  }

  void _attachHandler(AppAudioHandler? handler) {
    if (handler == null || identical(_handler, handler)) return;
    _handler?.currentTrack.removeListener(_onTrackChanged);
    _handler = handler;
    handler.currentTrack.addListener(_onTrackChanged);
  }

  /// Acompanha o avanço automático feito pelo player global e mostra o texto
  /// do hino que está tocando quando esta tela está visível.
  void _onTrackChanged() {
    if (!mounted || _isNavigating) return;
    final track = _handler?.currentTrack.value;
    if (track == null) return;
    if (track.extras['source'] != 'harp-content') return;
    if (_sameHymn(track.title, widget.harp)) return;
    if (ModalRoute.of(context)?.isCurrent != true) return;

    final hymn = _hymnByTitle(track.title);
    if (hymn == null) return;

    _isNavigating = true;
    Future.microtask(() {
      if (!mounted) return;
      _openHymn(hymn);
    });
  }

  Future<String> _getAudioDir() async {
    if (_audioDirPath != null) return _audioDirPath!;
    // Mantém o mesmo diretório usado pela aba Harpa para reaproveitar os
    // arquivos baixados (modo offline).
    final docs = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${docs.path}/harpa_audios');
    if (!await audioDir.exists()) await audioDir.create(recursive: true);
    return _audioDirPath = audioDir.path;
  }

  String _safeFileName(String hinoTitle) =>
      hinoTitle.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_');

  List<DataAudioModel> _playableHymns() {
    final list = widget.audioHymns
        .where((audio) => audio.hinoURL.trim().isNotEmpty)
        .toList();

    final hasCurrent =
        list.any((audio) => _sameHymn(audio.titulo, widget.harp));
    if (!hasCurrent && widget.audioUrl != null && widget.audioUrl!.isNotEmpty) {
      list.add(
        DataAudioModel(titulo: widget.harp, hinoURL: widget.audioUrl!),
      );
    }

    list.sort(
      (a, b) => _hymnNumber(a.titulo).compareTo(_hymnNumber(b.titulo)),
    );
    return list;
  }

  Future<void> _loadAudio() async {
    if (widget.audioUrl == null || widget.audioUrl!.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoadingAudio = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoadingAudio = true;
      });
    }

    try {
      final hymns = _playableHymns();
      var index =
          hymns.indexWhere((audio) => _sameHymn(audio.titulo, widget.harp));
      if (index < 0) {
        hymns.add(
          DataAudioModel(titulo: widget.harp, hinoURL: widget.audioUrl!),
        );
        index = hymns.length - 1;
      }

      final audioDir = await _getAudioDir();
      final tracks = hymns
          .map(
            (audio) => AppAudioTrack(
              id: 'harp-content:${_hymnNumber(audio.titulo)}:${audio.titulo}',
              title: audio.titulo,
              artist: 'Harpa Cristã',
              remoteUri: Uri.parse(audio.hinoURL),
              localPath: '$audioDir/${_safeFileName(audio.titulo)}.mp3',
              extras: const <String, String>{'source': 'harp-content'},
            ),
          )
          .toList();

      final handler = await ensureAudioHandler();
      if (handler != null) {
        _attachHandler(handler);
        _queueTracks = tracks;
        _queueIndex = index;

        final current = handler.currentTrack.value;
        final isThisTrack = current != null &&
            current.extras['source'] == 'harp-content' &&
            _sameHymn(current.title, widget.harp);
        // Não interrompe outro áudio (Harpa/Outros) só por abrir o texto do
        // hino: a fila é iniciada quando o usuário toca em play.
        final playingOther =
            current != null && sharedAudioPlayer.playing && !isThisTrack;

        if (!isThisTrack && !playingOther) {
          await handler.playTracks(
            tracks: tracks,
            index: index,
            continuous: true,
            autoPlay: widget.autoPlay,
          );
        }
      } else {
        await _audioPlayer.setUrl(widget.audioUrl!);
        if (widget.autoPlay) {
          await _audioPlayer.play();
        }
      }
    } catch (e) {
      // Mantém a tela funcional mesmo quando o áudio não pode ser carregado.
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAudio = false;
        });
      }
    }
  }

  bool _sameHymn(String a, String b) {
    final numberA = _hymnNumber(a);
    final numberB = _hymnNumber(b);
    if (numberA > 0 && numberB > 0) return numberA == numberB;
    return a.toLowerCase().trim() == b.toLowerCase().trim();
  }

  HarpTextModel? _hymnByTitle(String title) {
    for (final hymn in _hymns) {
      if (_sameHymn(hymn.hino, title)) return hymn;
    }
    return null;
  }

  /// Alterna entre reproduzir e pausar, reiniciando o hino caso ele já tenha
  /// chegado ao fim.
  Future<void> _togglePlayPause() async {
    try {
      final handler = activeAudioHandler;
      if (handler != null) {
        final current = handler.currentTrack.value;
        final isThisTrack = current != null &&
            current.extras['source'] == 'harp-content' &&
            _sameHymn(current.title, widget.harp);
        final tracks = _queueTracks;
        if (!isThisTrack && tracks != null && tracks.isNotEmpty) {
          // Outra música/hino estava no player: inicia este hino (fila
          // completa, para o modo contínuo continuar funcionando).
          await handler.playTracks(
            tracks: tracks,
            index: _queueIndex,
            continuous: true,
          );
          return;
        }
      }

      if (_audioPlayer.playing) {
        await _audioPlayer.pause();
        return;
      }
      if (_audioPlayer.processingState == ProcessingState.completed) {
        await _audioPlayer.seek(Duration.zero);
      }
      await _audioPlayer.play();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.t(
              'Não foi possível reproduzir o áudio. Verifique se há fones ou caixas de som conectados.',
            ),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<List<HarpTextModel>> loadTexts() async {
    try {
      String jsonString = await rootBundle
          .loadString('assets/json/outros/harpa_crista_640_hinos.json');
      Map<String, dynamic> jsonResponse = jsonDecode(jsonString);
      List<HarpTextModel> texts = [];
      jsonResponse.forEach((key, value) {
        texts.add(HarpTextModel.fromJson(value));
      });
      return texts;
    } catch (_) {
      return [];
    }
  }

  int _hymnNumber(String hymn) {
    final match = RegExp(r'^(\d+)').firstMatch(hymn.trim());
    return match == null ? 0 : int.parse(match.group(1)!);
  }

  String? _audioUrlFor(HarpTextModel hymn) {
    final hymnNumber = _hymnNumber(hymn.hino);

    for (final audio in widget.audioHymns) {
      if (_hymnNumber(audio.titulo) == hymnNumber) return audio.hinoURL;
    }

    return null;
  }

  void _openHymn(HarpTextModel hymn, {bool autoPlay = false}) {
    _isNavigating = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HarpContentView(
          harp: hymn.hino,
          audioUrl: _audioUrlFor(hymn),
          audioHymns: widget.audioHymns,
          autoPlay: autoPlay,
        ),
      ),
    );
  }

  Scaffold _buildScaffold({
    required Widget body,
    Widget? bottomNavigationBar,
  }) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: widget.harp,
        centerTitle: false,
        automaticallyImplyLeading: true,
      ),
      body: body,
      bottomNavigationBar: bottomNavigationBar,
    );
  }

  Widget _buildAudioPlayer() {
    final settings = context.watch<SettingsController>();
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Theme.of(context).colorScheme.surface,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: _isLoadingAudio
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StreamBuilder<PlayerState>(
                    stream: _audioPlayer.playerStateStream,
                    builder: (context, snapshot) {
                      final playerState = snapshot.data;
                      final processingState = playerState?.processingState;
                      final playing = playerState?.playing;

                      if (processingState == ProcessingState.loading ||
                          processingState == ProcessingState.buffering) {
                        return Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        );
                      }

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon((playing ?? false)
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_filled),
                            iconSize: 40.0,
                            color: Theme.of(context).colorScheme.onSurface,
                            onPressed: _togglePlayPause,
                          ),
                          IconButton(
                            icon: const Icon(Icons.stop_circle_outlined),
                            iconSize: 40.0,
                            color: Theme.of(context).colorScheme.onSurface,
                            onPressed: () {
                              _audioPlayer.stop();
                              _audioPlayer.seek(Duration.zero);
                            },
                          ),
                          IconButton(
                            tooltip: settings.continuousPlayback
                                ? context.l10n.t(
                                    "Reprodução contínua ativada (toque para desativar)")
                                : context.l10n.t(
                                    "Reprodução contínua desativada (toque para ativar)"),
                            icon: Icon(
                              settings.continuousPlayback
                                  ? Icons.repeat_on_rounded
                                  : Icons.repeat_rounded,
                            ),
                            iconSize: 30.0,
                            color: settings.continuousPlayback
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface,
                            onPressed: settings.toggleContinuousPlayback,
                          ),
                        ],
                      );
                    },
                  ),
                  Expanded(
                    child: StreamBuilder<Duration>(
                      stream: _audioPlayer.positionStream,
                      builder: (context, snapshot) {
                        final position = snapshot.data ?? Duration.zero;
                        final duration = _audioPlayer.duration ?? Duration.zero;
                        return Slider(
                          value: position.inSeconds
                              .clamp(0, duration.inSeconds)
                              .toDouble(),
                          max: duration.inSeconds > 0
                              ? duration.inSeconds.toDouble()
                              : 1.0,
                          onChanged: (value) => _audioPlayer
                              .seek(Duration(seconds: value.toInt())),
                          activeColor: Theme.of(context).colorScheme.onSurface,
                          inactiveColor: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withValues(alpha: 0.5),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final settings = context.watch<SettingsController>();

    return FutureBuilder<List<HarpTextModel>>(
      future: _textsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildScaffold(
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return _buildScaffold(
            body: Center(
              child: Text(
                context.l10n.t('Erro ao carregar os textos.'),
                style: TextStyle(color: colorScheme.onSurface),
              ),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildScaffold(
            body: Center(
              child: Text(
                context.l10n.t('Nenhum texto encontrado.'),
                style: TextStyle(color: colorScheme.onSurface),
              ),
            ),
          );
        }

        final hymns = snapshot.data!;
        final currentIndex = hymns.indexWhere(
          (text) =>
              text.hino.toLowerCase().trim() ==
              widget.harp.toLowerCase().trim(),
        );
        final harpText = currentIndex == -1
            ? HarpTextModel(hino: '', coro: '', verses: {})
            : hymns[currentIndex];

        final verseEntries = harpText.verses.entries.toList();
        final hasChorus = harpText.coro.trim().isNotEmpty &&
            harpText.coro.trim().toLowerCase() != 'não possui coro';

        return _buildScaffold(
          bottomNavigationBar: BottomBar(
            canGoBack: currentIndex > 0,
            canGoNext: currentIndex >= 0 && currentIndex < hymns.length - 1,
            onPrevious: currentIndex > 0
                ? () => _openHymn(hymns[currentIndex - 1],
                    autoPlay: _audioPlayer.playing)
                : null,
            onNext: currentIndex >= 0 && currentIndex < hymns.length - 1
                ? () => _openHymn(hymns[currentIndex + 1],
                    autoPlay: _audioPlayer.playing)
                : null,
            previousLabel: context.l10n.t('Hino anterior'),
            nextLabel: context.l10n.t('Próximo hino'),
          ),
          body: Center(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildAudioPlayer(),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(6.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == verseEntries.length) {
                          return const SizedBox(height: 24);
                        }

                        final entry = verseEntries[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  entry.key,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface
                                        .withValues(alpha: 0.9),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  entry.value,
                                  style: TextStyle(
                                    fontSize: settings.fontSize,
                                    color: colorScheme.onSurface,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (hasChorus) ...[
                                  const SizedBox(height: 24),
                                  Text(
                                    harpText.coro,
                                    style: TextStyle(
                                      fontSize: settings.fontSize,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: verseEntries.length + 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
