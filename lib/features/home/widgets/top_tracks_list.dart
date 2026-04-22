import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:projet/core/constants/app_colors.dart';
import 'package:projet/core/constants/app_strings.dart';
import 'package:projet/core/constants/app_theme.dart';
import 'package:projet/features/home/providers/stats_provider.dart';

/// Displays the top 5 most-played tracks.
class TopTracksList extends ConsumerWidget {
  const TopTracksList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up_rounded,
                  color: AppColors.tertiary, size: 18),
              const SizedBox(width: 8),
              Text(AppStrings.topTracks,
                  style: AppTheme.labelMd
                      .copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          statsAsync.when(
            data: (stats) {
              if (stats.topTracks.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(AppStrings.noTracksYet,
                        style: AppTheme.bodySm
                            .copyWith(color: AppColors.onSurfaceVariant)),
                  ),
                );
              }
              return Column(
                children: stats.topTracks.take(5).toList().asMap().entries.map((entry) {
                  final i = entry.key;
                  final track = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(bottom: i < 4 ? 8 : 0),
                    child: Row(
                      children: [
                        // Rank badge
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i == 0
                                ? AppColors.tertiary.withValues(alpha: 0.15)
                                : AppColors.surfaceContainer,
                          ),
                          child: Center(
                            child: Text(
                              '${i + 1}',
                              style: AppTheme.labelSm.copyWith(
                                color: i == 0
                                    ? AppColors.tertiary
                                    : AppColors.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            track.trackTitle,
                            style: AppTheme.bodySm.copyWith(fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${track.playCount}×',
                          style: AppTheme.labelSm.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.primary),
            ),
            error: (_, __) =>
                Text(AppStrings.apiError, style: AppTheme.bodySm),
          ),
        ],
      ),
    );
  }
}
