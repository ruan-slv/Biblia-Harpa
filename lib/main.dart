import 'package:audio_service/audio_service.dart';
import 'package:biblia_e_harpa/src/controllers/fontSizeController.dart';
import 'package:biblia_e_harpa/src/controllers/theme_controller.dart';
import 'package:biblia_e_harpa/src/screens/initial_screen.dart';
import 'package:biblia_e_harpa/src/models/music.dart';
import 'package:biblia_e_harpa/src/theme/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:upgrader/upgrader.dart';

/*
 * Arquivo principal que vai realizar a execução da aplicação 
 */

late final AudioHandler audioHandler;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await FontSizeController.loadFontSize();
  JustAudioMediaKit.ensureInitialized(windows: true);

  if (!kIsWeb) {
    final dir = await getApplicationDocumentsDirectory();
    //Hive.init(dir.path);
  }

  Hive.registerAdapter(MusicAdapter());
  await Hive.openBox<Music>("musicas");

  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  await ThemeController.loadTheme();
  //audioHandler = await initAudioHandler();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final upgraderMessages = UpgraderMessages(code: 'pt-br');
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeNotifier,
      builder: (context, currentTheme, _) {
        return MaterialApp(
          title: 'Bíblia e Harpa',
          theme: lightMode,
          darkTheme: darkMode,
          themeMode: currentTheme,
          debugShowCheckedModeBanner: false,
          home: UpgradeAlert(
            upgrader: Upgrader(
              debugLogging: false,
              messages: upgraderMessages,
            ),
            child: const Initial(),
          ),
        );
      },
    );
  }
}
