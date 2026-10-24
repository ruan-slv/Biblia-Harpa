/// Centraliza o controle de estado e as ações do Devocional do Dia.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/devotional_of_the_day.dart';

class DevotionalOfTheDayController extends ChangeNotifier {
  static const String _assetPath = 'assets/json/outros/devocionais.json';
  static const String _lastUpdateKey = 'devocional_do_dia_last_update';
  static const String _currentKey = 'devocional_do_dia';

  DevotionalOfTheDay? _current;
  DevotionalOfTheDay? get current => _current;

  /// Carrega o devocional do dia, reutilizando o valor em cache quando ainda
  /// for do dia atual (mesma lógica da Palavra do Dia).
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedLastUpdate = prefs.getString(_lastUpdateKey);
    final String? savedDevotional = prefs.getString(_currentKey);
    final now = DateTime.now();
    final needUpdate = savedLastUpdate == null ||
        DateTime.parse(savedLastUpdate).difference(now).inDays.abs() >= 1;

    if (!needUpdate && savedDevotional != null) {
      try {
        final Map<String, dynamic> json =
            Map<String, dynamic>.from(jsonDecode(savedDevotional) as Map);
        _current = DevotionalOfTheDay.fromJson(json);
        notifyListeners();
        return;
      } catch (_) {}
    }

    try {
      final String jsonString = await rootBundle.loadString(_assetPath);
      final decoded = jsonDecode(jsonString);
      final content = Map<String, dynamic>.from(decoded as Map);

      final entries = <DevotionalOfTheDay>[];
      content.forEach((topic, value) {
        if (value is! List) return;
        for (var index = 0; index < value.length; index++) {
          final item = value[index];
          if (item is! Map) continue;
          final map = Map<String, dynamic>.from(item);
          entries.add(DevotionalOfTheDay(
            topic: topic,
            index: index,
            versiculo: map['versiculo'] ?? map['Versiculo'] ?? '',
            texto: map['texto'] ?? map['Texto'] ?? '',
            oracao: map['Oração'] ?? map['oracao'] ?? '',
          ));
        }
      });

      if (entries.isEmpty) {
        _current = null;
        notifyListeners();
        return;
      }

      final selected = entries[Random().nextInt(entries.length)];
      _current = selected;
      await prefs.setString(_lastUpdateKey, now.toIso8601String());
      await prefs.setString(_currentKey, jsonEncode(selected.toJson()));
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar devocional do dia: $e');
      notifyListeners();
    }
  }
}
