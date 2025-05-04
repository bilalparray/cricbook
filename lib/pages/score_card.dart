import 'package:cricbook/models/player_match_stat.dart';
import 'package:flutter/material.dart';
import 'package:cricbook/services/player_stats_service.dart';
import 'package:cricbook/services/player_service.dart';

class ScorecardScreen extends StatefulWidget {
  final int matchId;
  const ScorecardScreen({Key? key, required this.matchId}) : super(key: key);

  @override
  _ScorecardScreenState createState() => _ScorecardScreenState();
}

class _ScorecardScreenState extends State<ScorecardScreen> {
  final _statsService = PlayerStatsService();
  final _playerService = PlayerService();

  List<PlayerMatchStats> _batting1 = [];
  List<PlayerMatchStats> _bowling1 = [];
  List<PlayerMatchStats> _batting2 = [];
  List<PlayerMatchStats> _bowling2 = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    // innings 1
    final stats1 = await _statsService.getStatsByMatch(widget.matchId);
    final b1 = stats1.where((s) => s.innings == 1).toList();
    final bo1 = stats1.where((s) => s.innings == 1).toList();
    // innings 2
    final stat2 = stats1.where((s) => s.innings == 2).toList();
    final b2 = stat2;
    final bo2 = stat2;

    setState(() {
      _batting1 = b1;
      _bowling1 = bo1;
      _batting2 = b2;
      _bowling2 = bo2;
      _loading = false;
    });
  }

  Future<String> _playerName(int playerId) async {
    final p = await _playerService.getPlayerById(playerId);
    return p?.name ?? 'Unknown';
  }

  Widget _buildBattingTable(List<PlayerMatchStats> stats) {
    return DataTable(
      columns: const [
        DataColumn(label: Text('Batsman')),
        DataColumn(label: Text('R')),
        DataColumn(label: Text('B')),
        DataColumn(label: Text('4s')),
        DataColumn(label: Text('6s')),
        DataColumn(label: Text('SR')),
      ],
      rows: stats.map((s) {
        return DataRow(cells: [
          DataCell(FutureBuilder<String>(
            future: _playerName(s.playerId),
            builder: (_, snap) => Text(snap.data ?? '...'),
          )),
          DataCell(Text('${s.runs}')),
          DataCell(Text('${s.balls}')),
          DataCell(Text('${s.fours}')),
          DataCell(Text('${s.sixes}')),
          DataCell(Text(s.strikeRate.toStringAsFixed(1))),
        ]);
      }).toList(),
    );
  }

  Widget _buildBowlingTable(List<PlayerMatchStats> stats) {
    return DataTable(
      columns: const [
        DataColumn(label: Text('Bowler')),
        DataColumn(label: Text('O')),
        DataColumn(label: Text('M')),
        DataColumn(label: Text('R')),
        DataColumn(label: Text('W')),
        DataColumn(label: Text('Econ')),
      ],
      rows: stats.map((s) {
        return DataRow(cells: [
          DataCell(FutureBuilder<String>(
            future: _playerName(s.playerId),
            builder: (_, snap) => Text(snap.data ?? '...'),
          )),
          DataCell(Text('${s.overs}')),
          DataCell(Text('${s.maidens}')),
          DataCell(Text('${s.runsConceded}')),
          DataCell(Text('${s.wickets}')),
          DataCell(Text(s.economy.toStringAsFixed(2))),
        ]);
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading)
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: Text('Full Scorecard')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1st Innings - Batting',
                style: TextStyle(fontWeight: FontWeight.bold)),
            _buildBattingTable(_batting1),
            SizedBox(height: 16),
            Text('1st Innings - Bowling',
                style: TextStyle(fontWeight: FontWeight.bold)),
            _buildBowlingTable(_bowling1),
            SizedBox(height: 24),
            Text('2nd Innings - Batting',
                style: TextStyle(fontWeight: FontWeight.bold)),
            _buildBattingTable(_batting2),
            SizedBox(height: 16),
            Text('2nd Innings - Bowling',
                style: TextStyle(fontWeight: FontWeight.bold)),
            _buildBowlingTable(_bowling2),
          ],
        ),
      ),
    );
  }
}
