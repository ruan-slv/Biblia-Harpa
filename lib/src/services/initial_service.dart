/**
 * Modify: 17/04/2026 ;
 * Ruan Gustavo Soares da Silva ;
 * Files service into initial screen ;
 */

import 'dart:convert';
import 'dart:math';
import 'package:biblia_e_harpa/src/models/initial_model.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service into Initial screen ;
class InitialService {

  Future<(DayWord?, DateTime?)> loadDayWord(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final String? lastDataUpdate = prefs.getString("last_update");
    final String? saveWord = prefs.getString("palavra_atual");
    final now = DateTime.now();
    final needUpdate = lastDataUpdate == null ||
        DateTime.parse(lastDataUpdate).difference(now).inDays.abs() >= 1;

    if (!needUpdate && saveWord != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(saveWord);
        final word = DayWord.fromJson(json);
        final lastUpdate = DateTime.parse(lastDataUpdate);
        return (word, lastUpdate);
      } catch (_) {}
    }

    try {
      final String jsonString = await DefaultAssetBundle.of(context)
          .loadString("assets/json/palavraDoDia.json");
      final List<dynamic> jsonResponse = jsonDecode(jsonString)["palavraDoDia"];
      if (jsonResponse.isEmpty) {
        return (DayWord(id: 0, text: "", reference: ""), now);
      }
      final randomIndex = Random().nextInt(jsonResponse.length);
      final selectedWord = jsonResponse[randomIndex];
      final word = DayWord.fromJson(selectedWord);
      await prefs.setString("last_update", now.toIso8601String());
      await prefs.setString("palavra_atual", jsonEncode(selectedWord));
      return (word, now);
    } catch (_) {
      return (null, null);
    }
  }

  Future<void> shareDayWord(DayWord? currentWord) async {
    if(currentWord != null) {
      await SharePlus.instance.share(
        ShareParams(
          text: "${currentWord.text} \n ${currentWord.reference}",
        ),
      );
    }
  }
}