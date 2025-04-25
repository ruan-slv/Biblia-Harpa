import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:biblia_e_harpa/models/music.dart';
import 'package:biblia_e_harpa/services/musicService.dart';
import 'package:biblia_e_harpa/src/config.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({super.key});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  final MusicService musicService = MusicService();
  final AudioPlayer player = AudioPlayer();
  bool _isPlaying = false;
  int? _currentPlayingIndex;

  @override
  void initState() {
    super.initState();
    // Verifica se a Box está aberta
    if (!Hive.box<Music>('musicas').isOpen) {
      debugPrint('Box "musicas" não está aberta!');
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  void _playMusic(String path, int index) async {
    try {
      if (_currentPlayingIndex == index && _isPlaying) {
        await player.pause();
        setState(() {
          _isPlaying = false;
        });
      } else {
        await player.setFilePath(path);
        await player.play();
        setState(() {
          _isPlaying = true;
          _currentPlayingIndex = index;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao tocar a música: $e')),
        );
      }
    }
  }

  Future<void> _pickMusicFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'aac'],
      );

      if (result != null && result.files.single.path != null) {
        final file = result.files.single;
        final music = Music(
          title: file.name,
          filePath: file.path!,
        );
        await musicService.addMusic(music); // Adiciona música de forma assíncrona
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Música "${file.name}" adicionada com sucesso!')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nenhum arquivo selecionado.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao adicionar música: $e')),
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
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao remover música: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: azulSereno,
        centerTitle: true,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: brancoNeve),
        title: const Text(
          "Minhas Músicas",
          style: TextStyle(color: brancoNeve),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickMusicFile,
        tooltip: 'Adicionar Música',
        child: const Icon(Icons.library_music),
      ),
      body: ValueListenableBuilder<Box<Music>>(
        valueListenable: Hive.box<Music>('musicas').listenable(),
        builder: (context, box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('Nenhuma música adicionada.'));
          }
          final musics = box.values.toList();
          debugPrint('Músicas carregadas: ${musics.length}'); // Log para depuração
          return ListView.builder(
            itemCount: musics.length,
            itemBuilder: (context, index) {
              final music = musics[index];
              final isPlaying = _isPlaying && _currentPlayingIndex == index;
              return ListTile(
                title: Text(music.title),
                subtitle: Text(music.filePath),
                leading: IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: () => _playMusic(music.filePath, index),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _removeMusic(index),
                ),
              );
            },
          );
        },
      ),
    );
  }
}