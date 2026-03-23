// lib/src/screens/audioBookChaptersScreen.dart

import 'dart:io';
import 'package:biblia_e_harpa/src/controllers/fontSizeController.dart';
import 'package:biblia_e_harpa/src/screens/bibleAudiosScreen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;

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

  bool _isCurrentlyBuffering = false;
  int? _currentIndex;
  Duration _currentPosition = Duration.zero;
  Duration _audioDuration = Duration.zero;
  final Map<int, bool> _isDownloading = {};
  final Set<int> _downloadedChapters = {};

  @override
  void initState() {
    super.initState();
    _filteredChapters = widget.book.chapters;
    _searchController.addListener(_filterChapters);
    _checkDownloadedChapters();

    _player.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        _isCurrentlyBuffering =
            state.processingState == ProcessingState.buffering ||
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

  // --- LÓGICA DE ARQUIVOS LOCAL ---

  Future<String> _getLocalFilePath(String fileName) async {
    if (kIsWeb) return '';
    try {
      final directory = await getApplicationDocumentsDirectory();
      final audioDir = Directory('${directory.path}/bible_audios');
      if (!await audioDir.exists()) {
        await audioDir.create(recursive: true);
      }
      final safeName =
          fileName.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_');
      return '${audioDir.path}/$safeName.mp3';
    } catch (e) {
      return '';
    }
  }

  Future<void> _checkDownloadedChapters() async {
    if (kIsWeb) return;
    try {
      for (int i = 0; i < widget.book.chapters.length; i++) {
        final path = await _getLocalFilePath(widget.book.chapters[i].name);
        if (path.isEmpty) continue;
        if (await File(path).exists()) {
          if (mounted) {
            setState(() {
              _downloadedChapters.add(i);
            });
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _downloadAudio(String url, String chapterName, int index) async {
    if (kIsWeb) return;
    if (_isDownloading[index] == true) return;

    setState(() => _isDownloading[index] = true);

    try {
      final dio = Dio();
      final savePath = await _getLocalFilePath(chapterName);
      if (savePath.isEmpty) throw Exception('Caminho local indisponível');

      await dio.download(url, savePath);

      if (mounted) {
        setState(() {
          _downloadedChapters.add(index);
          _isDownloading[index] = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$chapterName baixado com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDownloading[index] = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao baixar o áudio.')),
        );
      }
    }
  }

  Future<void> _deleteAudio(String chapterName, int index) async {
    try {
      final path = await _getLocalFilePath(chapterName);
      if (path.isEmpty) return;
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        if (mounted) {
          setState(() => _downloadedChapters.remove(index));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Áudio removido do dispositivo.')),
          );
        }
      }
    } catch (_) {}
  }

  // --- COMPARTILHAMENTO ---

  Future<void> _shareAudio(AudioData audio) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Preparando áudio para compartilhar...'),
            duration: Duration(seconds: 2)),
      );

      final localPath = await _getLocalFilePath(audio.name);
      XFile fileToShare;

      // Se o arquivo existe localmente, usa ele. Se não, baixa temporariamente.
      if (localPath.isNotEmpty && await File(localPath).exists()) {
        fileToShare = XFile(localPath);
      } else {
        final response = await http.get(Uri.parse(audio.url));
        final tempDir = await getTemporaryDirectory();
        final tempFile = File(
            '${tempDir.path}/${audio.name.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_')}.mp3');

        await tempFile.writeAsBytes(response.bodyBytes);
        fileToShare = XFile(tempFile.path);
      }

      await Share.shareXFiles(
        [fileToShare],
        text:
            'Ouça este trecho da Bíblia: ${audio.name} - ${widget.book.title}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Não foi possível compartilhar o áudio.")),
        );
      }
    }
  }

  // --- LÓGICA DE PLAYER ---

  Future<void> _playAudio(String url, int originalIndex) async {
    try {
      if (_currentIndex == originalIndex) {
        _player.playing ? await _player.pause() : await _player.play();
      } else {
        setState(() {
          _currentIndex = originalIndex;
          _currentPosition = Duration.zero;
          _audioDuration = Duration.zero;
          _isCurrentlyBuffering = true;
        });

        final chapterName = widget.book.chapters[originalIndex].name;
        bool usedLocal = false;

        final localPath = await _getLocalFilePath(chapterName);
        if (localPath.isNotEmpty && await File(localPath).exists()) {
          await _player.setAudioSource(AudioSource.file(localPath),
              preload: true);
          usedLocal = true;
        }

        if (!usedLocal) {
          await _player.setAudioSource(AudioSource.uri(Uri.parse(url)),
              preload: true);
        }
        await _player.play();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Houve um problema ao tocar o áudio')),
        );
        setState(() => _isCurrentlyBuffering = false);
      }
    }
  }

  void _filterChapters() {
    final query = _searchController.text;
    setState(() {
      _filteredChapters = widget.book.chapters.where((chapter) {
        return _normalize(chapter.name).contains(_normalize(query));
      }).toList();
    });
  }

  String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[áàâãä]'), 'a')
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[íìîï]'), 'i')
        .replaceAll(RegExp(r'[óòôõö]'), 'o')
        .replaceAll(RegExp(r'[úùûü]'), 'u')
        .replaceAll(RegExp(r'[ç]'), 'c');
  }

  void _playNextAudio() {
    if (_currentIndex == null || widget.book.chapters.isEmpty) return;
    int next = (_currentIndex! + 1) % widget.book.chapters.length;
    _playAudio(widget.book.chapters[next].url, next);
  }

  void _playPreviousAudio() {
    if (_currentIndex == null || widget.book.chapters.isEmpty) return;
    int prev = (_currentIndex! - 1) < 0
        ? widget.book.chapters.length - 1
        : _currentIndex! - 1;
    _playAudio(widget.book.chapters[prev].url, prev);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  Future<void> _buildDrawer() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (ctx) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: Padding(
            padding:
                EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                        color: Theme.of(ctx)
                            .colorScheme
                            .secondary
                            .withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Pesquisar capítulo...",
                      prefixIcon: Icon(Icons.search,
                          color: Theme.of(ctx).colorScheme.secondary),
                      filled: true,
                      fillColor:
                          Theme.of(ctx).colorScheme.background.withOpacity(0.5),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none),
                    ),
                    style:
                        TextStyle(color: Theme.of(ctx).colorScheme.secondary),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _filteredChapters.length,
                    itemBuilder: (context, index) {
                      final chapter = _filteredChapters[index];
                      final originalIndex =
                          widget.book.chapters.indexOf(chapter);
                      final isSelected = _currentIndex == originalIndex;
                      final isDownloaded =
                          _downloadedChapters.contains(originalIndex);
                      final isDownloading =
                          _isDownloading[originalIndex] == true;

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: Icon(
                              isSelected && _player.playing
                                  ? Icons.volume_up_rounded
                                  : Icons.play_circle_outline_rounded,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withOpacity(0.5)),
                          title: Text(chapter.name,
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary)),
                          trailing: Wrap(
                            spacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(Icons.share_rounded,
                                    size: 20,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary
                                        .withOpacity(0.6)),
                                onPressed: () => _shareAudio(chapter),
                              ),
                              SizedBox(
                                width: 32,
                                height: 32,
                                child: isDownloading
                                    ? CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary)
                                    : IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: Icon(
                                            isDownloaded
                                                ? Icons.download_done_rounded
                                                : Icons.download_rounded,
                                            size: 22,
                                            color: isDownloaded
                                                ? Colors.green
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .secondary
                                                    .withOpacity(0.5)),
                                        onPressed: () => isDownloaded
                                            ? _deleteAudio(
                                                chapter.name, originalIndex)
                                            : _downloadAudio(chapter.url,
                                                chapter.name, originalIndex),
                                      ),
                              ),
                            ],
                          ),
                          onTap: () {
                            _playAudio(chapter.url, originalIndex);
                            Navigator.pop(ctx);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentChapterName = _currentIndex != null
        ? widget.book.chapters[_currentIndex!].name
        : "Selecione um capítulo";
    final isPlaying = _player.playing;
    final bool isCurrentDownloaded =
        _currentIndex != null && _downloadedChapters.contains(_currentIndex);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.secondary),
        title: Text(widget.book.title,
            style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(30)),
                    child: Icon(Icons.menu_book_rounded,
                        size: 80,
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                  if (isCurrentDownloaded)
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                              color: Colors.green, shape: BoxShape.circle),
                          child: const Icon(Icons.offline_pin,
                              color: Colors.white, size: 20)),
                    ),
                ],
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(currentChapterName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary)),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _buildDrawer,
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: Text('Selecionar',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary)),
                  ),
                  const SizedBox(width: 10),
                  if (_currentIndex != null)
                    IconButton(
                      icon: Icon(Icons.share,
                          color: Theme.of(context).colorScheme.secondary),
                      onPressed: () =>
                          _shareAudio(widget.book.chapters[_currentIndex!]),
                    ),
                ],
              ),
              const SizedBox(height: 30),
              // Slider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    Slider(
                      value: _currentPosition.inSeconds.toDouble(),
                      min: 0,
                      max: _audioDuration.inSeconds
                          .toDouble()
                          .clamp(1.0, double.infinity),
                      onChanged: (value) =>
                          _player.seek(Duration(seconds: value.toInt())),
                      activeColor: Theme.of(context).colorScheme.secondary,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDuration(_currentPosition),
                              style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      Theme.of(context).colorScheme.secondary)),
                          Text(_formatDuration(_audioDuration),
                              style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      Theme.of(context).colorScheme.secondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Controles
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                      icon: const Icon(Icons.replay_10_rounded),
                      color: Theme.of(context).colorScheme.secondary,
                      onPressed: () => _player.seek(
                          Duration(seconds: _currentPosition.inSeconds - 10))),
                  IconButton(
                      icon: const Icon(Icons.skip_previous_rounded),
                      iconSize: 40,
                      color: Theme.of(context).colorScheme.secondary,
                      onPressed: _playPreviousAudio),
                  _isCurrentlyBuffering
                      ? CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.secondary)
                      : InkWell(
                          onTap: () => _currentIndex != null
                              ? (isPlaying ? _player.pause() : _player.play())
                              : null,
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary,
                                shape: BoxShape.circle),
                            child: Icon(
                                isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                size: 40,
                                color: Theme.of(context).colorScheme.primary),
                          ),
                        ),
                  IconButton(
                      icon: const Icon(Icons.skip_next_rounded),
                      iconSize: 40,
                      color: Theme.of(context).colorScheme.secondary,
                      onPressed: _playNextAudio),
                  IconButton(
                      icon: const Icon(Icons.forward_10_rounded),
                      color: Theme.of(context).colorScheme.secondary,
                      onPressed: () => _player.seek(
                          Duration(seconds: _currentPosition.inSeconds + 10))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
