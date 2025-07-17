// Versão adaptada do AudioScreen com a mesma estilização do PlaylistScreen e lógica de tocar/pausar
import 'dart:convert';
import 'package:biblia_e_harpa/src/config.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;

class AudioScreen extends StatefulWidget {
  const AudioScreen({super.key});

  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  final AudioPlayer _player = AudioPlayer();
  List<dynamic> _audios = [];
  bool _isLoading = true;
  String? _error;
  int? _currentIndex;
  Duration _currentPosition = Duration.zero;
  Duration _audioDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _fetchAudios();

    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _playNextAudio();
      }
      setState(() {});
    });

    _player.positionStream.listen((position) {
      setState(() {
        _currentPosition = position;
      });
    });

    _player.durationStream.listen((duration) {
      setState(() {
        _audioDuration = duration ?? Duration.zero;
      });
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _fetchAudios() async {
    try {
      final response = await http
          .get(Uri.parse("http://192.168.1.103:3000/list/"))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        setState(() {
          _audios = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception("Erro HTTP: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        _error = "Falha na conexão: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _playAudio(String url, int index) async {
    try {
      if (_currentIndex == index && _player.playing) {
        await _player.pause();
      } else {
        await _player.setUrl(url);
        await _player.play();
        setState(() {
          _currentIndex = index;
          _currentPosition = Duration.zero;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao tocar o áudio: $e')),
      );
    }
  }

  void _playNextAudio() {
    if (_currentIndex == null || _audios.isEmpty) return;
    final nextIndex = (_currentIndex! + 1) % _audios.length;
    _playAudio(_audios[nextIndex]['url'], nextIndex);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        iconTheme:  IconThemeData(color: Theme.of(context).colorScheme.secondary),
        title:  Text(
          "Áudios Online",
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _fetchAudios,
                        child:  Text("Tentar novamente", style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchAudios,
                  child: ListView.builder(
                    itemCount: _audios.length,
                    itemBuilder: (context, index) {
                      final audio = _audios[index];
                      final isPlaying =
                          _player.playing && _currentIndex == index;
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        color: isPlaying ? Colors.green[50] : Colors.white,
                        elevation: isPlaying ? 6 : 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 4),
                          child: Column(
                            children: [
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.green[200],
                                  child: Icon(
                                    isPlaying
                                        ? Icons.music_note
                                        : Icons.library_music,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  audio['title'] ?? 'Sem título',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isPlaying
                                        ? Colors.green[800]
                                        : Colors.black87,
                                  ),
                                ),
                                subtitle: Text(audio['livro'] ?? ''),
                                trailing: IconButton(
                                  icon: Icon(
                                    isPlaying ? Icons.pause : Icons.play_arrow,
                                    color: Colors.green[800],
                                  ),
                                  onPressed: () =>
                                      _playAudio(audio['url'], index),
                                ),
                              ),
                              if (isPlaying)
                                Column(
                                  children: [
                                    Slider(
                                      value:
                                          _currentPosition.inSeconds.toDouble(),
                                      min: 0,
                                      max: _audioDuration.inSeconds.toDouble() >
                                              0
                                          ? _audioDuration.inSeconds.toDouble()
                                          : 1,
                                      onChanged: (value) async {
                                        await _player.seek(
                                            Duration(seconds: value.toInt()));
                                      },
                                      activeColor: Colors.green,
                                      inactiveColor: Colors.green[100],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _formatDuration(_currentPosition),
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                          Text(
                                            _formatDuration(_audioDuration),
                                            style:
                                                const TextStyle(fontSize: 12),
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
                  ),
                ),
    );
  }
}
