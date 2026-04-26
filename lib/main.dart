import 'package:audio_service/audio_service.dart';
import 'package:biblia_e_harpa/src/controllers/fontSizeController.dart';
import 'package:biblia_e_harpa/src/controllers/theme_controller.dart';
import 'package:biblia_e_harpa/src/screens/initial_screen.dart';
import 'package:biblia_e_harpa/src/models/audio/music.dart';
import 'package:biblia_e_harpa/src/theme/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:upgrader/upgrader.dart';

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

/*
import 'package:biblia_e_harpa/src/provider/ola_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => OlaProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<OlaProvider>(context, listen: false).carregar());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OlaProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('SQLite + Provider')),
      body: Column(
        children: [
          TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Digite algo'),
          ),

          ElevatedButton(
            onPressed: () {
              provider.adicionar(controller.text);
              controller.clear();
            },
            child: const Text('Adicionar'),
          ),

          ElevatedButton(
            onPressed: provider.limpar,
            child: const Text('Limpar'),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: provider.mensagens.length,
              itemBuilder: (_, index) {
                return ListTile(
                  title: Text(provider.mensagens[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}*/