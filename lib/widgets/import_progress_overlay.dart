import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/cinematic_tokens.dart';
import 'cinelog_logo.dart';

/// Progress for import UI: [done] of [total] items written.
@immutable
class ImportProgress {
  const ImportProgress({required this.done, required this.total});

  final int done;
  final int total;
}

/// Full-screen dimmed backdrop with logo and progress while JSON import runs.
class ImportProgressOverlay extends StatelessWidget {
  const ImportProgressOverlay({
    super.key,
    this.progressListenable,
  });

  final ValueListenable<ImportProgress?>? progressListenable;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CineLogLogo(size: 96),
        const SizedBox(height: 28),
        const SizedBox(
          width: 36,
          height: 36,
          child: CircularProgressIndicator(
            color: Color(0xFFFF6B35),
            strokeWidth: 3,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Importing backup…',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (progressListenable != null) ...[
          const SizedBox(height: 12),
          ValueListenableBuilder<ImportProgress?>(
            valueListenable: progressListenable!,
            builder: (context, progress, _) {
              if (progress == null || progress.total <= 0) {
                return Text(
                  'Syncing to your watchlist',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 13,
                  ),
                );
              }
              return Text(
                '${progress.done} / ${progress.total}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              );
            },
          ),
        ] else ...[
          const SizedBox(height: 8),
          Text(
            'Syncing to your watchlist',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 13,
            ),
          ),
        ],
      ],
    );

    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: PopScope(
        canPop: false,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: CinematicTokens.pageBackground.withValues(alpha: 0.94),
            ),
            child: Center(child: content),
          ),
        ),
      ),
    );
  }
}
