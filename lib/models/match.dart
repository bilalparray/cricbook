// models/match.dart
enum MatchResult { TeamA_Win, TeamB_Win, Draw, NoResult }

class Match {
  final int? id;
  final int teamAId;
  final int teamBId;
  final DateTime date;
  MatchResult result;

  Match(
      {this.id,
      required this.teamAId,
      required this.teamBId,
      required this.date,
      this.result = MatchResult.NoResult});
}
