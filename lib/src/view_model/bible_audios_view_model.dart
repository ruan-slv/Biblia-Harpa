/// Coordena o estado e as ações consumidos pela camada de apresentação.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'dart:io';
import '../model/bible_audio.dart';
import 'service/bible_audio_assets_service.dart';
import '../utils/text_normalizer.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class BibleAudiosViewModel extends ChangeNotifier {
  final BibleAudioAssetsService audioAssetsService;

  BibleAudiosViewModel({required this.audioAssetsService});

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  String _query = '';
  String get query => _query;

  List<BibleAudioBook> _allBooks = const [];
  List<BibleAudioBook> get allBooks => _allBooks;

  List<BibleAudioBook> _filteredBooks = const [];
  List<BibleAudioBook> get filteredBooks => _filteredBooks;

  Future<void> load({required bool offlineOnly}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      var books = await audioAssetsService.loadAudioBooks();
      if (offlineOnly) {
        final offlineBooks = <BibleAudioBook>[];
        for (final book in books) {
          if (await _bookHasDownloads(book)) offlineBooks.add(book);
        }
        books = offlineBooks;
        if (books.isEmpty) {
          _error = "Nenhum áudio foi baixado para ser acessado offline.";
        }
      }
      _allBooks = books;
      _applyFilter();
    } catch (_) {
      _error = "Erro ao listar áudios. Verifique os arquivos do aplicativo.";
      _allBooks = const [];
      _filteredBooks = const [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void setQuery(String value) {
    _query = value;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    final q = TextNormalizer.normalize(_query.trim());
    if (q.isEmpty) {
      _filteredBooks = _allBooks;
      return;
    }
    _filteredBooks = _allBooks
        .where((b) => TextNormalizer.normalize(b.title).contains(q))
        .toList(growable: false);
  }

  Future<bool> _bookHasDownloads(BibleAudioBook book) async {
    for (final chapter in book.chapters) {
      final path = await _localFilePath(chapter.name);
      if (await File(path).exists()) return true;
    }
    return false;
  }

  Future<String> _localFilePath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${directory.path}/bible_audios');
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    final safeName =
        fileName.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_');
    return '${audioDir.path}/$safeName.mp3';
  }
}
