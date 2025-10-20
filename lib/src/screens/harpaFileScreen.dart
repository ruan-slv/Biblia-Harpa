// Em: lib/src/screens/harpaFileScreen.dart

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/dataAudioModel.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;
import 'dart:io';  // Adicione isso
import 'package:path_provider/path_provider.dart';

class Harpafilescreen extends StatefulWidget {
  final DataAudioModel harpa;
  const Harpafilescreen({super.key, required this.harpa});

  @override
  State<Harpafilescreen> createState() => _HarpafilescreenState();
}

class _HarpafilescreenState extends State<Harpafilescreen> {
  final AudioPlayer _player = AudioPlayer();

  // --- LÓGICA DE ESTADO SIMPLIFICADA ---
  PlayerState? _playerState; // A única variável de estado que precisamos
  Duration _currentPosition = Duration.zero;
  Duration _audioDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    // Configura os listeners PRIMEIRO
    _player.playerStateStream.listen((state) {
      if (!mounted) return;
      // Atualiza o estado da UI com o estado real do player
      setState(() {
        _playerState = state;
      });
      // Se o áudio terminar, prepara para o próximo play
      if (state.processingState == ProcessingState.completed) {
        _player.seek(Duration.zero);
        _player.pause();
      }
    });

    _player.positionStream.listen((p) {
      if (mounted) setState(() => _currentPosition = p);
    });

    _player.durationStream.listen((d) {
      if (mounted) setState(() => _audioDuration = d ?? Duration.zero);
    });

    // Inicia o carregamento do áudio
    _loadAndPlayAudio();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _loadAndPlayAudio() async {
    try {
      String url = widget.harpa.hinoURL;
      // Tenta stream direto com confirm bypass
      if (!url.contains('&confirm=')) {
        url = url.replaceAll('export=download', 'export=download&confirm=t');
      }
      final audioSource = AudioSource.uri(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Mobile Safari/537.36',
        },
      );
      await _player.setAudioSource(audioSource, preload: true);
      await _player.play();
    } catch (e) {
      //print("Erro no stream direto: $e");
      // Fallback: Baixa com Dio e toca de file local
      try {
        final dio = Dio();
        dio.options.headers = {
          'User-Agent': 'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Mobile Safari/537.36',
        };
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/${widget.harpa.titulo.replaceAll(' ', '_')}.mp3';
        await dio.download(widget.harpa.hinoURL, filePath);
        final localSource = AudioSource.file(filePath);
        await _player.setAudioSource(localSource, preload: true);
        await _player.play();
      } catch (downloadError) {
        //print("Erro no download fallback: ");//$downloadError
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao carregar áudio:')));// $downloadError
        }
      }
    }
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    // --- LÓGICA DE UI SIMPLIFICADA ---
    // Verifica se o playerState já foi inicializado
    final playerState = _playerState;
    // O player está tocando?
    final isPlaying = playerState?.playing ?? false;
    // O player está em um estado de carregamento?
    final processingState = playerState?.processingState;
    final isLoading = processingState == ProcessingState.loading ||
        processingState == ProcessingState.buffering;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.secondary),
        title: Text(widget.harpa.titulo, style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- GRUPO SUPERIOR (Sem mudanças) ---
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: MediaQuery.of(context).size.width * 0.6,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))],
                    ),
                    child: Icon(Icons.music_note_rounded, size: 100, color: Theme.of(context).colorScheme.secondary),
                  ),
                  const SizedBox(height: 30),
                  Text(widget.harpa.titulo, textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Text("Harpa Cristã", style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.secondary.withOpacity(0.7))),
                ],
              ),
              // --- GRUPO INFERIOR ---
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // CÓDIGO CORRETO
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
                    ),
                    child: Slider(
                      value: _currentPosition.inSeconds.toDouble(),
                      min: 0,
                      max: _audioDuration.inSeconds.toDouble().clamp(1.0, double.infinity),
                      onChanged: (value) => _player.seek(Duration(seconds: value.toInt())),
                      activeColor: Theme.of(context).colorScheme.secondary,
                      inactiveColor: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                    ),
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
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.replay_10_rounded),
                        iconSize: 32.0,
                        color: Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                        onPressed: () => _player.seek(Duration(seconds: _currentPosition.inSeconds - 10)),
                      ),
                      // --- LÓGICA DO BOTÃO DE PLAY SIMPLIFICADA ---
                      SizedBox(
                        width: 70,
                        height: 70,
                        child: Center(
                          child: isLoading
                              ? CircularProgressIndicator(
                            // Cor do loading corrigida
                            color: Theme.of(context).colorScheme.secondary,
                          )
                              : InkWell(
                            borderRadius: BorderRadius.circular(50),
                            onTap: () {
                              isPlaying ? _player.pause() : _player.play();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                size: 45.0,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.forward_10_rounded),
                        iconSize: 32.0,
                        color: Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                        onPressed: () => _player.seek(Duration(seconds: _currentPosition.inSeconds + 10)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}