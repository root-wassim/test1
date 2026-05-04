import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../models/track.dart';
import '../services/favorites_service.dart';
import '../services/player_provider.dart';
import '../services/quran_service.dart';
import 'now_playing_screen.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});
  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  List<Category> _categories = [];
  bool _loading = true;
  String? _expandedId;
  String _query = '';

  Set<String> _favoriteIds = {};
  StreamSubscription<Set<String>>? _favSub;

  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _favSub = FavoritesService.favoriteIdsStream().listen((ids) {
      if (mounted) setState(() => _favoriteIds = ids);
    });
    _load();
  }

  @override
  void dispose() {
    _favSub?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final cats = await QuranApiService.fetchCategories();
    if (mounted) setState(() { _categories = cats; _loading = false; });
  }

  /// Returns categories/tracks filtered by the search query.
  /// If a query is active, all matching categories are auto-expanded.
  List<Category> get _filtered {
    if (_query.isEmpty) return _categories;
    final q = _query.toLowerCase();
    final result = <Category>[];
    for (final cat in _categories) {
      // Match on category name OR any track title
      if (cat.name.toLowerCase().contains(q)) {
        result.add(cat); // whole category matches
      } else {
        final matchingTracks =
        cat.tracks.where((t) => t.title.toLowerCase().contains(q)).toList();
        if (matchingTracks.isNotEmpty) {
          result.add(Category(
            id: cat.id,
            name: cat.name,
            tracks: matchingTracks,
          ));
        }
      }
    }
    return result;
  }

  bool _isExpanded(Category cat) {
    if (_query.isNotEmpty) return true; // auto-expand when searching
    return _expandedId == cat.id;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white54),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : Column(
        children: [
          // ── Search bar ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v.trim()),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search tracks or categories…',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white38),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.white38, size: 18),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _query = '');
                  },
                )
                    : null,
                filled: true,
                fillColor: AppTheme.card,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ── Result count when searching ─────────────────────────
          if (_query.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${filtered.fold(0, (s, c) => s + c.tracks.length)} result(s)',
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ),
            ),

          // ── Category list ───────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_off, color: Colors.white24, size: 48),
                  SizedBox(height: 12),
                  Text('No results found',
                      style: TextStyle(color: Colors.white38)),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              itemCount: filtered.length,
              itemBuilder: (_, i) => _CategoryTile(
                category: filtered[i],
                allCategories: _categories,
                isExpanded: _isExpanded(filtered[i]),
                favoriteIds: _favoriteIds,
                onToggle: () => setState(() =>
                _expandedId = _expandedId == filtered[i].id
                    ? null
                    : filtered[i].id),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Category tile ──────────────────────────────────────────────────────────────

class _CategoryTile extends StatelessWidget {
  final Category category;
  final List<Category> allCategories;
  final bool isExpanded;
  final Set<String> favoriteIds;
  final VoidCallback onToggle;

  const _CategoryTile({
    required this.category,
    required this.allCategories, // 🔥 ADD
    required this.isExpanded,
    required this.favoriteIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          color: AppTheme.card, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          ListTile(
            onTap: onToggle,
            leading: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppTheme.primary, Color(0xFF8B5CF6)]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.menu_book, color: Colors.white, size: 22),
            ),
            title: Row(children: [
              // Surah number badge
              if (category.tracks.isNotEmpty && category.tracks.first.surahNumber != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${category.tracks.first.surahNumber}',
                    style: const TextStyle(color: Color(0xFF6C63FF), fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(category.name,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ]),
            subtitle: Text('${category.tracks.length} tracks',
                style: const TextStyle(color: Colors.white38, fontSize: 12)),
            trailing: AnimatedRotation(
              turns: isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.keyboard_arrow_down, color: Colors.white38),
            ),
          ),
          if (isExpanded) ...[
            const Divider(color: Colors.white12, height: 1),
            ...category.tracks.map((t) => _TrackTile(
              track: t,
              queue: allCategories
                  .expand((c) => c.tracks)
                  .toList(), // ✅ FULL QUEUE
              isFavorite: favoriteIds.contains(t.id),
            )),
          ],
        ],
      ),
    );
  }
}

// ── Track tile ─────────────────────────────────────────────────────────────────

class _TrackTile extends StatelessWidget {
  final Track track;
  final List<Track> queue;
  final bool isFavorite;

  const _TrackTile({
    required this.track,
    required this.queue,
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final isPlaying = player.current?.id == track.id;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: isPlaying
              ? AppTheme.primary.withOpacity(0.2)
              : AppTheme.surface,
          shape: BoxShape.circle,
        ),
        child: isPlaying
            ? const Icon(Icons.graphic_eq, color: AppTheme.primary, size: 18)
            : const Icon(Icons.play_arrow, color: Colors.white38, size: 18),
      ),
      title: Text(
        track.arabicTitle.isNotEmpty
            ? '${track.title}  ${track.arabicTitle}'
            : track.title,
        style: TextStyle(
            color: isPlaying ? AppTheme.primary : Colors.white,
            fontSize: 14,
            fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        track.reciter,
        style: const TextStyle(color: Colors.white38, fontSize: 11),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? AppTheme.accent : Colors.white38,
          size: 20,
        ),
        onPressed: () async {
          final added = await FavoritesService.toggleFavorite(track);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(added ? 'Added to favorites' : 'Removed from favorites'),
              backgroundColor: added ? AppTheme.primary : Colors.white24,
              duration: const Duration(seconds: 2),
            ));
          }
        },
      ),
      onTap: () {
        context.read<PlayerProvider>().playTrack(track, queue: queue);
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const NowPlayingScreen()));
      },
    );
  }
}