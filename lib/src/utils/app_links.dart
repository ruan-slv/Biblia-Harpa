import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppLinks {
  static Future<void>? _loadFuture;

  static Future<void> load() => _loadFuture ??= dotenv.load(fileName: '.env');

  static Uri? configuredUri(String key) {
    final value = dotenv.env[key]?.trim();
    if (value == null || value.isEmpty) return null;

    final uri = Uri.tryParse(value);
    if (uri == null ||
        uri.host.isEmpty ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      return null;
    }

    return uri;
  }

  static Uri requireUri(String key) {
    final uri = configuredUri(key);
    if (uri == null) {
      throw StateError(
        'A variável $key está ausente ou não contém uma URL HTTP(S) válida.',
      );
    }
    return uri;
  }

  static Uri bibleJson(String fileName) =>
      requireUri('BIBLE_JSON_DOWNLOAD_BASE_URL').resolve(fileName);

  static Uri harpAudio(String sourceUrl) {
    final source = Uri.parse(sourceUrl);
    final id = RegExp(r'/d/([^/]+)/').firstMatch(source.path)?.group(1);
    if (id == null) return source;

    return requireUri('GOOGLE_DRIVE_DOWNLOAD_BASE_URL').replace(
      queryParameters: {
        'export': 'download',
        'id': id,
        'confirm': 't',
      },
    );
  }
}
