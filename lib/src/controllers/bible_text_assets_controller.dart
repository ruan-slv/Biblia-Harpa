/// Implementa o serviço que dá suporte à camada de apresentação.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'dart:convert';
import '../model/bible_book.dart';
import 'package:flutter/services.dart';

class BibleTextAssetsController {
  const BibleTextAssetsController();

  /// Carrega os livros diretamente do JSON da versão selecionada.
  ///
  /// A chave `name` de cada item é a fonte de verdade para a listagem.
  Future<List<BibleBook>> loadBooks(String jsonAssetPath) async {
    try {
      final jsonString = await rootBundle.loadString(jsonAssetPath);
      final data = json.decode(jsonString);
      if (data is! List) return const [];
      return data
          .whereType<Map>()
          .map((item) => BibleBook.fromJson(Map<String, dynamic>.from(item)))
          .where((book) => book.name.trim().isNotEmpty)
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<BibleBook?> loadBook({
    required String jsonAssetPath,
    required String bookName,
  }) async {
    try {
      final books = await loadBooks(jsonAssetPath);
      for (final book in books) {
        if (book.name == bookName) return book;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
