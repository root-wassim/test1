import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:projet/core/constants/app_colors.dart';
import 'package:projet/core/constants/app_strings.dart';
import 'package:projet/core/constants/app_theme.dart';
import 'package:projet/features/explore/providers/explore_providers.dart';

/// Compact prayer times card for the home dashboard.
class PrayerTimesCard extends ConsumerWidget {
  const PrayerTimesCard({super.key});

  static const _prayerIcons = <String, IconData>{
    'Fajr': Icons.brightness_4_rounded,
    'Sunrise': Icons.wb_twilight_rounded,
    'Dhuhr': Icons.wb_sunny_rounded,
    'Asr': Icons.sunny_snowing,
    'Maghrib': Icons.brightness_6_rounded,
    'Isha': Icons.nightlight_round,
  };

  static const _prayerLabels = <String, String>{
    'Fajr': 'الفجر',
    'Sunrise': 'الشروق',
    'Dhuhr': 'الظهر',
    'Asr': 'العصر',
    'Maghrib': 'المغرب',
    'Isha': 'العشاء',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerData = ref.watch(prayerTimesProvider);

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
          Row(
            children: [
              const Icon(Icons.mosque_rounded,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(AppStrings.prayerTimes,
                  style: AppTheme.labelMd
                      .copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              prayerData.when(
                data: (data) => Text(
                  '${data.region}, ${data.country}',
                  style: AppTheme.labelSm
                      .copyWith(color: AppColors.onSurfaceVariant, fontSize: 9),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          prayerData.when(
            data: (data) {
              final entries = data.times.entries
                  .where((e) => _prayerLabels.containsKey(e.key))
                  .toList();
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: entries.map((e) {
                  final icon = _prayerIcons[e.key] ?? Icons.access_time;
                  final label = _prayerLabels[e.key] ?? e.key;
                  return Container(
                    width: (MediaQuery.of(context).size.width - 80) / 3,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Icon(icon,
                            color: AppColors.primary.withValues(alpha: 0.7),
                            size: 16),
                        const SizedBox(height: 4),
                        Text(label,
                            style: AppTheme.labelSm.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 9)),
                        const SizedBox(height: 2),
                        Text(e.value,
                            style: AppTheme.bodyMd.copyWith(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.w700,
                                fontSize: 13)),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.primary),
              ),
            ),
            error: (_, __) => Text(
              AppStrings.prayerTimesUnavailable,
              style:
                  AppTheme.bodySm.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
