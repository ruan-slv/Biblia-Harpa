/// Implementa operações de dados, armazenamento ou integração deste recurso.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class BibleDownloadService {
  // Mapeamento dos IDs do Google Drive fornecidos por você
  static const Map<String, String> driveIds = {
    'ar_svd.json': '1giTklXqXuvz5SsWulf3kZKBRrq_M4jgh',
    'de_schlachter.json': '1Rpi_Gg7B8zUlx41_R9DEkv8HbFmsx9Be',
    'el_greek.json': '1VgwPDqBCVk063xMtemFqet40J-b2FjwO',
    'en_bbe.json': '1pDrNDi4kGNHO0y8aOoAV6O_1cZZHP976',
    'en_kjv.json': '1p81u9Fgzzljac-vUkEqak0XCkeU6llYz',
    'eo_esperanto.json': '1BAy3bN18WlkCOfx5SANfA1izc2QjBmVz',
    'es_rvr.json': '13VubJJYDzGsAX8Tr7lU8KzJovnhiBDwW',
    'fi_finnish.json': '1n2kCsI-gjor9oUs7PzNQ4zxn8QY8K-cN',
    'fi_pr.json': '19TuYOMrZoHKlnZqe7kA8DURVeNAKeD_k',
    'fr_apee.json': '1ul7Itv7SDYeZ9PFyyTTOfbpi-GSZctJZ',
    'ko_ko.json': '1G8-pm9WzPvSHTqfr3od2_ARcm1ThAmTY',
    'ro_cornilescu.json': '178r8AjMYLoH4etfhVCVFvPfJ2eOUQ0oV',
    'ru_synodal.json': '1jKOuQNeaTrRaW2KkpET0lRqBU256CGG0',
    'vi_vietnamese.json': '1XBJ79vkcauZUmWZjaqboFMs8lV5vszHt',
    'zh_cuv.json': '1PFE2AmXRxplzn9OG0_KPQrezzT_w0vc5',
    'zh_ncv.json': '1nhm76il5JgPLk3ymTPWOR4miNSmxYLt0',
  };

  static const List<String> assetVersions = ['acf.json', 'nvi.json', 'aa.json'];

  Future<String> getLocalPath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return "${directory.path}/$fileName";
  }

  Future<bool> isDownloaded(String fileName) async {
    if (assetVersions.contains(fileName)) return true;
    final path = await getLocalPath(fileName);
    return File(path).existsSync();
  }

  Future<bool> downloadVersion(String fileName) async {
    final fileId = driveIds[fileName];
    if (fileId == null) return false;

    // Link para download direto do Drive
    final url = "https://drive.google.com/uc?export=download&id=$fileId";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final path = await getLocalPath(fileName);
        await File(path).writeAsBytes(response.bodyBytes);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
