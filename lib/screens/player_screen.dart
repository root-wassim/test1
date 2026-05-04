import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../config/theme.dart';
import '../models/track.dart';
import '../services/download_service.dart';
import '../services/favorites_service.dart';
import '../services/player_provider.dart';
import '../services/quran_service.dart';
import 'downloads_screen.dart';
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

  // ── Connectivity ────────────────────────────────────────────────────
  bool _isOnline = true;
  StreamSubscription<List<ConnectivityResult>>? _connSub;

  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _favSub = FavoritesService.favoriteIdsStream().listen((ids) {
      if (mounted) setState(() => _favoriteIds = ids);
    });
    // Track connectivity changes
    _connSub = Connectivity().onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (mounted && online != _isOnline) setState(() => _isOnline = online);
    });
    // Check initial connectivity
    Connectivity().checkConnectivity().then((results) {
      if (mounted) setState(() => _isOnline = results.any((r) => r != ConnectivityResult.none));
    });
    _load();
  }

  @override
  void dispose() {
    _favSub?.cancel();
    _connSub?.cancel();
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
          // ── Offline badge ──────────────────────────────────────────
          if (!_isOnline)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Text('Offline mode 📵',
                    style: TextStyle(color: Colors.orangeAccent, fontSize: 12)),
              ),
            ),
          // ── Downloads shortcut ─────────────────────────────────────
          IconButton(
            icon: const Icon(Icons.download_for_offline_outlined, color: Colors.white70),
            tooltip: 'Downloads',
            onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const DownloadsScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white54),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? _buildShimmer()
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
                isOnline: _isOnline,
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

  /// Returns 7 shimmer list-tile placeholders that mimic the real category layout.
  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppTheme.card,
      highlightColor: AppTheme.surface,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        itemCount: 7,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Leading square (mimics gradient icon)
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 14),
                // Title + subtitle lines
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 10,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                // Trailing arrow
                Container(
                  width: 20, height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ),
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
  final bool isOnline;
  final VoidCallback onToggle;

  const _CategoryTile({
    required this.category,
    required this.allCategories,
    required this.isExpanded,
    required this.favoriteIds,
    required this.isOnline,
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
              queue: allCategories.expand((c) => c.tracks).toList(),
              isFavorite: favoriteIds.contains(t.id),
              isOnline: isOnline,
            )),
          ],
        ],
      ),
    );
  }
}

// ── Track tile ─────────────────────────────────────────────────────────────────

class _TrackTile extends StatefulWidget {
  final Track track;
  final List<Track> queue;
  final bool isFavorite;
  final bool isOnline;

  const _TrackTile({
    required this.track,
    required this.queue,
    required this.isFavorite,
    required this.isOnline,
  });

  @override
  State<_TrackTile> createState() => _TrackTileState();
}

class _TrackTileState extends State<_TrackTile> {
  bool _downloaded = false;
  double? _progress; // null = not downloading

  @override
  void initState() {
    super.initState();
    _checkDownloaded();
  }

  Future<void> _checkDownloaded() async {
    final v = await DownloadService.isDownloaded(widget.track.id);
    if (mounted) setState(() => _downloaded = v);
  }

  Future<void> _startDownload() async {
    setState(() => _progress = 0.0);
    try {
      await DownloadService.downloadTrack(
        widget.track,
        onProgress: (p) { if (mounted) setState(() => _progress = p); },
      );
      if (mounted) setState(() { _downloaded = true; _progress = null; });
    } catch (_) {
      if (mounted) {
        setState(() => _progress = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download failed'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _deleteDownload() async {
    await DownloadService.deleteDownload(widget.track.id);
    if (mounted) setState(() { _downloaded = false; _progress = null; });
  }

  Widget _buildDownloadButton() {
    // Downloading in progress
    if (_progress != null) {
      return SizedBox(
        width: 36, height: 36,
        child: Stack(alignment: Alignment.center, children: [
          CircularProgressIndicator(
            value: _progress,
            strokeWidth: 2.5,
            color: AppTheme.primary,
          ),
          Text(
            '${((_progress ?? 0) * 100).toInt()}%',
            style: const TextStyle(color: Colors.white, fontSize: 8),
          ),
        ]),
      );
    }
    // Already downloaded
    if (_downloaded) {
      return GestureDetector(
        onLongPress: () async {
          final del = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: AppTheme.card,
              title: const Text('Delete download?', style: TextStyle(color: Colors.white)),
              content: Text('Remove "${widget.track.title}" from device?',
                  style: const TextStyle(color: Colors.white54)),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel', style: TextStyle(color: Colors.white38))),
                TextButton(onPressed: () => Navigator.pop(context, true),
                    child: const Text('Delete', style: TextStyle(color: Colors.red))),
              ],
            ),
          );
          if (del == true) _deleteDownload();
        },
        child: const Icon(Icons.download_done, color: Colors.greenAccent, size: 22),
      );
    }
    // Not downloaded — hide button when offline
    if (!widget.isOnline) return const SizedBox(width: 36);
    return IconButton(
      padding: EdgeInsets.zero,
      icon: const Icon(Icons.download, color: Colors.white38, size: 22),
      onPressed: _startDownload,
    );
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final isPlaying = player.current?.id == widget.track.id;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: isPlaying ? AppTheme.primary.withOpacity(0.2) : AppTheme.surface,
          shape: BoxShape.circle,
        ),
        child: isPlaying
            ? const Icon(Icons.graphic_eq, color: AppTheme.primary, size: 18)
            : const Icon(Icons.play_arrow, color: Colors.white38, size: 18),
      ),
      title: Text(
        widget.track.arabicTitle.isNotEmpty
            ? '${widget.track.title}  ${widget.track.arabicTitle}'
            : widget.track.title,
        style: TextStyle(
            color: isPlaying ? AppTheme.primary : Colors.white,
            fontSize: 14,
            fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        widget.track.reciter,
        style: const TextStyle(color: Colors.white38, fontSize: 11),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDownloadButton(),
          IconButton(
            icon: Icon(
              widget.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: widget.isFavorite ? AppTheme.accent : Colors.white38,
              size: 20,
            ),
            onPressed: () async {
              final added = await FavoritesService.toggleFavorite(widget.track);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(added ? 'Added to favorites ❤️' : 'Removed from favorites'),
                  backgroundColor: added ? AppTheme.primary : Colors.white24,
                  duration: const Duration(seconds: 2),
                ));
              }
            },
          ),
        ],
      ),
      onTap: () {
        context.read<PlayerProvider>().playTrack(widget.track, queue: widget.queue);
        Navigator.push(context, MaterialPageRoute(builder: (_) => const NowPlayingScreen()));
      },
    );
  }
}
