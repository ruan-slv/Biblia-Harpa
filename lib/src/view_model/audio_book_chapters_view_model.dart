import 'dart:io';
import '../model/bible_audio.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier, kIsWeb;
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

class BibleAudioChaptersViewModel extends ChangeNotifier {
  final BibleAudioBook book;
  final AudioPlayer player = AudioPlayer();

  BibleAudioChaptersViewModel({required this.book}) {
    _filteredChapters = book.chapters;
    _checkDownloadedChapters();

    player.playerStateStream.listen((state) {
      _isBuffering = state.processingState == ProcessingState.buffering ||
          state.processingState == ProcessingState.loading;
      notifyListeners();

      if (state.processingState == ProcessingState.completed) {
        playNext();
      }
    });

    player.positionStream.listen((position) {
      _currentPosition = position;
      notifyListeners();
    });

    player.durationStream.listen((duration) {
      _audioDuration = duration ?? Duration.zero;
      notifyListeners();
    });

    player.setVolume(_volume);
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
      if (await File(path).exists()) {
        _downloadedChapters.add(i);
      }
    }
    notifyListeners();
  }

  Future<void> updateVolume(double newVolume) async {
    final normalizedVolume = newVolume.clamp(0.0, 1.0);
    await player.setVolume(normalizedVolume);
    _volume = normalizedVolume;
    notifyListeners();
  }

  Future<void> play(int indexInFullList) async {
    final chapter = book.chapters[indexInFullList];
    try {
      if (_currentIndex == indexInFullList) {
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

      bool usedLocal = false;
      try {
        final localPath = await getLocalFilePath(chapter.name);
        if (localPath.isNotEmpty) {
          final file = File(localPath);
          if (await file.exists()) {
            await player.setAudioSource(
              AudioSource.file(localPath),
              preload: true,
            );
            usedLocal = true;
          }
        }
      } catch (_) {}

      if (!usedLocal) {
        await player.setAudioSource(
          AudioSource.uri(Uri.parse(chapter.url)),
          preload: true,
        );
      }

      await player.play();
    } catch (_) {
      _isBuffering = false;
      notifyListeners();
    }
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
    player.dispose();
    super.dispose();
  }
}
