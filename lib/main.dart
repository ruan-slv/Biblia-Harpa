import 'package:biblia_e_harpa/models/music.dart';
import 'package:biblia_e_harpa/src/initial/initial.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:biblia_e_harpa/src/adapters/music_adapter.dart'; // Adjust the path as needed

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  if(!kIsWeb) {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
  }
  Hive.registerAdapter(MusicAdapter());
  await Hive.openBox<Music>("musicas");
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biblia e Harpa',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const Initial(),
    );
  }
}