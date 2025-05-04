// services/ball_event_service.dart
import 'package:cricbook/database/db_provider.dart';
import '../models/ball_event.dart';

class BallEventService {
  final DBProvider _dbProvider = DBProvider();

  /// Insert a new ball event
  Future<int> insert(BallEvent event) async {
    final db = await _dbProvider.database;
    return await db.insert('ball_events', event.toMap());
  }

  /// Fetch all ball events for a match and innings
  Future<List<BallEvent>> getEvents(int matchId, int innings) async {
    final db = await _dbProvider.database;
    final res = await db.query(
      'ball_events',
      where: 'matchId = ? AND innings = ?',
      whereArgs: [matchId, innings],
      orderBy: 'over ASC, ball ASC',
    );
    return res.map((m) => BallEvent.fromMap(m)).toList();
  }

  /// Delete a specific ball event by ID
  Future<int> delete(int id) async {
    final db = await _dbProvider.database;
    return await db.delete('ball_events', where: 'id = ?', whereArgs: [id]);
  }

  /// Delete all events for a match (e.g., reset)
  Future<int> deleteMatchEvents(int matchId) async {
    final db = await _dbProvider.database;
    return await db
        .delete('ball_events', where: 'matchId = ?', whereArgs: [matchId]);
  }

  /// Update an existing event (e.g., correct a mis-entry)
  Future<int> update(BallEvent event) async {
    final db = await _dbProvider.database;
    return await db.update(
      'ball_events',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }
}
