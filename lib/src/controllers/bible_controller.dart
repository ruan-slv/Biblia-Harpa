/// Centraliza o controle de estado e as ações deste recurso do aplicativo.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BibleController {

  static final BibleController _instance = BibleController._internal();

  factory BibleController() {
    return _instance;
  }

  BibleController._internal() {
    loadReadTexts();
  }

  static const String _key = "textosLidos";
  final ValueNotifier<List<String>> textosLidosNotifier = ValueNotifier([]);

  Future<void> loadReadTexts() async {
    final prefs = await SharedPreferences.getInstance();
    textosLidosNotifier.value = prefs.getStringList(_key) ?? [];
  }

  Future<void> saveAsRead(String id) async {
    if (isRead(id)) return;
    final prefs = await SharedPreferences.getInstance();
    final newList = [...textosLidosNotifier.value, id];
    textosLidosNotifier.value = newList;
    await prefs.setStringList(_key, newList);
  }

  Future<void> unsaveAsRead(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final newList = List<String>.from(textosLidosNotifier.value)..remove(id);
    textosLidosNotifier.value = newList;
    await prefs.setStringList(_key, newList);
  }

  Future<void> toggleReadStatus(String id) async {
    if (isRead(id)) {
      await unsaveAsRead(id);
    } else {
      await saveAsRead(id);
    }
  }

  bool isRead(String id) {
    return textosLidosNotifier.value.contains(id);
  }

}
