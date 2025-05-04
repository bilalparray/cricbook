// player_service.dart
import 'package:cricbook/database/db_provider.dart';
import 'package:cricbook/models/player_model.dart';
import 'package:sqflite/sqflite.dart';

class PlayerService {
  Future<int> addPlayer(Player player) async {
    final db = await DBProvider().database;
    return await db.insert('players', player.toMap());
  }

  Future<List<Player>> getPlayersByTeam(int teamId) async {
    final db = await DBProvider().database;
    final res =
        await db.query('players', where: 'teamId = ?', whereArgs: [teamId]);
    return res.map((m) => Player.fromMap(m)).toList();
  }

  Future<int> updatePlayer(Player player) async {
    final db = await DBProvider().database;
    return await db.update('players', player.toMap(),
        where: 'id = ?', whereArgs: [player.id]);
  }

  Future<int> deletePlayer(int id) async {
    final db = await DBProvider().database;
    return await db.delete('players', where: 'id = ?', whereArgs: [id]);
  }
}
