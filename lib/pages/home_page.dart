import 'package:cricbook/pages/new_match_setup_page.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/hero_header.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
  }

  // Future<void> _loadData() async {
  //   setState(() => isLoading = true);
  //   try {
  //     await PlayerService.fetchPlayers();
  //     setState(() => isLoading = false);
  //   } catch (e) {
  //     setState(() {
  //       errorMessage = e.toString();
  //       isLoading = false;
  //     });
  //     ApiErrorNotification().dispatch(context);
  //     setState(() {
  //       errorMessage = e.toString();
  //       isLoading = false;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    if (errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: CustomAppBar(title: const Text('Home')),
        body: Center(child: Text(errorMessage)),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: const Text('Team Awesome Sozeith'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SettingsPage()),
            ),
          ),
        ],
      ),
      body: _buildPlayerContent(),
    );
  }

  Widget _buildPlayerContent() {
    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [const HeroHeader(), NewMatchSetupPage()],
    );
  }
}
