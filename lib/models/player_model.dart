class Player {
  int? id;
  int teamId;
  String name;

  Player({this.id, required this.teamId, required this.name});

  Map<String, dynamic> toMap() => {
        'id': id,
        'teamId': teamId,
        'name': name,
      };

  factory Player.fromMap(Map<String, dynamic> map) => Player(
        id: map['id'],
        teamId: map['teamId'],
        name: map['name'],
      );
}
