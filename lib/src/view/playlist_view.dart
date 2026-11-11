/// Implementa a interface e os fluxos de apresentação deste recurso.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'dart:async';

import 'package:biblia_e_harpa/src/controllers/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:watcher/watcher.dart';
import 'package:path_provider/path_provider.dart';

import '../model/music.dart';
import '../controllers/music_controller.dart';
import '../utils/theme.dart';
import '../services/app_audio_handler.dart';

class PlaylistView extends StatefulWidget {
  const PlaylistView({super.key});

  @override
  State<PlaylistView> createState() => _PlaylistViewState();
}

class _PlaylistViewState extends State<PlaylistView> {
  final MusicController _musicController = MusicController();
  AudioPlayer get player => sharedAudioPlayer;
  bool _isPlaying = false;
  int? _currentPlayingIndex;
  DirectoryWatcher? _watcher;

  Duration _currentPosition = Duration.zero;
  Duration _musicDuration = Duration.zero;

  final List<StreamSubscription<dynamic>> _subscriptions =
      <StreamSubscription<dynamic>>[];
  AppAudioHandler? _handler;

  @override
  void initState() {
    super.initState();
    _startDirectoryMonitoring();

    _subscriptions.add(
      player.positionStream.listen((position) {
        if (mounted) {
          setState(() {
            _currentPosition = position;
          });
        }
      }),
    );

    _subscriptions.add(
      player.durationStream.listen((duration) {
        if (mounted) {
          setState(() {
            _musicDuration = duration ?? Duration.zero;
          });
        }
      }),
    );

    _subscriptions.add(
      player.playingStream.listen((isPlaying) {
        if (mounted) {
          setState(() {
            _isPlaying = isPlaying;
          });
        }
      }),
    );
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

  /// Reflete o avanço automático/notificação na lista de músicas.
  void _syncFromHandler() {
    if (!mounted) return;
    final track = _handler?.currentTrack.value;
    if (track == null || track.extras['source'] != 'playlist') return;
    final index = int.tryParse(track.extras['index'] ?? '');
    if (index == null) return;
    if (_currentPlayingIndex == index) return;
    setState(() {
      _currentPlayingIndex = index;
      _currentPosition = Duration.zero;
      _musicDuration = Duration.zero;
    });
  }

  Future<void> _startDirectoryMonitoring() async {
    try {
      final directory = await getDownloadsDirectory();
      if (directory == null) {
        return;
      }

      _watcher = DirectoryWatcher(directory.path);

      _watcher!.events.listen((event) {
        if (event.type == ChangeType.ADD) {
          final filePath = event.path;
          if (filePath.endsWith('.mp3') ||
              filePath.endsWith('.mp4') ||
              filePath.endsWith('.wav') ||
              filePath.endsWith('.aac')) {
            final music = Music(
              title: filePath.split('/').last,
              filePath: filePath,
            );
            _musicController.addMusic(music).then((_) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Música "${music.title}" adicionada automaticamente!')),
                );
              }
            });
          }
        }
      });
    } catch (e) {
      // ignore
    }
  }

  Future<void> _playMusic(String path, int index) async {
    try {
      final activeHandler = activeAudioHandler;
      final current = activeHandler?.currentTrack.value;
      // Sem o serviço de mídia (fallback), usa o índice local.
      final isCurrent = current != null
          ? current.extras['source'] == 'playlist' &&
              current.extras['index'] == '$index'
          : _currentPlayingIndex == index;

      if (isCurrent) {
        if (player.playing) {
          await player.pause();
        } else {
          await player.play();
        }
        return;
      }

      setState(() {
        _currentPlayingIndex = index;
        _currentPosition = Duration.zero;
      });

      final tracks = <AppAudioTrack>[];
      final musics = _musicController.musics;
      for (var i = 0; i < musics.length; i++) {
        final music = musics[i];
        tracks.add(
          AppAudioTrack(
            id: 'playlist:$i:${music.filePath}',
            title: music.title,
            artist: 'Outros',
            remoteUri: Uri.file(music.filePath),
            localPath: music.filePath,
            extras: <String, String>{
              'source': 'playlist',
              'index': '$i',
            },
          ),
        );
      }

      final handler = await ensureAudioHandler();
      if (handler != null) {
        _attachHandler(handler);
        await handler.playTracks(
          tracks: tracks,
          index: index,
          continuous: true,
        );
      } else {
        await player.setFilePath(path);
        await player.play();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Erro ao tocar a música, verifique se o seu arquivo de aúdio é no formato mp3, wav e acc')),
        );
      }
    }
  }

  Future<void> _pickMusicFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'mp4', 'wav', 'aac'],
      );

      if (result != null && result.files.single.path != null) {
        final file = result.files.single;
        final music = Music(
          title: file.name,
          filePath: file.path!,
        );
        await _musicController.addMusic(music);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Música "${file.name}" adicionada com sucesso!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Erro ao adicionar música, verifique se o seu arquivo de aúdio é no formato mp3, wav e acc')),
        );
      }
    }
  }

  Future<void> _removeMusic(int index) async {
    try {
      await _musicController.deleteMusic(index);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Música removida com sucesso!')),
        );
      }
      if (_currentPlayingIndex == index) {
        final handler = activeAudioHandler;
        if (handler != null) {
          await handler.stop();
        } else {
          await player.stop();
        }
        setState(() {
          _isPlaying = false;
          _currentPlayingIndex = null;
          _currentPosition = Duration.zero;
          _musicDuration = Duration.zero;
        });
      } else if (_currentPlayingIndex != null &&
          index < _currentPlayingIndex!) {
        setState(() {
          _currentPlayingIndex = _currentPlayingIndex! - 1;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao remover música')),
        );
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: _pickMusicFile,
        tooltip: 'Adicionar Música',
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(
          Icons.library_music,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      body: AnimatedBuilder(
        animation: _musicController,
        builder: (context, _) {
          if (_musicController.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          final musics = _musicController.musics;
          if (musics.isEmpty) {
            return Center(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Vazio',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: settings.fontSize,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _pickMusicFile(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: Text(
                    "Adicionar áudio",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: settings.fontSize,
                    ),
                  ),
                ),
              ],
            ));
          }
          return ListView.builder(
            itemCount: musics.length,
            itemBuilder: (context, index) {
              final music = musics[index];
              final isPlaying = _isPlaying && _currentPlayingIndex == index;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                color: isPlaying
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.surface,
                elevation: isPlaying ? 6 : 2,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
                  child: Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.sucesso,
                          child: Icon(
                            isPlaying ? Icons.music_note : Icons.library_music,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          music.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isPlaying
                                ? AppTheme.sucesso
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                  isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: AppTheme.sucesso),
                              onPressed: () =>
                                  _playMusic(music.filePath, index),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              onPressed: () => _removeMusic(index),
                            ),
                          ],
                        ),
                      ),
                      if (isPlaying)
                        Column(
                          children: [
                            Slider(
                              value: _currentPosition.inSeconds.toDouble(),
                              min: 0,
                              max: _musicDuration.inSeconds.toDouble() > 0
                                  ? _musicDuration.inSeconds.toDouble()
                                  : 1,
                              onChanged: (value) async {
                                await player
                                    .seek(Duration(seconds: value.toInt()));
                              },
                              activeColor:
                                  Theme.of(context).colorScheme.primary,
                              inactiveColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(_currentPosition),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    _formatDuration(_musicDuration),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
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
      ),
    );
  }
}
