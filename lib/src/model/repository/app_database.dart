import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static const String databaseName = 'passwords.db';
  static const int databaseVersion = 2;

  static Future<Database> open() async {
    return openDatabase(
      databaseName,
      version: databaseVersion,
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createProfileTable(db);
        }
      },
      onOpen: (db) async {
        await _createTables(db);
      },
    );
  }

  static Future<void> _createTables(Database db) async {
    await db.execute(
      'CREATE TABLE IF NOT EXISTS passwords(service_name TEXT PRIMARY KEY, username TEXT, password TEXT)',
    );
    await _createProfileTable(db);
  }

  static Future<void> _createProfileTable(Database db) async {
    await db.execute(
      'CREATE TABLE IF NOT EXISTS profile(id INTEGER PRIMARY KEY, name TEXT NOT NULL, email TEXT NOT NULL, password TEXT NOT NULL)',
    );
  }
}
