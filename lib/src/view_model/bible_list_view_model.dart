import '../model/bible_audio.dart';
import 'service/bible_audio_assets_service.dart';
import 'service/bible_version_service.dart';
import '../utils/text_normalizer.dart';
import 'package:flutter/foundation.dart';

class BibleListViewModel extends ChangeNotifier {
  final BibleVersionService versionService;
  final BibleAudioAssetsService audioAssetsService;

  BibleListViewModel({
    required this.versionService,
    required this.audioAssetsService,
  }) {
    _init();
  }

  bool _initialized = false;
  bool get initialized => _initialized;

  String _selectedVersionFile = 'acf.json';
  String get selectedVersionFile => _selectedVersionFile;

  String get jsonAssetPath => 'assets/json/$_selectedVersionFile';

  String _query = '';
  String get query => _query;

  List<BibleAudioBook> _audioBooks = const [];
  List<BibleAudioBook> get audioBooks => _audioBooks;

  Future<void> _init() async {
    _selectedVersionFile = await versionService.getSelectedVersionFileName();
    try {
      _audioBooks = await audioAssetsService.loadAudioBooks();
    } catch (_) {
      _audioBooks = const [];
    }
    _initialized = true;
    notifyListeners();
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  Future<void> setVersionByKey(String key) async {
    // key: ACF | NVI | AA
    String newVersion = 'acf.json';
    switch (key) {
      case 'ACF':
        newVersion = 'acf.json';
        break;
      case 'NVI':
        newVersion = 'nvi.json';
        break;
      case 'AA':
        newVersion = 'aa.json';
        break;
    }
    _selectedVersionFile = newVersion;
    notifyListeners();
    await versionService.setSelectedVersionFileName(newVersion);
  }

  List<String> filterBooks(List<String> books) {
    final q = TextNormalizer.normalize(_query.trim());
    if (q.isEmpty) return books;
    return books
        .where((b) => TextNormalizer.normalize(b).contains(q))
        .toList(growable: false);
  }

  List<BibleAudioChapter>? findAudioChaptersForBook(String bookName) {
    try {
      return _audioBooks.firstWhere((b) => b.title == bookName).chapters;
    } catch (_) {
      return null;
    }
  }
}
