/// Implementa operações de dados, armazenamento ou integração deste recurso.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'package:share_plus/share_plus.dart';

class ShareAudioSource {
  void shareAudioSource(String text, String url) {
    StringBuffer audio = StringBuffer();
    audio.writeln("Áudio de Bíblia e Harpa - sem anúncios");
    audio.writeln(text);
    audio.writeln(url);

    Share.share(
      text,
      subject: url,
    );
  }
}
