import 'package:biblia_e_harpa/src/screens/bibleAudiosScreen.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class Audiobookchaptersscreen extends StatefulWidget {
  final Book book;
  const Audiobookchaptersscreen({super.key, required this.book});

  @override
  State<Audiobookchaptersscreen> createState() =>
      _AudiobookchaptersscreenState();
}

class _AudiobookchaptersscreenState extends State<Audiobookchaptersscreen> {
  final AudioPlayer _player = AudioPlayer();
  List<dynamic> _audios = [];
  bool _isLoading = true;
  bool _isBuffering = false;
  String? _error;
  int? _currentIndex;
  Duration _currentPosition = Duration.zero;
  Duration _audioDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audios = widget.book.chapters;

    _player.playerStateStream.listen((state) {
      setState(() {
        _isBuffering = state.processingState == ProcessingState.buffering ||
            state.processingState == ProcessingState.loading;
        if (state.processingState == ProcessingState.completed) {
          _playNextAudio();
        }
      });
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

  Future<void> _playAudio(String url, int index) async {
    try {
      setState(() {
        _isBuffering = true;
      });

      final chapter = _audios[index] as AudioData;
      final url = chapter.url;

      if (_currentIndex == index) {
        if (_player.playing) {
          await _player.pause();
        } else {
          await _player.play();
        }
      } else {
        setState(() {
          _currentIndex = index;
          _currentPosition = Duration.zero;
        });
        await _player.setAudioSource(
          AudioSource.uri(Uri.parse(url)),
        );
        await _player.play();
      }
    } catch (e) {
      setState(() {
        _isBuffering = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Houve um problema ao tocar o áudio')), //Erro ao tocar o áudio: $e
      );
    } finally {
      setState(() {
        _isBuffering = false;
      });
    }
  }

  void _playNextAudio() {
    if (_currentIndex == null || _audios.isEmpty) return;
    final nextIndex = (_currentIndex! + 1) % _audios.length;
    _playAudio(widget.book.chapters[nextIndex].url, nextIndex);
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
        automaticallyImplyLeading: true,
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.secondary),
        title: Text(
          widget.book.title,
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
      ),
      body: ListView.builder(
        itemCount: widget.book.chapters.length,
        itemBuilder: (context, index) {
          final chapter = widget.book.chapters[index];
          final isPlaying = _currentIndex == index && _player.playing;
          return Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            color: isPlaying ? Colors.green[50] : Colors.white,
            elevation: isPlaying ? 6 : 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 4,
              ),
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
                      chapter.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isPlaying ? Colors.green[800] : Colors.black87,
                      ),
                    ),
                    trailing: IconButton(
                      onPressed:() => _playAudio(chapter.url, index),
                      icon: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.green[800],
                      ),
                    ),
                  ),
                  if (isPlaying)
                    Column(
                      children: [
                        Slider(
                          value: _currentPosition.inSeconds.toDouble(),
                          min: 0,
                          max: _audioDuration.inSeconds.toDouble() > 0
                              ? _audioDuration.inSeconds.toDouble()
                              : 1,
                          onChanged: (value) async {
                            await _player.seek(
                              Duration(seconds: value.toInt()),
                            );
                          },
                          activeColor: Colors.green,
                          inactiveColor: Colors.green[100],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(_currentPosition),
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text(
                                _formatDuration(_audioDuration),
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
      ),
    );
  }
}
