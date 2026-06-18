import 'dart:convert';
import 'dart:io';

import 'package:biblia_e_harpa/src/view_model/settings_view_model.dart';
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
  final AudioPlayer _player = AudioPlayer();
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

  @override
  void initState() {
    super.initState();
    _fetchAudioHarpa();
    _searchController.addListener(_filtrarAudioHarpa);

    _player.positionStream.listen((p) => setState(() => _currentPosition = p));
    _player.durationStream.listen((d) => setState(() => _audioDuration = d ?? Duration.zero));
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) _playNext();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filtrarAudioHarpa);
    _searchController.dispose();
    _player.dispose();
    super.dispose();
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
    final query = _searchController.text;
    setState(() {
      _filtrarHarpa = _allHarpas.where((audio) => _normalize(audio.titulo).contains(_normalize(query))).toList();
    });
  }

  Future<String> _getLocalFilePath(String hinoTitle) async {
    final directory = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${directory.path}/harpa_audios');
    if (!await audioDir.exists()) await audioDir.create(recursive: true);
    final safeName = hinoTitle.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_');
    return '${audioDir.path}/$safeName.mp3';
  }

  Future<void> _fetchAudioHarpa() async {
    setState(() => isLoading = true);
    try {
      final String response = await rootBundle.loadString("assets/json/audiosHarpa.json");
      final Map<String, dynamic> jsonData = json.decode(response);
      final List data = jsonData["audios"];
      _allHarpas = data.map((audio) => DataAudioModel.fromJson(audio)).toList();

      for (int i = 0; i < _allHarpas.length; i++) {
        if (await File(await _getLocalFilePath(_allHarpas[i].titulo)).exists()) {
          _downloadedIndices.add(i);
        }
      }

      if (widget.isOffline) {
        _allHarpas = _allHarpas.where((h) => _downloadedIndices.contains(_allHarpas.indexOf(h))).toList();
      }

      setState(() {
        _filtrarHarpa = _allHarpas;
        isLoading = false;
        if (widget.isOffline && _allHarpas.isEmpty) error = "Nenhum hino foi baixado.";
      });
    } catch (e) {
      setState(() {
        error = "Erro ao carregar áudios.";
        isLoading = false;
      });
    }
  }

  Future<void> _loadAndPlay(int index) async {
    final hino = _filtrarHarpa[index];
    setState(() {
      _currentIndex = index;
      _currentPosition = Duration.zero;
      _audioDuration = Duration.zero;
    });

    try {
      final path = await _getLocalFilePath(hino.titulo);
      if (await File(path).exists()) {
        await _player.setAudioSource(AudioSource.file(path));
      } else {
        final connectivity = await Connectivity().checkConnectivity();
        if (connectivity.contains(ConnectivityResult.none)) throw Exception("Sem internet");
        
        String url = hino.hinoURL;
        if (url.contains("drive.google.com")) {
          final id = RegExp(r"/d/([^/]+)/").firstMatch(url)?.group(1);
          if (id != null) url = "https://drive.google.com/uc?export=download&id=$id&confirm=t";
        }
        await _player.setAudioSource(AudioSource.uri(Uri.parse(url)));
      }
      await _player.play();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao reproduzir áudio.")));
    }
  }

  void _playNext() {
    if (_currentIndex != null && _currentIndex! < _filtrarHarpa.length - 1) _loadAndPlay(_currentIndex! + 1);
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
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${hino.titulo} baixado!")));
    } catch (e) {
      setState(() => _isDownloading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro no download.")));
    }
  }

  Future<void> _delete(int index) async {
    final hino = _filtrarHarpa[index];
    final file = File(await _getLocalFilePath(hino.titulo));
    if (await file.exists()) await file.delete();
    setState(() => _downloadedIndices.remove(_allHarpas.indexOf(hino)));
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Removido.")));
  }

  Future<void> _share(int index) async {
    final hino = _filtrarHarpa[index];
    await SharePlus.instance.share(ShareParams(text: "Ouça ${hino.titulo} na Harpa Cristã: ${hino.hinoURL}"));
  }

  String _formatDuration(Duration d) => "${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: widget.isOffline ? CustomAppBar(automaticallyImplyLeading: true, centerTitle: false, title: "Hinos Baixados") : null,
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    final settings = context.watch<SettingsViewModel>();
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (error != null) return Center(child: Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: settings.fontSize)));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Pesquisar hino",
              hintStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
              prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.secondary),
              filled: true,
              fillColor: Theme.of(context).colorScheme.primary,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
            ),
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _filtrarHarpa.length,
            itemBuilder: (context, index) {
              final hino = _filtrarHarpa[index];
              final isSelected = _currentIndex == index;
              final isDownloaded = _downloadedIndices.contains(_allHarpas.indexOf(hino));

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5) : null,
                child: Column(
                  children: [
                    ListTile(
                      title: Text(hino.titulo, style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: settings.fontSize, fontWeight: isSelected ? FontWeight.bold : null)),
                      onTap: () => _loadAndPlay(index),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: Icon(Icons.share_outlined, color: Theme.of(context).colorScheme.secondary, size: 20), onPressed: () => _share(index)),
                          IconButton(
                            icon: Icon(isDownloaded ? Icons.delete_outline : Icons.download_outlined, color: Theme.of(context).colorScheme.secondary, size: 20),
                            onPressed: isDownloaded ? () => _delete(index) : () => _download(index),
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
                              max: _audioDuration.inSeconds > 0 ? _audioDuration.inSeconds.toDouble() : 1.0,
                              onChanged: (v) => _player.seek(Duration(seconds: v.toInt())),
                              activeColor: Theme.of(context).colorScheme.secondary,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_formatDuration(_currentPosition), style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 12)),
                                Row(
                                  children: [
                                    IconButton(icon: const Icon(Icons.replay_10), onPressed: () => _player.seek(Duration(seconds: _currentPosition.inSeconds - 10))),
                                    IconButton(
                                      icon: Icon(_player.playing ? Icons.pause_circle_filled : Icons.play_circle_filled),
                                      iconSize: 40,
                                      onPressed: () => _player.playing ? _player.pause() : _player.play(),
                                    ),
                                    IconButton(icon: const Icon(Icons.forward_10), onPressed: () => _player.seek(Duration(seconds: _currentPosition.inSeconds + 10))),
                                  ],
                                ),
                                Text(_formatDuration(_audioDuration), style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 12)),
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
