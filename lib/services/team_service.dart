// team_service.dart
import 'package:cricbook/database/db_provider.dart';
import 'package:cricbook/models/team_model.dart';

class TeamService {
  Future<int> addTeam(Team team) async {
    final db = await DBProvider().database;
    return await db.insert('teams', team.toMap());
  }

  Future<List<Team>> getAllTeams() async {
    final db = await DBProvider().database;
    final res = await db.query('teams');
    return res.map((m) => Team.fromMap(m)).toList();
  }

  Future<int> updateTeam(Team team) async {
    final db = await DBProvider().database;
    return await db
        .update('teams', team.toMap(), where: 'id = ?', whereArgs: [team.id]);
  }

  Future<int> deleteTeam(int id) async {
    final db = await DBProvider().database;
    return await db.delete('teams', where: 'id = ?', whereArgs: [id]);
  }

  /// Fetch a single team by its ID
  Future<Team?> getTeamById(int id) async {
    final db = await DBProvider().database;
    final res = await db.query(
      'teams',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (res.isNotEmpty) {
      return Team.fromMap(res.first);
    }
    return null;
  }
}
