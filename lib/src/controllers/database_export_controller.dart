/// Exporta a base de dados local (JSON da Bíblia e da Harpa) para uma
/// pasta do dispositivo escolhida pelo usuário.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Resultado de uma exportação da base de dados.
class DatabaseExportResult {
  const DatabaseExportResult({
    required this.success,
    required this.message,
    this.directory,
  });

  final bool success;
  final String message;

  /// Caminho da pasta onde os arquivos foram gravados (quando bem-sucedido).
  final String? directory;
}

class DatabaseExportController extends ChangeNotifier {
  /// Chave usada pelo [BibleVersionController] para persistir a versão
  /// selecionada da Bíblia.
  static const String _versionPrefsKey = 'selectedVersion';

  static const String _harpaAssetPath =
      'assets/json/outros/harpa_crista_640_hinos.json';
  static const String _harpaFileName = 'harpa_crista_640_hinos.json';

  bool _isExporting = false;
  bool get isExporting => _isExporting;

  /// Copia o JSON da versão da Bíblia selecionada e o JSON da Harpa para uma
  /// pasta do dispositivo, perguntando o destino ao usuário.
  Future<DatabaseExportResult> export() async {
    if (_isExporting) {
      return const DatabaseExportResult(
        success: false,
        message: 'Já existe uma exportação em andamento.',
      );
    }

    _isExporting = true;
    notifyListeners();

    try {
      // 1. Descobre qual versão da Bíblia está selecionada.
      final prefs = await SharedPreferences.getInstance();
      final versionFile = prefs.getString(_versionPrefsKey) ?? 'acf.json';
      final bibleAssetPath = 'assets/json/bible/$versionFile';

      // 2. Lê os arquivos direto dos assets do aplicativo.
      final bibleBytes = await rootBundle.load(bibleAssetPath);
      final harpaBytes = await rootBundle.load(_harpaAssetPath);

      final bibleData = bibleBytes.buffer.asUint8List(
        bibleBytes.offsetInBytes,
        bibleBytes.lengthInBytes,
      );
      final harpaData = harpaBytes.buffer.asUint8List(
        harpaBytes.offsetInBytes,
        harpaBytes.lengthInBytes,
      );

      // 3. Grava nos destinos possíveis (escolhido pelo usuário primeiro).
      for (final directory in await _candidateDirectories()) {
        try {
          if (!await directory.exists()) {
            await directory.create(recursive: true);
          }
          await File('${directory.path}/$versionFile')
              .writeAsBytes(bibleData);
          await File('${directory.path}/$_harpaFileName')
              .writeAsBytes(harpaData);

          return DatabaseExportResult(
            success: true,
            message: 'Base exportada com sucesso!',
            directory: directory.path,
          );
        } catch (e) {
          debugPrint('Falha ao gravar em ${directory.path}: $e');
        }
      }

      return const DatabaseExportResult(
        success: false,
        message: 'Não foi possível salvar os arquivos no dispositivo.',
      );
    } catch (e) {
      debugPrint('Erro ao exportar base de dados: $e');
      return DatabaseExportResult(
        success: false,
        message: 'Não foi possível exportar: $e',
      );
    } finally {
      _isExporting = false;
      notifyListeners();
    }
  }

  /// Monta a lista de pastas candidatas, na ordem de preferência:
  /// 1. pasta escolhida pelo usuário no seletor;
  /// 2. pasta externa do app (Android);
  /// 3. pasta Downloads (desktop);
  /// 4. pasta de documentos do app.
  Future<List<Directory>> _candidateDirectories() async {
    final directories = <Directory>[];

    try {
      final picked = await FilePicker.getDirectoryPath(
        dialogTitle: 'Escolha onde salvar a base de dados',
      );
      if (picked != null && picked.trim().isNotEmpty && picked.trim() != '/') {
        directories.add(Directory(picked));
      }
    } catch (e) {
      debugPrint('Falha ao abrir o seletor de pasta: $e');
    }

    try {
      if (Platform.isAndroid) {
        final external = await getExternalStorageDirectory();
        if (external != null) directories.add(external);
      }
      final downloads = await getDownloadsDirectory();
      if (downloads != null) directories.add(downloads);
    } catch (_) {
      // Plataformas sem suporte a essas pastas seguem para o fallback.
    }

    final documents = await getApplicationDocumentsDirectory();
    final fallback = Directory('${documents.path}/base_exportada');
    directories.add(fallback);

    return directories;
  }
}
