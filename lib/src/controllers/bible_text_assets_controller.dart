/// Implementa o serviço que dá suporte à camada de apresentação.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'dart:convert';
import '../model/bible_book.dart';
import 'package:flutter/services.dart';

class BibleTextAssetsController {
  const BibleTextAssetsController();

  Future<BibleBook?> loadBook({
    required String jsonAssetPath,
    required String bookName,
  }) async {
    try {
      final jsonString = await rootBundle.loadString(jsonAssetPath);
      final List data = json.decode(jsonString) as List;
      for (final item in data) {
        if (item is Map && item['name'] == bookName) {
          return BibleBook.fromJson(Map<String, dynamic>.from(item));
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
