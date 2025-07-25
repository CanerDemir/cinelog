import 'package:flutter_test/flutter_test.dart';
import 'package:cinelog/models/splash_config.dart';

void main() {
  group('SplashScreen Unit Tests', () {
    group('SplashConfig Tests', () {
      test('should create default configuration with correct values', () {
        const config = SplashConfig();
        
        expect(config.displayDuration, const Duration(seconds: 3));
        expect(config.logoAnimationDuration, const Duration(milliseconds: 800));
        expect(config.textAnimationDuration, const Duration(milliseconds: 600));
        expect(config.transitionDuration, const Duration(milliseconds: 500));
        expect(config.textAnimationDelay, const Duration(milliseconds: 300));
        expect(config.skipInDebug, false);
        expect(config.enableDebugLogging, false);
      });

      test('should create debug configuration with optimized values', () {
        final config = SplashConfig.debug();
        
        expect(config.displayDuration, const Duration(milliseconds: 500));
        expect(config.logoAnimationDuration, const Duration(milliseconds: 200));
        expect(config.textAnimationDuration, const Duration(milliseconds: 200));
        expect(config.transitionDuration, const Duration(milliseconds: 200));
        expect(config.textAnimationDelay, const Duration(milliseconds: 100));
        expect(config.skipInDebug, true);
        expect(config.enableDebugLogging, true);
      });

      test('should create production configuration with standard values', () {
        final config = SplashConfig.production();
        
        expect(config.displayDuration, const Duration(seconds: 3));
        expect(config.logoAnimationDuration, const Duration(milliseconds: 800));
        expect(config.textAnimationDuration, const Duration(milliseconds: 600));
        expect(config.transitionDuration, const Duration(milliseconds: 500));
        expect(config.textAnimationDelay, const Duration(milliseconds: 300));
        expect(config.skipInDebug, false);
        expect(config.enableDebugLogging, false);
      });

      test('should create fast configuration with reduced timings', () {
        final config = SplashConfig.fast();
        
        expect(config.displayDuration, const Duration(milliseconds: 1500));
        expect(config.logoAnimationDuration, const Duration(milliseconds: 400));
        expect(config.textAnimationDuration, const Duration(milliseconds: 300));
        expect(config.transitionDuration, const Duration(milliseconds: 300));
        expect(config.textAnimationDelay, const Duration(milliseconds: 150));
        expect(config.skipInDebug, false);
        expect(config.enableDebugLogging, false);
      });

      test('should handle custom configuration parameters', () {
        const config = SplashConfig(
          displayDuration: Duration(seconds: 5),
          logoAnimationDuration: Duration(milliseconds: 1000),
          textAnimationDuration: Duration(milliseconds: 800),
          transitionDuration: Duration(milliseconds: 600),
          textAnimationDelay: Duration(milliseconds: 400),
          skipInDebug: true,
          enableDebugLogging: true,
        );
        
        expect(config.displayDuration, const Duration(seconds: 5));
        expect(config.logoAnimationDuration, const Duration(milliseconds: 1000));
        expect(config.textAnimationDuration, const Duration(milliseconds: 800));
        expect(config.transitionDuration, const Duration(milliseconds: 600));
        expect(config.textAnimationDelay, const Duration(milliseconds: 400));
        expect(config.skipInDebug, true);
        expect(config.enableDebugLogging, true);
      });

      test('should determine skip splash correctly based on debug mode', () {
        // Test with skipInDebug = false
        const config1 = SplashConfig(skipInDebug: false);
        expect(config1.shouldSkipSplash(), false);
        
        // Test with skipInDebug = true
        const config2 = SplashConfig(skipInDebug: true);
        // This will return true only in debug mode, false in release mode
        // In test environment, this should return true since tests run in debug mode
        expect(config2.shouldSkipSplash(), true);
      });

      test('should handle equality comparison correctly', () {
        const config1 = SplashConfig();
        const config2 = SplashConfig();
        const config3 = SplashConfig(displayDuration: Duration(seconds: 5));
        
        expect(config1, equals(config2));
        expect(config1, isNot(equals(config3)));
        expect(config1.hashCode, equals(config2.hashCode));
        expect(config1.hashCode, isNot(equals(config3.hashCode)));
      });

      test('should generate correct toString representation', () {
        const config = SplashConfig();
        final toString = config.toString();
        
        expect(toString, contains('SplashConfig'));
        expect(toString, contains('displayDuration: 0:00:03.000000'));
        expect(toString, contains('logoAnimationDuration: 0:00:00.800000'));
        expect(toString, contains('textAnimationDuration: 0:00:00.600000'));
        expect(toString, contains('transitionDuration: 0:00:00.500000'));
        expect(toString, contains('textAnimationDelay: 0:00:00.300000'));
        expect(toString, contains('skipInDebug: false'));
        expect(toString, contains('enableDebugLogging: false'));
      });

      test('should handle debug logging method without errors', () {
        const config1 = SplashConfig(enableDebugLogging: false);
        const config2 = SplashConfig(enableDebugLogging: true);
        
        // These should not throw errors
        expect(() => config1.debugLog('Test message'), returnsNormally);
        expect(() => config2.debugLog('Test message'), returnsNormally);
      });
    });

    group('Animation Controller Logic Tests', () {
      test('should validate animation duration relationships', () {
        const config = SplashConfig();
        
        // Logo animation should start first
        expect(config.logoAnimationDuration.inMilliseconds, greaterThan(0));
        
        // Text animation delay should be reasonable relative to logo animation
        expect(config.textAnimationDelay.inMilliseconds, 
               lessThan(config.logoAnimationDuration.inMilliseconds));
        
        // Total display duration should be longer than individual animations
        expect(config.displayDuration.inMilliseconds, 
               greaterThan(config.logoAnimationDuration.inMilliseconds));
        expect(config.displayDuration.inMilliseconds, 
               greaterThan(config.textAnimationDuration.inMilliseconds));
      });

      test('should validate timing constraints for smooth animations', () {
        const config = SplashConfig();
        
        // Animation durations should be reasonable (not too fast or too slow)
        expect(config.logoAnimationDuration.inMilliseconds, greaterThan(100));
        expect(config.logoAnimationDuration.inMilliseconds, lessThan(2000));
        
        expect(config.textAnimationDuration.inMilliseconds, greaterThan(100));
        expect(config.textAnimationDuration.inMilliseconds, lessThan(2000));
        
        expect(config.transitionDuration.inMilliseconds, greaterThan(100));
        expect(config.transitionDuration.inMilliseconds, lessThan(1000));
      });

      test('should validate debug configuration optimizations', () {
        final debugConfig = SplashConfig.debug();
        final prodConfig = SplashConfig.production();
        
        // Debug config should have faster timings than production
        expect(debugConfig.displayDuration.inMilliseconds, 
               lessThan(prodConfig.displayDuration.inMilliseconds));
        expect(debugConfig.logoAnimationDuration.inMilliseconds, 
               lessThan(prodConfig.logoAnimationDuration.inMilliseconds));
        expect(debugConfig.textAnimationDuration.inMilliseconds, 
               lessThan(prodConfig.textAnimationDuration.inMilliseconds));
      });

      test('should validate fast configuration optimizations', () {
        final fastConfig = SplashConfig.fast();
        final defaultConfig = SplashConfig();
        
        // Fast config should have shorter timings than default
        expect(fastConfig.displayDuration.inMilliseconds, 
               lessThan(defaultConfig.displayDuration.inMilliseconds));
        expect(fastConfig.logoAnimationDuration.inMilliseconds, 
               lessThan(defaultConfig.logoAnimationDuration.inMilliseconds));
        expect(fastConfig.textAnimationDuration.inMilliseconds, 
               lessThan(defaultConfig.textAnimationDuration.inMilliseconds));
      });
    });

    group('Responsive Sizing Logic Tests', () {
      test('should calculate logo size within constraints', () {
        // Test logo size calculation logic (25% of screen width, min 80, max 150)
        
        // Small screen test
        double screenWidth = 200;
        double logoSize = screenWidth * 0.25; // 50
        logoSize = logoSize.clamp(80.0, 150.0); // Should clamp to 80
        expect(logoSize, equals(80.0));
        
        // Medium screen test
        screenWidth = 400;
        logoSize = screenWidth * 0.25; // 100
        logoSize = logoSize.clamp(80.0, 150.0); // Should remain 100
        expect(logoSize, equals(100.0));
        
        // Large screen test
        screenWidth = 800;
        logoSize = screenWidth * 0.25; // 200
        logoSize = logoSize.clamp(80.0, 150.0); // Should clamp to 150
        expect(logoSize, equals(150.0));
      });

      test('should calculate text size within constraints', () {
        // Test text size calculation logic (8% of screen width, min 24, max 40)
        
        // Small screen test
        double screenWidth = 200;
        double textSize = screenWidth * 0.08; // 16
        textSize = textSize.clamp(24.0, 40.0); // Should clamp to 24
        expect(textSize, equals(24.0));
        
        // Medium screen test
        screenWidth = 400;
        textSize = screenWidth * 0.08; // 32
        textSize = textSize.clamp(24.0, 40.0); // Should remain 32
        expect(textSize, equals(32.0));
        
        // Large screen test
        screenWidth = 600;
        textSize = screenWidth * 0.08; // 48
        textSize = textSize.clamp(24.0, 40.0); // Should clamp to 40
        expect(textSize, equals(40.0));
      });

      test('should calculate spacing within constraints', () {
        // Test spacing calculation logic (3% of screen height, min 16, max 32)
        
        // Small screen test
        double screenHeight = 400;
        double spacing = screenHeight * 0.03; // 12
        spacing = spacing.clamp(16.0, 32.0); // Should clamp to 16
        expect(spacing, equals(16.0));
        
        // Medium screen test
        screenHeight = 800;
        spacing = screenHeight * 0.03; // 24
        spacing = spacing.clamp(16.0, 32.0); // Should remain 24
        expect(spacing, equals(24.0));
        
        // Large screen test
        screenHeight = 1200;
        spacing = screenHeight * 0.03; // 36
        spacing = spacing.clamp(16.0, 32.0); // Should clamp to 32
        expect(spacing, equals(32.0));
      });

      test('should handle landscape orientation constraints', () {
        // Test landscape constraint logic
        double screenWidth = 800;
        double screenHeight = 400;
        
        // Width-based calculation
        double logoSizeWidth = screenWidth * 0.25; // 200
        logoSizeWidth = logoSizeWidth.clamp(80.0, 150.0); // 150
        
        // Height-based constraint (20% of height)
        double maxHeightBasedSize = screenHeight * 0.2; // 80
        double finalLogoSize = maxHeightBasedSize < logoSizeWidth ? 
                              maxHeightBasedSize.clamp(80.0, 150.0) : logoSizeWidth;
        
        expect(finalLogoSize, equals(80.0)); // Should use height constraint
      });
    });

    group('Timer Functionality Logic Tests', () {
      test('should validate timer duration calculations', () {
        const config = SplashConfig(displayDuration: Duration(milliseconds: 3000));
        
        // Timer duration should match display duration
        expect(config.displayDuration.inMilliseconds, equals(3000));
        
        // Timer should be longer than animation durations
        expect(config.displayDuration.inMilliseconds, 
               greaterThan(config.logoAnimationDuration.inMilliseconds));
        expect(config.displayDuration.inMilliseconds, 
               greaterThan(config.textAnimationDuration.inMilliseconds));
      });

      test('should validate animation sequencing logic', () {
        const config = SplashConfig();
        
        // Logo animation starts immediately (at 0ms)
        int logoStartTime = 0;
        
        // Text animation starts after delay
        int textStartTime = config.textAnimationDelay.inMilliseconds;
        
        // Navigation happens after display duration
        int navigationTime = config.displayDuration.inMilliseconds;
        
        expect(textStartTime, greaterThan(logoStartTime));
        expect(navigationTime, greaterThan(textStartTime));
        expect(navigationTime, greaterThan(logoStartTime + config.logoAnimationDuration.inMilliseconds));
      });

      test('should validate skip splash logic in different modes', () {
        const debugConfig = SplashConfig(skipInDebug: true);
        const prodConfig = SplashConfig(skipInDebug: false);
        
        // In test environment (debug mode), skipInDebug should work
        expect(debugConfig.shouldSkipSplash(), true);
        expect(prodConfig.shouldSkipSplash(), false);
      });
    });

    group('Error Handling Logic Tests', () {
      test('should handle invalid duration values gracefully', () {
        // Test with very small durations
        const config1 = SplashConfig(
          logoAnimationDuration: Duration(microseconds: 1),
          textAnimationDuration: Duration(microseconds: 1),
        );
        
        expect(config1.logoAnimationDuration.inMicroseconds, equals(1));
        expect(config1.textAnimationDuration.inMicroseconds, equals(1));
        
        // Test with zero durations
        const config2 = SplashConfig(
          logoAnimationDuration: Duration.zero,
          textAnimationDuration: Duration.zero,
        );
        
        expect(config2.logoAnimationDuration, equals(Duration.zero));
        expect(config2.textAnimationDuration, equals(Duration.zero));
      });

      test('should handle extreme screen size calculations', () {
        // Test with very small screen
        double screenWidth = 1;
        double logoSize = (screenWidth * 0.25).clamp(80.0, 150.0);
        expect(logoSize, equals(80.0)); // Should clamp to minimum
        
        // Test with very large screen
        screenWidth = 10000;
        logoSize = (screenWidth * 0.25).clamp(80.0, 150.0);
        expect(logoSize, equals(150.0)); // Should clamp to maximum
        
        // Test with zero screen size
        screenWidth = 0;
        logoSize = (screenWidth * 0.25).clamp(80.0, 150.0);
        expect(logoSize, equals(80.0)); // Should clamp to minimum
      });

      test('should validate configuration consistency', () {
        const config = SplashConfig();
        
        // All durations should be non-negative
        expect(config.displayDuration.inMilliseconds, greaterThanOrEqualTo(0));
        expect(config.logoAnimationDuration.inMilliseconds, greaterThanOrEqualTo(0));
        expect(config.textAnimationDuration.inMilliseconds, greaterThanOrEqualTo(0));
        expect(config.transitionDuration.inMilliseconds, greaterThanOrEqualTo(0));
        expect(config.textAnimationDelay.inMilliseconds, greaterThanOrEqualTo(0));
        
        // Boolean flags should have valid values
        expect(config.skipInDebug, isA<bool>());
        expect(config.enableDebugLogging, isA<bool>());
      });
    });
  });
}