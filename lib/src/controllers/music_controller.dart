/// Implementa o serviço que dá suporte à camada de apresentação.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../database/app_database.dart';
import '../model/music.dart';

class MusicController extends ChangeNotifier {
  MusicController() {
    loadMusics();
  }

  List<Music> _musics = const [];
  bool _loading = true;

  List<Music> get musics => List.unmodifiable(_musics);
  bool get loading => _loading;

  Future<void> loadMusics() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('music', orderBy: 'id ASC', limit: 20);
    _musics = rows.map(Music.fromMap).toList(growable: false);
    _loading = false;
    notifyListeners();
  }

  Future<void> addMusic(Music music) async {
    final db = await AppDatabase.instance.database;
    await db.insert('music', music.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
    await loadMusics();
  }

  List<Music> getMusics() {
    return musics;
  }

  Future<void> deleteMusic(int index) async {
    if (index < 0 || index >= _musics.length) return;
    final db = await AppDatabase.instance.database;
    await db.delete('music', where: 'id = ?', whereArgs: [_musics[index].id]);
    await loadMusics();
  }
}
