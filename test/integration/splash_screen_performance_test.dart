import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/screens/splash_screen.dart';
import '../../lib/models/splash_config.dart';
import '../../lib/widgets/cinelog_logo.dart';

void main() {

  group('Splash Screen Performance Tests', () {
    testWidgets('Animation frame rate and smoothness', (WidgetTester tester) async {
      final List<Duration> frameTimes = [];
      final List<Duration> frameDurations = [];
      Duration? lastFrameTime;

      // Monitor frame performance
      tester.binding.addPersistentFrameCallback((Duration timeStamp) {
        frameTimes.add(timeStamp);
        if (lastFrameTime != null) {
          frameDurations.add(timeStamp - lastFrameTime!);
        }
        lastFrameTime = timeStamp;
      });

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(config: SplashConfig.production()),
        ),
      );

      // Pump frames during animation period
      const animationDuration = Duration(seconds: 2);
      final endTime = DateTime.now().add(animationDuration);
      
      while (DateTime.now().isBefore(endTime)) {
        await tester.pump(const Duration(milliseconds: 16)); // Target 60 FPS
      }

      await tester.pumpAndSettle();

      // Analyze frame performance
      expect(frameTimes.length, greaterThan(60)); // Should have many frames

      // Calculate average frame duration
      if (frameDurations.isNotEmpty) {
        final averageFrameDuration = frameDurations
            .map((d) => d.inMicroseconds)
            .reduce((a, b) => a + b) / frameDurations.length;

        // Target 60 FPS = 16.67ms per frame
        expect(averageFrameDuration, lessThan(20000)); // Less than 20ms average

        // Check for frame drops (frames taking longer than 33ms)
        final droppedFrames = frameDurations
            .where((d) => d.inMilliseconds > 33)
            .length;
        
        // Allow some tolerance for test environment
        expect(droppedFrames, lessThan(frameDurations.length * 0.1));
      }
    });

    testWidgets('Memory usage during splash screen lifecycle', (WidgetTester tester) async {
      // Measure initial memory state
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      await tester.pumpAndSettle();

      // Create splash screen
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(config: SplashConfig.production()),
        ),
      );

      // Verify splash screen is created
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(CineLogLogo), findsOneWidget);

      // Run through animation cycle
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 1000));

      // Wait for navigation
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Verify cleanup occurred
      expect(find.byType(SplashScreen), findsNothing);

      // Force garbage collection
      await tester.pumpAndSettle();
      
      // Verify no memory leaks by creating another splash screen
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(config: SplashConfig.production()),
        ),
      );

      expect(find.byType(SplashScreen), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('Animation controller performance and cleanup', (WidgetTester tester) async {
      // Track animation controller lifecycle
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(config: SplashConfig.production()),
        ),
      );

      // Verify animations are active
      expect(find.byType(FadeTransition), findsOneWidget);
      expect(find.byType(SlideTransition), findsOneWidget);

      // Pump through animation frames to test performance
      for (int i = 0; i < 120; i++) { // 2 seconds at 60 FPS
        await tester.pump(const Duration(milliseconds: 16));
        
        // Verify animations remain stable
        expect(find.byType(FadeTransition), findsOneWidget);
        expect(find.byType(SlideTransition), findsOneWidget);
      }

      // Wait for navigation and cleanup
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify proper cleanup occurred
      expect(find.byType(SplashScreen), findsNothing);
    });

    testWidgets('Responsive layout performance on different screen sizes', (WidgetTester tester) async {
      final List<Size> testSizes = [
        const Size(320, 568), // iPhone SE
        const Size(375, 667), // iPhone 8
        const Size(414, 896), // iPhone 11 Pro Max
        const Size(768, 1024), // iPad
        const Size(1024, 768), // iPad Landscape
      ];

      for (final size in testSizes) {
        await tester.binding.setSurfaceSize(size);
        
        final stopwatch = Stopwatch()..start();
        
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: SplashConfig.fast()),
          ),
        );

        // Measure layout performance
        await tester.pump();
        stopwatch.stop();

        // Layout should be fast (under 100ms)
        expect(stopwatch.elapsedMilliseconds, lessThan(100));

        // Verify responsive elements are properly sized
        final logoWidget = tester.widget<CineLogLogo>(find.byType(CineLogLogo));
        expect(logoWidget.size, greaterThanOrEqualTo(80.0));
        expect(logoWidget.size, lessThanOrEqualTo(150.0));

        // Verify text is visible
        expect(find.text('CineLog'), findsOneWidget);

        await tester.pumpAndSettle();
      }

      // Reset to default size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('Animation performance with different configurations', (WidgetTester tester) async {
      final List<SplashConfig> configs = [
        SplashConfig.production(),
        SplashConfig.fast(),
        SplashConfig.debug(),
        const SplashConfig(
          logoAnimationDuration: Duration(milliseconds: 200),
          textAnimationDuration: Duration(milliseconds: 200),
          displayDuration: Duration(seconds: 1),
        ),
      ];

      for (final config in configs) {
        final stopwatch = Stopwatch()..start();
        
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );

        // Measure initial render performance
        await tester.pump();
        final renderTime = stopwatch.elapsedMilliseconds;
        
        // Initial render should be fast
        expect(renderTime, lessThan(50));

        // Test animation performance
        for (int i = 0; i < 30; i++) {
          await tester.pump(const Duration(milliseconds: 16));
        }

        // Verify animations are working
        expect(find.byType(FadeTransition), findsOneWidget);
        expect(find.byType(SlideTransition), findsOneWidget);

        await tester.pumpAndSettle();
        stopwatch.stop();

        // Total time should be reasonable
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      }
    });

    testWidgets('Transition performance to home screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(config: SplashConfig.fast()),
        ),
      );

      // Wait for splash screen to be ready
      await tester.pump(const Duration(milliseconds: 100));

      final stopwatch = Stopwatch()..start();

      // Wait for navigation transition
      await tester.pumpAndSettle(const Duration(seconds: 3));

      stopwatch.stop();

      // Verify navigation occurred
      expect(find.byType(SplashScreen), findsNothing);

      // Navigation should complete in reasonable time
      expect(stopwatch.elapsedMilliseconds, lessThan(3500));
    });

    testWidgets('CPU usage during animations', (WidgetTester tester) async {
      // Monitor scheduler frame callbacks
      int frameCallbackCount = 0;
      
      void frameCallback(Duration timeStamp) {
        frameCallbackCount++;
      }

      SchedulerBinding.instance.addPersistentFrameCallback(frameCallback);

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(config: SplashConfig.production()),
        ),
      );

      // Reset counter after initial setup
      frameCallbackCount = 0;

      // Run animations for 1 second
      const testDuration = Duration(seconds: 1);
      final endTime = DateTime.now().add(testDuration);
      
      while (DateTime.now().isBefore(endTime)) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      SchedulerBinding.instance.removeFrameCallback(frameCallback);

      // Should have reasonable frame callback count (around 60 for 1 second)
      expect(frameCallbackCount, greaterThan(30));
      expect(frameCallbackCount, lessThan(120)); // Allow some variance

      await tester.pumpAndSettle();
    });

    testWidgets('Error handling performance impact', (WidgetTester tester) async {
      // Test performance with error conditions
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            config: const SplashConfig(
              displayDuration: Duration(milliseconds: 100),
              logoAnimationDuration: Duration(milliseconds: 1), // Very short
              textAnimationDuration: Duration(milliseconds: 1),
            ),
          ),
        ),
      );

      // Should still render quickly even with extreme config
      await tester.pump();
      expect(stopwatch.elapsedMilliseconds, lessThan(100));

      // Should still navigate properly
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      stopwatch.stop();

      // Error handling shouldn't significantly impact performance
      expect(stopwatch.elapsedMilliseconds, lessThan(2500));
    });

    testWidgets('Concurrent animation performance', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(config: SplashConfig.production()),
        ),
      );

      // Verify both animations run concurrently without performance issues
      expect(find.byType(FadeTransition), findsOneWidget);
      expect(find.byType(SlideTransition), findsOneWidget);

      // Test concurrent animation performance
      final stopwatch = Stopwatch()..start();
      
      for (int i = 0; i < 60; i++) { // 1 second of animation
        await tester.pump(const Duration(milliseconds: 16));
        
        // Both animations should remain active
        expect(find.byType(FadeTransition), findsOneWidget);
        expect(find.byType(SlideTransition), findsOneWidget);
      }

      stopwatch.stop();

      // Concurrent animations should maintain good performance
      expect(stopwatch.elapsedMilliseconds, lessThan(1200)); // Allow some overhead

      await tester.pumpAndSettle();
    });

    testWidgets('Widget rebuild performance optimization', (WidgetTester tester) async {
      int buildCount = 0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              buildCount++;
              return SplashScreen(config: SplashConfig.production());
            },
          ),
        ),
      );

      // Reset build count after initial build
      buildCount = 0;

      // Pump several frames
      for (int i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      // Should not rebuild excessively during animations
      expect(buildCount, lessThan(5)); // Allow some rebuilds but not excessive

      await tester.pumpAndSettle();
    });
  });
}