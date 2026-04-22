import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projet/core/constants/app_colors.dart';
import 'package:projet/core/constants/app_strings.dart';
import 'package:projet/core/constants/app_theme.dart';

/// Quick access grid for navigating to explore sub-features.
class QuickAccessGrid extends StatelessWidget {
  const QuickAccessGrid({super.key});

  static const _items = <({String label, IconData icon, String route, Color color})>[
    (label: 'المصحف', icon: Icons.menu_book_rounded, route: '/explore/mushaf', color: Color(0xFF0D7C66)),
    (label: 'الأذكار', icon: Icons.auto_awesome, route: '/explore/azkar', color: Color(0xFF7B4FC4)),
    (label: 'الأدعية', icon: Icons.front_hand_rounded, route: '/explore/duas', color: Color(0xFF1565C0)),
    (label: 'القرآن', icon: Icons.format_list_numbered_rounded, route: '/explore/surah-index', color: Color(0xFFD4A017)),
    (label: 'ليلة القدر', icon: Icons.nightlight_round, route: '/explore/laylat-alqadr', color: Color(0xFF4A148C)),
    (label: 'الراديو', icon: Icons.radio_rounded, route: '/player', color: Color(0xFFB71C1C)),
  ];

  @override
  Widget build(BuildContext context) {
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
              const Icon(Icons.grid_view_rounded,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(AppStrings.quickAccess,
                  style: AppTheme.labelMd
                      .copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.1,
            children: _items.map((item) {
              return GestureDetector(
                onTap: () => context.push(item.route),
                child: Container(
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: item.color.withValues(alpha: 0.15)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item.icon,
                          color: item.color, size: 26),
                      const SizedBox(height: 6),
                      Text(
                        item.label,
                        style: AppTheme.labelSm.copyWith(
                          color: item.color,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
