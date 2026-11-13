import 'package:biblia_e_harpa/src/utils/app_links.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    dotenv.loadFromString(
      envString: [
        'BIBLE_JSON_DOWNLOAD_BASE_URL=${Uri.https('raw.example', '/assets/json/')}',
        'GOOGLE_DRIVE_DOWNLOAD_BASE_URL=${Uri.https('drive.example', '/uc')}',
      ].join('\n'),
    );
  });

  test('resolves downloadable Bible JSON from the configured base URL', () {
    final uri = AppLinks.bibleJson('nvi.json');

    expect(uri.host, 'raw.example');
    expect(uri.path, '/assets/json/nvi.json');
  });

  test('uses the configured Drive base when normalizing a shared file URL', () {
    final source = Uri(
      scheme: 'https',
      host: 'drive.example',
      path: '/file/d/audio-id/view',
    );

    final uri = AppLinks.harpAudio(source.toString());

    expect(uri.host, 'drive.example');
    expect(uri.path, '/uc');
    expect(uri.queryParameters, {
      'export': 'download',
      'id': 'audio-id',
      'confirm': 't',
    });
  });
}
