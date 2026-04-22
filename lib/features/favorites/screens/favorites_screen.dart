import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:projet/core/constants/app_colors.dart';
import 'package:projet/core/constants/app_strings.dart';
import 'package:projet/core/constants/app_theme.dart';
import 'package:projet/features/favorites/providers/favorites_provider.dart';
import 'package:projet/shared/widgets/loading_indicator.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesProvider);

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
                      color: AppColors.error.withValues(alpha: 0.1),
                    ),
                    child: const Icon(Icons.favorite_rounded,
                        color: AppColors.error, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(AppStrings.favorites,
                      style: AppTheme.headlineSm.copyWith(fontSize: 20)),
                  const Spacer(),
                  favoritesAsync.when(
                    data: (list) => Text(
                      '${list.length} ${AppStrings.tracks}',
                      style: AppTheme.labelSm
                          .copyWith(color: AppColors.onSurfaceVariant),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ── List ──
            Expanded(
              child: favoritesAsync.when(
                data: (favorites) {
                  if (favorites.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.favorite_border_rounded,
                              size: 56,
                              color: AppColors.onSurfaceVariant
                                  .withValues(alpha: 0.2)),
                          const SizedBox(height: 12),
                          Text(AppStrings.noFavorites,
                              style: AppTheme.bodyMd.copyWith(
                                  color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: favorites.length,
                    itemBuilder: (_, i) {
                      final fav = favorites[i];
                      return Dismissible(
                        key: ValueKey(fav.surahNumber),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (_) async {
                          return await ref
                              .read(favoritesProvider.notifier)
                              .removeFavorite(fav.surahNumber);
                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.fingerprint_rounded,
                                  color: AppColors.error, size: 20),
                              SizedBox(height: 2),
                              Text('🔐',
                                  style: TextStyle(fontSize: 10)),
                            ],
                          ),
                        ),
                        child: Container(
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
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF0D7C66),
                                      Color(0xFF17B169)
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '${fav.surahNumber}',
                                    style: AppTheme.labelSm.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(fav.surahName,
                                        style: AppTheme.bodyMd.copyWith(
                                            fontWeight: FontWeight.w600)),
                                    Text(fav.reciterName,
                                        style: AppTheme.bodySm.copyWith(
                                            color:
                                                AppColors.onSurfaceVariant,
                                            fontSize: 11)),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () =>
                                    context.push('/player'),
                                icon: const Icon(
                                    Icons.play_circle_rounded,
                                    color: AppColors.primary,
                                    size: 32),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const LoadingIndicator(),
                error: (e, _) => Center(
                  child: Text(AppStrings.apiError,
                      style: AppTheme.bodyMd
                          .copyWith(color: AppColors.error)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
