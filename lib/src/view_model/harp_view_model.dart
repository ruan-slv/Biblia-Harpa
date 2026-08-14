/// Coordena o estado e as ações consumidos pela camada de apresentação.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../keys/harp_key.dart';

class HarpViewModel extends ChangeNotifier {
  final String initialHarp;
  late String _currentHarp;
  final List<String> allHarps = harps;

  HarpViewModel({required this.initialHarp}) {
    _currentHarp = initialHarp;
    _loadReadStatus();
  }

  String get currentHarp => _currentHarp;
  int get currentIndex => allHarps.indexOf(_currentHarp) + 1;

  bool _isRead = false;
  bool get isRead => _isRead;

  Future<void> _loadReadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isRead = prefs.getBool('harp_read_$_currentHarp') ?? false;
    notifyListeners();
  }

  Future<void> toggleCurrentChapterRead() async {
    final prefs = await SharedPreferences.getInstance();
    _isRead = !_isRead;
    await prefs.setBool('harp_read_$_currentHarp', _isRead);
    notifyListeners();
  }

  void nextChapter() {
    if (currentIndex < allHarps.length) {
      _currentHarp = allHarps[currentIndex];
      _loadReadStatus();
      notifyListeners();
    }
  }

  void previousChapter() {
    if (currentIndex > 1) {
      _currentHarp = allHarps[currentIndex - 2];
      _loadReadStatus();
      notifyListeners();
    }
  }
}
