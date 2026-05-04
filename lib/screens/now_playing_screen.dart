import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../services/favorites_service.dart';
import '../services/player_provider.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  void _showMenu(BuildContext context, bool isFav) {
    final player = context.read<PlayerProvider>();
    final track = player.current;
    if (track == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Track info header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [AppTheme.primary, Color(0xFF8B5CF6)]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.music_note, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.arabicTitle.isNotEmpty
                          ? '${track.title}  ${track.arabicTitle}'
                          : track.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      track.reciter,
                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                )),
              ]),
            ),
            const Divider(color: Colors.white12, height: 1),
            // Favorite toggle
            ListTile(
              leading: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                color: isFav ? AppTheme.accent : Colors.white70,
              ),
              title: Text(
                isFav ? 'Remove from Favorites' : 'Add to Favorites',
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () async {
                Navigator.pop(context);
                await FavoritesService.toggleFavorite(track);
              },
            ),
            // Go to queue (close now playing)
            ListTile(
              leading: const Icon(Icons.queue_music, color: Colors.white70),
              title: const Text('Back to Queue', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context); // close sheet
                Navigator.pop(context); // close now playing
              },
            ),
            // Repeat toggle
            ListTile(
              leading: Icon(
                player.isLooping ? Icons.repeat_one : Icons.repeat,
                color: player.isLooping ? AppTheme.primary : Colors.white70,
              ),
              title: Text(
                player.isLooping ? 'Disable Repeat' : 'Repeat This Track',
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                player.toggleLoop();
                Navigator.pop(context);
              },
            ),
            // Shuffle toggle
            ListTile(
              leading: Icon(
                Icons.shuffle,
                color: player.isShuffled ? AppTheme.primary : Colors.white70,
              ),
              title: Text(
                player.isShuffled ? 'Disable Shuffle' : 'Shuffle Queue',
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                player.toggleShuffle();
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final track = player.current;
    if (track == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A0A2E), AppTheme.bg],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const SizedBox(height: 16),

                // Header
                StreamBuilder<Set<String>>(
                  stream: FavoritesService.favoriteIdsStream(),
                  builder: (context, snap) {
                    final isFav = snap.data?.contains(track.id) ?? false;
                    return Row(children: [
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down,
                            color: Colors.white, size: 30),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text('Now Playing',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  letterSpacing: 1)),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_horiz, color: Colors.white54),
                        onPressed: () => _showMenu(context, isFav),
                      ),
                    ]);
                  },
                ),

                const SizedBox(height: 32),

                // Album art
                Container(
                  width: double.infinity,
                  height: 280,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                        colors: [AppTheme.primary, Color(0xFF8B5CF6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    boxShadow: [
                      BoxShadow(
                          color: AppTheme.primary.withOpacity(0.4),
                          blurRadius: 40,
                          offset: const Offset(0, 20))
                    ],
                  ),
                  child: const Icon(Icons.music_note,
                      color: Colors.white, size: 100),
                ),

                const SizedBox(height: 32),

                // Song info + favorite button
                Row(children: [
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            if (track.surahNumber != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppTheme.primary.withOpacity(0.4)),
                                ),
                                child: Text(
                                  'Surah ${track.surahNumber}',
                                  style: const TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Expanded(
                              child: Text(track.title,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ]),
                          const SizedBox(height: 4),
                          // Arabic name
                          if (track.arabicTitle.isNotEmpty)
                            Text(
                              track.arabicTitle,
                              style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          const SizedBox(height: 2),
                          // Reciter name
                          Row(children: [
                            const Icon(Icons.mic, color: Colors.white38, size: 13),
                            const SizedBox(width: 4),
                            Text(
                              track.reciter,
                              style: const TextStyle(color: Colors.white38, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ]),
                        ]),
                  ),

                  // Live favorite heart
                  StreamBuilder<Set<String>>(
                    stream: FavoritesService.favoriteIdsStream(),
                    builder: (context, snap) {
                      final isFav = snap.data?.contains(track.id) ?? false;
                      return IconButton(
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            key: ValueKey(isFav),
                            color: isFav ? AppTheme.accent : Colors.white54,
                            size: 28,
                          ),
                        ),
                        onPressed: () => FavoritesService.toggleFavorite(track),
                      );
                    },
                  ),

                  IconButton(
                    icon: Icon(
                        player.isLooping ? Icons.repeat_one : Icons.repeat,
                        color: player.isLooping
                            ? AppTheme.primary
                            : Colors.white38),
                    onPressed: player.toggleLoop,
                  ),
                ]),

                const SizedBox(height: 24),

                // Progress slider
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 7),
                    activeTrackColor: AppTheme.primary,
                    inactiveTrackColor: Colors.white12,
                    thumbColor: Colors.white,
                    overlayColor: AppTheme.primary.withOpacity(0.1),
                  ),
                  child: Slider(
                      value: player.progress, onChanged: player.seek),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_fmt(player.position),
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 12)),
                        Text(_fmt(player.duration),
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 12)),
                      ]),
                ),

                const SizedBox(height: 28),

                // Playback controls
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(Icons.shuffle,
                            color: player.isShuffled
                                ? AppTheme.primary
                                : Colors.white38,
                            size: 24),
                        onPressed: player.toggleShuffle,
                      ),
                      IconButton(
                          icon: const Icon(Icons.skip_previous,
                              color: Colors.white, size: 40),
                          onPressed: player.playPrevious),
                      GestureDetector(
                        onTap: player.togglePlayPause,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(colors: [
                              AppTheme.primary,
                              Color(0xFF8B5CF6)
                            ]),
                            boxShadow: [
                              BoxShadow(
                                  color: AppTheme.primary.withOpacity(0.5),
                                  blurRadius: 20,
                                  spreadRadius: 2)
                            ],
                          ),
                          child: player.isLoading
                              ? const Center(
                              child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2)))
                              : Icon(
                              player.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Colors.white,
                              size: 36),
                        ),
                      ),
                      IconButton(
                          icon: const Icon(Icons.skip_next,
                              color: Colors.white, size: 40),
                          onPressed: player.playNext),
                      IconButton(
                          icon: const Icon(Icons.queue_music,
                              color: Colors.white38, size: 24),
                          onPressed: () => Navigator.pop(context)),
                    ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}