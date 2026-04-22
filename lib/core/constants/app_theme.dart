import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized reusable decorations & text styles for the Vaulted Gallery design.
class AppTheme {
  // ═══ Gradients ═══

  /// The signature vault glow gradient for CTAs and hero elements.
  static const LinearGradient vaultGlow = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.vaultGlowStart, AppColors.vaultGlowEnd],
  );

  /// Progress bar gradient: primary → tertiary.
  static const LinearGradient progressGradient = LinearGradient(
    colors: [AppColors.primary, AppColors.tertiary],
  );

  // ═══ Box Decorations ═══

  /// Background gradient for full-screen scaffolds.
  static const BoxDecoration screenBackground = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppColors.background, AppColors.surfaceContainerLow],
    ),
  );

  /// Card decoration — tonal surface container with large radius, no border.
  static BoxDecoration cardDecoration({
    Color color = AppColors.surfaceContainer,
    double radius = 24,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
    );
  }

  /// Glass panel decoration: translucent fill + backdrop blur + ghost border.
  static BoxDecoration glassDecoration({double radius = 20}) {
    return BoxDecoration(
      color: AppColors.glassBackground,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.glassBorder, width: 1),
    );
  }

  /// Input field decoration (for container wrapping).
  static BoxDecoration inputDecoration({bool focused = false}) {
    return BoxDecoration(
      color: AppColors.surfaceHigh,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: focused ? AppColors.primary : AppColors.outlineVariant.withValues(alpha: 0.3),
        width: focused ? 2 : 1,
      ),
    );
  }

  /// Ambient shadow for floating elements (glow, not drop).
  static List<BoxShadow> ambientShadow({
    Color? color,
    double blurRadius = 32,
    double opacity = 0.04,
  }) {
    return [
      BoxShadow(
        color: (color ?? AppColors.onSurface).withValues(alpha: opacity),
        blurRadius: blurRadius,
        spreadRadius: 0,
      ),
    ];
  }

  /// Green glow shadow for vault buttons.
  static List<BoxShadow> vaultGlowShadow = [
    BoxShadow(
      color: AppColors.primaryContainer.withValues(alpha: 0.4),
      blurRadius: 24,
      spreadRadius: 0,
      offset: const Offset(0, 8),
    ),
  ];

  // ═══ Text Styles ═══

  /// Display large — for high-impact statistics (e.g., "14h 22m").
  static const TextStyle displayLg = TextStyle(
    fontFamily: 'Inter',
    fontSize: 40,
    fontWeight: FontWeight.w900,
    color: AppColors.onSurface,
    letterSpacing: -1,
    height: 1.1,
  );

  /// Headline — for screen/section titles.
  static const TextStyle headlineMd = TextStyle(
    fontFamily: 'Inter',
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.onSurface,
    letterSpacing: -0.5,
  );

  /// Headline small — for card titles.
  static const TextStyle headlineSm = TextStyle(
    fontFamily: 'Inter',
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );

  /// Body medium — descriptions.
  static const TextStyle bodyMd = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
    height: 1.5,
  );

  /// Body small — secondary info.
  static const TextStyle bodySm = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
  );

  /// Label — uppercase field labels and status text.
  static const TextStyle labelMd = TextStyle(
    fontFamily: 'Inter',
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurfaceVariant,
    letterSpacing: 1.5,
  );

  /// Label small — tiny badges and timestamps.
  static const TextStyle labelSm = TextStyle(
    fontFamily: 'Inter',
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurfaceVariant,
    letterSpacing: 2,
  );

  /// Button text style.
  static const TextStyle buttonText = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.onPrimary,
  );

  // ═══ Border Radius ═══

  static const double radiusSm = 8;
  static const double radiusMd = 14;
  static const double radiusLg = 20;
  static const double radiusXl = 24;
  static const double radiusXxl = 40;

  // ═══ Spacing ═══

  static const double spaceSm = 8;
  static const double spaceMd = 12;
  static const double spaceLg = 16;
  static const double spaceXl = 20;
  static const double spaceXxl = 24;
  static const double spaceHuge = 32;
}
