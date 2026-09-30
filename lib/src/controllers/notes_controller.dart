import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/app_database.dart';
import '../model/note.dart';

/// Coordena as anotações do usuário, persistindo em SQLite (fonte primária)
/// e espelhando no SharedPreferences (backup/portabilidade).
class NotesController extends ChangeNotifier {
  static const String _prefsKey = 'user_notes';

  List<Note> _notes = [];
  bool _loading = true;

  List<Note> get notes => List.unmodifiable(_notes);
  bool get loading => _loading;

  NotesController() {
    loadNotes();
  }

  Future<void> loadNotes() async {
    try {
      final db = await AppDatabase.instance.database;
      final rows = await db.query('annotations', orderBy: 'updated_at DESC');
      _notes = rows.map(Note.fromMap).toList();
    } catch (_) {
      // Fallback: tenta restaurar do SharedPreferences.
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_prefsKey);
      if (data != null) {
        try {
          final list = jsonDecode(data) as List<dynamic>;
          _notes = list
              .map((e) => Note.fromMap(Map<String, dynamic>.from(e)))
              .toList()
            ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        } catch (_) {
          _notes = [];
        }
      } else {
        _notes = [];
      }
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> _mirrorToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _notes
        .map((n) => jsonEncode(
              {
                'title': n.title,
                'content': n.content,
                'reference': n.reference,
                'created_at': n.createdAt.millisecondsSinceEpoch,
                'updated_at': n.updatedAt.millisecondsSinceEpoch,
              },
            ))
        .toList();
    await prefs.setString(_prefsKey, jsonEncode(list));
  }

  Future<int> addNote({
    required String title,
    required String content,
    String? reference,
  }) async {
    final now = DateTime.now();
    final db = await AppDatabase.instance.database;
    final id = await db.insert(
      'annotations',
      {
        'title': title,
        'content': content,
        'reference': reference,
        'created_at': now.millisecondsSinceEpoch,
        'updated_at': now.millisecondsSinceEpoch,
      },
    );
    final note = Note(
      id: id,
      title: title,
      content: content,
      reference: reference,
      createdAt: now,
      updatedAt: now,
    );
    _notes.insert(0, note);
    notifyListeners();
    await _mirrorToPrefs();
    return id;
  }

  Future<void> updateNote(Note note) async {
    final updated = note.copyWith(updatedAt: DateTime.now());
    final db = await AppDatabase.instance.database;
    if (updated.id != null) {
      await db.update(
        'annotations',
        updated.toMap(),
        where: 'id = ?',
        whereArgs: [updated.id],
      );
    }
    final index = _notes.indexWhere((n) => n.id == updated.id);
    if (index != -1) {
      _notes[index] = updated;
    }
    _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    notifyListeners();
    await _mirrorToPrefs();
  }

  Future<void> deleteNote(Note note) async {
    final db = await AppDatabase.instance.database;
    if (note.id != null) {
      await db.delete('annotations', where: 'id = ?', whereArgs: [note.id]);
    }
    _notes.removeWhere((n) => n.id == note.id);
    notifyListeners();
    await _mirrorToPrefs();
  }
}
