import 'package:biblia_e_harpa/src/components/appBarComponent.dart';
import 'package:biblia_e_harpa/src/components/bottombar.dart';
import 'package:just_audio/just_audio.dart';
import 'package:biblia_e_harpa/src/controllers/bible_controller.dart';
import 'package:biblia_e_harpa/src/controllers/fontSizeController.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class AudioChapter {
  final String name;
  final String url;

  AudioChapter({required this.name, required this.url});

  factory AudioChapter.fromJson(Map<String, dynamic> json) {
    return AudioChapter(name: json["name"], url: json["url"]);
  }
}

class Textbiblescreen extends StatefulWidget {
  final String bookName;
  final String jsonPath;
  final int initialChapterNumber;
  final List<List<dynamic>> allBookChapters;
  final List<AudioChapter>? audioChapters;

  const Textbiblescreen({
    super.key,
    required this.bookName,
    required this.jsonPath,
    required this.initialChapterNumber,
    required this.allBookChapters,
    this.audioChapters,
  });

  @override
  State<Textbiblescreen> createState() => _TextbiblescreenState();
}

class _TextbiblescreenState extends State<Textbiblescreen> {
  late int currentChapterNumber;
  late List<dynamic> currentVerses;
  final ScrollController _scrollController = ScrollController();
  final BibleController _bibleController = BibleController();
  List<int> _selectedVerseIndices = [];
  final int _verseSelectionLimit = 15;

  final AudioPlayer _audioPlayer = AudioPlayer();
  AudioChapter? _currentAudioChapter;
  final TextEditingController _fillterKeyWordController =
      TextEditingController();
  List<int> _filteredVerseIndices = [];
  bool _isAutoScrollEnabled = false;

  @override
  void initState() {
    super.initState();
    currentChapterNumber = widget.initialChapterNumber;
    if (currentChapterNumber < 1) currentChapterNumber = 1;
    if (currentChapterNumber > widget.allBookChapters.length &&
        widget.allBookChapters.isNotEmpty) {
      currentChapterNumber = widget.allBookChapters.length;
    }

    if (widget.allBookChapters.isNotEmpty &&
        currentChapterNumber - 1 < widget.allBookChapters.length) {
      currentVerses = widget.allBookChapters[currentChapterNumber - 1];
    } else {
      currentVerses = [];
    }

    _loadAudioForChapter(currentChapterNumber);
    _filteredVerseIndices = List<int>.generate(currentVerses.length, (i) => i);

    _audioPlayer.positionStream.listen((position) {
      if (_isAutoScrollEnabled && _audioPlayer.duration != null) {
        _syncScrollWithAudio(position, _audioPlayer.duration!);
      }
    });
  }

  void _syncScrollWithAudio(Duration position, Duration total) {
    if (!_scrollController.hasClients || total.inMilliseconds == 0) return;

    final double percentage = position.inMilliseconds / total.inMilliseconds;
    final double maxScroll = _scrollController.position.maxScrollExtent;
    final double targetScroll = maxScroll * percentage.clamp(0.0, 1.0);

    _scrollController.animateTo(
      targetScroll,
      duration: const Duration(milliseconds: 500),
      curve: Curves.linear,
    );
  }

  void _filterKeyWords() {
    final query = _fillterKeyWordController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredVerseIndices =
            List<int>.generate(currentVerses.length, (i) => i);
      } else {
        final List<int> matches = [];
        for (int i = 0; i < currentVerses.length; i++) {
          if (currentVerses[i].toString().toLowerCase().contains(query)) {
            matches.add(i);
          }
        }
        _filteredVerseIndices = matches;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _audioPlayer.dispose();
    _fillterKeyWordController.dispose();
    super.dispose();
  }

  void _loadAudioForChapter(int chapterNumber) async {
    await _audioPlayer.stop();

    if (widget.audioChapters != null &&
        chapterNumber > 0 &&
        chapterNumber - 1 < widget.audioChapters!.length) {
      final audio = widget.audioChapters![chapterNumber - 1];
      try {
        await _audioPlayer.setUrl(audio.url);
        if (mounted) {
          setState(() {
            _currentAudioChapter =
                audio;
          });
        }
      } catch (e) {
        if (mounted) setState(() => _currentAudioChapter = null);
      }
    } else {
      if (mounted) setState(() => _currentAudioChapter = null);
    }
  }

  void _navigateToChapter(int newChapterNumber) {
    if (newChapterNumber >= 1 &&
        newChapterNumber <= widget.allBookChapters.length) {
      setState(() {
        currentChapterNumber = newChapterNumber;
        currentVerses = widget.allBookChapters[currentChapterNumber - 1];
        _selectedVerseIndices = [];
        _fillterKeyWordController.clear();
        _filteredVerseIndices =
            List<int>.generate(currentVerses.length, (i) => i);
      });
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
      _loadAudioForChapter(newChapterNumber);
    }
  }

  void _nextChapter() {
    if (currentChapterNumber < widget.allBookChapters.length) {
      _navigateToChapter(currentChapterNumber + 1);
    }
  }

  void _previousChapter() {
    if (currentChapterNumber > 1) {
      _navigateToChapter(currentChapterNumber - 1);
    }
  }

  void _showSelectionLimitWarning() {
    if (ModalRoute.of(context)?.isCurrent != true) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            "Aviso de Limite",
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
          content: Text(
            "Selecionar muitos versículos pode fazer com que o texto seja cortado ao compartilhar em algumas redes sociais. Considere compartilhar a quantidade máxima de versículos e depois realizar um novo compartilhamento com o restante dos versículos desejados!",
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                "Entendi",
                style:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _toggleVerseSelection(int index) {
    setState(() {
      if (_selectedVerseIndices.contains(index)) {
        _selectedVerseIndices.remove(index);
      } else {
        if (_selectedVerseIndices.length >= _verseSelectionLimit) {
          _showSelectionLimitWarning();
          return;
        }
        _selectedVerseIndices.add(index);
      }
    });
  }

  void _clearSelections() {
    setState(() => _selectedVerseIndices = []);
  }

  String _getDataForSharing() {
    StringBuffer shareText = StringBuffer();
    shareText.writeln("${widget.bookName} - Capítulo $currentChapterNumber");
    shareText.writeln();

    List<int> sortedIndices = _selectedVerseIndices.isNotEmpty
        ? (List.from(_selectedVerseIndices)..sort())
        : List<int>.generate(
            currentVerses.length.clamp(0, _verseSelectionLimit), (i) => i);

    for (int index in sortedIndices) {
      if (index < currentVerses.length) {
        shareText.writeln("${index + 1}. ${currentVerses[index]}");
      }
    }
    return shareText.toString();
  }

  Widget _buildAudioPlayer() {
    if (_currentAudioChapter == null) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.9),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Verificando áudio...",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 14,
                ),
              )
            ],
          ),
        ),
      );
    }
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.9),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            StreamBuilder<PlayerState>(
              stream: _audioPlayer.playerStateStream,
              builder: (context, snapshot) {
                final playerState = snapshot.data;
                final processingState = playerState?.processingState;
                final playing = playerState?.playing;
                if (processingState == ProcessingState.loading ||
                    processingState == ProcessingState.buffering) {
                  return CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.secondary);
                }
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon((playing ?? false)
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled),
                      iconSize: 48.0,
                      color: Theme.of(context).colorScheme.secondary,
                      onPressed: () => (playing ?? false)
                          ? _audioPlayer.pause()
                          : _audioPlayer.play(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.stop_circle_outlined),
                      iconSize: 48.0,
                      color: Theme.of(context).colorScheme.secondary,
                      onPressed: () {
                        _audioPlayer.stop();
                        _audioPlayer.seek(Duration.zero);
                      },
                    ),
                  ],
                );
              },
            ),
            Expanded(
              child: StreamBuilder<Duration>(
                stream: _audioPlayer.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final duration = _audioPlayer.duration ?? Duration.zero;
                  return Slider(
                    value: position.inSeconds
                        .clamp(0, duration.inSeconds)
                        .toDouble(),
                    max: duration.inSeconds.toDouble(),
                    onChanged: (value) =>
                        _audioPlayer.seek(Duration(seconds: value.toInt())),
                    activeColor: Theme.of(context).colorScheme.secondary,
                    inactiveColor: Colors.grey.withValues(alpha: 0.5),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (widget.allBookChapters.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(widget.bookName),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.secondary,
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  _isAutoScrollEnabled = !_isAutoScrollEnabled;
                });

                if (_isAutoScrollEnabled && !_audioPlayer.playing) {
                  _audioPlayer.play();
                }
              },
              icon: Icon(
                _isAutoScrollEnabled
                    ? Icons.auto_stories
                    : Icons.auto_stories_outlined,
                color: _isAutoScrollEnabled ? Colors.orangeAccent : null,
              ),
              tooltip: 'Acompanhamento automático',
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Center(
          child: ValueListenableBuilder<double>(
            valueListenable: FontSizeController.fontSizeNotifier,
            builder: (context, fontSize, _) {
              return Text(
                'Nenhum capítulo disponível para este livro.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: fontSize,
                ),
                textAlign: TextAlign.center,
              );
            },
          ),
        ),
      );
    }

    final chapterId = "${widget.bookName}_$currentChapterNumber";
    final bool noFilterResults = _fillterKeyWordController.text.isNotEmpty &&
        _filteredVerseIndices.isEmpty;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(
        title: widget.bookName,
        centerTitle: false,
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isAutoScrollEnabled = !_isAutoScrollEnabled;
              });

              if (_isAutoScrollEnabled &&
                  !_audioPlayer.playing &&
                  _currentAudioChapter != null) {
                _audioPlayer.play();
              }
            },
            icon: Icon(
              _isAutoScrollEnabled
                  ? Icons.auto_stories
                  : Icons.auto_stories_outlined,
              color: _isAutoScrollEnabled ? Colors.orangeAccent : null,
            ),
            tooltip: 'Acompanhamento automático',
          ),
          if (_selectedVerseIndices.isNotEmpty)
            IconButton(
              onPressed: _clearSelections,
              icon: const Icon(Icons.clear),
              tooltip: 'Limpar seleções',
            ),
          IconButton(
            onPressed: () {
              if (_selectedVerseIndices.isEmpty) {
                setState(() {
                  _selectedVerseIndices = List<int>.generate(
                    currentVerses.length < _verseSelectionLimit
                        ? currentVerses.length
                        : _verseSelectionLimit,
                    (i) => i,
                  );
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        '10 primeiros versículos selecionados para compartilhamento.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              } else {
                if (currentVerses.isNotEmpty) {
                  final String chapterText = _getDataForSharing();
                  SharePlus.instance.share(
                    ShareParams(
                      text: chapterText,
                      subject: "${widget.bookName}: $currentChapterNumber",
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Não há versículos para compartilhar neste capítulo.'),
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      bottomNavigationBar: ValueListenableBuilder<List<String>>(
        valueListenable: _bibleController.textosLidosNotifier,
        builder: (context, textosLidos, _) {
          final bool isRead = textosLidos.contains(chapterId);
          return BottomBar(
            canGoBack: currentChapterNumber > 1,
            canGoNext: currentChapterNumber < widget.allBookChapters.length,
            onPrevious: _previousChapter,
            onNext: _nextChapter,
            topChild: InkWell(
              onTap: () => _bibleController.toggleReadStatus(chapterId),
              borderRadius: BorderRadius.circular(20),
              child: Ink(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: isRead
                      ? Colors.green.withValues(alpha: 0.16)
                      : colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isRead
                        ? Colors.green.withValues(alpha: 0.45)
                        : colorScheme.secondary.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        color: isRead ? Colors.green : colorScheme.secondary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        isRead
                            ? Icons.check_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: isRead ? Colors.white : colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isRead ? "Capítulo concluído" : "Marcar como lido",
                            style: TextStyle(
                              color: colorScheme.secondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isRead
                                ? "Toque para marcar como não lido."
                                : "Toque para marcar como lido.",
                            style: TextStyle(
                              color:
                                  colorScheme.secondary.withValues(alpha: 0.72),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      body: Center(
        child: CustomScrollView(
            controller: _scrollController,
            slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _fillterKeyWordController,
                keyboardType: TextInputType.text,
                onChanged: (_) => _filterKeyWords(),
                decoration: InputDecoration(
                  hintText: "Pesquisar Palavra-chave",
                  hintStyle:
                      TextStyle(color: Theme.of(context).colorScheme.secondary),
                  prefixIcon: Icon(Icons.search,
                      color: Theme.of(context).colorScheme.secondary),
                  suffixIcon: IconButton(
                    onPressed: () {
                      _fillterKeyWordController.clear();
                      _filterKeyWords();
                    },
                    icon: Icon(Icons.clear,
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.primary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                ),
                style:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
                cursorColor: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildAudioPlayer(),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 25, bottom: 10),
                child: ValueListenableBuilder(
                  valueListenable: FontSizeController.fontSizeNotifier,
                  builder: (context, fontSize, _) {
                    return Text(
                      "Capítulo $currentChapterNumber de ${widget.allBookChapters.length}",
                      style: TextStyle(
                        fontSize: fontSize * 1.13,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          if (noFilterResults)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: ValueListenableBuilder<double>(
                  valueListenable: FontSizeController.fontSizeNotifier,
                  builder: (context, fontSize, _) {
                    return Text(
                      'Nenhum versículo encontrado para "${_fillterKeyWordController.text}" neste capítulo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: fontSize,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    );
                  },
                ),
              ),
            ),

          SliverPadding(
            padding: const EdgeInsets.all(6.0),
            sliver: noFilterResults
                ? const SliverToBoxAdapter(child: SizedBox.shrink())
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == _filteredVerseIndices.length) {
                          return const SizedBox(height: 24);
                        }

                        final int originalIndex = _filteredVerseIndices[index];
                        final String verseText = currentVerses[originalIndex].toString();
                        final int verseNumber = originalIndex + 1;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: GestureDetector(
                            onTap: () => _toggleVerseSelection(originalIndex),
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: _selectedVerseIndices
                                        .contains(originalIndex)
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.9)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ValueListenableBuilder<double>(
                                        valueListenable:
                                            FontSizeController.fontSizeNotifier,
                                        builder: (context, fontSize, _) {
                                          return Text(
                                            "$verseNumber ",
                                            style: TextStyle(
                                              fontSize: fontSize,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary
                                                  .withValues(alpha: 0.9)
                                            ),
                                          );
                                        },
                                      ),
                                      Expanded(
                                        child: ValueListenableBuilder<double>(
                                          valueListenable: FontSizeController
                                              .fontSizeNotifier,
                                          builder: (context, fontSize, _) {
                                            return Text(
                                              verseText,
                                              style: TextStyle(
                                                fontSize: fontSize,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary,
                                                height: 1.4,
                                              ),
                                              textAlign: TextAlign.justify,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: _filteredVerseIndices.length + 1,
                    ),
                  ),
          ),
        ],
          ),
        ),

    );
  }
}
