// Em: lib/src/screens/harpaFileScreen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:share_plus/share_plus.dart';
import '../models/dataAudioModel.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Importante para verificar conexão

class Harpafilescreen extends StatefulWidget {
  final List<DataAudioModel> allHarpas;
  final int initialIndex;

  const Harpafilescreen({
    super.key,
    required this.allHarpas,
    required this.initialIndex,
  });

  @override
  State<Harpafilescreen> createState() => _HarpafilescreenState();
}

class _HarpafilescreenState extends State<Harpafilescreen> {
  final AudioPlayer _player = AudioPlayer();

  // Variáveis de controle da lista
  late int _currentIndex;
  late DataAudioModel _currentHarpa;

  // Estado do Player
  PlayerState? _playerState;
  Duration _currentPosition = Duration.zero;
  Duration _audioDuration = Duration.zero;

  // Controle de Download
  bool _isDownloading = false;
  bool _isDownloaded = false;

  @override
  void initState() {
    super.initState();

    // Inicializa com os dados passados
    _currentIndex = widget.initialIndex;
    _currentHarpa = widget.allHarpas[_currentIndex];

    // Configura listeners
    _player.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        _playerState = state;
      });
      // Se terminar, toca o próximo automaticamente
      if (state.processingState == ProcessingState.completed) {
        _playNext();
      }
    });

    _player.positionStream.listen((p) {
      if (mounted) setState(() => _currentPosition = p);
    });

    _player.durationStream.listen((d) {
      if (mounted) setState(() => _audioDuration = d ?? Duration.zero);
    });

    // Verifica downloads e inicia o play
    _checkIfDownloaded();
    _loadAndPlayAudio();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  // --- LÓGICA DE ARQUIVOS LOCAL ---

  // 1. Define o caminho local do arquivo
  Future<String> _getLocalFilePath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${directory.path}/harpa_audios');
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    // Limpeza rigorosa do nome do arquivo
    final safeName =
        fileName.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_');
    return '${audioDir.path}/$safeName.mp3';
  }

  // 2. Verifica se o hino atual já está baixado
  Future<void> _checkIfDownloaded() async {
    final path = await _getLocalFilePath(_currentHarpa.titulo);
    final exists = await File(path).exists();
    if (mounted) {
      setState(() {
        _isDownloaded = exists;
      });
    }
  }

  // 3. Realiza o Download
  Future<void> _downloadAudio() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
    });

    try {
      final dio = Dio();
      final savePath = await _getLocalFilePath(_currentHarpa.titulo);

      // Garante URL válida para download direto (Google Drive fix)
      String url = _currentHarpa.hinoURL;
      if (url.contains('drive.google.com') && !url.contains('&confirm=')) {
        if (url.contains('?')) {
          url = '$url&confirm=t';
        } else {
          url = '$url?confirm=t';
        }
      }

      await dio.download(url, savePath);

      if (mounted) {
        setState(() {
          _isDownloaded = true;
          _isDownloading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('${_currentHarpa.titulo} baixado com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Erro ao baixar o áudio. Verifique a conexão.')),
        );
      }
    }
  }

  // 4. Deletar áudio
  Future<void> _deleteAudio() async {
    try {
      final path = await _getLocalFilePath(_currentHarpa.titulo);
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        if (mounted) {
          setState(() {
            _isDownloaded = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Áudio removido do dispositivo.')),
          );
        }
      }
    } catch (e) {
      // Erro silencioso ou log
    }
  }

  Future<void> _loadAndPlayAudio() async {
    try {
      setState(() {
        _currentPosition = Duration.zero;
        _audioDuration = Duration.zero;
      });

      final connectivity = await Connectivity().checkConnectivity();
      final hasInternet = !connectivity.contains(ConnectivityResult.none);

      final path = await _getLocalFilePath(_currentHarpa.titulo);
      final localFile = File(path);
      final hasLocal = await localFile.exists();

      // --- OFFLINE: só toca o que está baixado ---
      if (!hasInternet) {
        if (hasLocal) {
          await _player.setAudioSource(AudioSource.file(path));
          await _player.play();
          return;
        } else {
          throw Exception("Sem internet e sem arquivo offline.");
        }
      }

      // --- ONLINE MODE ---
      String url = _currentHarpa.hinoURL;

      // Correção Google Drive — sempre transformar em URL de download direto
      if (url.contains("drive.google.com")) {
        final idMatch = RegExp(r"/d/([^/]+)/").firstMatch(url);
        if (idMatch != null) {
          final id = idMatch.group(1);
          url = "https://drive.google.com/uc?export=download&id=$id&confirm=t";
        }
      }

      final onlineSource = AudioSource.uri(
        Uri.parse(url),
        headers: {
          // User-Agent antigo que funcionava
          'User-Agent':
              'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Mobile Safari/537.36'
        },
      );

      await _player.setAudioSource(onlineSource);
      await _player.play();
      return;
    } catch (e) {
      // --- FALLBACK: tentar baixar e tocar local ---
      try {
        final dio = Dio();
        dio.options.headers = {
          'User-Agent':
              'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Mobile Safari/537.36',
        };

        final savePath = await _getLocalFilePath(_currentHarpa.titulo);
        await dio.download(_currentHarpa.hinoURL, savePath);

        await _player.setAudioSource(AudioSource.file(savePath));
        await _player.play();

        setState(() => _isDownloaded = true);
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Erro ao reproduzir o áudio online e offline."),
            ),
          );
        }
      }
    }
  }

  // --- FUNÇÕES DE NAVEGAÇÃO ---
  void _playNext() {
    if (_currentIndex < widget.allHarpas.length - 1) {
      setState(() {
        _currentIndex++;
        _currentHarpa = widget.allHarpas[_currentIndex];
      });
      // Checa se o novo hino tem download e toca
      _checkIfDownloaded();
      _loadAndPlayAudio();
    }
  }

  void _playPrevious() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _currentHarpa = widget.allHarpas[_currentIndex];
      });
      _checkIfDownloaded();
      _loadAndPlayAudio();
    }
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Future<void> _shareAudio(DataAudioModel audio) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Preparando áudio para compartilhar...'),
            duration: Duration(seconds: 2)),
      );

      final localPath = await _getLocalFilePath(audio.titulo);
      XFile fileToShare;

      // Se o arquivo existe localmente, usa ele. Se não, baixa temporariamente.
      if (localPath.isNotEmpty && await File(localPath).exists()) {
        fileToShare = XFile(localPath);
      } else {
        final response = await http.get(Uri.parse(audio.hinoURL));
        final tempDir = await getTemporaryDirectory();
        final tempFile = File(
            '${tempDir.path}/${audio.titulo.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_')}.mp3');

        await tempFile.writeAsBytes(response.bodyBytes);
        fileToShare = XFile(tempFile.path);
      }

      await Share.shareXFiles(
        [fileToShare],
        text: 'Ouça este louvor da harpa cristã: ${audio.titulo}',
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

  @override
  Widget build(BuildContext context) {
    final playerState = _playerState;
    final isPlaying = playerState?.playing ?? false;
    final processingState = playerState?.processingState;
    final isLoading = processingState == ProcessingState.loading ||
        processingState == ProcessingState.buffering;

    final hasPrevious = _currentIndex > 0;
    final hasNext = _currentIndex < widget.allHarpas.length - 1;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.secondary),
        title: Text(
          _currentHarpa.titulo,
          style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          _isDownloading
              ? Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.secondary,
                      strokeWidth: 2,
                    ),
                  ),
                )
              : IconButton(
                  icon: Icon(
                    _isDownloaded ? Icons.download_done : Icons.download,
                    color: _isDownloaded
                        ? Colors.green
                        : Theme.of(context).colorScheme.secondary,
                  ),
                  tooltip: _isDownloaded
                      ? "Hino baixado (Toque para remover)"
                      : "Baixar hino",
                  onPressed: () {
                    if (_isDownloaded) {
                      _deleteAudio();
                    } else {
                      _downloadAudio();
                    }
                  },
                ),
          IconButton(
              onPressed: () => _shareAudio(_currentHarpa),
              icon: Icon(Icons.share,
                  color: Theme.of(context).colorScheme.secondary)),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- GRUPO SUPERIOR ---
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.6,
                        height: MediaQuery.of(context).size.width * 0.6,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5))
                          ],
                        ),
                        child: Icon(Icons.music_note_rounded,
                            size: 100,
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                      if (_isDownloaded)
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2)),
                            child: const Icon(Icons.offline_pin,
                                color: Colors.white, size: 20),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Text(_currentHarpa.titulo,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Text("Harpa Cristã",
                      style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.7))),
                ],
              ),

              // --- GRUPO INFERIOR ---
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 16.0),
                    ),
                    child: Slider(
                      value: _currentPosition.inSeconds.toDouble(),
                      min: 0,
                      max: _audioDuration.inSeconds
                          .toDouble()
                          .clamp(1.0, double.infinity),
                      onChanged: (value) =>
                          _player.seek(Duration(seconds: value.toInt())),
                      activeColor: Theme.of(context).colorScheme.secondary,
                      inactiveColor: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.3),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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

                  const SizedBox(height: 20),

                  // --- CONTROLES DE REPRODUÇÃO ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.replay_10_rounded),
                        iconSize: 28.0,
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.8),
                        onPressed: () => _player.seek(
                            Duration(seconds: _currentPosition.inSeconds - 10)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_previous_rounded),
                        iconSize: 36.0,
                        color: hasPrevious
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.3),
                        onPressed: hasPrevious ? _playPrevious : null,
                      ),
                      SizedBox(
                        width: 70,
                        height: 70,
                        child: Center(
                          child: isLoading
                              ? CircularProgressIndicator(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                )
                              : InkWell(
                                  borderRadius: BorderRadius.circular(50),
                                  onTap: () {
                                    isPlaying
                                        ? _player.pause()
                                        : _player.play();
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
                                              .withOpacity(0.3),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        )
                                      ],
                                    ),
                                    child: Icon(
                                      isPlaying
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded,
                                      size: 40.0,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next_rounded),
                        iconSize: 36.0,
                        color: hasNext
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.3),
                        onPressed: hasNext ? _playNext : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.forward_10_rounded),
                        iconSize: 28.0,
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.8),
                        onPressed: () => _player.seek(
                            Duration(seconds: _currentPosition.inSeconds + 10)),
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
