/// Implementa a interface e os fluxos de apresentação deste recurso.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:biblia_e_harpa/src/controllers/settings_controller.dart';
import 'package:biblia_e_harpa/src/model/data_audio_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:share_plus/share_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'component/app_bar_component.dart';
import '../l10n/app_localizations.dart';
import '../utils/theme.dart';
import '../utils/app_links.dart';
import '../services/app_audio_handler.dart';

class HarpAudioView extends StatefulWidget {
  final bool isOffline;

  const HarpAudioView({
    super.key,
    this.isOffline = false,
  });

  @override
  State<HarpAudioView> createState() => _HarpAudioViewState();
}

class _HarpAudioViewState extends State<HarpAudioView> {
  AudioPlayer get _player => sharedAudioPlayer;
  List<DataAudioModel> _allHarpas = [];
  List<DataAudioModel> _filtrarHarpa = [];
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = true;
  String? error;

  int? _currentIndex;
  Duration _currentPosition = Duration.zero;
  Duration _audioDuration = Duration.zero;
  bool _isDownloading = false;
  final Set<int> _downloadedIndices = {};

  final List<StreamSubscription<dynamic>> _subscriptions =
      <StreamSubscription<dynamic>>[];
  AppAudioHandler? _handler;
  String? _audioDirPath;

  @override
  void initState() {
    super.initState();
    _fetchAudioHarpa();
    _searchController.addListener(_filtrarAudioHarpa);

    _subscriptions.add(
      _player.positionStream.listen((p) {
        if (mounted) setState(() => _currentPosition = p);
      }),
    );
    _subscriptions.add(
      _player.durationStream.listen((d) {
        if (mounted) setState(() => _audioDuration = d ?? Duration.zero);
      }),
    );
    _subscriptions.add(
      _player.playerStateStream.listen((_) {
        if (mounted) setState(() {});
      }),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_filtrarAudioHarpa);
    _searchController.dispose();
    _handler?.currentTrack.removeListener(_syncFromHandler);
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  void _attachHandler(AppAudioHandler handler) {
    if (identical(_handler, handler)) return;
    _handler?.currentTrack.removeListener(_syncFromHandler);
    _handler = handler;
    handler.currentTrack.addListener(_syncFromHandler);
  }

  /// Mantém a lista alinhada quando o avanço acontece pela notificação/fones
  /// ou pelo modo contínuo do player global.
  void _syncFromHandler() {
    if (!mounted) return;
    final track = _handler?.currentTrack.value;
    if (track == null || track.extras['source'] != 'harp-audio') return;
    // Procura pelo título para continuar correto mesmo com a busca filtrando
    // a lista depois que a fila foi montada.
    final byTitle =
        _filtrarHarpa.indexWhere((hino) => hino.titulo == track.title);
    final index =
        byTitle >= 0 ? byTitle : int.tryParse(track.extras['index'] ?? '');
    if (index == null || index < 0 || index >= _filtrarHarpa.length) return;
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
      _currentPosition = Duration.zero;
      _audioDuration = Duration.zero;
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

  void _filtrarAudioHarpa() {
    // Guarda o hino em reprodução para reencontrá-lo na lista filtrada.
    final playingHino = (_currentIndex != null &&
            _currentIndex! >= 0 &&
            _currentIndex! < _filtrarHarpa.length)
        ? _filtrarHarpa[_currentIndex!]
        : null;
    final query = _searchController.text;
    setState(() {
      _filtrarHarpa = _allHarpas
          .where(
              (audio) => _normalize(audio.titulo).contains(_normalize(query)))
          .toList();
      if (playingHino == null) return;
      final newIndex = _filtrarHarpa.indexOf(playingHino);
      _currentIndex = newIndex < 0 ? null : newIndex;
    });
  }

  Future<String> _getAudioDir() async {
    if (_audioDirPath != null) return _audioDirPath!;
    final directory = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${directory.path}/harpa_audios');
    if (!await audioDir.exists()) await audioDir.create(recursive: true);
    return _audioDirPath = audioDir.path;
  }

  String _safeHinoName(String hinoTitle) =>
      hinoTitle.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_');

  Future<String> _getLocalFilePath(String hinoTitle) async {
    final audioDir = await _getAudioDir();
    return '$audioDir/${_safeHinoName(hinoTitle)}.mp3';
  }

  Future<void> _fetchAudioHarpa() async {
    setState(() => isLoading = true);
    try {
      final String response =
          await rootBundle.loadString("assets/json/outros/audios_harpa.json");
      final Map<String, dynamic> jsonData = json.decode(response);
      final List data = jsonData["audios"];
      _allHarpas = data.map((audio) => DataAudioModel.fromJson(audio)).toList();

      for (int i = 0; i < _allHarpas.length; i++) {
        if (await File(await _getLocalFilePath(_allHarpas[i].titulo))
            .exists()) {
          _downloadedIndices.add(i);
        }
      }

      if (widget.isOffline) {
        _allHarpas = _allHarpas
            .where((h) => _downloadedIndices.contains(_allHarpas.indexOf(h)))
            .toList();
      }

      setState(() {
        _filtrarHarpa = _allHarpas;
        isLoading = false;
        if (widget.isOffline && _allHarpas.isEmpty) {
          error = tr('Nenhum hino foi baixado.');
        }
      });
    } catch (e) {
      setState(() {
        error = tr('Erro ao carregar áudios.');
        isLoading = false;
      });
    }
  }

  Future<void> _loadAndPlay(int index) async {
    if (index < 0 || index >= _filtrarHarpa.length) return;
    setState(() {
      _currentIndex = index;
      _currentPosition = Duration.zero;
      _audioDuration = Duration.zero;
    });

    try {
      await AppLinks.load();
      final audioDir = await _getAudioDir();
      String localPathFor(String titulo) =>
          '$audioDir/${_safeHinoName(titulo)}.mp3';

      // A fila inteira é entregue ao player global: assim a notificação, os
      // fones e o modo contínuo conseguem avançar mesmo com a tela apagada.
      final tracks = <AppAudioTrack>[];
      for (var i = 0; i < _filtrarHarpa.length; i++) {
        final item = _filtrarHarpa[i];
        tracks.add(
          AppAudioTrack(
            id: 'harp-audio:$i:${item.titulo}',
            title: item.titulo,
            artist: 'Harpa Cristã',
            remoteUri: AppLinks.harpAudio(item.hinoURL),
            localPath: localPathFor(item.titulo),
            extras: <String, String>{
              'source': 'harp-audio',
              'index': '$i',
            },
          ),
        );
      }

      final localPath = tracks[index].localPath;
      final hasLocal = localPath != null && await File(localPath).exists();

      if (!hasLocal) {
        final connectivity = await Connectivity().checkConnectivity();
        if (connectivity.contains(ConnectivityResult.none)) {
          throw Exception("Sem internet");
        }
      }

      final handler = await ensureAudioHandler();
      if (handler != null) {
        _attachHandler(handler);
        await handler.playTracks(
          tracks: tracks,
          index: index,
          continuous: true,
        );
      } else {
        // Fallback quando o serviço de mídia não está disponível.
        if (hasLocal) {
          await _player.setAudioSource(AudioSource.file(localPath));
        } else {
          await _player.setAudioSource(
            AudioSource.uri(tracks[index].remoteUri),
          );
        }
        await _player.play();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(tr('Erro ao reproduzir áudio.'))));
      }
    }
  }

  Future<void> _playNext() async {
    final total = _filtrarHarpa.length;
    if (total == 0 || _currentIndex == null) return;

    if (_currentIndex! >= total - 1) {
      // Fim da lista: no modo contínuo volta ao primeiro hino.
      if (!context.read<SettingsController>().continuousPlayback) return;
      await _loadAndPlay(0);
      return;
    }
    await _loadAndPlay(_currentIndex! + 1);
  }

  Future<void> _playPrevious() async {
    final total = _filtrarHarpa.length;
    if (total == 0 || _currentIndex == null) return;

    if (_currentIndex! <= 0) {
      if (!context.read<SettingsController>().continuousPlayback) return;
      await _loadAndPlay(total - 1);
      return;
    }
    await _loadAndPlay(_currentIndex! - 1);
  }

  /// Alterna entre reproduzir e pausar, reiniciando o hino caso ele já tenha
  /// chegado ao fim.
  Future<void> _togglePlayPause() async {
    final index = _currentIndex;
    // Se outro áudio assumiu o player global, inicia o hino selecionado
    // (em vez de pausar/retomar o áudio de outra tela).
    if (index != null &&
        index >= 0 &&
        index < _filtrarHarpa.length &&
        activeAudioHandler != null) {
      final current = activeAudioHandler!.currentTrack.value;
      final isThisTrack = current != null &&
          current.extras['source'] == 'harp-audio' &&
          current.title == _filtrarHarpa[index].titulo;
      if (!isThisTrack) {
        await _loadAndPlay(index);
        return;
      }
    }

    if (_player.playing) {
      await _player.pause();
      return;
    }
    if (_player.processingState == ProcessingState.completed) {
      await _player.seek(Duration.zero);
    }
    await _player.play();
  }

  Future<void> _download(int index) async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);
    final hino = _filtrarHarpa[index];
    try {
      final savePath = await _getLocalFilePath(hino.titulo);
      await Dio().download(hino.hinoURL, savePath);
      setState(() {
        _downloadedIndices.add(_allHarpas.indexOf(hino));
        _isDownloading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(tr('{hino} baixado!', {'hino': hino.titulo}))));
      }
    } catch (e) {
      setState(() => _isDownloading = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(tr('Erro no download.'))));
      }
    }
  }

  Future<void> _delete(int index) async {
    final hino = _filtrarHarpa[index];
    final file = File(await _getLocalFilePath(hino.titulo));
    if (await file.exists()) await file.delete();
    setState(() => _downloadedIndices.remove(_allHarpas.indexOf(hino)));
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(tr('Removido.'))));
    }
  }

  Future<void> _share(int index) async {
    final hino = _filtrarHarpa[index];
    await SharePlus.instance.share(ShareParams(
        text: tr('Ouça {hino} na Harpa Cristã: {url}',
            {'hino': hino.titulo, 'url': hino.hinoURL})));
  }

  String _formatDuration(Duration d) =>
      "${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: widget.isOffline
          ? CustomAppBar(
              automaticallyImplyLeading: true,
              centerTitle: false,
              title: context.l10n.t('Hinos Baixados'))
          : null,
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    final settings = context.watch<SettingsController>();
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (error != null) {
      return Center(
          child: Text(error!,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: settings.fontSize)));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: context.l10n.t('Pesquisar hino'),
                    hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface),
                    prefixIcon: Icon(Icons.search,
                        color: Theme.of(context).colorScheme.onSurface),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                  ),
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
              IconButton(
                tooltip: settings.continuousPlayback
                    ? context.l10n
                        .t('Reprodução contínua ativada (toque para desativar)')
                    : context.l10n.t(
                        'Reprodução contínua desativada (toque para ativar)'),
                onPressed: settings.toggleContinuousPlayback,
                icon: Icon(
                  settings.continuousPlayback
                      ? Icons.repeat_on_rounded
                      : Icons.repeat_rounded,
                  color: settings.continuousPlayback
                      ? AppTheme.sucesso
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _filtrarHarpa.length,
            itemBuilder: (context, index) {
              final hino = _filtrarHarpa[index];
              final isSelected = _currentIndex == index;
              final isDownloaded =
                  _downloadedIndices.contains(_allHarpas.indexOf(hino));

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: isSelected
                    ? Theme.of(context).colorScheme.primaryContainer
                    : null,
                child: Column(
                  children: [
                    ListTile(
                      title: Text(hino.titulo,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: settings.fontSize,
                              fontWeight: isSelected ? FontWeight.bold : null)),
                      onTap: () => _loadAndPlay(index),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              icon: Icon(Icons.share_outlined,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  size: 20),
                              onPressed: () => _share(index)),
                          IconButton(
                            icon: Icon(
                                isDownloaded
                                    ? Icons.delete_outline
                                    : Icons.download_outlined,
                                color: Theme.of(context).colorScheme.onSurface,
                                size: 20),
                            onPressed: isDownloaded
                                ? () => _delete(index)
                                : () => _download(index),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            Slider(
                              value: _currentPosition.inSeconds.toDouble(),
                              max: _audioDuration.inSeconds > 0
                                  ? _audioDuration.inSeconds.toDouble()
                                  : 1.0,
                              onChanged: (v) =>
                                  _player.seek(Duration(seconds: v.toInt())),
                              activeColor:
                                  Theme.of(context).colorScheme.onSurface,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_formatDuration(_currentPosition),
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                        fontSize: 12)),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip: context.l10n.t('Hino anterior'),
                                      visualDensity: VisualDensity.compact,
                                      constraints: const BoxConstraints(
                                          minWidth: 36, minHeight: 36),
                                      icon: const Icon(
                                          Icons.skip_previous_rounded),
                                      onPressed: _currentIndex == null ||
                                              (!settings.continuousPlayback &&
                                                  _currentIndex! <= 0)
                                          ? null
                                          : _playPrevious,
                                    ),
                                    IconButton(
                                        tooltip: context.l10n.t('Voltar 10s'),
                                        visualDensity: VisualDensity.compact,
                                        constraints: const BoxConstraints(
                                            minWidth: 36, minHeight: 36),
                                        icon: const Icon(Icons.replay_10),
                                        onPressed: () => _player.seek(Duration(
                                            seconds:
                                                (_currentPosition.inSeconds -
                                                        10)
                                                    .clamp(0, 1 << 31)))),
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      constraints: const BoxConstraints(
                                          minWidth: 40, minHeight: 40),
                                      icon: Icon(_player.playing
                                          ? Icons.pause_circle_filled
                                          : Icons.play_circle_filled),
                                      iconSize: 36,
                                      onPressed: _togglePlayPause,
                                    ),
                                    IconButton(
                                        tooltip: context.l10n.t('Avançar 10s'),
                                        visualDensity: VisualDensity.compact,
                                        constraints: const BoxConstraints(
                                            minWidth: 36, minHeight: 36),
                                        icon: const Icon(Icons.forward_10),
                                        onPressed: () => _player.seek(Duration(
                                            seconds:
                                                (_currentPosition.inSeconds +
                                                        10)
                                                    .clamp(0, 1 << 31)))),
                                    IconButton(
                                      tooltip: context.l10n.t('Próximo hino'),
                                      visualDensity: VisualDensity.compact,
                                      constraints: const BoxConstraints(
                                          minWidth: 36, minHeight: 36),
                                      icon: const Icon(Icons.skip_next_rounded),
                                      onPressed: _currentIndex == null ||
                                              (!settings.continuousPlayback &&
                                                  _currentIndex! >=
                                                      _filtrarHarpa.length - 1)
                                          ? null
                                          : _playNext,
                                    ),
                                  ],
                                ),
                                Text(_formatDuration(_audioDuration),
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                        fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ]
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
