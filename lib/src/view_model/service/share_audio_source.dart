import 'package:share_plus/share_plus.dart';

class ShareAudioSource {
  void shareAudioSource(String text, String url) {
    StringBuffer audio = StringBuffer();
    audio.writeln("Áudio de Bíblia e Harpa - sem anúncios");
    audio.writeln(text);
    audio.writeln(url);

    SharePlus.instance.share(
      ShareParams(
        text: audio.toString(),
        subject: text,
      ),
    );
  }
}
