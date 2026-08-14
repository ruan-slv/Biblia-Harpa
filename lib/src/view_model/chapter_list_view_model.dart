/// Coordena o estado e as ações consumidos pela camada de apresentação.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'service/bible_text_assets_service.dart';
import 'package:flutter/foundation.dart';

class BibleChapterListViewModel extends ChangeNotifier {
  final BibleTextAssetsService textAssetsService;

  BibleChapterListViewModel({required this.textAssetsService});

  bool _loading = false;
  bool get loading => _loading;

  List<List<String>> _chapters = const [];
  List<List<String>> get chapters => _chapters;

  String _query = '';
  String get query => _query;

  Future<void> load({required String bookName, required String jsonAssetPath}) async {
    _loading = true;
    notifyListeners();

    final book = await textAssetsService.loadBook(
      jsonAssetPath: jsonAssetPath,
      bookName: bookName,
    );
    _chapters = book?.chapters ?? const [];

    _loading = false;
    notifyListeners();
  }

  void setQuery(String value) {
    _query = value.trim();
    notifyListeners();
  }

  List<int> filteredChapterNumbers() {
    if (_chapters.isEmpty) return const [];
    if (_query.isEmpty) {
      return List<int>.generate(_chapters.length, (i) => i + 1, growable: false);
    }
    final out = <int>[];
    for (int i = 0; i < _chapters.length; i++) {
      final chapterNumber = i + 1;
      if (chapterNumber.toString().contains(_query)) out.add(chapterNumber);
    }
    return out;
  }

  List<int> readChapterNumbersForBook({
    required String bookName,
    required List<String> readIds,
  }) {
    return readIds
        .where((id) => id.startsWith("${bookName}_"))
        .map((id) => int.tryParse(id.split('_').last) ?? 0)
        .where((n) => n > 0)
        .toList(growable: false);
  }
}
