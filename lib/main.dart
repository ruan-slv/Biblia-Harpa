import 'package:audio_service/audio_service.dart';
import 'package:biblia_e_harpa/src/model/music.dart';
import 'package:biblia_e_harpa/src/model/quiz_hive_model.dart';
import 'package:biblia_e_harpa/src/utils/theme.dart';
import 'package:biblia_e_harpa/src/view/home_view.dart';
import 'package:biblia_e_harpa/src/view_model/settings_view_model.dart';
import 'package:biblia_e_harpa/src/view_model/bible_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';

late final AudioHandler audioHandler;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  JustAudioMediaKit.ensureInitialized(windows: true);

  if (!kIsWeb) {
    await getApplicationDocumentsDirectory();
  }

  Hive.registerAdapter(MusicAdapter());
  Hive.registerAdapter(QuizOptionHiveAdapter());
  Hive.registerAdapter(QuizQuestionHiveAdapter());
  await Hive.openBox<Music>("musicas");
  await Hive.openBox<QuizQuestionHive>('quiz');

  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  final settingsViewModel = SettingsViewModel();
  await settingsViewModel.initialize();
  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsViewModel),
        ...BibleProviders.build(),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final upgraderMessages = UpgraderMessages(code: 'pt-br');
    return Consumer<SettingsViewModel>(
      builder: (context, settings, _) {
        return MaterialApp(
          title: 'Bíblia e Harpa',
          theme: lightMode,
          darkTheme: darkMode,
          themeMode: settings.themeMode,
          debugShowCheckedModeBanner: false,
          home: UpgradeAlert(
            upgrader: Upgrader(
              debugLogging: false,
              messages: upgraderMessages,
            ),
            child: const HomeView(),
          ),
        );
      },
    );
  }
}
