import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/track.dart';

/// Manages permanent offline downloads of Quran audio tracks.
///
/// Storage location: `<Documents>/quran_downloads/<trackId>.mp3`
/// Metadata (list of downloaded IDs) is persisted in SharedPreferences.
class DownloadService {
  static const String _prefKey = 'downloaded_track_ids';
  static const String _folderName = 'quran_downloads';

  // In-memory map: trackId → download progress (0.0 – 1.0)
  // Screens listen to this via ChangeNotifier or StatefulWidget setState.
  static final Map<String, double> downloadProgress = {};

  // ─── Directory helpers ────────────────────────────────────────────────

  static Future<Directory> _downloadsDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/$_folderName');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  static Future<String> _filePath(String trackId) async {
    final dir = await _downloadsDir();
    return '${dir.path}/$trackId.mp3';
  }

  // ─── Public API ───────────────────────────────────────────────────────

  /// Downloads [track] to local storage with progress updates.
  /// Progress (0.0 – 1.0) is written to [downloadProgress][trackId].
  /// Calls [onProgress] on each chunk if provided.
  static Future<void> downloadTrack(
    Track track, {
    void Function(double progress)? onProgress,
  }) async {
    final id = track.id;
    downloadProgress[id] = 0.0;

    try {
      final path = await _filePath(id);
      final dio = Dio();

      await dio.download(
        track.audioUrl,
        path,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final p = received / total;
            downloadProgress[id] = p;
            onProgress?.call(p);
          }
        },
        options: Options(receiveTimeout: const Duration(minutes: 10)),
      );

      // Persist the downloaded ID to SharedPreferences
      await _addToPrefs(id);
      downloadProgress[id] = 1.0;
      onProgress?.call(1.0);
    } catch (e) {
      // Clean up partial file on error
      downloadProgress.remove(id);
      final path = await _filePath(id);
      final file = File(path);
      if (await file.exists()) await file.delete();
      rethrow;
    }
  }

  /// Returns `true` if the track has been fully downloaded.
  static Future<bool> isDownloaded(String trackId) async {
    final ids = await getDownloadedTracks();
    if (!ids.contains(trackId)) return false;
    // Also verify the file actually exists (guard against manual deletion)
    final path = await _filePath(trackId);
    return File(path).existsSync();
  }

  /// Returns the absolute local file path if downloaded, otherwise `null`.
  static Future<String?> getLocalPath(String trackId) async {
    if (!await isDownloaded(trackId)) return null;
    return _filePath(trackId);
  }

  /// Deletes the local audio file and removes metadata from SharedPreferences.
  static Future<void> deleteDownload(String trackId) async {
    final path = await _filePath(trackId);
    final file = File(path);
    if (await file.exists()) await file.delete();
    await _removeFromPrefs(trackId);
    downloadProgress.remove(trackId);
  }

  /// Returns all downloaded track IDs from SharedPreferences.
  static Future<List<String>> getDownloadedTracks() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_prefKey) ?? [];
  }

  /// Returns the file size in bytes for a downloaded track, or 0.
  static Future<int> getFileSize(String trackId) async {
    final path = await _filePath(trackId);
    final file = File(path);
    if (await file.exists()) return await file.length();
    return 0;
  }

  /// Formats a byte count as a human-readable string (e.g. "12.4 MB").
  static String formatSize(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // ─── SharedPreferences helpers ────────────────────────────────────────

  static Future<void> _addToPrefs(String trackId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_prefKey) ?? [];
    if (!ids.contains(trackId)) {
      ids.add(trackId);
      await prefs.setStringList(_prefKey, ids);
    }
  }

  static Future<void> _removeFromPrefs(String trackId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_prefKey) ?? [];
    ids.remove(trackId);
    await prefs.setStringList(_prefKey, ids);
  }
}
