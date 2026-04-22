import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:projet/core/constants/app_colors.dart';
import 'package:projet/core/constants/app_strings.dart';
import 'package:projet/core/constants/app_theme.dart';
import 'package:projet/features/player/providers/download_provider.dart';
import 'package:projet/shared/widgets/loading_indicator.dart';

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloads = ref.watch(downloadProvider);
    final completedDownloads = downloads.entries
        .where((e) => e.value.isCompleted)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.1),
                    ),
                    child: const Icon(Icons.download_done_rounded,
                        color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(AppStrings.downloads,
                      style: AppTheme.headlineSm.copyWith(fontSize: 20)),
                  const Spacer(),
                  Text(
                    '${completedDownloads.length} ${AppStrings.tracks}',
                    style: AppTheme.labelSm
                        .copyWith(color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ── List ──
            Expanded(
              child: completedDownloads.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.cloud_download_outlined,
                              size: 56,
                              color: AppColors.onSurfaceVariant
                                  .withValues(alpha: 0.2)),
                          const SizedBox(height: 12),
                          Text(AppStrings.noDownloads,
                              style: AppTheme.bodyMd.copyWith(
                                  color: AppColors.onSurfaceVariant)),
                          const SizedBox(height: 4),
                          Text(AppStrings.downloadTracksHint,
                              style: AppTheme.bodySm.copyWith(
                                  color: AppColors.onSurfaceVariant
                                      .withValues(alpha: 0.6))),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: completedDownloads.length,
                      itemBuilder: (_, i) {
                        final entry = completedDownloads[i];
                        final surahNumber = entry.key;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: AppColors.outlineVariant
                                    .withValues(alpha: 0.08)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary
                                      .withValues(alpha: 0.1),
                                ),
                                child: Center(
                                  child: Text(
                                    '$surahNumber',
                                    style: AppTheme.labelSm.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${AppStrings.surahLabel} $surahNumber',
                                      style: AppTheme.bodyMd.copyWith(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      AppStrings.offlineAvailable,
                                      style: AppTheme.bodySm.copyWith(
                                          color: AppColors.primary,
                                          fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => ref
                                    .read(downloadProvider.notifier)
                                    .remove(surahNumber),
                                icon: const Icon(Icons.delete_outline_rounded,
                                    color: AppColors.error, size: 20),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
