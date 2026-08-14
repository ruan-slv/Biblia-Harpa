/// Coordena o estado e as ações consumidos pela camada de apresentação.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BibleReadViewModel extends ChangeNotifier {
  static const String _key = "textosLidos";

  BibleReadViewModel() {
    _load();
  }

  List<String> _readIds = const [];
  List<String> get readIds => _readIds;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _readIds = prefs.getStringList(_key) ?? const [];
    notifyListeners();
  }

  bool isRead(String id) => _readIds.contains(id);

  Future<void> saveAsRead(String id) async {
    if (isRead(id)) return;
    final prefs = await SharedPreferences.getInstance();
    _readIds = [..._readIds, id];
    await prefs.setStringList(_key, _readIds);
    notifyListeners();
  }

  Future<void> unsaveAsRead(String id) async {
    final prefs = await SharedPreferences.getInstance();
    _readIds = List<String>.from(_readIds)..remove(id);
    await prefs.setStringList(_key, _readIds);
    notifyListeners();
  }

  Future<void> toggleReadStatus(String id) async {
    if (isRead(id)) {
      await unsaveAsRead(id);
    } else {
      await saveAsRead(id);
    }
  }
}
