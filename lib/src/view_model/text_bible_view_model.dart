import '../model/bible_audio.dart';
import 'bible_read_view_model.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class BibleContentViewModel extends ChangeNotifier {
  final BibleReadViewModel readState;
  final String bookName;
  final String jsonPath;
  final List<List<String>> allBookChapters;
  final List<BibleAudioChapter>? audioChapters;
  final int verseSelectionLimit;

  final ScrollController scrollController = ScrollController();
  final TextEditingController keywordController = TextEditingController();
  final AudioPlayer audioPlayer = AudioPlayer();

  BibleContentViewModel({
    required this.readState,
    required this.bookName,
    required this.jsonPath,
    required this.allBookChapters,
    required this.audioChapters,
    required int initialChapterNumber,
    this.verseSelectionLimit = 15,
  }) {
    _setChapter(initialChapterNumber);
    _applyKeywordFilter();

    audioPlayer.positionStream.listen((position) {
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

  Future<void> loadAudioForChapter(int chapterNumber) async {
    await audioPlayer.stop();

    if (audioChapters != null &&
        chapterNumber > 0 &&
        chapterNumber - 1 < audioChapters!.length) {
      final audio = audioChapters![chapterNumber - 1];
      try {
        await audioPlayer.setUrl(audio.url);
        _currentAudioChapter = audio;
      } catch (_) {
        _currentAudioChapter = null;
      }
    } else {
      _currentAudioChapter = null;
    }

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
    shareText.writeln("$bookName - Capítulo $_currentChapterNumber");
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

  @override
  void dispose() {
    scrollController.dispose();
    keywordController.dispose();
    audioPlayer.dispose();
    super.dispose();
  }
}
