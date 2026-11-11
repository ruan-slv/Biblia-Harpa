/// Coordena o estado e as ações consumidos pela camada de apresentação.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'dart:async';
import 'dart:io';
import '../model/bible_audio.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier, kIsWeb;
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import '../services/app_audio_handler.dart';

class BibleAudioChaptersController extends ChangeNotifier {
  final BibleAudioBook book;
  AudioPlayer get player => sharedAudioPlayer;

  final List<StreamSubscription<dynamic>> _subscriptions =
      <StreamSubscription<dynamic>>[];
  final Map<int, String> _localPaths = <int, String>{};
  AppAudioHandler? _handler;
  bool _disposed = false;

  BibleAudioChaptersController({required this.book}) {
    _filteredChapters = book.chapters;
    _checkDownloadedChapters();

    _subscriptions.add(
      player.playerStateStream.listen((state) {
        if (_disposed) return;
        _isBuffering = state.processingState == ProcessingState.buffering ||
            state.processingState == ProcessingState.loading;
        notifyListeners();
      }),
    );

    _subscriptions.add(
      player.positionStream.listen((position) {
        if (_disposed) return;
        _currentPosition = position;
        notifyListeners();
      }),
    );

    _subscriptions.add(
      player.durationStream.listen((duration) {
        if (_disposed) return;
        _audioDuration = duration ?? Duration.zero;
        notifyListeners();
      }),
    );

    player.setVolume(_volume);
  }

  void _attachHandler(AppAudioHandler handler) {
    if (identical(_handler, handler)) return;
    _handler?.currentTrack.removeListener(_syncFromHandler);
    _handler = handler;
    handler.currentTrack.addListener(_syncFromHandler);
  }

  /// Reflete o avanço automático (modo contínuo/notificação) no capítulo atual.
  void _syncFromHandler() {
    if (_disposed) return;
    final track = _handler?.currentTrack.value;
    if (track == null || track.extras['source'] != 'bible-audio') return;
    if (track.extras['book'] != book.title) return;
    final index = int.tryParse(track.extras['index'] ?? '');
    if (index == null || index < 0 || index >= book.chapters.length) return;
    if (_currentIndex == index) return;
    _currentIndex = index;
    _currentPosition = Duration.zero;
    _audioDuration = Duration.zero;
    notifyListeners();
  }

  bool _isBuffering = false;
  bool get isBuffering => _isBuffering;

  int? _currentIndex;
  int? get currentIndex => _currentIndex;

  Duration _currentPosition = Duration.zero;
  Duration get currentPosition => _currentPosition;

  Duration _audioDuration = Duration.zero;
  Duration get audioDuration => _audioDuration;

  double _volume = 1.0;
  double get volume => _volume;

  String _query = '';
  String get query => _query;

  late List<BibleAudioChapter> _filteredChapters;
  List<BibleAudioChapter> get filteredChapters => _filteredChapters;

  final Map<int, bool> _isDownloading = {};
  Map<int, bool> get isDownloading => _isDownloading;

  final Set<int> _downloadedChapters = {};
  Set<int> get downloadedChapters => _downloadedChapters;

  void setQuery(String value) {
    _query = value;
    _filteredChapters = book.chapters.where((c) {
      final name = c.name.toLowerCase();
      return name.contains(value.toLowerCase());
    }).toList(growable: false);
    notifyListeners();
  }

  Future<String> getLocalFilePath(String fileName) async {
    if (kIsWeb) return '';
    final directory = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${directory.path}/bible_audios');
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    final safeName =
        fileName.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_');
    return '${audioDir.path}/$safeName.mp3';
  }

  Future<void> _checkDownloadedChapters() async {
    if (kIsWeb) return;
    for (int i = 0; i < book.chapters.length; i++) {
      final path = await getLocalFilePath(book.chapters[i].name);
      if (path.isEmpty) continue;
      _localPaths[i] = path;
      if (await File(path).exists()) {
        _downloadedChapters.add(i);
      }
    }
    if (_disposed) return;
    notifyListeners();
  }

  Future<void> updateVolume(double newVolume) async {
    final normalizedVolume = newVolume.clamp(0.0, 1.0);
    await player.setVolume(normalizedVolume);
    _volume = normalizedVolume;
    notifyListeners();
  }

  Future<void> play(int indexInFullList) async {
    if (indexInFullList < 0 || indexInFullList >= book.chapters.length) return;
    try {
      final active = activeAudioHandler;
      final current = active?.currentTrack.value;
      // Só alterna play/pause quando este capítulo é o que está no player
      // global; caso outro áudio tenha assumido, inicia o capítulo.
      final isCurrent = current != null
          ? current.extras['source'] == 'bible-audio' &&
              current.extras['book'] == book.title &&
              current.extras['index'] == '$indexInFullList'
          : _currentIndex == indexInFullList;

      if (isCurrent) {
        if (player.playing) {
          await player.pause();
        } else {
          await player.play();
        }
        return;
      }

      _currentIndex = indexInFullList;
      _currentPosition = Duration.zero;
      _audioDuration = Duration.zero;
      _isBuffering = true;
      notifyListeners();

      final tracks = await _buildTracks();
      final handler = await ensureAudioHandler();

      if (handler != null) {
        _attachHandler(handler);
        await handler.playTracks(
          tracks: tracks,
          index: indexInFullList,
          continuous: true,
        );
        return;
      }

      // Fallback quando o serviço de mídia não está disponível.
      final chapter = book.chapters[indexInFullList];
      final localPath = _localPaths[indexInFullList];
      var usedLocal = false;
      if (localPath != null && localPath.isNotEmpty) {
        if (await File(localPath).exists()) {
          await player.setAudioSource(
            AudioSource.file(localPath),
            preload: true,
          );
          usedLocal = true;
        }
      }
      if (!usedLocal) {
        await player.setAudioSource(
          AudioSource.uri(Uri.parse(chapter.url)),
          preload: true,
        );
      }
      await player.play();
    } catch (_) {
      _isBuffering = false;
      if (!_disposed) notifyListeners();
    }
  }

  /// Monta a fila completa de capítulos do livro para o player global.
  Future<List<AppAudioTrack>> _buildTracks() async {
    final tracks = <AppAudioTrack>[];
    for (var i = 0; i < book.chapters.length; i++) {
      final chapter = book.chapters[i];
      var localPath = _localPaths[i];
      if (localPath == null || localPath.isEmpty) {
        localPath = await getLocalFilePath(chapter.name);
        _localPaths[i] = localPath;
      }
      tracks.add(
        AppAudioTrack(
          id: 'bible-audio:$i:${chapter.name}',
          title: '${book.title} — ${chapter.name}',
          artist: 'Bíblia em áudio',
          remoteUri: Uri.parse(chapter.url),
          localPath: localPath.isEmpty ? null : localPath,
          extras: <String, String>{
            'source': 'bible-audio',
            'book': book.title,
            'index': '$i',
          },
        ),
      );
    }
    return tracks;
  }

  void playNext() {
    if (_currentIndex == null || book.chapters.isEmpty) return;
    var nextIndex = _currentIndex! + 1;
    if (nextIndex >= book.chapters.length) nextIndex = 0;
    play(nextIndex);
  }

  void playPrevious() {
    if (_currentIndex == null || book.chapters.isEmpty) return;
    var prevIndex = _currentIndex! - 1;
    if (prevIndex < 0) prevIndex = book.chapters.length - 1;
    play(prevIndex);
  }

  Future<bool> download(int indexInFullList) async {
    if (kIsWeb) return false;
    if (_isDownloading[indexInFullList] == true) return false;

    _isDownloading[indexInFullList] = true;
    notifyListeners();

    try {
      final dio = Dio();
      final chapter = book.chapters[indexInFullList];
      final savePath = await getLocalFilePath(chapter.name);
      if (savePath.isEmpty) throw Exception('Caminho local indisponível');

      await dio.download(chapter.url, savePath);

      _downloadedChapters.add(indexInFullList);
      _isDownloading[indexInFullList] = false;
      notifyListeners();
      return true;
    } catch (_) {
      _isDownloading[indexInFullList] = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> delete(int indexInFullList) async {
    if (kIsWeb) return false;
    try {
      final chapter = book.chapters[indexInFullList];
      final path = await getLocalFilePath(chapter.name);
      if (path.isEmpty) return false;
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
      _downloadedChapters.remove(indexInFullList);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<String?> prepareShareFilePath(int indexInFullList) async {
    if (kIsWeb) return null;
    final chapter = book.chapters[indexInFullList];
    final localPath = await getLocalFilePath(chapter.name);
    if (localPath.isNotEmpty && await File(localPath).exists()) {
      return localPath;
    }

    final response = await http.get(Uri.parse(chapter.url));
    final tempDir = await getTemporaryDirectory();
    final tempFile = File(
      '${tempDir.path}/${chapter.name.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_')}.mp3',
    );
    await tempFile.writeAsBytes(response.bodyBytes);
    return tempFile.path;
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    _disposed = true;
    _handler?.currentTrack.removeListener(_syncFromHandler);
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    super.dispose();
  }
}
