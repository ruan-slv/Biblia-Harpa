/// Coordena o estado e as ações consumidos pela camada de apresentação.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'bible_audio_assets_controller.dart';
import 'bible_share_controller.dart';
import 'bible_text_assets_controller.dart';
import 'bible_version_controller.dart';
import 'bible_audios_controller.dart';
import 'bible_list_controller.dart';
import 'bible_read_controller.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class BibleProvidersController {
  static List<SingleChildWidget> build() {
    return [
      Provider<BibleVersionController>(create: (_) => BibleVersionController()),
      Provider<BibleShareController>(create: (_) => const BibleShareController()),
      Provider<BibleTextAssetsController>(create: (_) => const BibleTextAssetsController()),
      Provider<BibleAudioAssetsController>(
        create: (_) => const BibleAudioAssetsController(),
      ),
      ChangeNotifierProvider<BibleReadController>(create: (_) => BibleReadController()),
      ChangeNotifierProvider<BibleListController>(create: (ctx) {
        return BibleListController(
          versionService: ctx.read<BibleVersionController>(),
          audioAssetsService: ctx.read<BibleAudioAssetsController>(),
          textAssetsService: ctx.read<BibleTextAssetsController>(),
        );
      }),
      ChangeNotifierProvider<BibleAudiosController>(create: (ctx) {
        return BibleAudiosController(
          audioAssetsService: ctx.read<BibleAudioAssetsController>(),
        );
      }),
    ];
  }
}

typedef BibleProviders = BibleProvidersController;
