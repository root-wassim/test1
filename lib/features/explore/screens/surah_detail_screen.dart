import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:projet/core/constants/app_colors.dart';
import 'package:projet/core/constants/app_strings.dart';
import 'package:projet/core/constants/app_theme.dart';
import 'package:projet/features/explore/models/surah_model.dart';
import 'package:projet/features/explore/providers/explore_providers.dart';
import 'package:projet/shared/widgets/loading_indicator.dart';

class SurahDetailScreen extends ConsumerWidget {
  const SurahDetailScreen({super.key, required this.surah});

  final SurahModel surah;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ayahData = ref.watch(ayahProvider(surah.number));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            _buildHeader(context),

            // ── Content ──
            Expanded(
              child: ayahData.when(
                data: (data) {
                  if (data.isEmpty) {
                    return Center(child: Text(AppStrings.noResults, style: AppTheme.bodyMd));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: data.length + 1, // +1 for bismillah
                    itemBuilder: (_, i) {
                      if (i == 0) return _buildBismillah();
                      final ayah = data[i - 1] as Map<String, dynamic>;
                      final text = (ayah['text'] ?? '').toString();
                      final numberInSurah = int.tryParse('${ayah['number_in_surah'] ?? i}') ?? i;
                      return _buildAyahCard(text, numberInSurah);
                    },
                  );
                },
                loading: () => const LoadingIndicator(),
                error: (e, s) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error, size: 40),
                        const SizedBox(height: 12),
                        Text(AppStrings.apiError, style: AppTheme.bodyMd.copyWith(color: AppColors.error)),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => ref.invalidate(ayahProvider(surah.number)),
                          icon: const Icon(Icons.refresh, size: 18),
                          label: Text(AppStrings.retry),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: surah.isMeccan
              ? [const Color(0xFF0D3B2E), const Color(0xFF0D7C66)]
              : [const Color(0xFF0D2B5E), const Color(0xFF1565C0)],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  surah.isMeccan ? AppStrings.meccan : AppStrings.medinan,
                  style: AppTheme.labelSm.copyWith(color: Colors.white, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            surah.nameAr,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            surah.nameEn,
            style: AppTheme.bodyMd.copyWith(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _metaBadge(Icons.format_list_numbered, '${surah.ayatCount} ${AppStrings.verses}'),
              const SizedBox(width: 16),
              _metaBadge(Icons.numbers, '${AppStrings.surahLabel} ${surah.number}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metaBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 14),
          const SizedBox(width: 6),
          Text(label, style: AppTheme.labelSm.copyWith(color: Colors.white.withValues(alpha: 0.9), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildBismillah() {
    if (surah.number == 1 || surah.number == 9) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(
        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.primary.withValues(alpha: 0.9),
          height: 2.0,
        ),
      ),
    );
  }

  Widget _buildAyahCard(String ayahText, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Ayah number badge
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.12),
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: AppTheme.labelSm.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 11),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Arabic text
          Text(
            ayahText,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurface,
              height: 2.0,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
