import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:projet/core/constants/app_colors.dart';
import 'package:projet/core/constants/app_strings.dart';
import 'package:projet/core/constants/app_theme.dart';
import 'package:projet/features/explore/models/azkar_model.dart';
import 'package:projet/features/explore/providers/explore_providers.dart';
import 'package:projet/shared/widgets/loading_indicator.dart';

class AzkarScreen extends ConsumerWidget {
  const AzkarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final azkarData = ref.watch(azkarProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: azkarData.when(
          data: (categories) => _AzkarContent(categories: categories),
          loading: () => const LoadingIndicator(),
          error: (e, _) => Center(child: Text(AppStrings.apiError, style: AppTheme.bodyMd.copyWith(color: AppColors.error))),
        ),
      ),
    );
  }
}

class _AzkarContent extends StatefulWidget {
  const _AzkarContent({required this.categories});
  final List<AzkarCategory> categories;

  @override
  State<_AzkarContent> createState() => _AzkarContentState();
}

class _AzkarContentState extends State<_AzkarContent> with SingleTickerProviderStateMixin {
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
              Text(AppStrings.azkarTitle, style: AppTheme.headlineSm.copyWith(fontSize: 18)),
              const Spacer(),
              Text('${widget.categories.length} ${AppStrings.categoriesLabel}',
                  style: AppTheme.labelSm.copyWith(color: AppColors.onSurfaceVariant)),
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
            children: widget.categories.map((cat) => _AzkarCategoryView(items: cat.items)).toList(),
          ),
        ),
      ],
    );
  }
}

class _AzkarCategoryView extends StatefulWidget {
  const _AzkarCategoryView({required this.items});
  final List<AzkarItem> items;

  @override
  State<_AzkarCategoryView> createState() => _AzkarCategoryViewState();
}

class _AzkarCategoryViewState extends State<_AzkarCategoryView> with AutomaticKeepAliveClientMixin {
  late List<int> _remaining;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _remaining = widget.items.map((e) => e.count).toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: widget.items.length,
      itemBuilder: (_, i) {
        final item = widget.items[i];
        final remaining = _remaining[i];
        final done = remaining <= 0;
        return GestureDetector(
          onTap: done
              ? null
              : () => setState(() => _remaining[i] = _remaining[i] - 1),
          child: AnimatedOpacity(
            opacity: done ? 0.4 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: done ? AppColors.surfaceContainerLow : AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: done
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : AppColors.outlineVariant.withValues(alpha: 0.08),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Text
                  Text(
                    item.text,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 17,
                      color: done ? AppColors.onSurfaceVariant : AppColors.onSurface,
                      height: 1.9,
                      decoration: done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Counter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (done)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle, color: AppColors.primary, size: 14),
                              const SizedBox(width: 4),
                              Text(AppStrings.completed, style: AppTheme.labelSm.copyWith(color: AppColors.primary, fontSize: 10)),
                            ],
                          ),
                        )
                      else
                        Text(
                          AppStrings.tapToCount,
                          style: AppTheme.labelSm.copyWith(color: AppColors.onSurfaceVariant, fontSize: 10),
                        ),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: done
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : AppColors.primary.withValues(alpha: 0.1),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: done
                              ? const Icon(Icons.check, color: AppColors.primary, size: 20)
                              : Text(
                                  '$remaining',
                                  style: AppTheme.bodyMd.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
