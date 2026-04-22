import 'package:flutter/material.dart';

class AppColors {
  // ── Surface Hierarchy (nested plates) ──
  static const Color surfaceContainerLowest = Color(0xFF060E20);
  static const Color background = Color(0xFF0B1326);
  static const Color surface = Color(0xFF0B1326);
  static const Color surfaceContainerLow = Color(0xFF131B2E);
  static const Color surfaceContainer = Color(0xFF171F33);
  static const Color surfaceHigh = Color(0xFF222A3D);
  static const Color surfaceContainerHighest = Color(0xFF2D3449);
  static const Color surfaceBright = Color(0xFF31394D);
  static const Color surfaceVariant = Color(0xFF2D3449);

  // ── Primary: Emerald ──
  static const Color primary = Color(0xFF4EDEA3);
  static const Color primaryContainer = Color(0xFF00A572);
  static const Color onPrimary = Color(0xFF003824);
  static const Color primaryFixed = Color(0xFF6FFBBE);

  // ── Tertiary: Sky ──
  static const Color tertiary = Color(0xFF7BD0FF);
  static const Color tertiaryContainer = Color(0xFF009BD1);

  // ── Text / Content ──
  static const Color onSurface = Color(0xFFDAE2FD);
  static const Color onSurfaceVariant = Color(0xFFBCC9C6);
  static const Color onBackground = Color(0xFFDAE2FD);

  // ── Secondary ──
  static const Color secondary = Color(0xFFBCC7DE);
  static const Color secondaryContainer = Color(0xFF3E495D);

  // ── Semantic ──
  static const Color error = Color(0xFFFFB4AB);
  static const Color errorContainer = Color(0xFF93000A);

  // ── Outlines ──
  static const Color outline = Color(0xFF879391);
  static const Color outlineVariant = Color(0xFF3D4947);

  // ── Inverse ──
  static const Color inverseSurface = Color(0xFFDAE2FD);
  static const Color inverseOnSurface = Color(0xFF283044);
  static const Color inversePrimary = Color(0xFF006C49);

  // ── Vault Glow Gradient Stops ──
  static const Color vaultGlowStart = Color(0xFF4EDEA3);
  static const Color vaultGlowEnd = Color(0xFF00A572);

  // ── Glass Panel ──
  static const Color glassBackground = Color(0x992D3449); // surfaceVariant 60%
  static const Color glassBorder = Color(0x263D4947);      // outlineVariant 15%
}
