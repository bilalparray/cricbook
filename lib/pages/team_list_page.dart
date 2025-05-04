// team_list_page.dart
import 'package:cricbook/models/team_model.dart';
import 'package:cricbook/services/team_service.dart';
import 'package:flutter/material.dart';
import 'team_detail_page.dart';

class TeamListPage extends StatefulWidget {
  const TeamListPage({super.key});
  @override
  _TeamListPageState createState() => _TeamListPageState();
}

class _TeamListPageState extends State<TeamListPage> {
  final _service = TeamService();
  late Future<List<Team>> _teams;
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _teams = _service.getAllTeams();
    setState(() {});
  }

  void _showDialog({Team? team}) {
    final isEdit = team != null;
    if (isEdit) {
      _nameController.text = team.name;
    } else {
      _nameController.clear();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? 'Edit Team' : 'Add Team'),
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
                team.name = name;
                await _service.updateTeam(team);
              } else {
                await _service.addTeam(Team(name: name));
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

  void _confirmDelete(Team team) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete Team'),
        content: Text('Delete ${team.name}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await _service.deleteTeam(team.id!);
              Navigator.pop(context);
              _load();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Teams')),
      body: FutureBuilder<List<Team>>(
        future: _teams,
        builder: (context, snap) {
          if (!snap.hasData) return Center(child: CircularProgressIndicator());
          final teams = snap.data!;
          return ListView.builder(
            itemCount: teams.length,
            itemBuilder: (ctx, i) {
              final t = teams[i];
              return Card(
                child: ListTile(
                  title: Text(t.name),
                  subtitle: Text('P:${t.played} W:${t.won} L:${t.lost}'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TeamDetailPage(team: t)),
                  ),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _showDialog(team: t)),
                    IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _confirmDelete(t)),
                  ]),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () => _showDialog(), child: Icon(Icons.add)),
    );
  }
}
