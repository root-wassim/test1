import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

/// Custom action IDs for controls not in the default MediaAction set.
const kSeekForward10 = 'seek_forward_10';
const kSeekBackward10 = 'seek_backward_10';

/// Bridges just_audio with audio_service to show a Spotify-style
/// media notification with full controls on Android and iOS.
///
/// Lifecycle:
/// - [playTrack] : loads URL + updates MediaItem + plays
/// - Notification controls call the overridden methods directly
/// - User swipes away notification → [onNotificationDeleted] → stop()
class QuranAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();

  /// Expose the internal player for stream subscriptions in the UI.
  AudioPlayer get player => _player;

  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;

  QuranAudioHandler() {
    _init();
  }

  void _init() {
    // ── Sync playback state → notification ──
    _playerStateSub = _player.playerStateStream.listen(_broadcastPlaybackState);

    // ── Sync position → notification progress bar ──
    _positionSub = _player.positionStream.listen((position) {
      _broadcastPlaybackState(_player.playerState, position: position);
    });

    // ── Sync duration → media item ──
    _durationSub = _player.durationStream.listen((duration) {
      final current = mediaItem.value;
      if (current != null && duration != null) {
        mediaItem.add(current.copyWith(duration: duration));
      }
    });
  }

  // ── Public API used by PlayerController ──

  /// Load and play a new track. Updates the media notification.
  Future<void> playTrack({
    required String url,
    required String title,
    required String reciterName,
    String? localPath,
  }) async {
    // Update the notification metadata immediately
    final item = MediaItem(
      id: url,
      title: title,
      artist: reciterName,
      album: 'QuranPlay',
      artUri: Uri.parse('https://raw.githubusercontent.com/sonergonul/quran-json/master/quran_icon.png'), // Default elegant icon
    );
    mediaItem.add(item);

    // Load the audio source
    if (localPath != null) {
      await _player.setFilePath(localPath);
    } else {
      await _player.setUrl(url);
    }
    await _player.play();
  }

  // ── AudioHandler overrides (called by notification buttons) ──

  @override
  Future<void> play() async {
    await _player.play();
  }

  @override
  Future<void> pause() async {
    await _player.pause();
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    // Clear playback state
    playbackState.add(playbackState.value.copyWith(
      playing: false,
      processingState: AudioProcessingState.idle,
    ));
    // Clear the media item so the notification dismisses cleanly
    mediaItem.add(null);
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  @override
  Future<void> rewind() async {
    // ← 10s button in notification
    final newPos = _player.position - const Duration(seconds: 10);
    await _player.seek(newPos < Duration.zero ? Duration.zero : newPos);
  }

  @override
  Future<void> fastForward() async {
    // → 10s button in notification
    final newPos = _player.position + const Duration(seconds: 10);
    final dur = _player.duration ?? Duration.zero;
    await _player.seek(newPos > dur ? dur : newPos);
  }

  @override
  Future<void> skipToNext() async {
    _skipStreamController.add('skip_next');
  }

  @override
  Future<void> skipToPrevious() async {
    _skipStreamController.add('skip_previous');
  }

  @override
  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {
    switch (name) {
      case kSeekForward10:
        await fastForward();
        break;
      case kSeekBackward10:
        await rewind();
        break;
    }
  }

  @override
  Future<void> onNotificationDeleted() async {
    // User swiped away the notification → stop everything
    await stop();
  }

  @override
  Future<void> onTaskRemoved() async {
    // App killed from Task Manager → stop everything
    await stop();
  }

  // ── Skip event stream (listened to by PlayerScreen) ──
  final _skipStreamController = StreamController<String>.broadcast();
  Stream<String> get skipStream => _skipStreamController.stream;

  // ── Playback state broadcast ──
  void _broadcastPlaybackState(PlayerState state, {Duration? position}) {
    final playing = state.playing;
    final processingState = _mapProcessingState(state.processingState);

    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          MediaControl.rewind,
          playing ? MediaControl.pause : MediaControl.play,
          MediaControl.fastForward,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
          MediaAction.skipToNext,
          MediaAction.skipToPrevious,
          MediaAction.rewind,
          MediaAction.fastForward,
        },
        androidCompactActionIndices: const [1, 2, 3], // -10s | play/pause | +10s
        processingState: processingState,
        playing: playing,
        updatePosition: position ?? _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: 0,
      ),
    );
  }

  AudioProcessingState _mapProcessingState(ProcessingState state) {
    switch (state) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

  /// Clean up resources when the handler is no longer needed.
  Future<void> cleanup() async {
    await _playerStateSub?.cancel();
    await _positionSub?.cancel();
    await _durationSub?.cancel();
    await _skipStreamController.close();
    await _player.dispose();
  }
}
