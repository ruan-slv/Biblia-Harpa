import 'dart:convert';
import 'package:biblia_e_harpa/src/view_model/settings_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'component/app_bar_component.dart';

class HarpTextModel {
  final String hino;
  final String coro;
  final Map<String, String> verses;

  HarpTextModel({required this.hino, required this.coro, required this.verses});

  factory HarpTextModel.fromJson(Map<String, dynamic> json) {
    return HarpTextModel(
      hino: json['hino'] ?? 'Hino não encontrado',
      coro: json['coro'] ?? 'Não possui coro',
      verses: Map<String, String>.from(json['verses'] ?? {}),
    );
  }
}

class HarpContentView extends StatefulWidget {
  const HarpContentView({
    super.key,
    required this.harp,
    this.audioUrl,
  });

  final String harp;
  final String? audioUrl;

  @override
  State<HarpContentView> createState() => _HarpContentViewState();
}

class _HarpContentViewState extends State<HarpContentView> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isLoadingAudio = false;

  @override
  void initState() {
    super.initState();
    _loadAudio();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadAudio() async {
    if (widget.audioUrl == null || widget.audioUrl!.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoadingAudio = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
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
          _isLoadingAudio = false;
        });
      }
    }
  }

  Future<List<HarpTextModel>> loadTexts() async {
    try {
      String jsonString = await rootBundle
          .loadString('assets/json/harpa_crista_640_hinos.json');
      Map<String, dynamic> jsonResponse = jsonDecode(jsonString);
      List<HarpTextModel> texts = [];
      jsonResponse.forEach((key, value) {
        texts.add(HarpTextModel.fromJson(value));
      });
      return texts;
    } catch (_) {
      return [];
    }
  }

  Widget _buildAudioPlayer() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.9),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: _isLoadingAudio
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.secondary,
                ),
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
                            icon: Icon((playing ?? false)
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_filled),
                            iconSize: 40.0,
                            color: Theme.of(context).colorScheme.secondary,
                            onPressed: () => (playing ?? false)
                                ? _audioPlayer.pause()
                                : _audioPlayer.play(),
                          ),
                          IconButton(
                            icon: const Icon(Icons.stop_circle_outlined),
                            iconSize: 40.0,
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
    final settings = context.watch<SettingsViewModel>();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        title: widget.harp,
        centerTitle: false,
        automaticallyImplyLeading: true,
      ),
      body: FutureBuilder<List<HarpTextModel>>(
          future: loadTexts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Erro ao carregar os textos.',
                  style: TextStyle(color: colorScheme.secondary),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'Nenhum texto encontrado.',
                  style: TextStyle(color: colorScheme.secondary),
                ),
              );
            }

            final harpText = snapshot.data!.firstWhere(
              (text) =>
                  text.hino.toLowerCase().trim() ==
                  widget.harp.toLowerCase().trim(),
              orElse: () => HarpTextModel(hino: '', coro: '', verses: {}),
            );

            final verseEntries = harpText.verses.entries.toList();
            final hasChorus = harpText.coro.trim().isNotEmpty &&
                harpText.coro.trim().toLowerCase() != 'não possui coro';

            return Center(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildAudioPlayer(),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(6.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == verseEntries.length) {
                            return const SizedBox(height: 24);
                          }

                          final entry = verseEntries[index];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Text(
                                    entry.key,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.secondary
                                          .withValues(alpha: 0.9),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    entry.value,
                                    style: TextStyle(
                                      fontSize: settings.fontSize,
                                      color: colorScheme.secondary,
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  if (hasChorus) ...[
                                    const SizedBox(height: 24),
                                    Text(
                                      harpText.coro,
                                      style: TextStyle(
                                        fontSize: settings.fontSize,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.secondary,
                                        height: 1.5,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: verseEntries.length + 1,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
      ),
    );
  }
}
