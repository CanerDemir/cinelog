import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:cinelog/models/splash_config.dart';

void main() {
  group('SplashConfig', () {
    test('should create default configuration', () {
      const config = SplashConfig();
      
      expect(config.displayDuration, const Duration(seconds: 3));
      expect(config.logoAnimationDuration, const Duration(milliseconds: 800));
      expect(config.textAnimationDuration, const Duration(milliseconds: 600));
      expect(config.transitionDuration, const Duration(milliseconds: 500));
      expect(config.textAnimationDelay, const Duration(milliseconds: 300));
      expect(config.skipInDebug, false);
      expect(config.enableDebugLogging, false);
    });

    test('should create debug configuration', () {
      final config = SplashConfig.debug();
      
      expect(config.displayDuration, const Duration(milliseconds: 500));
      expect(config.logoAnimationDuration, const Duration(milliseconds: 200));
      expect(config.textAnimationDuration, const Duration(milliseconds: 200));
      expect(config.transitionDuration, const Duration(milliseconds: 200));
      expect(config.textAnimationDelay, const Duration(milliseconds: 100));
      expect(config.skipInDebug, true);
      expect(config.enableDebugLogging, true);
    });

    test('should create production configuration', () {
      final config = SplashConfig.production();
      
      expect(config.displayDuration, const Duration(seconds: 3));
      expect(config.logoAnimationDuration, const Duration(milliseconds: 800));
      expect(config.textAnimationDuration, const Duration(milliseconds: 600));
      expect(config.transitionDuration, const Duration(milliseconds: 500));
      expect(config.textAnimationDelay, const Duration(milliseconds: 300));
      expect(config.skipInDebug, false);
      expect(config.enableDebugLogging, false);
    });

    test('should create fast configuration', () {
      final config = SplashConfig.fast();
      
      expect(config.displayDuration, const Duration(milliseconds: 1500));
      expect(config.logoAnimationDuration, const Duration(milliseconds: 400));
      expect(config.textAnimationDuration, const Duration(milliseconds: 300));
      expect(config.transitionDuration, const Duration(milliseconds: 300));
      expect(config.textAnimationDelay, const Duration(milliseconds: 150));
      expect(config.skipInDebug, false);
      expect(config.enableDebugLogging, false);
    });

    test('should handle custom configuration', () {
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

    test('should determine skip splash correctly', () {
      // Test with skipInDebug = false
      const config1 = SplashConfig(skipInDebug: false);
      expect(config1.shouldSkipSplash(), false);
      
      // Test with skipInDebug = true
      const config2 = SplashConfig(skipInDebug: true);
      // This will return true only in debug mode, false in release mode
      expect(config2.shouldSkipSplash(), kDebugMode);
    });

    test('should handle equality correctly', () {
      const config1 = SplashConfig();
      const config2 = SplashConfig();
      const config3 = SplashConfig(displayDuration: Duration(seconds: 5));
      
      expect(config1, equals(config2));
      expect(config1, isNot(equals(config3)));
    });

    test('should generate correct toString', () {
      const config = SplashConfig();
      final toString = config.toString();
      
      expect(toString, contains('SplashConfig'));
      expect(toString, contains('displayDuration: 0:00:03.000000'));
      expect(toString, contains('logoAnimationDuration: 0:00:00.800000'));
      expect(toString, contains('skipInDebug: false'));
    });
  });
}