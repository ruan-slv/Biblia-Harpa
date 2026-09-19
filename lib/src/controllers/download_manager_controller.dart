/// Gerencia o download de conteúdos da Bíblia e Harpa do Google Drive.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class DownloadItem {
  final String key;
  final String name;
  final String language;
  final String url;
  final String type; // 'bible', 'audio', 'harp', 'devotional', 'quiz', 'daily_word'

  DownloadItem({
    required this.key,
    required this.name,
    required this.language,
    required this.url,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      'language': language,
      'url': url,
      'type': type,
    };
  }
}

class DownloadManagerController extends ChangeNotifier {
  static const String _dataJsonPath = 'assets/data.json';

  List<DownloadItem> _bibleVersions = [];
  List<DownloadItem> _audios = [];
  List<DownloadItem> _contentItems = [];

  Map<String, bool> _downloadedFiles = {};
  Map<String, double> _downloadProgress = {};

  List<DownloadItem> get bibleVersions => _bibleVersions;
  List<DownloadItem> get audios => _audios;
  List<DownloadItem> get contentItems => _contentItems;

  bool get isLoaded => _bibleVersions.isNotEmpty;

  Future<void> loadDownloadData() async {
    try {
      final jsonString = await rootBundle.loadString(_dataJsonPath);
      final data = jsonDecode(jsonString);

      // Load Bible versions
      if (data['bible_versions'] != null) {
        for (var item in data['bible_versions']) {
          _bibleVersions.add(DownloadItem(
            key: item['key'],
            name: item['name'],
            language: item['language'],
            url: item['url'],
            type: 'bible',
          ));
        }
      }

      // Load audios
      if (data['audios'] != null) {
        final audios = data['audios'];
        if (audios['bible'] != null) {
          _audios.add(DownloadItem(
            key: audios['bible']['key'],
            name: audios['bible']['name'],
            language: 'Portuguese',
            url: audios['bible']['url'],
            type: 'audio',
          ));
        }
        if (audios['harp'] != null) {
          _audios.add(DownloadItem(
            key: audios['harp']['key'],
            name: audios['harp']['name'],
            language: 'Portuguese',
            url: audios['harp']['url'],
            type: 'audio',
          ));
        }
      }

      // Load other content
      if (data['devotionals'] != null) {
        _contentItems.add(DownloadItem(
          key: data['devotionals']['key'],
          name: data['devotionals']['name'],
          language: 'Portuguese',
          url: data['devotionals']['url'],
          type: 'devotional',
        ));
      }
      if (data['harp'] != null) {
        _contentItems.add(DownloadItem(
          key: data['harp']['key'],
          name: data['harp']['name'],
          language: 'Portuguese',
          url: data['harp']['url'],
          type: 'harp',
        ));
      }
      if (data['daily_word'] != null) {
        _contentItems.add(DownloadItem(
          key: data['daily_word']['key'],
          name: data['daily_word']['name'],
          language: 'Portuguese',
          url: data['daily_word']['url'],
          type: 'daily_word',
        ));
      }
      if (data['quiz'] != null) {
        _contentItems.add(DownloadItem(
          key: data['quiz']['key'],
          name: data['quiz']['name'],
          language: 'Portuguese',
          url: data['quiz']['url'],
          type: 'quiz',
        ));
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading download data: $e');
    }
  }

  Future<String> getDownloadDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final downloadDir = Directory('${directory.path}/downloads');
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }
    return downloadDir.path;
  }

  Future<void> downloadFile(DownloadItem item) async {
    try {
      _downloadProgress[item.key] = 0.0;
      notifyListeners();

      final downloadDir = await getDownloadDirectory();
      final filePath = '$downloadDir/${item.key}.json';
      final file = File(filePath);

      final response = await http.get(Uri.parse(item.url));
      if (response.statusCode == 200) {
        await file.writeAsString(response.body);
        _downloadProgress[item.key] = 1.0;
        notifyListeners();
      } else {
        throw Exception('Download failed with status ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error downloading ${item.key}: $e');
      _downloadProgress[item.key] = -1.0; // Error state
      notifyListeners();
    }
  }

  Future<bool> isDownloaded(String key) async {
    try {
      final downloadDir = await getDownloadDirectory();
      final filePath = '$downloadDir/$key.json';
      return File(filePath).existsSync();
    } catch (e) {
      return false;
    }
  }

  Future<String?> getDownloadedFilePath(String key) async {
    try {
      final downloadDir = await getDownloadDirectory();
      final filePath = '$downloadDir/$key.json';
      if (File(filePath).existsSync()) {
        return filePath;
      }
    } catch (e) {
      // ignore
    }
    return null;
  }
}