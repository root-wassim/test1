import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../models/track.dart';
import '../services/download_service.dart';
import '../services/player_provider.dart';
import '../services/quran_service.dart';
import 'now_playing_screen.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});
  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  // List of (trackId, Track?, fileSizeBytes)
  List<_DownloadItem> _items = [];
  bool _loading = true;

  // We need the full track list to match IDs → Track objects
  List<Track> _allTracks = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    // Load all tracks from API (or fallback) to get metadata for downloaded IDs
    final cats = await QuranApiService.fetchCategories();
    _allTracks = cats.expand((c) => c.tracks).toList();

    final ids = await DownloadService.getDownloadedTracks();
    final items = <_DownloadItem>[];
    for (final id in ids) {
      final track = _allTracks.firstWhere(
        (t) => t.id == id,
        orElse: () => Track(
          id: id, title: 'Track $id', arabicTitle: '',
          category: 'Quran', reciter: '', audioUrl: '', surahNumber: null,
        ),
      );
      final size = await DownloadService.getFileSize(id);
      items.add(_DownloadItem(track: track, sizeBytes: size));
    }
    if (mounted) setState(() { _items = items; _loading = false; });
  }

  Future<void> _delete(_DownloadItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: const Text('Delete download?', style: TextStyle(color: Colors.white)),
        content: Text('Remove "${item.track.title}" from device?\n(${DownloadService.formatSize(item.sizeBytes)})',
            style: const TextStyle(color: Colors.white54)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel', style: TextStyle(color: Colors.white38))),
          TextButton(onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true) {
      await DownloadService.deleteDownload(item.track.id);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Downloads'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white54), onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : _items.isEmpty
              ? const Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.download_for_offline, color: Colors.white24, size: 72),
                    SizedBox(height: 16),
                    Text('No downloads yet', style: TextStyle(color: Colors.white38, fontSize: 18)),
                    SizedBox(height: 8),
                    Text('Tap ↓ on any track to download it', style: TextStyle(color: Colors.white24, fontSize: 13)),
                  ]),
                )
              : Column(
                  children: [
                    // Summary bar
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12)),
                      child: Row(children: [
                        const Icon(Icons.storage, color: AppTheme.primary, size: 18),
                        const SizedBox(width: 8),
                        Text('${_items.length} tracks · ${DownloadService.formatSize(_items.fold(0, (s, i) => s + i.sizeBytes))}',
                            style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      ]),
                    ),
                    // Track list
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: _items.length,
                        itemBuilder: (_, i) => _buildItem(_items[i]),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildItem(_DownloadItem item) {
    final player = context.watch<PlayerProvider>();
    final isPlaying = player.current?.id == item.track.id;

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
            gradient: LinearGradient(colors: [
              isPlaying ? AppTheme.primary : Colors.green.shade700,
              isPlaying ? const Color(0xFF8B5CF6) : Colors.green.shade500,
            ]),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isPlaying ? Icons.graphic_eq : Icons.download_done,
            color: Colors.white, size: 20,
          ),
        ),
        title: Text(
          item.track.title,
          style: TextStyle(
            color: isPlaying ? AppTheme.primary : Colors.white,
            fontWeight: FontWeight.w500, fontSize: 14,
          ),
          maxLines: 1, overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${item.track.arabicTitle.isNotEmpty ? "${item.track.arabicTitle} · " : ""}${DownloadService.formatSize(item.sizeBytes)} · Offline ready',
          style: const TextStyle(color: Colors.white38, fontSize: 11),
          maxLines: 1, overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
          onPressed: () => _delete(item),
        ),
        onTap: () {
          player.playTrack(item.track, queue: _allTracks);
          Navigator.push(context, MaterialPageRoute(builder: (_) => const NowPlayingScreen()));
        },
      ),
    );
  }
}

class _DownloadItem {
  final Track track;
  final int sizeBytes;
  const _DownloadItem({required this.track, required this.sizeBytes});
}
