// db_provider.dart
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  static final DBProvider _instance = DBProvider._internal();
  factory DBProvider() => _instance;
  DBProvider._internal();

  static const _dbName = 'cricbook.db';
  static const _dbVersion = 2;

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = await getDatabasesPath();
    return await openDatabase(
      join(path, _dbName),
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create teams table
    await db.execute('''
      CREATE TABLE teams(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        played INTEGER NOT NULL,
        won INTEGER NOT NULL,
        lost INTEGER NOT NULL
      )
    ''');
    // Create players table
    await db.execute('''
      CREATE TABLE players(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        teamId INTEGER NOT NULL,
        name TEXT NOT NULL,
        FOREIGN KEY(teamId) REFERENCES teams(id) ON DELETE CASCADE
      )
    ''');
    // Create matches table
    await db.execute('''
      CREATE TABLE matches(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        teamAId INTEGER NOT NULL,
        teamBId INTEGER NOT NULL,
        tossWinnerId INTEGER NOT NULL,
        tossChoice TEXT NOT NULL,
        overs INTEGER NOT NULL,
        venue TEXT,
        date TEXT NOT NULL,
        format TEXT,
        firstInningRuns INTEGER,
        firstInningWickets INTEGER,
        secondInningRuns INTEGER,
        secondInningWickets INTEGER,
        FOREIGN KEY(teamAId) REFERENCES teams(id),
        FOREIGN KEY(teamBId) REFERENCES teams(id),
        FOREIGN KEY(tossWinnerId) REFERENCES teams(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE ball_events (
        id INTEGER PRIMARY KEY,
        match_id INTEGER, 
        innings INTEGER,
        over INTEGER, 
        ball INTEGER, 
        batsman INTEGER,
        bowler INTEGER,
        runs INTEGER,
        extra_type TEXT,
        extra_runs INTEGER,
        wicket_type TEXT,
        dismissed_player INTEGER,
        FOREIGN KEY (match_id) REFERENCES matches(id),
        FOREIGN KEY (batsman) REFERENCES players(id),
        FOREIGN KEY (bowler) REFERENCES players(id),
        FOREIGN KEY (dismissed_player) REFERENCES players(id)
      )''');
    await db.execute('''
      CREATE TABLE player_stats (
        id INTEGER PRIMARY KEY,
        match_id INTEGER,
        player_id INTEGER,
        innings INTEGER,
        runs INTEGER,
        balls INTEGER,
        fours INTEGER,
        sixes INTEGER,
        strike_rate REAL,
        overs INTEGER,
        maidens INTEGER,
        runs_conceded INTEGER,
        wickets INTEGER,
        economy REAL,
        FOREIGN KEY (match_id) REFERENCES matches(id),
        FOREIGN KEY (player_id) REFERENCES players(id)
      )''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add inning columns to matches
      await db
          .execute('ALTER TABLE matches ADD COLUMN firstInningRuns INTEGER');
      await db
          .execute('ALTER TABLE matches ADD COLUMN firstInningWickets INTEGER');
      await db
          .execute('ALTER TABLE matches ADD COLUMN secondInningRuns INTEGER');
      await db.execute(
          'ALTER TABLE matches ADD COLUMN secondInningWickets INTEGER');
    }
  }
}
