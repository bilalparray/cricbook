// models/ball_event.dart
class BallEvent {
  final int? id;
  final int matchId;
  final int innings;
  final int over;
  final int ballNumber;
  final int batsmanId;
  final int bowlerId;
  final int runs;
  final String
      extraType; // e.g. "None", "Wide", "NoBall", "Bye", "LegBye", "Penalty"
  final int extraRuns;
  final String
      wicketType; // e.g. "Bowled", "Caught", "LBW", "RunOut", "Stumped", "None"
  final int? dismissedPlayerId;

  BallEvent(
      {this.id,
      required this.matchId,
      required this.innings,
      required this.over,
      required this.ballNumber,
      required this.batsmanId,
      required this.bowlerId,
      required this.runs,
      this.extraType = 'None',
      this.extraRuns = 0,
      this.wicketType = 'None',
      this.dismissedPlayerId});

  // Map to/from for SQLite
  Map<String, dynamic> toMap() => {
        'id': id,
        'match_id': matchId,
        'innings': innings,
        'over': over,
        'ball': ballNumber,
        'batsman': batsmanId,
        'bowler': bowlerId,
        'runs': runs,
        'extra_type': extraType,
        'extra_runs': extraRuns,
        'wicket_type': wicketType,
        'dismissed_player': dismissedPlayerId
      };

  static BallEvent fromMap(Map<String, dynamic> map) => BallEvent(
      id: map['id'],
      matchId: map['match_id'],
      innings: map['innings'],
      over: map['over'],
      ballNumber: map['ball'],
      batsmanId: map['batsman'],
      bowlerId: map['bowler'],
      runs: map['runs'],
      extraType: map['extra_type'],
      extraRuns: map['extra_runs'],
      wicketType: map['wicket_type'],
      dismissedPlayerId: map['dismissed_player']);
}
