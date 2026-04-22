import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:projet/core/constants/app_colors.dart';
import 'package:projet/core/constants/app_strings.dart';
import 'package:projet/core/constants/app_theme.dart';
import 'package:projet/features/home/providers/stats_provider.dart';

/// Bar chart showing minutes listened per day for the current month.
class ListeningHistogram extends ConsumerWidget {
  const ListeningHistogram({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart_rounded,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(AppStrings.listeningHistogram,
                  style: AppTheme.labelMd
                      .copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: statsAsync.when(
              data: (stats) {
                final histogram = stats.monthlyMinutesByDay;
                if (histogram.isEmpty) {
                  return Center(
                    child: Text(AppStrings.noTracksYet,
                        style: AppTheme.bodySm
                            .copyWith(color: AppColors.onSurfaceVariant)),
                  );
                }

                final maxY = histogram.values
                    .fold<int>(0, (a, b) => a > b ? a : b)
                    .toDouble();

                return BarChart(
                  BarChartData(
                    maxY: maxY > 0 ? maxY * 1.2 : 60,
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => AppColors.surfaceContainer,
                        getTooltipItem: (group, _, rod, __) {
                          return BarTooltipItem(
                            '${rod.toY.toInt()} min',
                            AppTheme.labelSm
                                .copyWith(color: AppColors.primary),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          getTitlesWidget: (val, _) => Text(
                            '${val.toInt()}',
                            style: AppTheme.labelSm.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (val, _) {
                            final day = val.toInt() + 1;
                            if (day % 5 != 1 && day != 1) {
                              return const SizedBox.shrink();
                            }
                            return Text(
                              '$day',
                              style: AppTheme.labelSm.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 9,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: AppColors.outlineVariant.withValues(alpha: 0.1),
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: _buildBars(histogram),
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.primary),
              ),
              error: (_, __) => Center(
                child: Text(AppStrings.apiError,
                    style:
                        AppTheme.bodySm.copyWith(color: AppColors.error)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _buildBars(Map<int, int> histogram) {
    final now = DateTime.now();
    final daysInMonth =
        DateTime(now.year, now.month + 1, 0).day;

    return List.generate(daysInMonth, (i) {
      final day = i + 1;
      final minutes = (histogram[day] ?? 0).toDouble();
      final isToday = day == now.day;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: minutes,
            width: 6,
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(3)),
            gradient: isToday
                ? const LinearGradient(
                    colors: [AppColors.primary, AppColors.tertiary],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  )
                : LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.4),
                      AppColors.primary.withValues(alpha: 0.6),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
          ),
        ],
      );
    });
  }
}
