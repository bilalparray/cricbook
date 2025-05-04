// new_match_setup_page.dart
import 'package:cricbook/models/match_model.dart';
import 'package:cricbook/models/team_model.dart';
import 'package:cricbook/pages/new_score_page.dart';
import 'package:cricbook/services/match_service.dart';
import 'package:cricbook/services/team_service.dart';
import 'package:flutter/material.dart';

class NewMatchSetupPage extends StatefulWidget {
  const NewMatchSetupPage({super.key});
  @override
  _NewMatchSetupPageState createState() => _NewMatchSetupPageState();
}

class _NewMatchSetupPageState extends State<NewMatchSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _teamService = TeamService();
  final _matchService = MatchService();

  List<Team> _teams = [];
  Team? _teamA;
  Team? _teamB;
  Team? _tossWinner;
  String? _tossChoice;
  int? _overs;
  String? _venue;
  DateTime? _matchDate;
  String? _format;

  final _oversController = TextEditingController();
  final _venueController = TextEditingController();
  final _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTeams();
    _matchDate = DateTime.now();
    _dateController.text = _matchDate!.toLocal().toString().split(' ')[0];
  }

  Future<void> _loadTeams() async {
    final teams = await _teamService.getAllTeams();
    setState(() => _teams = teams);
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _matchDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        _matchDate = date;
        _dateController.text = date.toLocal().toString().split(' ')[0];
      });
    }
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final match = MatchModel(
      teamAId: _teamA!.id!,
      teamBId: _teamB!.id!,
      tossWinnerId: _tossWinner!.id!,
      tossChoice: _tossChoice!,
      overs: _overs!,
      venue: _venue,
      date: _matchDate!,
      format: _format,
    );
    final id = await _matchService.addMatch(match);
    Navigator.pushReplacementNamed(context, '/match/$id/score');
  }

  @override
  void dispose() {
    _oversController.dispose();
    _venueController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New Match Setup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _teams.isEmpty
            ? Center(child: Text('Please add teams first.'))
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    DropdownButtonFormField<Team>(
                      decoration: InputDecoration(labelText: 'Team A'),
                      items: _teams
                          .map((t) =>
                              DropdownMenuItem(value: t, child: Text(t.name)))
                          .toList(),
                      onChanged: (val) => setState(() => _teamA = val),
                      validator: (v) => v == null ? 'Select Team A' : null,
                    ),
                    SizedBox(height: 12),
                    DropdownButtonFormField<Team>(
                      decoration: InputDecoration(labelText: 'Team B'),
                      items: _teams
                          .map((t) =>
                              DropdownMenuItem(value: t, child: Text(t.name)))
                          .toList(),
                      onChanged: (val) => setState(() => _teamB = val),
                      validator: (v) {
                        if (v == null) return 'Select Team B';
                        if (_teamA != null && v == _teamA)
                          return 'Team B must differ';
                        return null;
                      },
                    ),
                    SizedBox(height: 12),
                    DropdownButtonFormField<Team>(
                      decoration: InputDecoration(labelText: 'Toss Won By'),
                      items: _teams
                          .map((t) =>
                              DropdownMenuItem(value: t, child: Text(t.name)))
                          .toList(),
                      onChanged: (val) => setState(() => _tossWinner = val),
                      validator: (v) => v == null ? 'Select toss winner' : null,
                    ),
                    SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Toss Choice'),
                      items: ['Bat', 'Bowl']
                          .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => _tossChoice = v),
                      validator: (v) => v == null ? 'Select toss choice' : null,
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _oversController,
                      decoration: InputDecoration(labelText: 'Overs'),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter overs';
                        final n = int.tryParse(v);
                        if (n == null || n <= 0) return 'Invalid overs';
                        return null;
                      },
                      onSaved: (v) => _overs = int.parse(v!),
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _venueController,
                      decoration:
                          InputDecoration(labelText: 'Venue (optional)'),
                      onSaved: (v) => _venue = v,
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _dateController,
                      decoration: InputDecoration(
                          labelText: 'Date',
                          suffixIcon: Icon(Icons.calendar_today)),
                      readOnly: true,
                      onTap: _pickDate,
                    ),
                    SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration:
                          InputDecoration(labelText: 'Format (optional)'),
                      items: ['T20', 'ODI', 'Test', 'Other']
                          .map(
                              (f) => DropdownMenuItem(value: f, child: Text(f)))
                          .toList(),
                      onChanged: (v) => setState(() => _format = v),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            _onSubmit();
                            _startMatchAndGoToScore();
                          }
                        },
                        child: Text('Start Match'))
                  ],
                ),
              ),
      ),
    );
  }

  void _startMatchAndGoToScore() async {
    // build & save your MatchModel exactly as in _onSubmit…
    final match = MatchModel(
      teamAId: _teamA!.id!,
      teamBId: _teamB!.id!,
      tossWinnerId: _tossWinner!.id!,
      tossChoice: _tossChoice!,
      overs: _overs!,
      venue: _venue,
      date: _matchDate!,
      format: _format,
    );
    final id = await _matchService.addMatch(match);

    // then navigate directly:
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScoreboardScreen(matchId: id),
      ),
    );
  }
}
