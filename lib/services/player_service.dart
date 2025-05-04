// services/player_service.dart
import 'package:cricbook/database/db_provider.dart';
import 'package:cricbook/models/player_model.dart';

class PlayerService {
  final DBProvider _dbProvider = DBProvider();

  /// Add a new player
  Future<int> addPlayer(Player player) async {
    final db = await _dbProvider.database;
    return await db.insert('players', player.toMap());
  }

  /// Get all players for a specific team
  Future<List<Player>> getPlayersByTeam(int teamId) async {
    final db = await _dbProvider.database;
    final res =
        await db.query('players', where: 'teamId = ?', whereArgs: [teamId]);
    return res.map((m) => Player.fromMap(m)).toList();
  }

  /// Fetch a single player by ID
  Future<Player?> getPlayerById(int id) async {
    final db = await _dbProvider.database;
    final res = await db.query('players', where: 'id = ?', whereArgs: [id]);
    if (res.isNotEmpty) {
      return Player.fromMap(res.first);
    }
    return null;
  }

  /// Update an existing player
  Future<int> updatePlayer(Player player) async {
    final db = await _dbProvider.database;
    return await db.update(
      'players',
      player.toMap(),
      where: 'id = ?',
      whereArgs: [player.id],
    );
  }

  /// Delete a player by ID
  Future<int> deletePlayer(int id) async {
    final db = await _dbProvider.database;
    return await db.delete(
      'players',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
