// lib/src/screens/text_harp_screen.dart

import 'dart:convert';
import 'package:biblia_e_harpa/src/config.dart';
import 'package:biblia_e_harpa/src/controllers/fontSizeController.dart';
import 'package:biblia_e_harpa/src/keys/harpkey.dart';
import 'package:biblia_e_harpa/src/services/share_audio_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

class TextModel {
  final String hino;
  final String coro;
  final Map<String, String> verses;

  TextModel({required this.hino, required this.coro, required this.verses});

  factory TextModel.fromJson(Map<String, dynamic> json) {
    return TextModel(
      hino: json['hino'] ?? 'Hino não encontrado',
      coro: json['coro'] ?? 'Não possui coro',
      verses: Map<String, String>.from(json['verses'] ?? {}),
    );
  }
}

class HarpContentScreen extends StatefulWidget {
  const HarpContentScreen({
    super.key,
    required this.harp,
    this.audioUrl, // Recebe a URL do áudio
  });

  final String harp;
  final String? audioUrl;

  @override
  State<HarpContentScreen> createState() => _HarpContentScreenState();
}

class _HarpContentScreenState extends State<HarpContentScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ScrollController _scrollController = ScrollController(); // Adicionado para controlar o scroll
  bool _isLoadingAudio = false;
  bool _hasAudio = false;
  bool _isAutoScrollEnabled = false; // Estado para o acompanhamento automático

  @override
  void initState() {
    super.initState();
    _loadAudio();

    // Listener para sincronizar o scroll com a posição do áudio em tempo real
    _audioPlayer.positionStream.listen((position) {
      if (_isAutoScrollEnabled && _audioPlayer.duration != null) {
        _syncScrollWithAudio(position, _audioPlayer.duration!);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Limpeza do controlador de scroll
    _audioPlayer.dispose();
    super.dispose();
  }

  // Método que calcula a posição do scroll baseada na percentagem do áudio
  void _syncScrollWithAudio(Duration position, Duration total) {
    if (!_scrollController.hasClients) return;

    double percentage = position.inMilliseconds / total.inMilliseconds;
    double maxScroll = _scrollController.position.maxScrollExtent;
    double targetScroll = maxScroll * percentage;

    _scrollController.animateTo(
      targetScroll,
      duration: const Duration(milliseconds: 500),
      curve: Curves.linear,
    );
  }

  Future<void> _loadAudio() async {
    if (widget.audioUrl == null || widget.audioUrl!.isEmpty) {
      if (mounted) {
        setState(() {
          _hasAudio = false;
          _isLoadingAudio = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _hasAudio = true;
        _isLoadingAudio = true;
      });
    }

    try {
      await _audioPlayer.setUrl(widget.audioUrl!);
      if (mounted) {
        setState(() {
          _isLoadingAudio = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasAudio = false;
          _isLoadingAudio = false;
        });
      }
    }
  }

  Future<List<TextModel>> loadTexts() async {
    try {
      String jsonString = await rootBundle
          .loadString('assets/json/harpa_crista_640_hinos.json');
      Map<String, dynamic> jsonResponse = jsonDecode(jsonString);
      List<TextModel> texts = [];
      jsonResponse.forEach((key, value) {
        texts.add(TextModel.fromJson(value));
      });
      return texts;
    } catch (_) {
      return [];
    }
  }

  ShareAudioSource? shareAudioSource = ShareAudioSource();

  Widget _buildAudioPlayer() {
    if (!_hasAudio && !_isLoadingAudio) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 20.0),
      color: Theme.of(context).colorScheme.primary.withOpacity(0.9),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: _isLoadingAudio
            ? Row(
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
                    "Carregando áudio...",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 14,
                    ),
                  )
                ],
              )
            : Row(
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
                        return Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        );
                      }

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.share),
                            iconSize: 48.0,
                            color: Theme.of(context).colorScheme.secondary,
                            onPressed: () => shareAudioSource?.shareAudioSource(
                              widget.harp,
                              widget.audioUrl!,
                            ),
                          ),
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
                          max: duration.inSeconds > 0
                              ? duration.inSeconds.toDouble()
                              : 1.0,
                          onChanged: (value) => _audioPlayer
                              .seek(Duration(seconds: value.toInt())),
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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          widget.harp,
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.secondary),
        centerTitle: true,
        actions: [
          // Botão adicionado na AppBar para disparar o scroll automático
          IconButton(
            onPressed: () {
              setState(() {
                _isAutoScrollEnabled = !_isAutoScrollEnabled;
              });

              // Inicia o áudio se ativar o scroll e houver áudio disponível
              if (_isAutoScrollEnabled && !_audioPlayer.playing && _hasAudio) {
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<List<TextModel>>(
          future: loadTexts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Erro ao carregar os textos.'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Nenhum texto encontrado.'));
            }

            final harpText = snapshot.data!.firstWhere(
              (text) =>
                  text.hino.toLowerCase().trim() ==
                  widget.harp.toLowerCase().trim(),
              orElse: () => TextModel(hino: '', coro: '', verses: {}),
            );

            return SingleChildScrollView(
              controller: _scrollController, // Vinculação do controlador aqui
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildAudioPlayer(),
                    const SizedBox(height: 30),
                    ...harpText.verses.entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 30.0),
                        child: Column(
                          children: [
                            Text(
                              entry.key,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            ValueListenableBuilder<double>(
                              valueListenable: FontSizeController.fontSizeNotifier,
                              builder: (context, fontSize, _) {
                                return Text(
                                  entry.value,
                                  style: TextStyle(
                                    fontSize: fontSize,
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                                  textAlign: TextAlign.center,
                                );
                              },
                            ),
                            const SizedBox(height: 30.0),
                            ValueListenableBuilder<double>(
                              valueListenable: FontSizeController.fontSizeNotifier,
                              builder: (context, fontSize, _) {
                                return Text(
                                  harpText.coro,
                                  style: TextStyle(
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                                  textAlign: TextAlign.center,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
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