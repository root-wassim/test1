import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:projet/core/services/download_service.dart';
import 'package:projet/core/services/quran_audio_handler.dart';
import 'package:projet/features/home/providers/stats_provider.dart';

/// ── Singleton audio handler (audio_service bridge) ──
/// Initialized by main.dart via AudioService.init() before the app starts.
/// We expose it through a Riverpod provider so any widget can access it.
final audioHandlerProvider = Provider<QuranAudioHandler>((ref) {
  throw UnimplementedError(
    'audioHandlerProvider must be overridden in main.dart via ProviderScope.',
  );
});

/// Expose the underlying AudioPlayer from the handler for stream subscriptions.
final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  return ref.watch(audioHandlerProvider).player;
});

/// ── Player Controller ──
/// All playback commands go through QuranAudioHandler (which forwards to
/// just_audio AND keeps the notification in sync).
class PlayerController {
  PlayerController(this.ref);

  final Ref ref;
  String _currentTitle = '';
  bool _isPlayingOffline = false;

  QuranAudioHandler get _handler => ref.read(audioHandlerProvider);

  /// Play a track. Automatically uses local file if downloaded, else streams.
  /// Also updates the media notification with title + reciterName.
  Future<void> play({
    required String url,
    required String title,
    String reciterName = '',
  }) async {
    _currentTitle = title;
    await ref.read(statsProvider.notifier).startSession(title);

    // Check for offline file first
    final downloadService = DownloadService();
    final localPath = await downloadService.getLocalPath(url);
    _isPlayingOffline = localPath != null;

    // Play from local or remote
    final source = localPath ?? url;
    await _handler.playTrack(
      url: source,
      title: title,
      reciterName: reciterName,
    );
  }

  Future<void> pause() async {
    await _handler.pause();
    await ref.read(statsProvider.notifier).stopSession();
  }

  Future<void> setRepeat(bool repeat) async {
    await _handler.player.setLoopMode(repeat ? LoopMode.one : LoopMode.off);
  }

  String get currentTitle => _currentTitle;

  /// Whether the current track is playing from a local offline file.
  bool get isPlayingOffline => _isPlayingOffline;
}

final playerControllerProvider = Provider<PlayerController>(
  (ref) => PlayerController(ref),
);
