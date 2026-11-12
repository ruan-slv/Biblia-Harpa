import 'dart:async';

import 'bible_text_assets_controller.dart';
import '../model/bible_audio.dart';
import 'continue_reading_controller.dart';
import 'bible_read_controller.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../services/app_audio_handler.dart';
import '../l10n/app_localizations.dart';

class BibleContentController extends ChangeNotifier {
  final BibleReadController readState;
  final String bookName;
  String _jsonPath;
  String get jsonPath => _jsonPath;
  List<List<String>> _allBookChapters;
  List<List<String>> get allBookChapters => _allBookChapters;
  final List<BibleAudioChapter>? audioChapters;
  final int verseSelectionLimit;

  /// Serviço responsável por registrar o capítulo aberto para retomada global.
  final ContinueReadingController continueReadingController;

  final ScrollController scrollController = ScrollController();
  final TextEditingController keywordController = TextEditingController();
  AudioPlayer get audioPlayer => sharedAudioPlayer;
  StreamSubscription<Duration>? _positionSubscription;

  BibleContentController({
    required this.readState,
    required this.bookName,
    required String jsonPath,
    required List<List<String>> allBookChapters,
    required this.audioChapters,
    required int initialChapterNumber,
    this.verseSelectionLimit = 20,
    this.continueReadingController = const ContinueReadingController(),
  })  : _jsonPath = jsonPath,
        _allBookChapters = allBookChapters {
    _setChapter(initialChapterNumber);
    _applyKeywordFilter();
    _saveContinueReading();

    _positionSubscription = audioPlayer.positionStream.listen((position) {
      // O player é global: só rola o texto quando o áudio em execução é o
      // capítulo da Bíblia (e não um hino tocando em segundo plano).
      final source = activeAudioHandler?.currentTrack.value?.extras['source'];
      if (source != null && source != 'bible-text') return;
      if (_isAutoScrollEnabled && audioPlayer.duration != null) {
        syncScrollWithAudio(position, audioPlayer.duration!);
      }
    });
  }

  int _currentChapterNumber = 1;
  int get currentChapterNumber => _currentChapterNumber;

  List<String> _currentVerses = const [];
  List<String> get currentVerses => _currentVerses;

  List<int> _selectedVerseIndices = const [];
  List<int> get selectedVerseIndices => _selectedVerseIndices;

  List<int> _filteredVerseIndices = const [];
  List<int> get filteredVerseIndices => _filteredVerseIndices;

  bool _isAutoScrollEnabled = false;
  bool get isAutoScrollEnabled => _isAutoScrollEnabled;

  BibleAudioChapter? _currentAudioChapter;
  BibleAudioChapter? get currentAudioChapter => _currentAudioChapter;

  String get chapterId => "${bookName}_$_currentChapterNumber";
  String get chapterTitle => "$bookName $_currentChapterNumber";

  bool get noFilterResults =>
      keywordController.text.isNotEmpty && _filteredVerseIndices.isEmpty;

  /// Identificador da faixa do capítulo atualmente carregada no player.
  String? _loadedAudioChapterId;

  String _audioIdFor(int chapterNumber) =>
      'bible-text:$bookName:$chapterNumber';

  /// Indica que outra origem (Harpa/Outros) está tocando e não deve ser
  /// interrompida apenas porque o usuário abriu um capítulo da Bíblia.
  bool get _foreignAudioPlaying {
    final current = activeAudioHandler?.currentTrack.value;
    return current != null &&
        current.extras['source'] != 'bible-text' &&
        sharedAudioPlayer.playing;
  }

  Future<void> loadAudioForChapter(int chapterNumber) async {
    if (audioChapters == null ||
        chapterNumber <= 0 ||
        chapterNumber - 1 >= audioChapters!.length) {
      _currentAudioChapter = null;
      _loadedAudioChapterId = null;
      notifyListeners();
      return;
    }

    final audio = audioChapters![chapterNumber - 1];
    _currentAudioChapter = audio;

    // Mantém a Harpa/Outros tocando em segundo plano: o capítulo fica
    // disponível e é carregado sob demanda ao tocar em play.
    if (_foreignAudioPlaying) {
      _loadedAudioChapterId = null;
      notifyListeners();
      return;
    }

    await _loadChapterAudio(audio, chapterNumber);
    notifyListeners();
  }

  Future<void> _loadChapterAudio(
    BibleAudioChapter audio,
    int chapterNumber,
  ) async {
    final id = _audioIdFor(chapterNumber);
    final active = activeAudioHandler;
    final current = active?.currentTrack.value;

    // Já é a faixa em reprodução (ou está carregada no fallback sem serviço).
    if (_loadedAudioChapterId == id && (active == null || current?.id == id)) {
      return;
    }

    try {
      await audioPlayer.stop();
      final track = AppAudioTrack(
        id: id,
        title: '$bookName $chapterNumber',
        artist: 'Bíblia em áudio',
        remoteUri: Uri.parse(audio.url),
        extras: const <String, String>{'source': 'bible-text'},
      );

      final handler = await ensureAudioHandler();
      if (handler != null) {
        await handler.playTrack(track, autoPlay: false);
      } else {
        await audioPlayer.setUrl(audio.url);
      }
      _loadedAudioChapterId = id;
    } catch (_) {
      _loadedAudioChapterId = null;
      _currentAudioChapter = null;
    }
  }

  /// Carrega (se necessário) e reproduz o áudio do capítulo aberto.
  Future<void> playCurrentChapterAudio() async {
    final audio = _currentAudioChapter;
    if (audio == null) return;
    await _loadChapterAudio(audio, _currentChapterNumber);
    await audioPlayer.play();
    notifyListeners();
  }

  /// Para a reprodução do capítulo e libera a fila do player global.
  Future<void> stopChapterAudio() async {
    final handler = activeAudioHandler;
    if (handler != null) {
      await handler.stop();
    } else {
      await audioPlayer.stop();
    }
    _loadedAudioChapterId = null;
    notifyListeners();
  }

  void setKeywordQuery(String _) {
    _applyKeywordFilter();
    notifyListeners();
  }

  void _applyKeywordFilter() {
    final query = keywordController.text.toLowerCase();
    if (query.isEmpty) {
      _filteredVerseIndices =
          List<int>.generate(_currentVerses.length, (i) => i);
      return;
    }

    final matches = <int>[];
    for (int i = 0; i < _currentVerses.length; i++) {
      if (_currentVerses[i].toLowerCase().contains(query)) matches.add(i);
    }
    _filteredVerseIndices = matches;
  }

  void syncScrollWithAudio(Duration position, Duration total) {
    if (!scrollController.hasClients || total.inMilliseconds == 0) return;

    final percentage = position.inMilliseconds / total.inMilliseconds;
    final maxScroll = scrollController.position.maxScrollExtent;
    final targetScroll = maxScroll * percentage.clamp(0.0, 1.0);

    scrollController.animateTo(
      targetScroll,
      duration: const Duration(milliseconds: 500),
      curve: Curves.linear,
    );
  }

  void toggleAutoScroll() {
    _isAutoScrollEnabled = !_isAutoScrollEnabled;
    notifyListeners();
  }

  void navigateToChapter(int newChapterNumber) {
    if (newChapterNumber < 1 || newChapterNumber > allBookChapters.length) {
      return;
    }

    _setChapter(newChapterNumber);
    _saveContinueReading();
    keywordController.clear();
    _applyKeywordFilter();
    _selectedVerseIndices = const [];
    notifyListeners();

    if (scrollController.hasClients) {
      scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    loadAudioForChapter(newChapterNumber);
  }

  void nextChapter() => navigateToChapter(_currentChapterNumber + 1);
  void previousChapter() => navigateToChapter(_currentChapterNumber - 1);

  void _saveContinueReading() {
    continueReadingController.saveBible(
      bookName: bookName,
      jsonPath: jsonPath,
      chapterNumber: _currentChapterNumber,
    );
  }

  Future<void> toggleCurrentChapterRead() async {
    final newId = "${bookName}_$_currentChapterNumber";
    final legacyId = "$bookName $_currentChapterNumber";

    if (readState.isRead(legacyId) && !readState.isRead(newId)) {
      await readState.unsaveAsRead(legacyId);
      await readState.saveAsRead(newId);
      return;
    }

    if (readState.isRead(newId) && readState.isRead(legacyId)) {
      await readState.unsaveAsRead(legacyId);
    }

    await readState.toggleReadStatus(newId);
  }

  bool toggleVerseSelection(int index) {
    final list = List<int>.from(_selectedVerseIndices);
    if (list.contains(index)) {
      list.remove(index);
      _selectedVerseIndices = list;
      notifyListeners();
      return true;
    }

    if (list.length >= verseSelectionLimit) return false;
    list.add(index);
    _selectedVerseIndices = list;
    notifyListeners();
    return true;
  }

  void clearSelections() {
    _selectedVerseIndices = const [];
    notifyListeners();
  }

  String buildShareText() {
    final shareText = StringBuffer();
    shareText.writeln(tr('{book} - Capítulo {number}', {
      'book': bookName,
      'number': '$_currentChapterNumber',
    }));
    shareText.writeln();

    final indices = _selectedVerseIndices.isNotEmpty
        ? (List<int>.from(_selectedVerseIndices)..sort())
        : List<int>.generate(
            _currentVerses.length.clamp(0, verseSelectionLimit), (i) => i);

    for (final i in indices) {
      if (i < _currentVerses.length) {
        shareText.writeln("${i + 1}. ${_currentVerses[i]}");
      }
    }
    return shareText.toString();
  }

  void _setChapter(int chapterNumber) {
    if (allBookChapters.isEmpty) {
      _currentChapterNumber = 1;
      _currentVerses = const [];
      return;
    }

    var c = chapterNumber;
    if (c < 1) c = 1;
    if (c > allBookChapters.length) c = allBookChapters.length;

    _currentChapterNumber = c;
    _currentVerses = allBookChapters[_currentChapterNumber - 1];
  }

  Future<void> changeVersion({
    required String newVersionFileName,
    required BibleTextAssetsController textAssetsService,
  }) async {
    final newPath = "assets/json/bible/$newVersionFileName";
    final books = await textAssetsService.loadBooks(newPath);
    if (books.isEmpty) return;

    int bookIndex = books.indexWhere(
      (b) => b.name.trim().toLowerCase() == bookName.trim().toLowerCase(),
    );

    if (bookIndex == -1) {
      final normalizedTarget =
          bookName.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
      bookIndex = books.indexWhere((b) =>
          b.name.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '') ==
          normalizedTarget);
    }

    if (bookIndex != -1) {
      final newBook = books[bookIndex];
      _jsonPath = newPath;
      _allBookChapters = newBook.chapters;
      _setChapter(_currentChapterNumber);
      _applyKeywordFilter();
      _selectedVerseIndices = const [];
      _saveContinueReading();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    scrollController.dispose();
    keywordController.dispose();
    super.dispose();
  }
}
