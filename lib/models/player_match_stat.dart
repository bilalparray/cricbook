// models/player_match_stats.dart
class PlayerMatchStats {
  final int? id;
  final int matchId;
  final int playerId;
  final int innings;
  int runs;
  int balls;
  int fours;
  int sixes;
  double strikeRate;
  int overs; // overs bowled (as an integer number of complete overs)
  int maidens;
  int runsConceded;
  int wickets;
  double economy;

  PlayerMatchStats(
      {this.id,
      required this.matchId,
      required this.playerId,
      required this.innings,
      this.runs = 0,
      this.balls = 0,
      this.fours = 0,
      this.sixes = 0,
      this.strikeRate = 0.0,
      this.overs = 0,
      this.maidens = 0,
      this.runsConceded = 0,
      this.wickets = 0,
      this.economy = 0.0});

  Map<String, dynamic> toMap() => {
        'id': id,
        'match_id': matchId,
        'player_id': playerId,
        'innings': innings,
        'runs': runs,
        'balls': balls,
        'fours': fours,
        'sixes': sixes,
        'strike_rate': strikeRate,
        'overs': overs,
        'maidens': maidens,
        'runs_conceded': runsConceded,
        'wickets': wickets,
        'economy': economy
      };

  static PlayerMatchStats fromMap(Map<String, dynamic> map) => PlayerMatchStats(
      id: map['id'],
      matchId: map['match_id'],
      playerId: map['player_id'],
      innings: map['innings'],
      runs: map['runs'],
      balls: map['balls'],
      fours: map['fours'],
      sixes: map['sixes'],
      strikeRate: map['strike_rate'],
      overs: map['overs'],
      maidens: map['maidens'],
      runsConceded: map['runs_conceded'],
      wickets: map['wickets'],
      economy: map['economy']);
}
