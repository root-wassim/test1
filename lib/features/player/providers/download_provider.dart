import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// State for a single track download.
class DownloadState {
  const DownloadState({this.progress = 0, this.isDownloading = false, this.filePath});

  final double progress; // 0.0 to 1.0
  final bool isDownloading;
  final String? filePath;

  bool get isCompleted => filePath != null && !isDownloading;

  DownloadState copyWith({double? progress, bool? isDownloading, String? filePath}) {
    return DownloadState(
      progress: progress ?? this.progress,
      isDownloading: isDownloading ?? this.isDownloading,
      filePath: filePath ?? this.filePath,
    );
  }
}

/// Manages download states for all tracks keyed by surah number.
class DownloadNotifier extends StateNotifier<Map<int, DownloadState>> {
  DownloadNotifier() : super({});

  /// Check if a track is downloaded.
  bool isDownloaded(int surahNumber) => state[surahNumber]?.isCompleted ?? false;

  /// Get the local file path for a downloaded track.
  String? getFilePath(int surahNumber) => state[surahNumber]?.filePath;

  /// Download a track from the given URL.
  Future<void> download(int surahNumber, String url) async {
    if (state[surahNumber]?.isDownloading ?? false) return;

    state = {
      ...state,
      surahNumber: const DownloadState(isDownloading: true, progress: 0),
    };

    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/audio/surah_$surahNumber.mp3';
      final file = File(filePath);

      // Create directory if needed
      await file.parent.create(recursive: true);

      // Check if already downloaded
      if (await file.exists()) {
        state = {
          ...state,
          surahNumber: DownloadState(filePath: filePath),
        };
        return;
      }

      // Download with progress
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        state = {
          ...state,
          surahNumber: DownloadState(filePath: filePath),
        };
      } else {
        state = {...state, surahNumber: const DownloadState()};
      }
    } catch (_) {
      state = {...state, surahNumber: const DownloadState()};
    }
  }

  /// Remove a downloaded file.
  Future<void> remove(int surahNumber) async {
    final path = state[surahNumber]?.filePath;
    if (path != null) {
      final file = File(path);
      if (await file.exists()) await file.delete();
    }
    state = {...state, surahNumber: const DownloadState()};
  }

  /// Scan the downloads directory and populate state from existing files.
  Future<void> scanExisting() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final audioDir = Directory('${dir.path}/audio');
      if (!await audioDir.exists()) return;

      final files = audioDir.listSync().whereType<File>();
      for (final file in files) {
        final name = file.path.split('/').last;
        final match = RegExp(r'surah_(\d+)\.mp3').firstMatch(name);
        if (match != null) {
          final num = int.tryParse(match.group(1)!);
          if (num != null) {
            state = {
              ...state,
              num: DownloadState(filePath: file.path),
            };
          }
        }
      }
    } catch (_) {}
  }
}

final downloadProvider =
    StateNotifierProvider<DownloadNotifier, Map<int, DownloadState>>(
  (ref) => DownloadNotifier()..scanExisting(),
);
