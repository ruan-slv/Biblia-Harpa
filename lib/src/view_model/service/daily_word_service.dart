import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/daily_word.dart';

class DailyWordService {
  Future<(DailyWord?, DateTime?)> loadDailyWord(BuildContext context) async {
    final assetBundle = DefaultAssetBundle.of(context);
    final prefs = await SharedPreferences.getInstance();
    final String? lastDataUpdate = prefs.getString("last_update");
    final String? savedWord = prefs.getString("palavra_atual");
    final now = DateTime.now();
    final needUpdate = lastDataUpdate == null ||
        DateTime.parse(lastDataUpdate).difference(now).inDays.abs() >= 1;

    if (!needUpdate && savedWord != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(savedWord);
        final word = DailyWord.fromJson(json);
        final lastUpdate = DateTime.parse(lastDataUpdate);
        return (word, lastUpdate);
      } catch (_) {}
    }

    try {
      final String jsonString = await assetBundle
          .loadString("assets/json/palavraDoDia.json");
      final List<dynamic> jsonResponse = jsonDecode(jsonString)["palavraDoDia"];
      if (jsonResponse.isEmpty) {
        return (DailyWord(id: 0, text: "", reference: ""), now);
      }
      final randomIndex = Random().nextInt(jsonResponse.length);
      final selectedWord = jsonResponse[randomIndex];
      final word = DailyWord.fromJson(selectedWord);
      await prefs.setString("last_update", now.toIso8601String());
      await prefs.setString("palavra_atual", jsonEncode(selectedWord));
      return (word, now);
    } catch (_) {
      return (null, null);
    }
  }

  Future<void> shareDailyWord(DailyWord? currentWord) async {
    if (currentWord != null) {
      await SharePlus.instance.share(
        ShareParams(
          text: "${currentWord.text} \n ${currentWord.reference}",
        ),
      );
    }
  }
}
