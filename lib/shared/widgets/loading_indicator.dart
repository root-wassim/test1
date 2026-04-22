import 'package:flutter/material.dart';
import 'package:projet/core/constants/app_colors.dart';

/// A reusable centered circular progress indicator matching the vault theme.
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.size = 36, this.strokeWidth = 3});

  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          backgroundColor: AppColors.surfaceContainerHighest,
        ),
      ),
    );
  }
}
