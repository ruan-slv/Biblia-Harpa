/// Implementa o serviço que dá suporte à camada de apresentação.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

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
