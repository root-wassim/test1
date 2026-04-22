import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:projet/core/constants/app_colors.dart';
import 'package:projet/core/constants/app_strings.dart';
import 'package:projet/core/constants/app_theme.dart';
import 'package:projet/features/home/providers/goal_provider.dart';
import 'package:projet/features/home/providers/stats_provider.dart';

class MonthlyGoalWidget extends ConsumerWidget {
  const MonthlyGoalWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalHours = ref.watch(monthlyGoalProvider); // int (hours)
    final statsAsync = ref.watch(statsProvider);

    final totalMinutes = statsAsync.when(
      data: (s) => s.totalMinutes.toDouble(),
      loading: () => 0.0,
      error: (_, __) => 0.0,
    );
    final goalMinutes = goalHours * 60;
    final progress =
        goalMinutes > 0 ? (totalMinutes / goalMinutes).clamp(0.0, 1.0) : 0.0;
    final percentage = (progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border:
            Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.emoji_events_rounded,
                  color: AppColors.tertiary, size: 18),
              const SizedBox(width: 8),
              Text(AppStrings.monthlyGoal,
                  style:
                      AppTheme.labelMd.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              // Goal dropdown
              _GoalDropdown(currentGoalHours: goalHours),
            ],
          ),
          const SizedBox(height: 16),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage >= 100 ? AppColors.tertiary : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(totalMinutes / 60).toStringAsFixed(1)}h / ${goalHours}h',
                style: AppTheme.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant, fontSize: 12),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: percentage >= 100
                      ? AppColors.tertiary.withValues(alpha: 0.12)
                      : AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$percentage%',
                  style: AppTheme.labelSm.copyWith(
                    color: percentage >= 100
                        ? AppColors.tertiary
                        : AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalDropdown extends ConsumerWidget {
  const _GoalDropdown({required this.currentGoalHours});
  final int currentGoalHours;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final options = [5, 10, 15, 20, 30, 50];

    return PopupMenuButton<int>(
      onSelected: (hours) {
        ref.read(goalStorageProvider).setGoal(ref, hours);
      },
      itemBuilder: (_) => options
          .map((h) => PopupMenuItem(
                value: h,
                child: Text('$h h',
                    style: AppTheme.bodyMd
                        .copyWith(color: AppColors.onSurface)),
              ))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(10),
          border:
              Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.15)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${currentGoalHours}h',
              style: AppTheme.labelSm.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.expand_more_rounded,
                color: AppColors.primary, size: 16),
          ],
        ),
      ),
    );
  }
}
