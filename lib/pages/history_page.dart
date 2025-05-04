// history_page.dart
import 'package:cricbook/models/match.dart';
import 'package:cricbook/pages/new_score_page.dart';
import 'package:cricbook/pages/score_card.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:cricbook/models/match_model.dart';

import 'package:cricbook/services/match_service.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final _matchService = MatchService();
  late Future<List<MatchModel>> _matchesFuture;

  @override
  void initState() {
    super.initState();
    _matchesFuture = _matchService.getAllMatches();
  }

  Future<void> _deleteMatch(int id) async {
    await _matchService.deleteMatch(id);
    setState(() => _matchesFuture = _matchService.getAllMatches());
  }

  Future<void> _exportPdf(MatchModel match) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Match ID: ${match.id}'),
            pw.Text('Teams: ${match.teamAId} vs ${match.teamBId}'),
            pw.Text('Date: ${match.date.toLocal()}'),
            pw.Text('Result: ${match.result.toString().split('.').last}'),
          ],
        ),
      ),
    );
    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'match_${match.id}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Match History')),
      body: FutureBuilder<List<MatchModel>>(
        future: _matchesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final matches = snapshot.data ?? [];
          if (matches.isEmpty) {
            return Center(child: Text('No matches found.'));
          }
          return ListView.separated(
            itemCount: matches.length,
            separatorBuilder: (_, __) => Divider(),
            itemBuilder: (context, index) {
              final m = matches[index];
              final completed = m.result != MatchResult.NoResult;
              return ListTile(
                title: Text(
                    'Match ${m.id}: Team ${m.teamAId} vs Team ${m.teamBId}'),
                subtitle: Text(
                  '${m.date.toLocal().toString().split(' ')[0]} • ${completed ? 'Completed' : 'In progress'}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon:
                          Icon(completed ? Icons.visibility : Icons.play_arrow),
                      tooltip: completed ? 'View Scorecard' : 'Resume Match',
                      onPressed: () {
                        if (completed) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ScorecardScreen(matchId: m.id!),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ScoreboardScreen(matchId: m.id!),
                            ),
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.picture_as_pdf),
                      tooltip: 'Export to PDF',
                      onPressed: () => _exportPdf(m),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      tooltip: 'Delete Match',
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text('Delete Match'),
                            content: Text(
                                'Are you sure you want to delete this match?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) _deleteMatch(m.id!);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
