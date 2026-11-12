/// Coordena o estado e as ações consumidos pela camada de apresentação.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'dart:async';

import '../model/bible_audio.dart';
import 'bible_audio_assets_controller.dart';
import 'bible_text_assets_controller.dart';
import 'bible_version_controller.dart';
import 'settings_controller.dart';
import '../utils/bible_version_defaults.dart';
import '../utils/text_normalizer.dart';
import 'package:flutter/foundation.dart';

class BibleListController extends ChangeNotifier {
  final BibleVersionController versionService;
  final BibleAudioAssetsController audioAssetsService;
  final BibleTextAssetsController textAssetsService;
  final SettingsController? settingsController;

  BibleListController({
    required this.versionService,
    required this.audioAssetsService,
    required this.textAssetsService,
    this.settingsController,
  }) {
    _lastLanguageCode = settingsController?.languageCode;
    _lastLanguageVersion = settingsController?.languageVersion ?? 0;
    settingsController?.addListener(_handleSettingsChanged);
    _init();
  }

  bool _initialized = false;
  bool get initialized => _initialized;

  String _selectedVersionFile = kDefaultPortugueseBibleFile;
  String get selectedVersionFile => _selectedVersionFile;

  String get selectedVersionKey => bibleVersionKeyForFile(_selectedVersionFile);

  String? _lastLanguageCode;
  int _lastLanguageVersion = 0;

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
    final fileName = bibleVersionFileForKey(key);
    if (fileName == null) return;
    await _applyVersionFile(fileName);
  }

  /// Aplica a versão padrão do idioma informado (ex.: russo → Bíblia russa).
  Future<void> setVersionForLanguage(String languageCode) =>
      _applyVersionFile(bibleVersionFileForLanguage(languageCode));

  /// Reage à troca de idioma em tempo de execução, recarregando a Bíblia.
  void _handleSettingsChanged() {
    final settings = settingsController;
    if (settings == null) return;
    final versionChanged = settings.languageVersion != _lastLanguageVersion;
    final codeChanged = settings.languageCode != _lastLanguageCode;
    if (!versionChanged && !codeChanged) return;
    _lastLanguageVersion = settings.languageVersion;
    _lastLanguageCode = settings.languageCode;
    unawaited(setVersionForLanguage(settings.languageCode));
  }

  Future<void> _applyVersionFile(String fileName) async {
    if (_selectedVersionFile == fileName) return;
    _selectedVersionFile = fileName;
    await versionService.setSelectedVersionFileName(fileName);
    await _loadBooks();
    notifyListeners();
  }

  @override
  void dispose() {
    settingsController?.removeListener(_handleSettingsChanged);
    super.dispose();
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
