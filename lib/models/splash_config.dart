import 'package:flutter/foundation.dart';

/// Configuration class for splash screen behavior and timing
class SplashConfig {
  /// Total duration the splash screen is displayed
  final Duration displayDuration;
  
  /// Duration of the logo fade-in animation
  final Duration logoAnimationDuration;
  
  /// Duration of the text slide-up animation
  final Duration textAnimationDuration;
  
  /// Duration of the screen transition animation
  final Duration transitionDuration;
  
  /// Delay before starting the text animation after logo starts
  final Duration textAnimationDelay;
  
  /// Whether to skip splash screen in debug mode
  final bool skipInDebug;
  
  /// Whether to enable debug logging for splash screen
  final bool enableDebugLogging;

  const SplashConfig({
    this.displayDuration = const Duration(seconds: 3),
    this.logoAnimationDuration = const Duration(milliseconds: 800),
    this.textAnimationDuration = const Duration(milliseconds: 600),
    this.transitionDuration = const Duration(milliseconds: 500),
    this.textAnimationDelay = const Duration(milliseconds: 300),
    this.skipInDebug = false,
    this.enableDebugLogging = false,
  });

  /// Creates a configuration optimized for development/debugging
  factory SplashConfig.debug({
    bool skipSplash = true,
    bool enableLogging = true,
  }) {
    return SplashConfig(
      displayDuration: const Duration(milliseconds: 500), // Shorter for debugging
      logoAnimationDuration: const Duration(milliseconds: 200),
      textAnimationDuration: const Duration(milliseconds: 200),
      transitionDuration: const Duration(milliseconds: 200),
      textAnimationDelay: const Duration(milliseconds: 100),
      skipInDebug: skipSplash,
      enableDebugLogging: enableLogging,
    );
  }

  /// Creates a configuration optimized for production
  factory SplashConfig.production() {
    return const SplashConfig(
      displayDuration: Duration(seconds: 3),
      logoAnimationDuration: Duration(milliseconds: 800),
      textAnimationDuration: Duration(milliseconds: 600),
      transitionDuration: Duration(milliseconds: 500),
      textAnimationDelay: Duration(milliseconds: 300),
      skipInDebug: false,
      enableDebugLogging: false,
    );
  }

  /// Creates a fast configuration for quick app launches
  factory SplashConfig.fast() {
    return const SplashConfig(
      displayDuration: Duration(milliseconds: 1500),
      logoAnimationDuration: Duration(milliseconds: 400),
      textAnimationDuration: Duration(milliseconds: 300),
      transitionDuration: Duration(milliseconds: 300),
      textAnimationDelay: Duration(milliseconds: 150),
      skipInDebug: false,
      enableDebugLogging: false,
    );
  }

  /// Determines if splash screen should be skipped based on configuration and debug mode
  bool shouldSkipSplash() {
    return skipInDebug && kDebugMode;
  }

  /// Logs debug information if debug logging is enabled
  void debugLog(String message) {
    if (enableDebugLogging && kDebugMode) {
      debugPrint('[SplashScreen] $message');
    }
  }

  @override
  String toString() {
    return 'SplashConfig('
        'displayDuration: $displayDuration, '
        'logoAnimationDuration: $logoAnimationDuration, '
        'textAnimationDuration: $textAnimationDuration, '
        'transitionDuration: $transitionDuration, '
        'textAnimationDelay: $textAnimationDelay, '
        'skipInDebug: $skipInDebug, '
        'enableDebugLogging: $enableDebugLogging'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SplashConfig &&
        other.displayDuration == displayDuration &&
        other.logoAnimationDuration == logoAnimationDuration &&
        other.textAnimationDuration == textAnimationDuration &&
        other.transitionDuration == transitionDuration &&
        other.textAnimationDelay == textAnimationDelay &&
        other.skipInDebug == skipInDebug &&
        other.enableDebugLogging == enableDebugLogging;
  }

  @override
  int get hashCode {
    return Object.hash(
      displayDuration,
      logoAnimationDuration,
      textAnimationDuration,
      transitionDuration,
      textAnimationDelay,
      skipInDebug,
      enableDebugLogging,
    );
  }
}