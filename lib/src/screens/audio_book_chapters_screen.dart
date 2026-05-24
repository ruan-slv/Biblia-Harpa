import 'dart:io';
import 'package:biblia_e_harpa/src/controllers/font_size_controller.dart';
import 'package:biblia_e_harpa/src/screens/bible_audios_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../components/app_bar_component.dart';

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
  double _volume = 1.0;
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

    _player.setVolume(_volume);
  }

  @override
  void dispose() {
    _player.dispose();
    _searchController.removeListener(_filterChapters);
    _searchController.dispose();

    super.dispose();
  }
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
    if (kIsWeb) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Download não suportado nesta plataforma.')),
        );
      }
      return;
    }

    if (_isDownloading[index] == true) return;

    setState(() {
      _isDownloading[index] = true;
    });

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
        setState(() {
          _isDownloading[index] = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao baixar o áudio.')),
        );
      }
    }
  }
  Future<void> _deleteAudio(String chapterName, int index) async {
    if (kIsWeb) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Remoção não suportada nesta plataforma.')),
        );
      }
      return;
    }

    try {
      final path = await _getLocalFilePath(chapterName);
      if (path.isEmpty) return;
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        if (mounted) {
          setState(() {
            _downloadedChapters.remove(index);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Áudio removido do dispositivo.')),
          );
        }
      }
    } catch (_) {}
  }

  Future<void> _shareAudio(AudioData audio) async {
    try {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preparando áudio para compartilhar...'),
          duration: Duration(seconds: 2),
        ),
      );

      final localPath = await _getLocalFilePath(audio.name);
      XFile fileToShare;

      if (localPath.isNotEmpty && await File(localPath).exists()) {
        fileToShare = XFile(localPath);
      } else {
        final response = await http.get(Uri.parse(audio.url));
        final tempDir = await getTemporaryDirectory();
        final tempFile = File(
          '${tempDir.path}/${audio.name.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_')}.mp3',
        );

        await tempFile.writeAsBytes(response.bodyBytes);
        fileToShare = XFile(tempFile.path);
      }

      await SharePlus.instance.share(
        ShareParams(
          files: [fileToShare],
          text: 'Ouça este trecho da Bíblia: ${audio.name} - ${widget.book.title}',
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Não foi possível compartilhar o áudio.")),
      );
    }
  }

  Future<void> _updateVolume(double newVolume) async {
    final normalizedVolume = newVolume.clamp(0.0, 1.0);
    await _player.setVolume(normalizedVolume);
    if (!mounted) return;
    setState(() {
      _volume = normalizedVolume;
    });
  }

  Future<void> _playAudio(String url, int originalIndex) async {
    try {
      if (_currentIndex == originalIndex) {
        if (_player.playing) {
          await _player.pause();
        } else {
          await _player.play();
        }
      } else {
        setState(() {
          _currentIndex = originalIndex;
          _currentPosition = Duration.zero;
          _audioDuration = Duration.zero;
          _isCurrentlyBuffering = true;
        });

        final chapterName = widget.book.chapters[originalIndex].name;
        bool usedLocal = false;
        try {
          final localPath = await _getLocalFilePath(chapterName);
          if (localPath.isNotEmpty) {
            final file = File(localPath);
            if (await file.exists()) {
              await _player.setAudioSource(
                AudioSource.file(localPath),
                preload: true,
              );
              usedLocal = true;
            }
          }
        } catch (_) {}

        if (!usedLocal) {
          await _player.setAudioSource(
            AudioSource.uri(Uri.parse(url)),
            preload: true,
          );
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

  void _filterChapters() {
    final query = _searchController.text;
    setState(() {
      _filteredChapters = widget.book.chapters.where((chapter) {
        return _normalize(chapter.name).contains(_normalize(query));
      }).toList();
    });
  }

  void _playNextAudio() {
    if (_currentIndex == null || widget.book.chapters.isEmpty) return;
    int nextIndexInFullList = _currentIndex! + 1;
    if (nextIndexInFullList >= widget.book.chapters.length) {
      nextIndexInFullList = 0;
    }
    final nextChapter = widget.book.chapters[nextIndexInFullList];
    _playAudio(nextChapter.url, nextIndexInFullList);
  }

  void _playPreviousAudio() {
    if (_currentIndex == null || widget.book.chapters.isEmpty) return;
    int prevIndexInFullList = _currentIndex! - 1;
    if (prevIndexInFullList < 0) {
      prevIndexInFullList = widget.book.chapters.length - 1;
    }
    final prevChapter = widget.book.chapters[prevIndexInFullList];
    _playAudio(prevChapter.url, prevIndexInFullList);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Future<void> _buildDrawer() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (ctx) {
        final ScrollController scrollController = ScrollController();
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
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 8),
                Center(
                    child: Text("Lista de Capítulos",
                        style: TextStyle(
                            color: Theme.of(ctx)
                                .colorScheme
                                .secondary
                                .withValues(alpha: 0.8),
                            fontWeight: FontWeight.bold))),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Pesquisar capítulo...",
                      hintStyle: TextStyle(
                          color: Theme.of(ctx)
                              .colorScheme
                              .secondary
                              .withValues(alpha: 0.7)),
                      prefixIcon: Icon(Icons.search,
                          color: Theme.of(ctx).colorScheme.secondary),
                      suffixIcon: IconButton(
                          onPressed: () {
                            _searchController.clear();
                          },
                          icon: Icon(Icons.clear,
                              color: Theme.of(ctx).colorScheme.secondary)),
                      filled: true,
                      fillColor:
                          Theme.of(ctx).colorScheme.surface.withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 20),
                    ),
                    style:
                        TextStyle(color: Theme.of(ctx).colorScheme.secondary),
                    cursorColor: Theme.of(ctx).colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _filteredChapters.length,
                    itemBuilder: (context, index) {
                      final chapter = _filteredChapters[index];
                      final originalIndex =
                          widget.book.chapters.indexOf(chapter);
                      final isCurrentlySelected =
                          _currentIndex == originalIndex;
                      final isDownloaded =
                          _downloadedChapters.contains(originalIndex);
                      final isDownloading =
                          _isDownloading[originalIndex] == true;

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: isCurrentlySelected
                              ? Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withValues(alpha: 0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: Icon(
                            isCurrentlySelected && _player.playing
                                ? Icons.volume_up_rounded
                                : Icons.play_circle_outline_rounded,
                            color: isCurrentlySelected
                                ? Theme.of(context).colorScheme.secondary
                                : Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withValues(alpha: 0.5),
                            size: 30,
                          ),
                          title: ValueListenableBuilder(
                            valueListenable:
                                FontSizeController.fontSizeNotifier,
                            builder: (context, fontSize, _) {
                              return Text(
                                chapter.name,
                                style: TextStyle(
                                  fontWeight: isCurrentlySelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontSize: fontSize,
                                ),
                              );
                            },
                          ),
                          trailing: SizedBox(
                            width: 40,
                            height: 40,
                            child: isDownloading
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary),
                                  )
                                : IconButton(
                                    icon: Icon(
                                      isDownloaded
                                          ? Icons.download_done_rounded
                                          : Icons.download_rounded,
                                      color: isDownloaded
                                          ? Colors.green
                                          : Theme.of(context)
                                              .colorScheme
                                              .secondary
                                              .withValues(alpha: 0.5),
                                    ),
                                    onPressed: () {
                                      if (isDownloaded) {
                                        _deleteAudio(
                                            chapter.name, originalIndex);
                                      } else {
                                        _downloadAudio(chapter.url,
                                            chapter.name, originalIndex);
                                      }
                                    },
                                  ),
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
                const SizedBox(height: 20),
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
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(
        centerTitle: false,
        automaticallyImplyLeading: true,
        title: widget.book.title,
      ),
      body: Stack(
          children: [
          Positioned.fill(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                )
                              ],
                            ),
                            child: Icon(
                              Icons.menu_book_rounded,
                              size: 80,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          if (isCurrentDownloaded)
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.offline_pin,
                                    color: Colors.white, size: 20),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          currentChapterName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.book.title,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => _buildDrawer(),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                        child: Text(
                          'Selecionar',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary),
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (_currentIndex != null)
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () =>
                                  _shareAudio(widget.book.chapters[_currentIndex!]),
                              icon: const Icon(Icons.share_outlined),
                              label: const Text('Compartilhar'),
                            ),
                            OutlinedButton.icon(
                              onPressed: isCurrentDownloaded
                                  ? () => _deleteAudio(
                                      widget.book.chapters[_currentIndex!].name,
                                      _currentIndex!,
                                    )
                                  : () => _downloadAudio(
                                      widget.book.chapters[_currentIndex!].url,
                                      widget.book.chapters[_currentIndex!].name,
                                      _currentIndex!,
                                    ),
                              icon: Icon(
                                isCurrentDownloaded
                                    ? Icons.delete_outline_rounded
                                    : Icons.download_rounded,
                              ),
                              label: Text(
                                isCurrentDownloaded ? 'Remover download' : 'Baixar',
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          children: [
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 8.0),
                                overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 16.0),
                                trackHeight: 4.0,
                              ),
                              child: Slider(
                                value: _currentPosition.inSeconds.toDouble(),
                                min: 0,
                                max: _audioDuration.inSeconds
                                    .toDouble()
                                    .clamp(1.0, double.infinity),
                                onChanged: (value) => _player
                                    .seek(Duration(seconds: value.toInt())),
                                activeColor:
                                    Theme.of(context).colorScheme.secondary,
                                inactiveColor: Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_formatDuration(_currentPosition),
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary)),
                                  Text(_formatDuration(_audioDuration),
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () => _updateVolume(_volume - 0.1),
                                icon: const Icon(Icons.volume_down_rounded),
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      'Volume ${(_volume * 100).round()}%',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.secondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Slider(
                                      value: _volume,
                                      min: 0,
                                      max: 1,
                                      divisions: 10,
                                      activeColor:
                                          Theme.of(context).colorScheme.secondary,
                                      inactiveColor: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withValues(alpha: 0.24),
                                      onChanged: _updateVolume,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => _updateVolume(_volume + 0.1),
                                icon: const Icon(Icons.volume_up_rounded),
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                              icon: const Icon(Icons.replay_10_rounded),
                              iconSize: 32.0,
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withValues(alpha: 0.8),
                              onPressed: () => _player.seek(Duration(
                                  seconds: _currentPosition.inSeconds - 10))),
                          IconButton(
                              icon: const Icon(Icons.skip_previous_rounded),
                              iconSize: 40.0,
                              color: Theme.of(context).colorScheme.secondary,
                              onPressed: _playPreviousAudio),
                          SizedBox(
                            width: 70,
                            height: 70,
                            child: Center(
                              child: _isCurrentlyBuffering
                                  ? CircularProgressIndicator(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary)
                                  : InkWell(
                                      borderRadius: BorderRadius.circular(50),
                                      onTap: () {
                                        if (_currentIndex != null) {
                                          isPlaying
                                              ? _player.pause()
                                              : _player.play();
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary
                                                      .withValues(alpha: 0.3),
                                                  blurRadius: 10,
                                                  spreadRadius: 2)
                                            ]),
                                        child: Icon(
                                            isPlaying
                                                ? Icons.pause_rounded
                                                : Icons.play_arrow_rounded,
                                            size: 40.0,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                      ),
                                    ),
                            ),
                          ),
                          IconButton(
                              icon: const Icon(Icons.skip_next_rounded),
                              iconSize: 40.0,
                              color: Theme.of(context).colorScheme.secondary,
                              onPressed: _playNextAudio),
                          IconButton(
                              icon: const Icon(Icons.forward_10_rounded),
                              iconSize: 32.0,
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withValues(alpha: 0.8),
                              onPressed: () => _player.seek(Duration(
                                  seconds: _currentPosition.inSeconds + 10))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
        ),

    );
  }
}
