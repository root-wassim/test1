import 'package:flutter/material.dart';
import 'package:projet/core/constants/app_colors.dart';
import 'package:projet/core/constants/app_theme.dart';

/// A track list tile with play, favorite, and download actions.
class TrackListTile extends StatelessWidget {
  const TrackListTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.trackNumber,
    required this.isPlaying,
    required this.isFavorite,
    required this.isDownloaded,
    required this.onPlay,
    required this.onFavorite,
    required this.onDownload,
  });

  final String title;
  final String subtitle;
  final int trackNumber;
  final bool isPlaying;
  final bool isFavorite;
  final bool isDownloaded;
  final VoidCallback onPlay;
  final VoidCallback onFavorite;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPlay,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isPlaying
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isPlaying
                ? AppColors.primary.withValues(alpha: 0.25)
                : AppColors.outlineVariant.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            // Track number / playing indicator
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isPlaying
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.surfaceContainer,
              ),
              child: Center(
                child: isPlaying
                    ? const Icon(Icons.equalizer_rounded,
                        color: AppColors.primary, size: 18)
                    : Text(
                        '$trackNumber',
                        style: AppTheme.labelSm.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // Title + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.bodyMd.copyWith(
                      fontWeight: isPlaying ? FontWeight.w700 : FontWeight.w500,
                      color: isPlaying ? AppColors.primary : AppColors.onSurface,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTheme.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Actions
            IconButton(
              onPressed: onFavorite,
              icon: Icon(
                isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: isFavorite ? AppColors.error : AppColors.onSurfaceVariant,
                size: 20,
              ),
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              onPressed: onDownload,
              icon: Icon(
                isDownloaded
                    ? Icons.download_done_rounded
                    : Icons.download_rounded,
                color: isDownloaded
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
                size: 20,
              ),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}
