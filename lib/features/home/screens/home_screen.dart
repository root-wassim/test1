import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:projet/core/constants/app_colors.dart';
import 'package:projet/core/constants/app_strings.dart';
import 'package:projet/core/constants/app_theme.dart';
import 'package:projet/features/auth/providers/auth_provider.dart';
import 'package:projet/features/home/providers/goal_provider.dart';
import 'package:projet/features/home/providers/stats_provider.dart';
import 'package:projet/features/home/widgets/listening_histogram.dart';
import 'package:projet/features/home/widgets/monthly_goal_widget.dart';
import 'package:projet/features/home/widgets/prayer_times_card.dart';
import 'package:projet/features/home/widgets/quick_access_grid.dart';
import 'package:projet/features/home/widgets/top_tracks_list.dart';
import 'package:projet/features/home/widgets/welcome_banner.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getUserName(WidgetRef ref) {
    final user = ref.watch(authStateChangesProvider).asData?.value;
    if (user == null) return 'Utilisateur';
    final name = user.displayName;
    if (name != null && name.isNotEmpty) return name;
    final email = user.email ?? '';
    return email.split('@').first;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(monthlyGoalLoaderProvider);
    final stats = ref.watch(statsProvider);
    final goalHours = ref.watch(monthlyGoalProvider);
    final totalMinutes = stats.value?.totalMinutes ?? 0;
    final goalMinutes = goalHours * 60;
    final progress = goalMinutes == 0 ? 0.0 : (totalMinutes / goalMinutes).clamp(0.0, 1.0);
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Row(
                children: [
                  const Icon(Icons.security, color: AppColors.primary, size: 22),
                  const SizedBox(width: 8),
                  Text(AppStrings.brandName, style: AppTheme.headlineSm.copyWith(color: AppColors.primary, fontSize: 16, letterSpacing: 1)),
                ],
              ),
              const SizedBox(height: 16),

              // ── Welcome ──
              const WelcomeBanner(),
              const SizedBox(height: 20),

              // ── 🕌 Prayer Times ──
              const PrayerTimesCard(),
              const SizedBox(height: 16),

              // ── 🚀 Quick Access Grid ──
              const QuickAccessGrid(),
              const SizedBox(height: 20),

              // ── Total Listening Time ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.cardDecoration(color: AppColors.surfaceContainer),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.play_circle_filled, color: AppColors.primary, size: 28),
                    const SizedBox(height: 12),
                    Text('TEMPS D\'ÉCOUTE TOTAL', style: AppTheme.labelMd.copyWith(fontSize: 10)),
                    const SizedBox(height: 8),
                    Text.rich(
                      TextSpan(children: [
                        TextSpan(text: '$h', style: AppTheme.displayLg),
                        TextSpan(text: 'h ', style: AppTheme.displayLg.copyWith(fontSize: 24, fontWeight: FontWeight.w400)),
                        TextSpan(text: m.toString().padLeft(2, '0'), style: AppTheme.displayLg),
                        TextSpan(text: 'm', style: AppTheme.displayLg.copyWith(fontSize: 24, fontWeight: FontWeight.w400)),
                      ]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Monthly Goal ──
              const MonthlyGoalWidget(),
              const SizedBox(height: 16),

              // ── Listening Histogram ──
              const ListeningHistogram(),
              const SizedBox(height: 16),

              // ── Top Tracks ──
              const TopTracksList(),
            ],
          ),
        ),
      ),
    );
  }
}
