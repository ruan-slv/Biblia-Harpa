import 'package:hive/hive.dart';

part 'music.g.dart'; // 👈 necessário para build_runner gerar o MusicAdapter

@HiveType(typeId: 0)
class Music extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String filePath;

  Music({required this.title, required this.filePath});
}
