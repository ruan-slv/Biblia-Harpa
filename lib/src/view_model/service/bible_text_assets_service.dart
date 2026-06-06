import 'dart:convert';
import '../../model/bible_book.dart';
import 'package:flutter/services.dart';

class BibleTextAssetsService {
  const BibleTextAssetsService();

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
