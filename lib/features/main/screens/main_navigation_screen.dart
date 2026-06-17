import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/route_names.dart';
import '../../flashcards/screens/deck_screen.dart';
import '../../home/providers/home_provider.dart';
import '../../home/screens/home_screen.dart';
import '../../notes/screens/notes_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../stats/providers/stats_provider.dart';
import '../../stats/screens/stats_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final _pages = const [
    HomeScreen(),
    NotesScreen(),
    DeckScreen(),
    StatsScreen(),
    SettingsScreen(),
  ];

  final _titles = const [
    'Home',
    'Notes',
    'Flashcards',
    'Statistics',
    'Settings',
  ];

  void _onDestinationSelected(int index) {
    setState(() => _currentIndex = index);
    if (index == 0) {
      context.read<HomeProvider>().loadHomeData();
    }
    if (index == 3) {
      context.read<StatsProvider>().loadStats();
    }
  }

  Future<void> _refreshOverviewData() async {
    await Future.wait([
      context.read<HomeProvider>().loadHomeData(),
      context.read<StatsProvider>().loadStats(),
    ]);
  }

  Widget? _buildFab() {
    if (_currentIndex == 1) {
      return FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, RouteNames.addEditNote);
          if (!mounted) {
            return;
          }
          await _refreshOverviewData();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Note'),
      );
    }
    if (_currentIndex == 2) {
      return FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, RouteNames.addEditFlashcard);
          if (!mounted) {
            return;
          }
          await _refreshOverviewData();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Card'),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_currentIndex])),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      floatingActionButton: _buildFab(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.sticky_note_2_outlined),
            selectedIcon: Icon(Icons.sticky_note_2),
            label: 'Notes',
          ),
          NavigationDestination(
            icon: Icon(Icons.layers_outlined),
            selectedIcon: Icon(Icons.layers),
            label: 'Cards',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
