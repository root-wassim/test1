import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/track.dart';
import '../services/favorites_service.dart';
import '../services/biometric_service.dart';
import '../services/player_provider.dart';
import '../config/theme.dart';
import 'now_playing_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  Future<void> _deleteFavorite(BuildContext context, String trackId, String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: const Text('Remove from Favorites', style: TextStyle(color: Colors.white)),
        content: Text('Remove "$title"?\nYou\'ll need to verify with fingerprint.', style: const TextStyle(color: Colors.white54)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: Colors.white38))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Remove', style: TextStyle(color: AppTheme.accent))),
        ],
      ),
    );

    if (confirmed != true) return;

    final auth = await BiometricService.authenticate(reason: 'Confirm removal from favorites');
    if (auth) {
      await FavoritesService.removeFavorite(trackId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from favorites'), backgroundColor: AppTheme.accent, duration: Duration(seconds: 2)),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biometric authentication failed'), backgroundColor: Colors.red, duration: Duration(seconds: 2)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(children: [
              const Icon(Icons.fingerprint, color: AppTheme.primary, size: 18),
              const SizedBox(width: 4),
              const Text('Delete needs fingerprint', style: TextStyle(color: Colors.white38, fontSize: 11)),
            ]),
          ),
        ],
      ),
      body: StreamBuilder<List<Track>>(
        stream: FavoritesService.favoritesStream(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
          }

          final favs = snap.data ?? [];

          if (favs.isEmpty) {
            return Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.favorite_border, color: Colors.white24, size: 80),
                const SizedBox(height: 16),
                const Text('No favorites yet', style: TextStyle(color: Colors.white38, fontSize: 18)),
                const SizedBox(height: 8),
                const Text('Tap ♥ on any track to add it here', style: TextStyle(color: Colors.white24, fontSize: 13)),
              ]),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favs.length,
            itemBuilder: (_, i) {
              final track = favs[i];
              final player = context.watch<PlayerProvider>();
              final isPlaying = player.current?.id == track.id;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isPlaying ? AppTheme.primary.withOpacity(0.1) : AppTheme.card,
                  borderRadius: BorderRadius.circular(12),
                  border: isPlaying ? Border.all(color: AppTheme.primary.withOpacity(0.3)) : null,
                ),
                child: ListTile(
                  leading: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppTheme.primary, Color(0xFF8B5CF6)]),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(isPlaying ? Icons.graphic_eq : Icons.music_note, color: Colors.white, size: 20),
                  ),
                  title: Text(track.title, style: TextStyle(color: isPlaying ? AppTheme.primary : Colors.white, fontWeight: FontWeight.w500, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(track.category, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppTheme.accent, size: 22),
                    onPressed: () => _deleteFavorite(context, track.id, track.title),
                  ),
                  onTap: () {
                    context.read<PlayerProvider>().playTrack(track, queue: favs);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const NowPlayingScreen()));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
