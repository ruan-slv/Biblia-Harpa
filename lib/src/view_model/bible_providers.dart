/// Coordena o estado e as ações consumidos pela camada de apresentação.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'service/bible_audio_assets_service.dart';
import 'service/bible_share_service.dart';
import 'service/bible_text_assets_service.dart';
import 'service/bible_version_service.dart';
import 'bible_audios_view_model.dart';
import 'bible_list_view_model.dart';
import 'bible_read_view_model.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class BibleProviders {
  static List<SingleChildWidget> build() {
    return [
      Provider<BibleVersionService>(create: (_) => BibleVersionService()),
      Provider<BibleShareService>(create: (_) => const BibleShareService()),
      Provider<BibleTextAssetsService>(create: (_) => const BibleTextAssetsService()),
      Provider<BibleAudioAssetsService>(
        create: (_) => const BibleAudioAssetsService(),
      ),
      ChangeNotifierProvider<BibleReadViewModel>(create: (_) => BibleReadViewModel()),
      ChangeNotifierProvider<BibleListViewModel>(create: (ctx) {
        return BibleListViewModel(
          versionService: ctx.read<BibleVersionService>(),
          audioAssetsService: ctx.read<BibleAudioAssetsService>(),
        );
      }),
      ChangeNotifierProvider<BibleAudiosViewModel>(create: (ctx) {
        return BibleAudiosViewModel(
          audioAssetsService: ctx.read<BibleAudioAssetsService>(),
        );
      }),
    ];
  }
}
