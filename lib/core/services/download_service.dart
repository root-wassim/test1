import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projet/core/services/firestore_user_service.dart';
import 'package:projet/core/services/user_prefs_service.dart';

class DownloadService {
  static const _downloadedMapBaseKey = 'downloaded_tracks_map';

  String get _downloadedMapKey =>
      UserPrefsService.instance.keyFor(_downloadedMapBaseKey);
  Future<Directory> _getDownloadDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/quran_audio');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  String _safeFileName(String url) {
    final uri = Uri.parse(url);
    final params = uri.queryParameters;
    final reciter = params['reciter'] ?? '';
    final id = params['id'] ?? '';
    if (reciter.isNotEmpty && id.isNotEmpty) {
      return '${reciter}_${id.padLeft(3, '0')}.mp3';
    }
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.length >= 2) {
      return '${segments[segments.length - 2]}_${segments.last}'
          .replaceAll(RegExp(r'[^a-zA-Z0-9_\-\.]'), '_');
    }
    return '${url.hashCode.abs()}.mp3';
  }

  /// Download with real progress — throttled to max 1 update per 150ms.
  Future<String> downloadTrack({
    required String url,
    required String title,
    String? reciterName,
    int? surahNumber,
    void Function(double progress)? onProgress,
  }) async {
    final dir = await _getDownloadDir();
    final fileName = _safeFileName(url);
    final file = File('${dir.path}/$fileName');

    debugPrint('[DL] $title → $fileName');

    if (await file.exists() && await file.length() > 0) {
      await _saveMapping(url, file.path, title, reciterName, surahNumber, await file.length());
      return file.path;
    }

    final tmpFile = File('${file.path}.tmp');
    if (await tmpFile.exists()) await tmpFile.delete();

    // http.Client follows redirects by default — no manual resolution needed
    final client = http.Client();
    final response = await client.send(http.Request('GET', Uri.parse(url)));

    if (response.statusCode != 200) {
      client.close();
      throw Exception('HTTP ${response.statusCode}');
    }

    final totalBytes = response.contentLength ?? -1;
    int receivedBytes = 0;
    debugPrint('[DL] totalBytes=$totalBytes');

    // Throttle: only emit progress every 150ms to avoid flooding Riverpod
    int lastEmitMs = 0;

    final sink = tmpFile.openWrite();
    try {
      await for (final chunk in response.stream) {
        sink.add(chunk);
        receivedBytes += chunk.length;

        if (onProgress != null) {
          final nowMs = DateTime.now().millisecondsSinceEpoch;
          if (nowMs - lastEmitMs >= 150) {
            lastEmitMs = nowMs;
            if (totalBytes > 0) {
              onProgress((receivedBytes / totalBytes).clamp(0.0, 1.0));
            } else {
              // Indeterminate: pulse based on MB downloaded
              final mb = receivedBytes / (1024 * 1024);
              onProgress((mb % 1.0)); // cycles 0→1 every MB
            }
          }
        }
      }
      await sink.flush();
    } finally {
      await sink.close();
      client.close();
    }

    // Always emit 100% so the UI completes smoothly
    onProgress?.call(1.0);

    if (receivedBytes == 0) {
      await tmpFile.delete();
      throw Exception('Downloaded 0 bytes');
    }

    await tmpFile.rename(file.path);
    final now = DateTime.now();
    await _saveMapping(url, file.path, title, reciterName, surahNumber, receivedBytes);
    debugPrint('[DL] Done: $receivedBytes B → ${file.path}');

    // Sync metadata to Firestore (non-blocking, best-effort)
    FirestoreUserService().saveDownloadMeta(
      url: url,
      title: title,
      reciterName: reciterName ?? '',
      surahNumber: surahNumber ?? 0,
      fileSize: receivedBytes,
      downloadedAt: now,
    ).ignore();

    return file.path;
  }

  Future<bool> isDownloaded(String url) async {
    final map = await _getDownloadMap();
    final entry = map[url];
    if (entry == null) return false;
    final file = File(entry['path'] ?? '');
    return file.existsSync() && file.lengthSync() > 0;
  }

  Future<String?> getLocalPath(String url) async {
    final map = await _getDownloadMap();
    final entry = map[url];
    if (entry == null) return null;
    final file = File(entry['path'] ?? '');
    if (file.existsSync() && file.lengthSync() > 0) return file.path;
    return null;
  }

  Future<void> deleteTrack(String url) async {
    final map = await _getDownloadMap();
    final entry = map[url];
    if (entry != null) {
      final f = File(entry['path'] ?? '');
      if (await f.exists()) await f.delete();
      map.remove(url);
      await _saveDownloadMap(map);
      // Remove from Firestore (non-blocking)
      FirestoreUserService().deleteDownloadMeta(url).ignore();
    }
  }

  Future<void> deleteAll() async {
    final map = await _getDownloadMap();
    for (final e in map.values) {
      final f = File(e['path'] ?? '');
      if (await f.exists()) await f.delete();
    }
    map.clear();
    await _saveDownloadMap(map);
  }

  Future<List<Map<String, String>>> getAllDownloaded() async {
    final map = await _getDownloadMap();
    final result = <Map<String, String>>[];
    final stale = <String>[];
    for (final e in map.entries) {
      final f = File(e.value['path'] ?? '');
      if (f.existsSync() && f.lengthSync() > 0) {
        result.add({
          'url': e.key,
          'path': e.value['path'] ?? '',
          'title': e.value['title'] ?? '',
          'reciterName': e.value['reciterName'] ?? '',
          'fileSize': e.value['fileSize'] ?? '0',
          'downloadedAt': e.value['downloadedAt'] ?? '',
        });
      } else {
        stale.add(e.key);
      }
    }
    if (stale.isNotEmpty) {
      for (final k in stale) { map.remove(k); }
      await _saveDownloadMap(map);
    }
    return result;
  }

  Future<int> getTotalSize() async {
    int total = 0;
    for (final d in await getAllDownloaded()) {
      final f = File(d['path'] ?? '');
      if (f.existsSync()) total += f.lengthSync();
    }
    return total;
  }

  Future<int> getDownloadCount() async => (await getAllDownloaded()).length;

  Future<Map<String, Map<String, String>>> _getDownloadMap() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_downloadedMapKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, Map<String, String>.from(v as Map)));
    } catch (_) {
      return {};
    }
  }

  Future<void> _saveMapping(String url, String path, String title,
      String? reciterName, int? surahNumber, int fileSize) async {
    final map = await _getDownloadMap();
    map[url] = {
      'path': path,
      'title': title,
      'reciterName': reciterName ?? '',
      'surahNumber': surahNumber != null ? '$surahNumber' : '',
      'fileSize': '$fileSize',
      'downloadedAt': DateTime.now().toIso8601String(),
    };
    await _saveDownloadMap(map);
  }

  Future<void> _saveDownloadMap(Map<String, Map<String, String>> map) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_downloadedMapKey, jsonEncode(map));
  }
}
