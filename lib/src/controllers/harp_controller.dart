/// Coordena o estado e as ações consumidos pela camada de apresentação.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HarpController extends ChangeNotifier {
  final String initialHarp;
  late String _currentHarp;
  List<String> allHarps = [];
  bool _loading = true;

  HarpController({required this.initialHarp}) {
    _currentHarp = initialHarp;
    _loadHarpsFromJson();
    _loadReadStatus();
  }

  bool get loading => _loading;

  Future<void> _loadHarpsFromJson() async {
    try {
      final response = await rootBundle.loadString("assets/json/outros/harpa_crista_640_hinos.json");
      final decoded = json.decode(response);
      List<String> harps = [];
      
      if (decoded is Map) {
        for (final key in decoded.keys) {
          final item = decoded[key];
          if (item is Map) {
            final title = item["hino"] ?? "";
            if (title.isNotEmpty) {
              harps.add(title);
            }
          }
        }
      }
      
      setState(() {
        allHarps = harps;
        _loading = false;
      });
    } catch (e) {
      print("Error loading harps from JSON: $e");
      setState(() {
        _loading = false;
      });
    }
  }

  void setState(VoidCallback callback) {
    callback();
    notifyListeners();
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