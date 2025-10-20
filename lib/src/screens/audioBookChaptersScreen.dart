// Em: lib/src/screens/audioBookChaptersScreen.dart

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
  final TextEditingController _searchController = TextEditingController();
  late List<AudioData> _filteredChapters;

  // ESTA VARIÁVEL AGORA É CONTROLADA APENAS PELO PLAYERSTATETREAM
  bool _isCurrentlyBuffering = false;
  int? _currentIndex;
  Duration _currentPosition = Duration.zero;
  Duration _audioDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _filteredChapters = widget.book.chapters;
    _searchController.addListener(_filterChapters);

    // Listener agora é a ÚNICA fonte da verdade para o estado de buffering
    _player.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        _isCurrentlyBuffering = state.processingState == ProcessingState.buffering ||
            state.processingState == ProcessingState.loading;
      });

      if (state.processingState == ProcessingState.completed) {
        _playNextAudio();
      }
    });

    _player.positionStream.listen((position) {
      if (mounted) setState(() => _currentPosition = position);
    });

    _player.durationStream.listen((duration) {
      if (mounted) setState(() => _audioDuration = duration ?? Duration.zero);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    _searchController.removeListener(_filterChapters);
    _searchController.dispose();
    super.dispose();
  }

  String _normalize(String input) {
    return input.toLowerCase().replaceAll(RegExp(r'[áàâãä]'), 'a').replaceAll(RegExp(r'[éèêë]'), 'e').replaceAll(RegExp(r'[íìîï]'), 'i').replaceAll(RegExp(r'[óòôõö]'), 'o').replaceAll(RegExp(r'[úùûü]'), 'u').replaceAll(RegExp(r'[ç]'), 'c');
  }

  void _filterChapters() {
    final query = _searchController.text;
    setState(() {
      _filteredChapters = widget.book.chapters.where((chapter) {
        return _normalize(chapter.name).contains(_normalize(query));
      }).toList();
    });
  }

  // --- FUNÇÃO DE PLAY REATORADA ---
  Future<void> _playAudio(String url, int originalIndex) async {
    try {
      if (_currentIndex == originalIndex) {
        if (_player.playing) {
          await _player.pause();
        } else {
          await _player.play();
        }
      } else {
        // Mostra o loading MANUALMENTE antes de carregar
        setState(() {
          _currentIndex = originalIndex;
          _currentPosition = Duration.zero;
          _audioDuration = Duration.zero;
          _isCurrentlyBuffering = true; // Feedback imediato para o usuário
        });

        await _player.setAudioSource(
          AudioSource.uri(Uri.parse(url)),
          // Preload garante que ele comece a carregar antes de tocar
          preload: true,
        );
        await _player.play();
      }
    } catch (e) {
      print("Erro ao tocar áudio: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Houve um problema ao tocar o áudio')),
      );
      // Se der erro, garante que o loading para
      if (mounted) setState(() => _isCurrentlyBuffering = false);
    }
  }

  void _playNextAudio() {
    if (_currentIndex == null || widget.book.chapters.isEmpty) return;
    int nextIndexInFullList = _currentIndex! + 1;
    if (nextIndexInFullList >= widget.book.chapters.length) {
      nextIndexInFullList = 0; // Loop para o início
    }
    final nextChapter = widget.book.chapters[nextIndexInFullList];
    _playAudio(nextChapter.url, nextIndexInFullList);
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
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.secondary),
        title: Text(widget.book.title, style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Pesquisar capítulo",
                labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                border: const OutlineInputBorder(),
                prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.secondary),
                suffixIcon: IconButton(
                  onPressed: () => _searchController.clear(),
                  icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.secondary),
                ),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary)),
              ),
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
              cursorColor: Theme.of(context).colorScheme.secondary,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredChapters.length,
              itemBuilder: (context, index) {
                final chapter = _filteredChapters[index];
                final originalIndex = widget.book.chapters.indexOf(chapter);
                final isCurrentlySelected = _currentIndex == originalIndex;
                final isPlaying = isCurrentlySelected && _player.playing;

                // A condição de loading agora é dupla: o estado do player OU o clique inicial
                final showLoading = isCurrentlySelected && _isCurrentlyBuffering;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  color: Theme.of(context).colorScheme.primary,
                  elevation: isCurrentlySelected ? 6 : 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            child: showLoading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Theme.of(context).colorScheme.primary),
                          ),
                          title: Text(chapter.name, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary)),
                          onTap: () => _playAudio(chapter.url, originalIndex),
                        ),
                        if (isCurrentlySelected)
                          Column(
                            children: [
                              Slider(
                                value: _currentPosition.inSeconds.toDouble(),
                                min: 0,
                                max: _audioDuration.inSeconds.toDouble().clamp(1.0, double.infinity),
                                onChanged: (value) async => await _player.seek(Duration(seconds: value.toInt())),
                                activeColor: Theme.of(context).colorScheme.secondary,
                                inactiveColor: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(_formatDuration(_currentPosition), style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.secondary)),
                                    Text(_formatDuration(_audioDuration), style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.secondary)),
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
        ],
      ),
    );
  }
}
