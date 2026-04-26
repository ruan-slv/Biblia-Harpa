import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'ola.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE ola (
            mensagem TEXT
          )
        ''');
      },
    );
  }

  // Inserir
  static Future<void> insert(String mensagem) async {
    final db = await database;
    await db.insert('ola', {'mensagem': mensagem});
  }

  // Listar
  static Future<List<String>> getAll() async {
    final db = await database;
    final result = await db.query('ola');

    return result.map((e) => e['mensagem'] as String).toList();
  }

  // Limpar tabela
  static Future<void> clear() async {
    final db = await database;
    await db.delete('ola');
  }
}