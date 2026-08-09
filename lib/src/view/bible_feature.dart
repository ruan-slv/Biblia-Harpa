import 'package:biblia_e_harpa/src/view/bible_audio_wrapper.dart';
import 'package:biblia_e_harpa/src/view/bible_list_view.dart';
import 'package:flutter/material.dart';

class BibleFeature extends StatelessWidget {
  final Widget child;

  const BibleFeature._(this.child);

  static Widget bibleList() => const BibleFeature._(BibleListView());
  static Widget bibleAudiosWrapper() => const BibleFeature._(BibleAudioWrapper());

  @override
  Widget build(BuildContext context) {
    // Agora os provedores são globais no main.dart
    return child;
  }
}
