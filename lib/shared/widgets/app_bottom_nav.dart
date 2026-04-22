import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projet/core/constants/app_colors.dart';
import 'package:projet/core/constants/app_strings.dart';
import 'package:projet/core/constants/app_theme.dart';

/// Bottom navigation shell for the main app screens.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.child});

  final Widget child;

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/player')) return 1;
    if (location.startsWith('/favorites')) return 2;
    if (location.startsWith('/downloads')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
      case 1:
        context.go('/player');
      case 2:
        context.go('/favorites');
      case 3:
        context.go('/downloads');
      case 4:
        context.go('/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
          ),
        ),
        child: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (i) => _onTap(context, i),
          backgroundColor: AppColors.surfaceContainer,
          indicatorColor: AppColors.primary.withValues(alpha: 0.15),
          animationDuration: const Duration(milliseconds: 400),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          height: 70,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.dashboard_rounded, color: AppColors.onSurfaceVariant, size: 22),
              selectedIcon: Icon(Icons.dashboard_rounded, color: AppColors.primary, size: 22),
              label: AppStrings.navVault,
            ),
            NavigationDestination(
              icon: Icon(Icons.headphones_rounded, color: AppColors.onSurfaceVariant, size: 22),
              selectedIcon: Icon(Icons.headphones_rounded, color: AppColors.primary, size: 22),
              label: AppStrings.navStream,
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_border_rounded, color: AppColors.onSurfaceVariant, size: 22),
              selectedIcon: Icon(Icons.favorite_rounded, color: AppColors.primary, size: 22),
              label: AppStrings.navFavoris,
            ),
            NavigationDestination(
              icon: Icon(Icons.download_rounded, color: AppColors.onSurfaceVariant, size: 22),
              selectedIcon: Icon(Icons.download_done_rounded, color: AppColors.primary, size: 22),
              label: AppStrings.navDownloads,
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded, color: AppColors.onSurfaceVariant, size: 22),
              selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary, size: 22),
              label: AppStrings.navProfile,
            ),
          ],
        ),
      ),
    );
  }
}
