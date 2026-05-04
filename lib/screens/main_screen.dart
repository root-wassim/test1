import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/player_provider.dart';
import '../config/theme.dart';
import 'stats_screen.dart';
import 'player_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import '../widgets/mini_player.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _tab = 0;

  final _screens = const [
    StatsScreen(),
    PlayerScreen(),
    FavoritesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: IndexedStack(index: _tab, children: _screens),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (player.current != null) const MiniPlayer(),
          NavigationBar(
            backgroundColor: AppTheme.surface,
            indicatorColor: AppTheme.primary.withOpacity(0.2),
            selectedIndex: _tab,
            onDestinationSelected: (i) => setState(() => _tab = i),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart, color: AppTheme.primary), label: 'Stats'),
              NavigationDestination(icon: Icon(Icons.library_music_outlined), selectedIcon: Icon(Icons.library_music, color: AppTheme.primary), label: 'Library'),
              NavigationDestination(icon: Icon(Icons.favorite_outline), selectedIcon: Icon(Icons.favorite, color: AppTheme.primary), label: 'Favorites'),
              NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: AppTheme.primary), label: 'Profile'),
            ],
          ),
        ],
      ),
    );
  }
}
