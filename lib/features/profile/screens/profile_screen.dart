import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:projet/core/constants/app_colors.dart';
import 'package:projet/core/constants/app_strings.dart';
import 'package:projet/core/constants/app_theme.dart';
import 'package:projet/features/auth/providers/auth_provider.dart';
import 'package:projet/features/home/providers/stats_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final profileAsync = ref.watch(userProfileProvider);
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // ── Avatar ──
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.vaultGlow,
                  boxShadow: AppTheme.vaultGlowShadow,
                ),
                child: Center(
                  child: Text(
                    (user?.displayName?.isNotEmpty == true
                            ? user!.displayName![0]
                            : 'E')
                        .toUpperCase(),
                    style: AppTheme.headlineMd
                        .copyWith(color: AppColors.onPrimary, fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Name ──
              profileAsync.when(
                data: (profile) {
                  final name = profile?['fullName'] ??
                      user?.displayName ??
                      AppStrings.guest;
                  return Text(name.toString(),
                      style: AppTheme.headlineSm.copyWith(fontSize: 20));
                },
                loading: () => Text(user?.displayName ?? '',
                    style: AppTheme.headlineSm),
                error: (_, __) => Text(user?.displayName ?? '',
                    style: AppTheme.headlineSm),
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? '',
                style: AppTheme.bodySm
                    .copyWith(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 24),

              // ── Stats Cards ──
              statsAsync.when(
                data: (stats) => Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.headphones_rounded,
                        label: AppStrings.totalListening,
                        value:
                            '${(stats.totalMinutes / 60).toStringAsFixed(1)}h',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.calendar_month_rounded,
                        label: AppStrings.daysActive,
                        value: '${stats.monthlyMinutesByDay.length}',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.trending_up_rounded,
                        label: AppStrings.topTracks,
                        value: '${stats.topTracks.length}',
                      ),
                    ),
                  ],
                ),
                loading: () => const SizedBox(height: 80),
                error: (_, __) => const SizedBox(height: 80),
              ),
              const SizedBox(height: 24),

              // ── Settings Options ──
              _SettingTile(
                icon: Icons.person_outline_rounded,
                label: AppStrings.editProfile,
                onTap: () {},
              ),
              _SettingTile(
                icon: Icons.shield_outlined,
                label: AppStrings.securitySettings,
                onTap: () {},
              ),
              _SettingTile(
                icon: Icons.info_outline_rounded,
                label: AppStrings.about,
                onTap: () {},
              ),
              const SizedBox(height: 16),

              // ── Logout ──
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(authServiceProvider).logout();
                    if (context.mounted) context.go('/login');
                  },
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: Text(AppStrings.logout),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(
                        color: AppColors.error.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 8),
          Text(value,
              style: AppTheme.headlineSm
                  .copyWith(fontSize: 18, color: AppColors.primary)),
          const SizedBox(height: 2),
          Text(label,
              style: AppTheme.labelSm
                  .copyWith(color: AppColors.onSurfaceVariant, fontSize: 9),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile(
      {required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.onSurfaceVariant, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: AppTheme.bodyMd.copyWith(fontSize: 14)),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.3),
                size: 20),
          ],
        ),
      ),
    );
  }
}
