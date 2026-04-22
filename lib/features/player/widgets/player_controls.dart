import 'package:flutter/material.dart';
import 'package:projet/core/constants/app_colors.dart';
import 'package:projet/core/constants/app_strings.dart';
import 'package:projet/core/constants/app_theme.dart';

/// Reusable player control buttons (previous, play/pause, next, repeat).
class PlayerControls extends StatelessWidget {
  const PlayerControls({
    super.key,
    required this.isPlaying,
    required this.isLoading,
    required this.isRepeating,
    required this.onPlayPause,
    required this.onPrevious,
    required this.onNext,
    required this.onRepeat,
  });

  final bool isPlaying;
  final bool isLoading;
  final bool isRepeating;
  final VoidCallback onPlayPause;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onRepeat;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Repeat toggle
        IconButton(
          onPressed: onRepeat,
          icon: Icon(
            Icons.repeat_rounded,
            color: isRepeating ? AppColors.primary : AppColors.onSurfaceVariant,
          ),
          tooltip: AppStrings.repeat,
        ),
        const SizedBox(width: 8),

        // Previous
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surfaceContainer,
          ),
          child: IconButton(
            onPressed: onPrevious,
            icon: const Icon(Icons.skip_previous_rounded,
                color: AppColors.onSurface, size: 24),
            tooltip: AppStrings.previous,
          ),
        ),
        const SizedBox(width: 16),

        // Play/Pause
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppTheme.vaultGlow,
            boxShadow: AppTheme.vaultGlowShadow,
          ),
          child: isLoading
              ? const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: AppColors.onPrimary),
                  ),
                )
              : IconButton(
                  onPressed: onPlayPause,
                  icon: Icon(
                    isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: AppColors.onPrimary,
                    size: 32,
                  ),
                ),
        ),
        const SizedBox(width: 16),

        // Next
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surfaceContainer,
          ),
          child: IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.skip_next_rounded,
                color: AppColors.onSurface, size: 24),
            tooltip: AppStrings.next,
          ),
        ),
        const SizedBox(width: 8),

        // Speed (placeholder)
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.speed_rounded,
              color: AppColors.onSurfaceVariant, size: 22),
        ),
      ],
    );
  }
}
