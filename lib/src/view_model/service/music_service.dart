/// Implementa o serviço que dá suporte à camada de apresentação.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../model/music.dart';

class MusicService {
  late final Box<Music> _musicBox;

  MusicService() {
    try {
      _musicBox = Hive.box<Music>('musicas');
      debugPrint('Box "musicas" inicializada com sucesso. Tamanho: ${_musicBox.length}');
    } catch (e) {
      debugPrint('Erro ao inicializar Box "musicas": $e');
      rethrow;
    }
  }

  Future<void> addMusic(Music music) async {
    try {
      await _musicBox.add(music);
      debugPrint('Música adicionada: ${music.title}, Caminho: ${music.filePath}');
    } catch (e) {
      debugPrint('Erro ao adicionar música: $e');
      rethrow;
    }
  }

  List<Music> getMusics() {
    try {
      final musics = _musicBox.values.skip(0).take(20).toList();
      debugPrint('Músicas recuperadas: ${musics.length}');
      return musics;
    } catch (e) {
      debugPrint('Erro ao recuperar músicas: $e');
      return [];
    }
  }

  Future<void> deleteMusic(int index) async {
    try {
      await _musicBox.deleteAt(index);
      debugPrint('Música removida no índice: $index');
    } catch (e) {
      debugPrint('Erro ao remover música: $e');
      rethrow;
    }
  }
}
