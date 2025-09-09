import 'dart:convert';
import 'package:biblia_e_harpa/src/controllers/fontSizeController.dart';
import 'package:biblia_e_harpa/src/screens/audioBookChaptersScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import "package:flutter/services.dart" show rootBundle;

class AudioData {
  final String name;
  final String url;

  AudioData({
    required this.name,
    required this.url,
  });

  factory AudioData.fromJson(Map<String, dynamic> json) {
    return AudioData(name: json["name"], url: json["url"]);
  }
}

class Book {
  final String title;
  final List<AudioData> chapters;

  Book({
    required this.title,
    required this.chapters,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    var list = json["chapters"] as List;
    List<AudioData> chapterList =
        list.map((i) => AudioData.fromJson(i)).toList();
    return Book(title: json["title"], chapters: chapterList);
  }
}

class Bibleaudiosscreen extends StatefulWidget {
  const Bibleaudiosscreen({super.key});

  @override
  State<Bibleaudiosscreen> createState() => _BibleaudiosscreenState();
}

class _BibleaudiosscreenState extends State<Bibleaudiosscreen> {
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
    _fetchAudios();

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

  Future<void> _fetchAudios() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final String response = await rootBundle.loadString("assets/json/audios.json");
      final List data = json.decode(response);

      List<Book> books = data.map((book) => Book.fromJson(book)).toList();

      setState(() {
        _audios = books;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error =
            "Esta funcionalidade começou a ser desenvolvida no dia 03/09/2025\nAguarde só mais um pouco, tentaremos finalizar esta funcionalidade até Novembro";
        _isLoading = false;
      });
    }
  }

  Future<void> _playAudio(String url, int index) async {
    try {
      setState(() {
        _isBuffering = true;
      });

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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    return ListView.builder(
      itemCount: _audios.length,
      itemBuilder: (context, index) {
        final book = _audios[index] as Book;
        return ListTile(
          trailing: Icon(
            Icons.list,
            color: Theme.of(context).colorScheme.secondary,
          ),
          title: Text(
            book.title,
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Audiobookchaptersscreen(book: book),
              ),
            );
          },
        );
      },
    );
  }
}
