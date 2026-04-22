import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:projet/core/constants/app_colors.dart';
import 'package:projet/core/constants/app_strings.dart';
import 'package:projet/core/constants/app_theme.dart';
import 'package:projet/features/explore/models/surah_model.dart';
import 'package:projet/features/explore/providers/explore_providers.dart';
import 'package:projet/shared/widgets/loading_indicator.dart';

class SurahIndexScreen extends ConsumerStatefulWidget {
  const SurahIndexScreen({super.key});

  @override
  ConsumerState<SurahIndexScreen> createState() => _SurahIndexScreenState();
}

class _SurahIndexScreenState extends ConsumerState<SurahIndexScreen> {
  String _search = '';
  String _filter = 'all'; // all, Meccan, Medinan

  @override
  Widget build(BuildContext context) {
    final surahs = ref.watch(surahsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.onSurface, size: 20),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 4),
                  Text(AppStrings.quranIndex, style: AppTheme.headlineSm.copyWith(fontSize: 18)),
                  const Spacer(),
                  Text('114 ${AppStrings.surahs}', style: AppTheme.labelSm.copyWith(color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),

            // ── Search ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  onChanged: (v) => setState(() => _search = v),
                  style: AppTheme.bodyMd.copyWith(color: AppColors.onSurface, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: AppStrings.searchSurahHint,
                    hintStyle: AppTheme.bodyMd.copyWith(color: AppColors.onSurfaceVariant.withValues(alpha: 0.5), fontSize: 13),
                    prefixIcon: Icon(Icons.search, color: AppColors.onSurfaceVariant.withValues(alpha: 0.5), size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

            // ── Filter Chips ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildChip(AppStrings.filterAll, 'all'),
                  const SizedBox(width: 8),
                  _buildChip(AppStrings.filterMeccan, 'Meccan'),
                  const SizedBox(width: 8),
                  _buildChip(AppStrings.filterMedinan, 'Medinan'),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ── List ──
            Expanded(
              child: surahs.when(
                data: (items) {
                  var filtered = items.toList();
                  if (_filter != 'all') {
                    filtered = filtered.where((s) => s.type == _filter).toList();
                  }
                  if (_search.isNotEmpty) {
                    final q = _search.toLowerCase();
                    filtered = filtered.where((s) =>
                        s.nameAr.contains(q) ||
                        s.nameEn.toLowerCase().contains(q) ||
                        '${s.number}'.contains(q)).toList();
                  }

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off, size: 40, color: AppColors.onSurfaceVariant.withValues(alpha: 0.3)),
                          const SizedBox(height: 8),
                          Text(AppStrings.noResults, style: AppTheme.bodyMd),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final s = filtered[i];
                      return _buildSurahTile(s);
                    },
                  );
                },
                loading: () => const LoadingIndicator(),
                error: (e, _) => Center(child: Text(AppStrings.apiError, style: AppTheme.bodyMd.copyWith(color: AppColors.error))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, String value) {
    final active = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? AppColors.primary.withValues(alpha: 0.4) : AppColors.outlineVariant.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          label,
          style: AppTheme.labelSm.copyWith(
            color: active ? AppColors.primary : AppColors.onSurfaceVariant,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildSurahTile(SurahModel surah) {
    return GestureDetector(
      onTap: () => context.push('/explore/surah/${surah.number}', extra: surah),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            // Number badge
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: surah.isMeccan
                    ? const LinearGradient(colors: [Color(0xFF0D7C66), Color(0xFF17B169)])
                    : const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF42A5F5)]),
              ),
              child: Center(
                child: Text(
                  '${surah.number}',
                  style: AppTheme.labelSm.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Names
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(surah.nameAr, style: AppTheme.bodyMd.copyWith(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(surah.nameEn, style: AppTheme.bodySm.copyWith(color: AppColors.onSurfaceVariant, fontSize: 12)),
                ],
              ),
            ),
            // Meta
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: surah.isMeccan
                        ? const Color(0xFF0D7C66).withValues(alpha: 0.12)
                        : const Color(0xFF1565C0).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    surah.isMeccan ? AppStrings.meccan : AppStrings.medinan,
                    style: AppTheme.labelSm.copyWith(
                      color: surah.isMeccan ? const Color(0xFF17B169) : const Color(0xFF42A5F5),
                      fontSize: 9,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text('${surah.ayatCount} ${AppStrings.verses}',
                    style: AppTheme.labelSm.copyWith(color: AppColors.onSurfaceVariant, fontSize: 10)),
              ],
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, color: AppColors.onSurfaceVariant.withValues(alpha: 0.3), size: 20),
          ],
        ),
      ),
    );
  }
}
