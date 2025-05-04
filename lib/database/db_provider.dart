// db_provider.dart
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  static final DBProvider _instance = DBProvider._internal();
  factory DBProvider() => _instance;
  DBProvider._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = await getDatabasesPath();
    return await openDatabase(
      join(path, 'cricbook.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE teams(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            played INTEGER,
            won INTEGER,
            lost INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE players(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            teamId INTEGER,
            name TEXT,
            FOREIGN KEY(teamId) REFERENCES teams(id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }
}
