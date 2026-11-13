/// Implementa a interface e os fluxos de apresentação deste recurso.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'component/app_bar_component.dart';
import '../model/data_audio_model.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:biblia_e_harpa/src/utils/theme.dart';
import '../services/app_audio_handler.dart';
import '../utils/app_links.dart';

class HarpFileView extends StatefulWidget {
  final List<DataAudioModel> allHymns;
  final int initialIndex;

  const HarpFileView({
    super.key,
    required this.allHymns,
    required this.initialIndex,
  });

  @override
  State<HarpFileView> createState() => _HarpFileViewState();
}

class _HarpFileViewState extends State<HarpFileView> {
  AudioPlayer get _player => sharedAudioPlayer;

  late int _currentIndex;
  late DataAudioModel _currentHymn;

  PlayerState? _playerState;
  Duration _currentPosition = Duration.zero;
  Duration _audioDuration = Duration.zero;

  bool _isDownloading = false;
  bool _isDownloaded = false;

  final List<StreamSubscription<dynamic>> _subscriptions =
      <StreamSubscription<dynamic>>[];
  AppAudioHandler? _handler;
  String? _audioDirPath;

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.initialIndex;
    _currentHymn = widget.allHymns[_currentIndex];

    _subscriptions.add(
      _player.playerStateStream.listen((state) {
        if (!mounted) return;
        setState(() {
          _playerState = state;
        });
      }),
    );

    _subscriptions.add(
      _player.positionStream.listen((p) {
        if (mounted) setState(() => _currentPosition = p);
      }),
    );

    _subscriptions.add(
      _player.durationStream.listen((d) {
        if (mounted) setState(() => _audioDuration = d ?? Duration.zero);
      }),
    );

    _checkIfDownloaded();
    _loadAndPlayAudio();
  }

  @override
  void dispose() {
    _handler?.currentTrack.removeListener(_syncFromHandler);
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  void _attachHandler(AppAudioHandler handler) {
    if (identical(_handler, handler)) return;
    _handler?.currentTrack.removeListener(_syncFromHandler);
    _handler = handler;
    handler.currentTrack.addListener(_syncFromHandler);
  }

  void _syncFromHandler() {
    if (!mounted) return;
    final track = _handler?.currentTrack.value;
    if (track == null || track.extras['source'] != 'harp-file') return;
    final index = int.tryParse(track.extras['index'] ?? '');
    if (index == null || index < 0 || index >= widget.allHymns.length) return;
    if (index == _currentIndex) return;
    setState(() {
      _currentIndex = index;
      _currentHymn = widget.allHymns[index];
      _currentPosition = Duration.zero;
      _audioDuration = Duration.zero;
    });
    _checkIfDownloaded();
  }

  Future<String> _getAudioDir() async {
    if (_audioDirPath != null) return _audioDirPath!;
    final directory = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${directory.path}/harpa_audios');
    if (!await audioDir.exists()) await audioDir.create(recursive: true);
    return _audioDirPath = audioDir.path;
  }

  String _safeFileName(String fileName) =>
      fileName.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_');

  Future<String> _getLocalFilePath(String fileName) async {
    final audioDir = await _getAudioDir();
    return '$audioDir/${_safeFileName(fileName)}.mp3';
  }

  Future<void> _checkIfDownloaded() async {
    final path = await _getLocalFilePath(_currentHymn.titulo);
    final exists = await File(path).exists();
    if (mounted) {
      setState(() {
        _isDownloaded = exists;
      });
    }
  }

  Future<void> _downloadAudio() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
    });

    try {
      final dio = Dio();
      final savePath = await _getLocalFilePath(_currentHymn.titulo);

      String url = _currentHymn.hinoURL;
      if (url.contains('drive.google.com') && !url.contains('&confirm=')) {
        if (url.contains('?')) {
          url = '$url&confirm=t';
        } else {
          url = '$url?confirm=t';
        }
      }

      await dio.download(url, savePath);

      if (mounted) {
        setState(() {
          _isDownloaded = true;
          _isDownloading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('${_currentHymn.titulo} baixado com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Erro ao baixar o áudio. Verifique a conexão.')),
        );
      }
    }
  }

  Future<void> _deleteAudio() async {
    try {
      final path = await _getLocalFilePath(_currentHymn.titulo);
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        if (mounted) {
          setState(() {
            _isDownloaded = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Áudio removido do dispositivo.')),
          );
        }
      }
    } catch (_) {}
  }

  Future<void> _loadAndPlayAudio({bool allowDownloadFallback = true}) async {
    try {
      await AppLinks.load();
      setState(() {
        _currentPosition = Duration.zero;
        _audioDuration = Duration.zero;
      });

      final audioDir = await _getAudioDir();
      final tracks = <AppAudioTrack>[];
      for (var i = 0; i < widget.allHymns.length; i++) {
        final hymn = widget.allHymns[i];
        tracks.add(
          AppAudioTrack(
            id: 'harp-file:$i:${hymn.titulo}',
            title: hymn.titulo,
            artist: 'Harpa Cristã',
            remoteUri: AppLinks.harpAudio(hymn.hinoURL),
            localPath: '$audioDir/${_safeFileName(hymn.titulo)}.mp3',
            headers: const <String, String>{
              'User-Agent':
                  'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Mobile Safari/537.36',
            },
            extras: <String, String>{
              'source': 'harp-file',
              'index': '$i',
            },
          ),
        );
      }

      final localPath = tracks[_currentIndex].localPath;
      final hasLocal = localPath != null && await File(localPath).exists();
      if (!hasLocal) {
        final connectivity = await Connectivity().checkConnectivity();
        if (connectivity.contains(ConnectivityResult.none)) {
          throw Exception("Sem internet e sem arquivo offline.");
        }
      }

      final handler = await ensureAudioHandler();
      if (handler != null) {
        _attachHandler(handler);
        await handler.playTracks(
          tracks: tracks,
          index: _currentIndex,
          continuous: true,
        );
        return;
      }

      if (hasLocal) {
        await _player.setAudioSource(AudioSource.file(localPath));
      } else {
        await _player.setAudioSource(
          AudioSource.uri(
            tracks[_currentIndex].remoteUri,
            headers: tracks[_currentIndex].headers,
          ),
        );
      }
      await _player.play();
    } catch (_) {
      // Mesmo fallback de antes: baixa o hino e toca do arquivo local quando
      // a reprodução online falha.
      if (allowDownloadFallback) {
        final downloaded = await _downloadCurrentForPlayback();
        if (downloaded) {
          await _loadAndPlayAudio(allowDownloadFallback: false);
          return;
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erro ao reproduzir o áudio online e offline."),
          ),
        );
      }
    }
  }

  /// Baixa o hino atual para o armazenamento do aparelho (fallback offline).
  Future<bool> _downloadCurrentForPlayback() async {
    try {
      final savePath = await _getLocalFilePath(_currentHymn.titulo);
      final dio = Dio();
      dio.options.headers = const <String, String>{
        'User-Agent':
            'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Mobile Safari/537.36',
      };
      await AppLinks.load();
      await dio.download(
        AppLinks.harpAudio(_currentHymn.hinoURL).toString(),
        savePath,
      );
      if (mounted) {
        setState(() => _isDownloaded = true);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  void _playNext() {
    if (_currentIndex < widget.allHymns.length - 1) {
      setState(() {
        _currentIndex++;
        _currentHymn = widget.allHymns[_currentIndex];
      });
      _checkIfDownloaded();
      _loadAndPlayAudio();
    }
  }

  void _playPrevious() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _currentHymn = widget.allHymns[_currentIndex];
      });
      _checkIfDownloaded();
      _loadAndPlayAudio();
    }
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final playerState = _playerState;
    final isPlaying = playerState?.playing ?? false;
    final processingState = playerState?.processingState;
    final isLoading = processingState == ProcessingState.loading ||
        processingState == ProcessingState.buffering;

    final hasPrevious = _currentIndex > 0;
    final hasNext = _currentIndex < widget.allHymns.length - 1;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: _currentHymn.titulo,
        centerTitle: false,
        automaticallyImplyLeading: true,
        actions: [
          _isDownloading
              ? Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.onSurface,
                      strokeWidth: 2,
                    ),
                  ),
                )
              : IconButton(
                  icon: Icon(
                    _isDownloaded ? Icons.download_done : Icons.download,
                    color: _isDownloaded
                        ? AppTheme.sucesso
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                  tooltip: _isDownloaded
                      ? "Hino baixado (Toque para remover)"
                      : "Baixar hino",
                  onPressed: () {
                    if (_isDownloaded) {
                      _deleteAudio();
                    } else {
                      _downloadAudio();
                    }
                  },
                ),
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      height: MediaQuery.of(context).size.width * 0.6,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5))
                        ],
                      ),
                      child: Icon(Icons.music_note_rounded,
                          size: 100,
                          color: Theme.of(context).colorScheme.onSurface),
                    ),
                    if (_isDownloaded)
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                              color: AppTheme.sucesso,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 2)),
                          child: const Icon(Icons.offline_pin,
                              color: Colors.white, size: 20),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 30),
                Text(_currentHymn.titulo,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Text("Harpa Cristã",
                    style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7))),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 16.0),
                  ),
                  child: Slider(
                    value: _currentPosition.inSeconds.toDouble(),
                    min: 0,
                    max: _audioDuration.inSeconds
                        .toDouble()
                        .clamp(1.0, double.infinity),
                    onChanged: (value) =>
                        _player.seek(Duration(seconds: value.toInt())),
                    activeColor: Theme.of(context).colorScheme.onSurface,
                    inactiveColor: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.3),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(_currentPosition),
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurface)),
                      Text(_formatDuration(_audioDuration),
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurface)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.replay_10_rounded),
                      iconSize: 28.0,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.8),
                      onPressed: () => _player.seek(
                          Duration(seconds: _currentPosition.inSeconds - 10)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_previous_rounded),
                      iconSize: 36.0,
                      color: hasPrevious
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.3),
                      onPressed: hasPrevious ? _playPrevious : null,
                    ),
                    SizedBox(
                      width: 70,
                      height: 70,
                      child: Center(
                        child: isLoading
                            ? CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.onSurface,
                              )
                            : InkWell(
                                borderRadius: BorderRadius.circular(50),
                                onTap: () {
                                  isPlaying ? _player.pause() : _player.play();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.3),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      )
                                    ],
                                  ),
                                  child: Icon(
                                    isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    size: 40.0,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next_rounded),
                      iconSize: 36.0,
                      color: hasNext
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.3),
                      onPressed: hasNext ? _playNext : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.forward_10_rounded),
                      iconSize: 28.0,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.8),
                      onPressed: () => _player.seek(
                          Duration(seconds: _currentPosition.inSeconds + 10)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
