/// Coordena o estado e as ações consumidos pela camada de apresentação.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import '../model/bible_audio.dart';
import 'bible_audio_assets_controller.dart';
import 'bible_text_assets_controller.dart';
import 'bible_version_controller.dart';
import '../utils/text_normalizer.dart';
import 'package:flutter/foundation.dart';

class BibleListController extends ChangeNotifier {
  final BibleVersionController versionService;
  final BibleAudioAssetsController audioAssetsService;
  final BibleTextAssetsController textAssetsService;

  BibleListController({
    required this.versionService,
    required this.audioAssetsService,
    required this.textAssetsService,
  }) {
    _init();
  }

  bool _initialized = false;
  bool get initialized => _initialized;

  String _selectedVersionFile = 'acf.json';
  String get selectedVersionFile => _selectedVersionFile;

  String get selectedVersionKey {
    // Reverse map: file -> key
    switch (_selectedVersionFile) {
      case 'acf.json': return 'ACF';
      case 'aa.json': return 'AA';
      case 'nvi.json': return 'NVI';
      case 'en_kjv.json': return 'KJV';
      case 'en_bbe.json': return 'BBE';
      case 'es_rvr.json': return 'RVR';
      case 'de_schlachter.json': return 'SCHLACHTER';
      case 'fr_apee.json': return 'APEE';
      case 'ru_synodal.json': return 'SYNODAL';
      case 'zh_cuv.json': return 'CUV';
      case 'zh_ncv.json': return 'NCV';
      case 'ko_ko.json': return 'KO';
      case 'vi_vietnamese.json': return 'VIETNAMESE';
      case 'el_greek.json': return 'GREEK';
      case 'ro_cornilescu.json': return 'CORNILESCU';
      case 'eo_esperanto.json': return 'ESPERANTO';
      case 'ar_svd.json': return 'SVD';
      case 'fi_finnish.json': return 'FINNISH';
      case 'fi_pr.json': return 'FI_PR';
      default: return 'ACF';
    }
  }

  String get jsonAssetPath => 'assets/json/bible/$_selectedVersionFile';

  String _query = '';
  String get query => _query;

  List<String> _books = const [];
  List<String> get books => _books;

  List<BibleAudioBook> _audioBooks = const [];
  List<BibleAudioBook> get audioBooks => _audioBooks;

  Future<void> _init() async {
    _selectedVersionFile = await versionService.getSelectedVersionFileName();
    await _loadBooks();
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
    String newVersion = 'acf.json';
    switch (key) {
      case 'ACF':
        newVersion = 'acf.json';
        break;
      case 'AA':
        newVersion = 'aa.json';
        break;
      case 'NVI':
        newVersion = 'nvi.json';
        break;
      case 'KJV':
        newVersion = 'en_kjv.json';
        break;
      case 'BBE':
        newVersion = 'en_bbe.json';
        break;
      case 'RVR':
        newVersion = 'es_rvr.json';
        break;
      case 'SCHLACHTER':
        newVersion = 'de_schlachter.json';
        break;
      case 'APEE':
        newVersion = 'fr_apee.json';
        break;
      case 'SYNODAL':
        newVersion = 'ru_synodal.json';
        break;
      case 'CUV':
        newVersion = 'zh_cuv.json';
        break;
      case 'NCV':
        newVersion = 'zh_ncv.json';
        break;
      case 'KO':
        newVersion = 'ko_ko.json';
        break;
      case 'VIETNAMESE':
        newVersion = 'vi_vietnamese.json';
        break;
      case 'GREEK':
        newVersion = 'el_greek.json';
        break;
      case 'CORNILESCU':
        newVersion = 'ro_cornilescu.json';
        break;
      case 'ESPERANTO':
        newVersion = 'eo_esperanto.json';
        break;
      case 'SVD':
        newVersion = 'ar_svd.json';
        break;
      case 'FINNISH':
        newVersion = 'fi_finnish.json';
        break;
      case 'FI_PR':
        newVersion = 'fi_pr.json';
        break;
    }
    _selectedVersionFile = newVersion;
    await versionService.setSelectedVersionFileName(newVersion);
    await _loadBooks();
    notifyListeners();
  }

  Future<void> _loadBooks() async {
    _books = (await textAssetsService.loadBooks(jsonAssetPath))
        .map((book) => book.name)
        .toList(growable: false);
  }

  List<String> filterBooks() {
    final q = TextNormalizer.normalize(_query.trim());
    if (q.isEmpty) return _books;
    return _books
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
