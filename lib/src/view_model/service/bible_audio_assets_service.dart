import 'dart:convert';
import '../../model/bible_audio.dart';
import 'package:flutter/services.dart';

class BibleAudioAssetsService {
  const BibleAudioAssetsService();

  Future<List<BibleAudioBook>> loadAudioBooks() async {
    final response = await rootBundle.loadString("assets/json/audios.json");
    final List data = json.decode(response) as List;
    return data
        .whereType<Map>()
        .map((e) => BibleAudioBook.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
