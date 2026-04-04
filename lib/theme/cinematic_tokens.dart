import 'package:flutter/material.dart';

/// Tokens from DESIGN.md — The Cinematic Curator.
abstract final class CinematicTokens {
  /// Full-screen page canvas — deep charcoal below the header accent strip.
  static const Color pageBackground = Color(0xFF0E0E0E);

  /// [ColorScheme.surface], bottom nav, app chrome — matches [pageBackground].
  static const Color surface = pageBackground;

  /// Deeper black for gradients (below [pageBackground]).
  static const Color surfaceDim = Color(0xFF0A0A0A);
  static const Color surfaceContainerLow = Color(0xFF181818);
  static const Color surfaceContainer = Color(0xFF1E1E1E);
  static const Color surfaceContainerHigh = Color(0xFF252525);
  static const Color surfaceBright = Color(0xFF2E2E2E);

  static const Color primary = Color(0xFFE85D2C);
  static const Color primaryContainer = Color(0xFFFF6B35);
  static const Color secondary = Color(0xFF9ACBFF);
  static const Color tertiary = Color(0xFFC0C1FF);

  static const Color onPrimaryFixed = Color(0xFF131313);
  static const Color labelMuted = Color(0xFF8A8A8A);
  static const Color hint = Color(0xFF6B6B6B);

  /// Stitch `surface-tint` — soft peach for header ambient glow.
  static const Color surfaceTint = Color(0xFFFFB59D);

  /// Stitch `surface-container-high` — segmented controls, search pills, menus.
  static const Color panel = Color(0xFF2A2A2A);

  /// Ghost border — outline at low opacity (DESIGN.md).
  static Color outlineGhost(BuildContext context) =>
      Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.15);

  static const double radiusXl = 24;
  static const double radiusLg = 16;
  static const double radiusPill = 24;

  /// Downward-only orange wash **below** the header (avoids BoxShadow bleeding up).
  static BoxDecoration headerUnderShadowDecoration() {
    return BoxDecoration(boxShadow: [
      BoxShadow(
        color: Color.fromRGBO(38, 57, 77, 1),
        blurRadius: 30,
        spreadRadius: -10,
        offset: Offset(0, 20),
      )
    ]);
  }

  static List<BoxShadow> primaryAmbientGlow() => [
        BoxShadow(
          color: primaryContainer.withValues(alpha: 0.35),
          blurRadius: 28,
          spreadRadius: 0,
          offset: const Offset(0, 12),
        ),
      ];

  static List<BoxShadow> logoGlow(double size) => [
        BoxShadow(
          color: primaryContainer.withValues(alpha: 0.45),
          blurRadius: size * 0.45,
          spreadRadius: size * 0.02,
          offset: Offset.zero,
        ),
      ];
}
