import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:just_audio/just_audio.dart';
import '../models/track.dart';
import '../services/stats_service.dart';
import '../services/download_service.dart';

class PlayerProvider extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  Track? _current;
  List<Track> _queue = [];
  int _index = -1;
  bool _isLoading = false;
  String? _error;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isLooping = false;
  bool _isShuffled = false;
  DateTime? _playStartTime;

  Track? get current => _current;
  List<Track> get queue => _queue;
  bool get isPlaying => _player.playing;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get isLooping => _isLooping;
  bool get isShuffled => _isShuffled;
  int get currentIndex => _index;

  double get progress {
    if (_duration.inMilliseconds == 0) return 0;
    return (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0);
  }

  PlayerProvider() {
    _player.positionStream.listen((p) { _position = p; notifyListeners(); });
    _player.durationStream.listen((d) { _duration = d ?? Duration.zero; notifyListeners(); });
    _player.playerStateStream.listen((s) {
      if (s.processingState == ProcessingState.completed) _onTrackComplete();
      notifyListeners();
    });
  }

  void _onTrackComplete() {
    _recordStats();
    playNext();
  }

  void _recordStats() {
    if (_current != null && _playStartTime != null) {
      final seconds = DateTime.now().difference(_playStartTime!).inSeconds;
      if (seconds > 5) {
        StatsService.recordListening(_current!.id, _current!.title, seconds);
      }
      _playStartTime = null;
    }
  }

  Future<void> playTrack(Track track, {List<Track>? queue}) async {
    _recordStats();

    if (queue != null) _queue = List<Track>.from(queue);

    _current = track;

    _index = _queue.indexWhere((t) => t.id == track.id);
    if (_index == -1) _index = 0;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // ── Priority 1: permanent download (plays offline, zero network) ───
      final localPath = await DownloadService.getLocalPath(track.id);
      if (localPath != null) {
        await _player.setFilePath(localPath);
      } else {
        // ── Priority 2: flutter_cache_manager (caches on first play) ────
        // getSingleFile() downloads+caches the file. On repeat plays it
        // returns the locally-cached copy — enabling casual offline use.
        final file = await DefaultCacheManager().getSingleFile(track.audioUrl);
        await _player.setFilePath(file.path);
      }
      await _player.play();
      _playStartTime = DateTime.now();
    } catch (e) {
      // ── Priority 3: fallback to direct stream (online only) ─────────
      try {
        await _player.setUrl(track.audioUrl);
        await _player.play();
        _playStartTime = DateTime.now();
      } catch (_) {
        _error = 'Cannot play track. Check your internet connection.';
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  void togglePlayPause() {
    if (_player.playing) {
      _player.pause();
      _recordStats();
    } else {
      _player.play();
      _playStartTime = DateTime.now();
    }
    notifyListeners();
  }

  void playNext() {
    if (_queue.isEmpty) return;
    final next = _isShuffled
        ? Random().nextInt(_queue.length)
        : (_index + 1) % _queue.length;
    // No queue param — keep existing queue
    playTrack(_queue[next]);
  }

  void playPrevious() {
    if (_position.inSeconds > 3) { _player.seek(Duration.zero); return; }
    if (_queue.isEmpty) return;
    final prev = (_index - 1 + _queue.length) % _queue.length;
    playTrack(_queue[prev]);
  }

  void seek(double v) =>
      _player.seek(Duration(milliseconds: (v * _duration.inMilliseconds).round()));
  void toggleLoop() {
    _isLooping = !_isLooping;
    _player.setLoopMode(_isLooping ? LoopMode.one : LoopMode.off);
    notifyListeners();
  }
  void toggleShuffle() { _isShuffled = !_isShuffled; notifyListeners(); }

  @override
  void dispose() { _recordStats(); _player.dispose(); super.dispose(); }
}