import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/player_provider.dart';
import '../config/theme.dart';
import '../screens/now_playing_screen.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final track = player.current;
    if (track == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NowPlayingScreen())),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppTheme.primary, Color(0xFF8B5CF6)]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              // Icon
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.music_note, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(track.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(track.category, style: const TextStyle(color: Colors.white70, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
              ])),
              // Controls
              IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(), icon: const Icon(Icons.skip_previous, color: Colors.white, size: 24), onPressed: player.playPrevious),
              const SizedBox(width: 4),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: player.isLoading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Icon(player.isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 28),
                onPressed: player.togglePlayPause,
              ),
              const SizedBox(width: 4),
              IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(), icon: const Icon(Icons.skip_next, color: Colors.white, size: 24), onPressed: player.playNext),
            ]),
            const SizedBox(height: 6),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: player.progress,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
