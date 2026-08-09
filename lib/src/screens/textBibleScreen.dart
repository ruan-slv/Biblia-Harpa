// lib/src/screens/textBibleScreen.dart

import 'dart:convert';
import 'package:biblia_e_harpa/src/components/appBarComponent.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:biblia_e_harpa/src/controllers/bible_controller.dart';
import 'package:biblia_e_harpa/src/controllers/fontSizeController.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

// Modelo para os dados do áudio
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
  final List<AudioChapter>? audioChapters; // Recebe a lista de áudios

  const Textbiblescreen({
    super.key,
    required this.bookName,
    required this.jsonPath,
    required this.initialChapterNumber,
    required this.allBookChapters,
    this.audioChapters, // Parâmetro opcional no construtor
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
  final int _verseSelectionLimit = 10;

  // Controle do Player de Áudio
  final AudioPlayer _audioPlayer = AudioPlayer();
  AudioChapter? _currentAudioChapter;

  // Controle de Filtro (Utiliza lista de índices para referência aos versículos originais)
  final TextEditingController _fillterKeyWordController =
      TextEditingController();
  List<int> _filteredVerseIndices =
      []; // Lista de índices dos versículos que correspondem ao filtro.

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

    // Carrega o áudio para o capítulo inicial
    _loadAudioForChapter(currentChapterNumber);
    // Inicializa lista filtrada com todos os índices (0 a N-1)
    _filteredVerseIndices = List<int>.generate(currentVerses.length, (i) => i);

    _audioPlayer.positionStream.listen((position) {
      if (_isAutoScrollEnabled && _audioPlayer.duration != null) {
        _syncScrollWithAudio(position, _audioPlayer.duration!);
      }
    });
  }

  void _syncScrollWithAudio(Duration position, Duration total) {
    if (!_scrollController.hasClients) return;

    double percentage = position.inMilliseconds / total.inMilliseconds;

    double maxScroll = _scrollController.position.maxScrollExtent;
    double targetScroll = maxScroll * percentage;

    _scrollController.animateTo(targetScroll,
        duration: const Duration(milliseconds: 500), curve: Curves.linear);
  }

  // MÉTODO DE FILTRAGEM CORRIGIDO E CENTRALIZADO
  void _filterKeyWords() {
    final query = _fillterKeyWordController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        // Se a busca estiver vazia, exibe todos os versículos
        _filteredVerseIndices =
            List<int>.generate(currentVerses.length, (i) => i);
      } else {
        // Filtra e armazena APENAS os índices que contêm a palavra-chave
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
    _audioPlayer.dispose(); // Libera os recursos do player ao sair
    _fillterKeyWordController.dispose(); // Adicionado dispose
    super.dispose();
  }

  // Método para carregar e preparar o áudio
  void _loadAudioForChapter(int chapterNumber) async {
    await _audioPlayer.stop(); // Garante que o áudio anterior pare

    if (widget.audioChapters != null &&
        chapterNumber > 0 &&
        chapterNumber - 1 < widget.audioChapters!.length) {
      final audio = widget.audioChapters![chapterNumber - 1];
      try {
        await _audioPlayer.setUrl(audio.url); // Prepara o áudio
        if (mounted) {
          setState(() {
            _currentAudioChapter =
                audio; // Atualiza o estado para mostrar o player
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
        // Reinicia filtro ao mudar de capítulo
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
      // Carrega o áudio correspondente ao novo capítulo
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
          backgroundColor: Theme.of(context).colorScheme.background,
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
        color: Theme.of(context).colorScheme.primary.withOpacity(0.9),
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
      color: Theme.of(context).colorScheme.primary.withOpacity(0.9),
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
                    inactiveColor: Colors.grey.withOpacity(0.5),
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
    if (widget.allBookChapters.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget.bookName),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.secondary,
          actions: [
            // Botão de Auto-Scroll (Vazio)
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
              tooltip: 'Acompanhamento Automático',
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
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
    // Variável para verificar se o filtro está ativo E sem resultados
    final bool noFilterResults = _fillterKeyWordController.text.isNotEmpty &&
        _filteredVerseIndices.isEmpty;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: CustomAppBar(
        title: '${widget.bookName} - Cap. $currentChapterNumber',
        centerTitle: true,
        automaticallyImplyLeading: true,
        actions: [
          // BOTÃO DE AUTO-SCROLL (Acompanhamento Automático)
          IconButton(
            onPressed: () {
              setState(() {
                _isAutoScrollEnabled = !_isAutoScrollEnabled;
              });

              // Se ativar o scroll e o áudio não estiver tocando, inicia o play
              if (_isAutoScrollEnabled && !_audioPlayer.playing && _currentAudioChapter != null) {
                _audioPlayer.play();
              }
            },
            icon: Icon(
              _isAutoScrollEnabled
                  ? Icons.auto_stories
                  : Icons.auto_stories_outlined,
              color: _isAutoScrollEnabled ? Colors.orangeAccent : null,
            ),
            tooltip: 'Acompanhamento Automático',
          ),
          ValueListenableBuilder<List<String>>(
            valueListenable: _bibleController.textosLidosNotifier,
            builder: (context, textosLidos, _) {
              final bool isRead = textosLidos.contains(chapterId);
              return IconButton(
                onPressed: () {
                  _bibleController.toggleReadStatus(chapterId);
                },
                icon: Icon(
                  isRead ? Icons.remove_red_eye : Icons.remove_red_eye_outlined,
                  color: isRead
                      ? Colors.lightBlueAccent
                      : Theme.of(context).colorScheme.secondary,
                ),
                tooltip: isRead ? 'Marcar como não lido' : 'Marcar como lido',
              );
            },
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
                  Share.share(
                    chapterText,
                    subject:
                        "${widget.bookName} - Capítulo $currentChapterNumber",
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
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Campo de Busca/Filtro
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _fillterKeyWordController,
                // CORRIGIDO: Tipo de teclado para texto
                keyboardType: TextInputType.text,
                // CORRIGIDO: Chama o filtro ao digitar
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
                      // CORRIGIDO: Chama o filtro ao limpar
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
                padding: const EdgeInsets.only(top: 40, bottom: 10),
                child: ValueListenableBuilder(
                  valueListenable: FontSizeController.fontSizeNotifier,
                  builder: (context, fontSize, _) {
                    return Text(
                      "Capítulo $currentChapterNumber de ${widget.allBookChapters.length}",
                      style: TextStyle(
                        fontSize: fontSize * 1.20,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // NOVO: Mensagem de Nenhum Resultado Encontrado
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
            // CORRIGIDO: Renderiza uma lista vazia se não houver resultados de filtro
            sliver: noFilterResults
                ? const SliverToBoxAdapter(child: SizedBox.shrink())
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        // O último item é o botão de navegação
                        if (index == _filteredVerseIndices.length) {
                          return Padding(
                            padding:
                                const EdgeInsets.only(top: 30.0, bottom: 20),
                            child: ValueListenableBuilder<double>(
                              valueListenable:
                                  FontSizeController.fontSizeNotifier,
                              builder: (context, fontSize, _) {
                                return Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        ElevatedButton(
                                          onPressed: currentChapterNumber > 1
                                              ? _previousChapter
                                              : null,
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.all(20),
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            foregroundColor: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            elevation: 2,
                                          ),
                                          child: Text(
                                            "Anterior",
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                            ),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: currentChapterNumber <
                                                  widget.allBookChapters.length
                                              ? _nextChapter
                                              : null,
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.all(20),
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            foregroundColor: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            elevation: 2,
                                          ),
                                          child: Text(
                                            "Próximo",
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          );
                        }

                        // CORRIGIDO: Busca o índice real na lista filtrada
                        final int originalIndex = _filteredVerseIndices[index];
                        final String verseText =
                            currentVerses[originalIndex].toString();
                        final int verseNumber =
                            originalIndex + 1; // Número real do versículo

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: GestureDetector(
                            // CORRIGIDO: Usa o índice original para seleção
                            onTap: () => _toggleVerseSelection(originalIndex),
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: _selectedVerseIndices
                                        .contains(originalIndex)
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.9)
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
                                                  .withOpacity(0.9),
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
                      // CORRIGIDO: O childCount usa o tamanho da lista filtrada + 1 (para o botão)
                      childCount: _filteredVerseIndices.length + 1,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}