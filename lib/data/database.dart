import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class RapidDatabase {
  static Database _database;

  static Future<Database> get instance async {
    if (_database == null) {
      _database = await initDatabase();
    }
    return _database;
  }

  static Future<Database> initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'rapid.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (database, version) async {
        await database.execute(
          'CREATE TABLE chat('
          'id TEXT PRIMARY KEY,'
          'userId TEXT NOT NULL,'
          'userName TEXT NOT NULL,'
          'createdAt INTEGER NOT NULL'
          ');',
        );
        await database.execute(
          'CREATE TABLE message('
          'id TEXT PRIMARY KEY,'
          'chatId TEXT NOT NULL,'
          'userId TEXT NOT NULL,'
          'body TEXT NOT NULL,'
          'seen INTEGER NOT NULL,'
          'changed INTEGER NOT NULL,'
          'createdAt INTEGER NOT NULL'
          ');',
        );
      },
    );
  }
}
