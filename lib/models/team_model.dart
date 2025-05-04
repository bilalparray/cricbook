// models.dart
class Team {
  int? id;
  String name;
  int played;
  int won;
  int lost;

  Team(
      {this.id,
      required this.name,
      this.played = 0,
      this.won = 0,
      this.lost = 0});

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'played': played,
        'won': won,
        'lost': lost,
      };

  factory Team.fromMap(Map<String, dynamic> map) => Team(
        id: map['id'],
        name: map['name'],
        played: map['played'],
        won: map['won'],
        lost: map['lost'],
      );
}
