import 'package:hive/hive.dart';

part 'music.g.dart';

@HiveType(typeId: 0)
class Music extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String filePath;

  Music({required this.title, required this.filePath});
}
