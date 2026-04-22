import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:projet/core/constants/app_colors.dart';
import 'package:projet/core/constants/app_strings.dart';
import 'package:projet/core/constants/app_theme.dart';
import 'package:projet/features/explore/models/dua_model.dart';
import 'package:projet/features/explore/providers/explore_providers.dart';
import 'package:projet/shared/widgets/loading_indicator.dart';

class DuasScreen extends ConsumerWidget {
  const DuasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duasData = ref.watch(duasProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: duasData.when(
          data: (categories) => _DuasContent(categories: categories),
          loading: () => const LoadingIndicator(),
          error: (e, _) => Center(child: Text(AppStrings.apiError, style: AppTheme.bodyMd.copyWith(color: AppColors.error))),
        ),
      ),
    );
  }
}

class _DuasContent extends StatefulWidget {
  const _DuasContent({required this.categories});
  final List<DuaCategory> categories;

  @override
  State<_DuasContent> createState() => _DuasContentState();
}

class _DuasContentState extends State<_DuasContent> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
              Text(AppStrings.duasTitle, style: AppTheme.headlineSm.copyWith(fontSize: 18)),
            ],
          ),
        ),

        // ── Tabs ──
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.onSurfaceVariant,
            labelStyle: AppTheme.labelSm.copyWith(fontWeight: FontWeight.w700, fontSize: 12),
            unselectedLabelStyle: AppTheme.labelSm.copyWith(fontWeight: FontWeight.w500, fontSize: 12),
            dividerColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            tabs: widget.categories.map((c) => Tab(text: '${c.icon} ${c.label}')).toList(),
          ),
        ),

        // ── Content ──
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: widget.categories.map((cat) {
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: cat.items.length,
                itemBuilder: (_, i) {
                  final dua = cat.items[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.08)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary.withValues(alpha: 0.12),
                              ),
                              child: Center(
                                child: Text(
                                  '${dua.id}',
                                  style: AppTheme.labelSm.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 11),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          dua.text,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 17,
                            color: AppColors.onSurface,
                            height: 1.9,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
