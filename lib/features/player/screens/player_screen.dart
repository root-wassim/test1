import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:projet/core/constants/app_colors.dart';
import 'package:projet/core/constants/app_strings.dart';
import 'package:projet/core/constants/app_theme.dart';
import 'package:projet/features/favorites/providers/favorites_provider.dart';
import 'package:projet/features/player/providers/download_provider.dart';
import 'package:projet/features/player/widgets/player_controls.dart';
import 'package:projet/features/player/widgets/track_list_tile.dart';
import 'package:projet/features/player/providers/player_provider.dart';
import 'package:projet/features/player/providers/reciters_provider.dart';
import 'package:projet/features/player/models/reciter_model.dart';
import 'package:projet/features/player/models/track_model.dart';
import 'package:projet/shared/widgets/loading_indicator.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  int? _selectedReciterId;
  String? _error;
  bool _repeat = false;
  String _reciterSearch = '';
  String _surahSearch = '';

  // Local state for current playback
  String _currentTitle = '';
  String _currentReciterName = '';
  bool _isPlaying = false;

  // Track list for skip prev/next
  List<TrackModel> _currentTrackList = [];
  int _currentTrackIndex = -1;

  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<ProcessingState>? _processingStateSub;
  StreamSubscription<String>? _skipStreamSub;

  @override
  void initState() {
    super.initState();
    // Listen to player state changes to keep UI in sync
    final player = ref.read(audioPlayerProvider);
    _isPlaying = player.playing;
    _currentTitle = ref.read(playerControllerProvider).currentTitle;

    _playerStateSub = player.playerStateStream.listen((state) {
      if (mounted) {
        setState(() => _isPlaying = state.playing);
      }
    });

    // Listen for track completion to auto-advance
    _processingStateSub = player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed && mounted) {
        _onTrackCompleted();
      }
    });

    // Listen for skip commands from the notification bar
    final handler = ref.read(audioHandlerProvider);
    _skipStreamSub = handler.skipStream.listen((action) {
      if (action == 'skip_next') _skipNext();
      if (action == 'skip_previous') _skipPrevious();
    });
  }

  @override
  void dispose() {
    _playerStateSub?.cancel();
    _processingStateSub?.cancel();
    _skipStreamSub?.cancel();
    super.dispose();
  }

  void _onTrackCompleted() {
    if (_repeat) {
      // Replay current track
      final player = ref.read(audioPlayerProvider);
      player.seek(Duration.zero);
      player.play();
      return;
    }
    // Auto-advance to next track
    _skipNext();
  }

  Future<void> _play(String title, String url, {
    int? index,
    List<TrackModel>? trackList,
    String reciterName = '',
  }) async {
    try {
      if (trackList != null) _currentTrackList = trackList;
      if (index != null) _currentTrackIndex = index;
      _currentReciterName = reciterName;
      await ref.read(playerControllerProvider).play(
        url: url,
        title: title,
        reciterName: reciterName,
      );
      if (mounted) {
        setState(() {
          _currentTitle = title;
          _error = null;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _error = AppStrings.playbackError);
    }
  }

  Future<void> _skipNext() async {
    if (_currentTrackList.isEmpty || _currentTrackIndex < 0) return;
    final nextIndex = _currentTrackIndex + 1;
    if (nextIndex >= _currentTrackList.length) return;
    final track = _currentTrackList[nextIndex];
    if (track.audioUrl.isEmpty) return;
    await _play(track.title, track.audioUrl,
        index: nextIndex, reciterName: _currentReciterName);
  }

  Future<void> _skipPrevious() async {
    // If we're more than 3s into the track, restart it instead of going to previous
    final player = ref.read(audioPlayerProvider);
    if (player.position.inSeconds > 3) {
      await player.seek(Duration.zero);
      return;
    }
    if (_currentTrackList.isEmpty || _currentTrackIndex <= 0) return;
    final prevIndex = _currentTrackIndex - 1;
    final track = _currentTrackList[prevIndex];
    if (track.audioUrl.isEmpty) return;
    await _play(track.title, track.audioUrl,
        index: prevIndex, reciterName: _currentReciterName);
  }

  void _seekForward() {
    final player = ref.read(audioPlayerProvider);
    final pos = player.position;
    final duration = player.duration ?? Duration.zero;
    final newPos = pos + const Duration(seconds: 10);
    player.seek(newPos > duration ? duration : newPos);
  }

  void _seekBackward() {
    final player = ref.read(audioPlayerProvider);
    final pos = player.position;
    final newPos = pos - const Duration(seconds: 10);
    player.seek(newPos < Duration.zero ? Duration.zero : newPos);
  }

  Future<void> _togglePlayPause() async {
    final player = ref.read(audioPlayerProvider);
    if (player.playing) {
      await ref.read(playerControllerProvider).pause();
    } else {
      // If there's a loaded source, resume. Otherwise do nothing.
      if (player.duration != null) {
        await player.play();
      } else if (_currentTrackList.isNotEmpty && _currentTrackIndex >= 0) {
        // Re-play the current track
        final track = _currentTrackList[_currentTrackIndex];
        if (track.audioUrl.isNotEmpty) {
          await _play(track.title, track.audioUrl, index: _currentTrackIndex);
        }
      }
    }
  }

  Future<void> _addFavorite(String title, String audioUrl) async {
    try {
      await ref.read(favoritesProvider.notifier).addFavorite(
        FavoriteTrack(
          surahNumber: _currentTrackIndex + 1,
          surahName: title,
          reciterName: _currentReciterName,
          audioUrl: audioUrl,
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.favorite, color: Colors.redAccent, size: 16),
                const SizedBox(width: 8),
                Text(AppStrings.addedToFavorites),
              ],
            ),
            backgroundColor: AppColors.surfaceContainerHighest,
          ),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _error = AppStrings.favoriteError);
    }
  }


  Future<void> _downloadTrack(TrackModel track, String reciterName) async {
    final surahNum = int.tryParse(track.title.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final url = track.audioUrl;
    if (url.isEmpty) return;

    final downloads = ref.read(downloadProvider);
    if (downloads[surahNum]?.isDownloading ?? false) return;
    if (downloads[surahNum]?.isCompleted ?? false) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.alreadyDownloaded),
            backgroundColor: AppColors.surfaceContainerHighest,
          ),
        );
      }
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.downloadStarted),
          backgroundColor: AppColors.surfaceContainerHighest,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    try {
      await ref.read(downloadProvider.notifier).download(surahNum, url);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.download_done_rounded, color: AppColors.primary, size: 18),
                const SizedBox(width: 10),
                Text(AppStrings.downloadComplete),
              ],
            ),
            backgroundColor: AppColors.surfaceContainerHighest,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.downloadError} ($e)'),
            backgroundColor: AppColors.errorContainer,
          ),
        );
      }
    }
  }


  // ── Compact Now Playing Banner (single-row, minimal height) ──
  Widget _buildCompactNowPlayingBanner(String title, String reciterName) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 2, 16, 2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        color: AppColors.surfaceContainerLow,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          // Music icon bubble
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: AppTheme.vaultGlow,
            ),
            child: const Icon(Icons.music_note, color: AppColors.onPrimary, size: 16),
          ),
          const SizedBox(width: 10),
          // Title + reciter (compact, one line each)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTheme.bodyMd.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  reciterName,
                  style: AppTheme.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // VAULTED badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: AppColors.primary.withValues(alpha: 0.12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified, color: AppColors.primary, size: 11),
                const SizedBox(width: 3),
                Text(
                  'VAULTED',
                  style: AppTheme.labelSm.copyWith(color: AppColors.primary, fontSize: 8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Reciter Selector ──
  Widget _buildReciterSelector(List<ReciterModel> allReciters, ReciterModel selected) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 2),
      child: GestureDetector(
        onTap: () => _openReciterPicker(allReciters),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.15),
                ),
                child: const Icon(Icons.person, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.reciters,
                      style: AppTheme.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      selected.name,
                      style: AppTheme.bodyMd.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Surah Search Bar ──
  Widget _buildSurahSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 2),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          onChanged: (v) => setState(() => _surahSearch = v),
          style: AppTheme.bodyMd.copyWith(color: AppColors.onSurface, fontSize: 13),
          decoration: InputDecoration(
            hintText: AppStrings.searchSurahsHint,
            hintStyle: AppTheme.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
              fontSize: 13,
            ),
            prefixIcon: Icon(Icons.search, color: AppColors.onSurfaceVariant.withValues(alpha: 0.5), size: 20),
            suffixIcon: _surahSearch.isNotEmpty
                ? GestureDetector(
                    onTap: () => setState(() => _surahSearch = ''),
                    child: Icon(Icons.close, color: AppColors.onSurfaceVariant.withValues(alpha: 0.5), size: 18),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  // ── Reciter Picker Modal ──
  void _openReciterPicker(List<ReciterModel> allReciters) {
    _reciterSearch = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final filtered = _reciterSearch.isEmpty
                ? allReciters
                : allReciters
                    .where((r) => r.name.toLowerCase().contains(_reciterSearch.toLowerCase()))
                    .toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.outlineVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings.allReciters,
                          style: AppTheme.headlineSm.copyWith(fontSize: 18),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.surfaceContainerHighest,
                            ),
                            child: const Icon(Icons.close, color: AppColors.onSurfaceVariant, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.search_off, size: 40, color: AppColors.onSurfaceVariant.withValues(alpha: 0.3)),
                                const SizedBox(height: 8),
                                Text(AppStrings.noResults, style: AppTheme.bodyMd),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: filtered.length,
                            itemBuilder: (_, i) {
                              final r = filtered[i];
                              final isActive = r.id == _selectedReciterId;
                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    setState(() => _selectedReciterId = r.id);
                                    Navigator.pop(ctx);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: isActive
                                          ? AppColors.primary.withValues(alpha: 0.08)
                                          : Colors.transparent,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isActive
                                                ? AppColors.primary.withValues(alpha: 0.2)
                                                : AppColors.surfaceContainerHighest,
                                          ),
                                          child: Center(
                                            child: Text(
                                              r.name.isNotEmpty ? r.name[0].toUpperCase() : '?',
                                              style: AppTheme.bodyMd.copyWith(
                                                color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Text(
                                            r.name,
                                            style: AppTheme.bodyMd.copyWith(
                                              color: isActive ? AppColors.primary : AppColors.onSurface,
                                              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                                              fontSize: 14,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (isActive)
                                          const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final recitersAsync = ref.watch(recitersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: recitersAsync.when(
          data: (reciters) {
            if (reciters.isEmpty) {
              return Center(
                child: Text(AppStrings.noReciters, style: AppTheme.bodyMd),
              );
            }

            // Select first reciter by default
            final selectedId = _selectedReciterId ?? reciters.first.id;
            if (_selectedReciterId == null) _selectedReciterId = selectedId;
            final selected = reciters.firstWhere(
              (r) => r.id == selectedId,
              orElse: () => reciters.first,
            );

            final tracksAsync = ref.watch(tracksByReciterProvider(selectedId));

            return Column(
              children: [
                // ── Header ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      const Icon(Icons.headphones_rounded,
                          color: AppColors.primary, size: 22),
                      const SizedBox(width: 8),
                      Text(AppStrings.nowStreamingSecurely,
                          style: AppTheme.labelMd.copyWith(
                              color: AppColors.primary,
                              letterSpacing: 1,
                              fontSize: 10)),
                    ],
                  ),
                ),

                // ── Now Playing ──
                if (_currentTitle.isNotEmpty)
                  _buildCompactNowPlayingBanner(
                      _currentTitle, _currentReciterName),

                // ── Controls ──
                if (_currentTitle.isNotEmpty)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: PlayerControls(
                      isPlaying: _isPlaying,
                      isLoading: false,
                      isRepeating: _repeat,
                      onPlayPause: _togglePlayPause,
                      onPrevious: _skipPrevious,
                      onNext: _skipNext,
                      onRepeat: () {
                        setState(() => _repeat = !_repeat);
                        ref.read(playerControllerProvider).setRepeat(_repeat);
                      },
                    ),
                  ),

                // ── Error ──
                if (_error != null)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.errorContainer.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppColors.error, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(_error!,
                                style: AppTheme.bodySm
                                    .copyWith(color: AppColors.error)),
                          ),
                        ],
                      ),
                    ),
                  ),

                // ── Reciter Selector ──
                _buildReciterSelector(reciters, selected),

                // ── Surah Search ──
                _buildSurahSearch(),

                // ── Track List ──
                Expanded(
                  child: tracksAsync.when(
                    data: (tracks) {
                      var filtered = tracks.toList();
                      if (_surahSearch.isNotEmpty) {
                        final q = _surahSearch.toLowerCase();
                        filtered = filtered
                            .where((t) =>
                                t.title.toLowerCase().contains(q) ||
                                t.surahNumber.toString().contains(q))
                            .toList();
                      }

                      if (filtered.isEmpty) {
                        return Center(
                          child: Text(AppStrings.noResults,
                              style: AppTheme.bodyMd),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final track = filtered[i];
                          final isCurrent = track.title == _currentTitle;
                          return TrackListTile(
                            title: track.title,
                            subtitle: selected.name,
                            trackNumber: track.surahNumber,
                            isPlaying: isCurrent && _isPlaying,
                            isFavorite: ref
                                .read(favoritesProvider.notifier)
                                .isFavorite(track.surahNumber),
                            isDownloaded: ref
                                    .read(downloadProvider)[track.surahNumber]
                                    ?.isCompleted ??
                                false,
                            onPlay: () => _play(
                              track.title,
                              track.audioUrl,
                              index: tracks.indexOf(track),
                              trackList: tracks,
                              reciterName: selected.name,
                            ),
                            onFavorite: () =>
                                _addFavorite(track.title, track.audioUrl),
                            onDownload: () =>
                                _downloadTrack(track, selected.name),
                          );
                        },
                      );
                    },
                    loading: () => const LoadingIndicator(),
                    error: (e, _) => Center(
                      child: Text(AppStrings.apiError,
                          style: AppTheme.bodyMd
                              .copyWith(color: AppColors.error)),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const LoadingIndicator(),
          error: (e, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    color: AppColors.error, size: 40),
                const SizedBox(height: 12),
                Text(AppStrings.apiError,
                    style:
                        AppTheme.bodyMd.copyWith(color: AppColors.error)),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(recitersProvider),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(AppStrings.retry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
