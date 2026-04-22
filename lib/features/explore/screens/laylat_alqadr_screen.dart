import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:projet/core/constants/app_colors.dart';
import 'package:projet/core/constants/app_strings.dart';
import 'package:projet/core/constants/app_theme.dart';
import 'package:projet/features/explore/providers/explore_providers.dart';
import 'package:projet/shared/widgets/loading_indicator.dart';

class LaylatAlQadrScreen extends ConsumerWidget {
  const LaylatAlQadrScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(laylatAlQadrProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            _buildHeader(context),

            // ── Content ──
            Expanded(
              child: data.when(
                data: (json) => _buildContent(json),
                loading: () => const LoadingIndicator(),
                error: (e, _) => Center(child: Text(AppStrings.apiError, style: AppTheme.bodyMd.copyWith(color: AppColors.error))),
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
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A0536), Color(0xFF4A148C), Color(0xFF0D47A1)],
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
              const Text('🌙', style: TextStyle(fontSize: 28)),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'ليلة القدر',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white, height: 1.2),
          ),
          const SizedBox(height: 6),
          Text(
            AppStrings.laylatAlQadrSubtitle,
            style: AppTheme.bodyMd.copyWith(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> json) {
    final sections = <Widget>[];

    // The API wraps everything under 'laylat_al_qadr'
    final root = json['laylat_al_qadr'];
    final Map<String, dynamic> data;
    if (root is Map<String, dynamic>) {
      data = root;
    } else {
      data = json;
    }

    data.forEach((sectionKey, sectionValue) {
      if (sectionValue is! Map) return;

      final sectionMap = sectionValue as Map<String, dynamic>;
      final sectionName = (sectionMap['name'] ?? sectionKey).toString();

      // Collect content lines for this section
      final contentWidgets = <Widget>[];

      sectionMap.forEach((k, v) {
        if (k == 'name') return; // skip the label itself

        if (v is String && v.isNotEmpty) {
          // Direct string value
          contentWidgets.add(_buildTextLine(v));
        } else if (v is List) {
          // Array of strings (e.g., confirmed signs, acts)
          for (final item in v) {
            if (item is String && item.isNotEmpty) {
              contentWidgets.add(_buildBulletLine(item));
            }
          }
        } else if (v is Map) {
          // Nested sub-object (e.g., scholars_opinions has ibn_kathir, ibn_taymiyyah)
          v.forEach((subKey, subVal) {
            if (subVal is String && subVal.isNotEmpty) {
              contentWidgets.add(_buildBulletLine(subVal));
            }
          });
        }
      });

      if (contentWidgets.isNotEmpty) {
        sections.add(_buildSection(sectionName, contentWidgets));
      }
    });

    if (sections.isEmpty) {
      return Center(child: Text(AppStrings.noResults, style: AppTheme.bodyMd));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: sections,
    );
  }

  /// Card with an Arabic title + a list of pre-built content widgets.
  Widget _buildSection(String title, List<Widget> children) {
    final cleanTitle = title.replaceAll('_', ' ');
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
          if (cleanTitle.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                cleanTitle,
                textDirection: TextDirection.rtl,
                style: AppTheme.bodyMd.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ...children,
        ],
      ),
    );
  }

  /// A plain RTL text paragraph.
  Widget _buildTextLine(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        style: const TextStyle(fontSize: 15, color: AppColors.onSurface, height: 1.85),
      ),
    );
  }

  /// A bullet point item (green dot + RTL text).
  Widget _buildBulletLine(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: TextDirection.rtl,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 8),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 14, color: AppColors.onSurface, height: 1.8),
            ),
          ),
        ],
      ),
    );
  }
}
