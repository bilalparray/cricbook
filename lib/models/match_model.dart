// models.dart (update MatchModel)
class MatchModel {
  int? id;
  int teamAId;
  int teamBId;
  int tossWinnerId;
  String tossChoice;
  int overs;
  String? venue;
  DateTime date;
  String? format;

  // Add inning score fields
  int? firstInningRuns;
  int? firstInningWickets;
  int? secondInningRuns;
  int? secondInningWickets;

  MatchModel({
    this.id,
    required this.teamAId,
    required this.teamBId,
    required this.tossWinnerId,
    required this.tossChoice,
    required this.overs,
    this.venue,
    required this.date,
    this.format,
    this.firstInningRuns,
    this.firstInningWickets,
    this.secondInningRuns,
    this.secondInningWickets,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'teamAId': teamAId,
        'teamBId': teamBId,
        'tossWinnerId': tossWinnerId,
        'tossChoice': tossChoice,
        'overs': overs,
        'venue': venue,
        'date': date.toIso8601String(),
        'format': format,
        'firstInningRuns': firstInningRuns,
        'firstInningWickets': firstInningWickets,
        'secondInningRuns': secondInningRuns,
        'secondInningWickets': secondInningWickets,
      };

  factory MatchModel.fromMap(Map<String, dynamic> map) => MatchModel(
        id: map['id'],
        teamAId: map['teamAId'],
        teamBId: map['teamBId'],
        tossWinnerId: map['tossWinnerId'],
        tossChoice: map['tossChoice'],
        overs: map['overs'],
        venue: map['venue'],
        date: DateTime.parse(map['date']),
        format: map['format'],
        firstInningRuns: map['firstInningRuns'],
        firstInningWickets: map['firstInningWickets'],
        secondInningRuns: map['secondInningRuns'],
        secondInningWickets: map['secondInningWickets'],
      );

  get result => null;

  // Add setters if needed (Dart fields are mutable by default)
}
