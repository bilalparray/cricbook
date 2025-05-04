// team_detail_page.dart
import 'package:cricbook/models/player_model.dart';
import 'package:cricbook/models/team_model.dart';
import 'package:cricbook/services/player_service.dart';
import 'package:flutter/material.dart';

class TeamDetailPage extends StatefulWidget {
  final Team team;
  TeamDetailPage({required this.team});
  @override
  _TeamDetailPageState createState() => _TeamDetailPageState();
}

class _TeamDetailPageState extends State<TeamDetailPage> {
  final _playerService = PlayerService();
  late Future<List<Player>> _players;
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _players = _playerService.getPlayersByTeam(widget.team.id!);
    setState(() {});
  }

  void _showPlayerDialog({Player? player}) {
    final isEdit = player != null;
    if (isEdit)
      _nameController.text = player.name;
    else
      _nameController.clear();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? 'Edit Player' : 'Add Player'),
        content: TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Name')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final name = _nameController.text.trim();
              if (name.isEmpty) return;
              if (isEdit) {
                player!..name = name;
                await _playerService.updatePlayer(player);
              } else {
                await _playerService
                    .addPlayer(Player(teamId: widget.team.id!, name: name));
              }
              Navigator.pop(context);
              _load();
            },
            child: Text(isEdit ? 'Save' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Player player) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete Player'),
        content: Text('Delete ${player.name}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await _playerService.deletePlayer(player.id!);
              Navigator.pop(context);
              _load();
            },
            child: Text('Delete'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.team.name)),
      body: FutureBuilder<List<Player>>(
        future: _players,
        builder: (context, snap) {
          if (!snap.hasData) return Center(child: CircularProgressIndicator());
          final players = snap.data!;
          return ListView.builder(
            itemCount: players.length,
            itemBuilder: (ctx, i) {
              final p = players[i];
              return ListTile(
                title: Text(p.name),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _showPlayerDialog(player: p)),
                  IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _confirmDelete(p)),
                ]),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () => _showPlayerDialog(), child: Icon(Icons.add)),
    );
  }
}
