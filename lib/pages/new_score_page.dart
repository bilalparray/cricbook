import 'package:cricbook/models/player_model.dart';
import 'package:cricbook/services/ball_event_service.dart';
import 'package:cricbook/services/player_stats_service.dart';
import 'package:flutter/material.dart';
import 'package:cricbook/models/ball_event.dart';

import 'package:cricbook/models/match_model.dart';
import 'package:cricbook/models/team_model.dart';
import 'package:cricbook/services/match_service.dart';
import 'package:cricbook/services/team_service.dart';
import 'package:cricbook/services/player_service.dart';

class ScoreboardScreen extends StatefulWidget {
  final int matchId;
  ScoreboardScreen({Key? key, required this.matchId}) : super(key: key);

  @override
  _ScoreboardScreenState createState() => _ScoreboardScreenState();
}

class _ScoreboardScreenState extends State<ScoreboardScreen> {
  final _matchService = MatchService();
  final _teamService = TeamService();
  final _playerService = PlayerService();
  final _ballEventService = BallEventService();
  final _statsService = PlayerStatsService();

  MatchModel? _match;
  Team? _battingTeam;
  Team? _bowlingTeam;
  List<Player> _battingPlayers = [];
  List<Player> _bowlingPlayers = [];

  Player? _striker;
  Player? _nonStriker;
  Player? _currentBowler;

  int _runs = 0;
  int _wickets = 0;
  int _balls = 0;
  int _oversLimit = 0;

  @override
  void initState() {
    super.initState();
    _initMatch();
  }

  Future<void> _initMatch() async {
    _match = await _matchService.getMatch(widget.matchId);
    if (_match == null) return;
    _battingTeam = await _teamService.getTeamById(_match!.tossWinnerId);
    _bowlingTeam = await _teamService.getTeamById(
        _match!.tossWinnerId == _match!.teamAId
            ? _match!.teamBId
            : _match!.teamAId);

    _oversLimit = _match!.overs;
    _battingPlayers = await _playerService.getPlayersByTeam(_battingTeam!.id!);
    _bowlingPlayers = await _playerService.getPlayersByTeam(_bowlingTeam!.id!);
    if (_battingPlayers.length >= 2) {
      _striker = _battingPlayers[0];
      _nonStriker = _battingPlayers[1];
    }
    if (_bowlingPlayers.isNotEmpty) _currentBowler = _bowlingPlayers[0];
    setState(() {});
  }

  void _switchStrike() {
    setState(() {
      final temp = _striker;
      _striker = _nonStriker;
      _nonStriker = temp;
    });
  }

  Future<void> _addBall(
      {required int runs,
      String extraType = 'None',
      int extraRuns = 0,
      bool wicket = false,
      Player? dismissed}) async {
    if (_match == null) return;
    int over = _balls ~/ 6;
    int ballNo = _balls % 6 + 1;
    final event = BallEvent(
      matchId: _match!.id!,
      innings: 1,
      over: over,
      ballNumber: ballNo,
      batsmanId: _striker!.id!,
      bowlerId: _currentBowler!.id!,
      runs: runs,
      extraType: extraType,
      extraRuns: extraRuns,
      wicketType: wicket ? 'Wicket' : 'None',
      dismissedPlayerId: wicket ? dismissed?.id : null,
    );
    await _ballEventService.insert(event);
    // update scores
    _runs += runs + extraRuns;
    if (wicket) _wickets++;
    if (extraType == 'None') _balls++;
    if (_balls == _match!.overs * 6 || _wickets == 10) {
      _endInnings();
    }
    if ((runs + extraRuns) % 2 == 1) _switchStrike();
    setState(() {});
  }

  void _endInnings() {
    // handle end innings: show dialog to select result...
  }

  void _selectBowler() async {
    final bowler = await showDialog<Player>(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text('Select Bowler'),
        children: _bowlingPlayers
            .map((p) => SimpleDialogOption(
                  child: Text(p.name),
                  onPressed: () => Navigator.pop(context, p),
                ))
            .toList(),
      ),
    );
    if (bowler != null) setState(() => _currentBowler = bowler);
  }

  @override
  Widget build(BuildContext context) {
    if (_match == null)
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar:
          AppBar(title: Text('${_battingTeam!.name} vs ${_bowlingTeam!.name}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Score
            Text('${_battingTeam!.name}: $_runs/$_wickets',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('Overs: ${_balls ~/ 6}.${_balls % 6}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            // Batsmen & Bowler
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('⚡ ${_striker?.name}'),
                    Text('   🏏'),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('🎯 ${_currentBowler?.name}'),
                    Text('Overs bowled'),
                  ],
                )
              ],
            ),
            Divider(height: 32),
            // Ball entry
            Wrap(spacing: 8, children: [
              ElevatedButton(
                  onPressed: () => _addBall(runs: 0), child: Text('0')),
              ElevatedButton(
                  onPressed: () => _addBall(runs: 1), child: Text('1')),
              ElevatedButton(
                  onPressed: () => _addBall(runs: 2), child: Text('2')),
              ElevatedButton(
                  onPressed: () => _addBall(runs: 4), child: Text('4')),
              ElevatedButton(
                  onPressed: () => _addBall(runs: 6), child: Text('6')),
              ElevatedButton(
                  onPressed: () =>
                      _addBall(runs: 0, extraType: 'Wide', extraRuns: 1),
                  child: Text('Wide')),
              ElevatedButton(
                  onPressed: () =>
                      _addBall(runs: 0, extraType: 'NoBall', extraRuns: 1),
                  child: Text('No Ball')),
              ElevatedButton(
                  onPressed: () =>
                      _addBall(runs: 0, extraType: 'Bye', extraRuns: 0),
                  child: Text('Bye')),
              ElevatedButton(
                  onPressed: () =>
                      _addBall(runs: 0, extraType: 'LegBye', extraRuns: 0),
                  child: Text('LegBye')),
              ElevatedButton(
                  onPressed: () =>
                      _addBall(runs: 0, wicket: true, dismissed: _striker),
                  child: Text('Wicket')),
            ]),
            Spacer(),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              ElevatedButton(
                  onPressed: _switchStrike, child: Text('Swap Strike')),
              ElevatedButton(
                  onPressed: _selectBowler, child: Text('Change Bowler')),
              ElevatedButton(
                onPressed: _endInnings,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('End Innings'),
              ),
            ])
          ],
        ),
      ),
    );
  }
}
