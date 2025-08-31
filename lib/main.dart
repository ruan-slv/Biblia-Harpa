import 'package:biblia_e_harpa/src/controllers/fontSizeController.dart';
import 'package:biblia_e_harpa/src/controllers/theme_controller.dart';
import 'package:biblia_e_harpa/src/initial/initial.dart';
import 'package:biblia_e_harpa/src/models/music.dart';
import 'package:biblia_e_harpa/src/theme/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:upgrader/upgrader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await FontSizeController.loadFontSize();

  if (!kIsWeb) {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
  }

  Hive.registerAdapter(MusicAdapter());
  await Hive.openBox<Music>("musicas");

  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  await ThemeController.loadTheme();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
              showIgnore: false,
              showLater: false,
              dialogStyle: UpgradeDialogStyle.material,
            ),
            child: const Initial(),
          ),
        );
      },
    );
  }
}
