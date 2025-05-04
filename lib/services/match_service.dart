// match_service.dart
import 'package:cricbook/database/db_provider.dart';
import 'package:cricbook/models/match_model.dart';

class MatchService {
  Future<int> addMatch(MatchModel match) async {
    final db = await DBProvider().database;
    return db.insert('matches', match.toMap());
  }

  Future<List<MatchModel>> getAllMatches() async {
    final db = await DBProvider().database;
    final res = await db.query('matches', orderBy: 'date DESC');
    return res.map((m) => MatchModel.fromMap(m)).toList();
  }

  Future<MatchModel?> getMatch(int id) async {
    final db = await DBProvider().database;
    final res = await db.query('matches', where: 'id = ?', whereArgs: [id]);
    return res.isNotEmpty ? MatchModel.fromMap(res.first) : null;
  }

  Future<int> updateMatch(MatchModel match) async {
    final db = await DBProvider().database;
    return db.update(
      'matches',
      match.toMap(),
      where: 'id = ?',
      whereArgs: [match.id],
    );
  }

  Future<int> deleteMatch(int id) async {
    final db = await DBProvider().database;
    return db.delete('matches', where: 'id = ?', whereArgs: [id]);
  }
}
