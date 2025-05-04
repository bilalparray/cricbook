// services/player_stats_service.dart
import 'package:cricbook/database/db_provider.dart';
import 'package:cricbook/models/player_match_stat.dart';

class PlayerStatsService {
  final DBProvider _dbProvider = DBProvider();

  /// Initialize stats record for a player in a match innings if not exists
  Future<void> initStats(int matchId, int playerId, int innings) async {
    final db = await _dbProvider.database;
    final res = await db.query(
      'player_stats',
      where: 'matchId = ? AND playerId = ? AND innings = ?',
      whereArgs: [matchId, playerId, innings],
    );
    if (res.isEmpty) {
      final stats = PlayerMatchStats(
        matchId: matchId,
        playerId: playerId,
        innings: innings,
      );
      await db.insert('player_stats', stats.toMap());
    }
  }

  /// Retrieve stats for a player in a match innings
  Future<PlayerMatchStats?> getStats(
      int matchId, int playerId, int innings) async {
    final db = await _dbProvider.database;
    final res = await db.query(
      'player_stats',
      where: 'matchId = ? AND playerId = ? AND innings = ?',
      whereArgs: [matchId, playerId, innings],
    );
    if (res.isNotEmpty) {
      return PlayerMatchStats.fromMap(res.first);
    }
    return null;
  }

  /// Retrieve all stats for a match
  Future<List<PlayerMatchStats>> getStatsByMatch(int matchId) async {
    final db = await _dbProvider.database;
    final res = await db.query(
      'player_stats',
      where: 'matchId = ?',
      whereArgs: [matchId],
    );
    return res.map((m) => PlayerMatchStats.fromMap(m)).toList();
  }

  /// Update batting stats for a batsman
  Future<void> updateBatting(int matchId, int playerId, int innings,
      {int runs = 0, int balls = 0, int fours = 0, int sixes = 0}) async {
    final db = await _dbProvider.database;
    await initStats(matchId, playerId, innings);
    final stats = await getStats(matchId, playerId, innings);
    if (stats == null) return;
    stats.runs += runs;
    stats.balls += balls;
    stats.fours += fours;
    stats.sixes += sixes;
    stats.strikeRate = stats.balls > 0 ? (stats.runs / stats.balls) * 100 : 0.0;
    await db.update(
      'player_stats',
      stats.toMap(),
      where: 'id = ?',
      whereArgs: [stats.id],
    );
  }

  /// Update bowling stats for a bowler
  Future<void> updateBowling(int matchId, int playerId, int innings,
      {int ballsBowled = 0,
      int runsConceded = 0,
      int wickets = 0,
      int maidens = 0}) async {
    final db = await _dbProvider.database;
    await initStats(matchId, playerId, innings);
    final stats = await getStats(matchId, playerId, innings);
    if (stats == null) return;
    stats.balls += ballsBowled;
    stats.overs = stats.balls ~/ 6;
    stats.maidens += maidens;
    stats.runsConceded += runsConceded;
    stats.wickets += wickets;
    stats.economy = stats.overs > 0 ? stats.runsConceded / stats.overs : 0.0;
    await db.update(
      'player_stats',
      stats.toMap(),
      where: 'id = ?',
      whereArgs: [stats.id],
    );
  }

  /// Reset stats for all players in match
  Future<void> resetMatchStats(int matchId) async {
    final db = await _dbProvider.database;
    await db.delete('player_stats', where: 'matchId = ?', whereArgs: [matchId]);
  }
}
