/// Implementa a interface e os fluxos de apresentação deste recurso.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;


import 'package:biblia_e_harpa/src/view_model/settings_view_model.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:watcher/watcher.dart';
import 'package:path_provider/path_provider.dart';

import '../model/music.dart';
import '../view_model/service/music_service.dart';

class PlaylistView extends StatefulWidget {
  const PlaylistView({super.key});

  @override
  State<PlaylistView> createState() => _PlaylistViewState();
}

class _PlaylistViewState extends State<PlaylistView> {
  final MusicService musicService = MusicService();
  final AudioPlayer player = AudioPlayer();
  bool _isPlaying = false;
  int? _currentPlayingIndex;
  DirectoryWatcher? _watcher;

  Duration _currentPosition = Duration.zero;
  Duration _musicDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startDirectoryMonitoring();

    player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _playNextMusic();
      }
    });

    player.positionStream.listen((position) {
      setState(() {
        _currentPosition = position;
      });
    });

    player.durationStream.listen((duration) {
      setState(() {
        _musicDuration = duration ?? Duration.zero;
      });
    });

    player.playingStream.listen((isPlaying) {
      setState(() {
        _isPlaying = isPlaying;
      });
    });
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
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
            musicService.addMusic(music).then((_) {
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

  void _playMusic(String path, int index) async {
    try {
      if (_currentPlayingIndex == index) {
        if (player.playing) {
          await player.pause();
        } else {
          await player.play();
        }
      } else {
        setState(() {
          _currentPlayingIndex = index;
          _currentPosition = Duration.zero;
        });
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

  void _playNextMusic() async {
    final box = Hive.box<Music>("musicas");
    if (_currentPlayingIndex == null || box.isEmpty) return;
    int nextIndex = (_currentPlayingIndex! + 1) % box.length;
    final nextMusic = box.getAt(nextIndex);
    if (nextMusic != null) {
      _playMusic(nextMusic.filePath, nextIndex);
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
        await musicService.addMusic(music);
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
      await musicService.deleteMusic(index);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Música removida com sucesso!')),
        );
      }
      if (_currentPlayingIndex == index) {
        await player.stop();
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
    final settings = context.watch<SettingsViewModel>();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      floatingActionButton: FloatingActionButton(
        onPressed: _pickMusicFile,
        tooltip: 'Adicionar Música',
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(
            Icons.library_music,
            color: Theme.of(context).colorScheme.secondary,
        ),
      ),
      body: ValueListenableBuilder<Box<Music>>(
          valueListenable: Hive.box<Music>('musicas').listenable(),
          builder: (context, box, _) {
            if (box.isEmpty) {
              return Center(
                  child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Vazio',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
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
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: settings.fontSize,
                    ),
                  ),
                ),
              ],
            ));
            }
            final musics = box.values.toList();
            return ListView.builder(
              itemCount: musics.length,
              itemBuilder: (context, index) {
                final music = musics[index];
                final isPlaying = _isPlaying && _currentPlayingIndex == index;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  color: isPlaying ? Colors.green[50] : Colors.white,
                  elevation: isPlaying ? 6 : 2,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
                    child: Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green[200],
                            child: Icon(
                              isPlaying ? Icons.music_note : Icons.library_music,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            music.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  isPlaying ? Colors.green[800] : Colors.black87,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                    isPlaying ? Icons.pause : Icons.play_arrow,
                                    color: Colors.green[800]),
                                onPressed: () =>
                                    _playMusic(music.filePath, index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.redAccent),
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
                                activeColor: Colors.green,
                                inactiveColor: Colors.green[100],
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
