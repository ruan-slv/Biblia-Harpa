/// Implementa o serviço que dá suporte à camada de apresentação.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'package:share_plus/share_plus.dart';

class BibleShareController {
  const BibleShareController();

  Future<void> shareText(String text) async {
    await SharePlus.instance.share(ShareParams(text: text));
  }

  Future<void> shareAudioSource(String text, String url) async {
    final audio = StringBuffer()
      ..writeln("Áudio de Bíblia e Harpa - sem anúncios")
      ..writeln(text)
      ..writeln(url);

    await SharePlus.instance.share(
      ShareParams(
        text: audio.toString(),
        subject: text,
      ),
    );
  }
}

typedef ShareAudioSource = BibleShareController;
