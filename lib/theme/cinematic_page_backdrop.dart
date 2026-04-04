import 'package:flutter/material.dart';

import 'cinematic_tokens.dart';

/// Thin warm wash directly under the top edge (header “shadow”, ~Stitch 8px soft glow).
class CinematicHeaderAccentLayer extends StatelessWidget {
  const CinematicHeaderAccentLayer({super.key});

  static const double height = 44;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            CinematicTokens.primaryContainer.withValues(alpha: 0.045),
            CinematicTokens.surfaceTint.withValues(alpha: 0.022),
            Colors.transparent,
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
      ),
    );
  }
}

/// Deep page fill + [CinematicHeaderAccentLayer] at the top.
///
/// Used via [MaterialApp.builder]; keep scaffolds transparent.
class CinematicPageBackdrop extends StatelessWidget {
  const CinematicPageBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: CinematicTokens.pageBackground),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: CinematicHeaderAccentLayer.height,
            child: const CinematicHeaderAccentLayer(),
          ),
        ],
      ),
    );
  }
}
