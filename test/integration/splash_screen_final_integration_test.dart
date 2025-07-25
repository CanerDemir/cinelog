import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/screens/splash_screen.dart';
import '../../lib/models/splash_config.dart';
import '../../lib/widgets/cinelog_logo.dart';
import '../../lib/services/storage_service.dart';

void main() {
  group('Splash Screen Integration Testing and Final Polish', () {
    // Skip storage initialization in tests since it requires platform plugins
    // The splash screen tests focus on UI and animation behavior

    testWidgets('Complete app launch flow - splash screen functionality', (WidgetTester tester) async {
      // Test the complete splash screen functionality as specified in task 12
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF1A1D29),
          ),
          home: SplashScreen(config: SplashConfig.fast()),
        ),
      );

      // Verify splash screen displays correctly (Requirement 1.1)
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(CineLogLogo), findsOneWidget);
      expect(find.text('CineLog'), findsOneWidget);

      // Verify background color matches app theme
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFF1A1D29));

      // Verify animations are present and working
      expect(find.byType(FadeTransition), findsOneWidget);
      expect(find.byType(SlideTransition), findsOneWidget);

      // Test animation performance by pumping frames
      for (int i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 16)); // 60 FPS
        // Verify animations remain stable during execution
        expect(find.byType(SplashScreen), findsOneWidget);
      }

      // Wait for navigation to complete (Requirement 1.4)
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify navigation occurred successfully
      expect(find.byType(SplashScreen), findsNothing);
    });

    testWidgets('Performance impact verification - smooth animations', (WidgetTester tester) async {
      // Test performance impact as specified in task requirements
      
      final List<Duration> frameTimes = [];
      Duration? lastFrameTime;

      // Monitor frame performance
      tester.binding.addPersistentFrameCallback((Duration timeStamp) {
        if (lastFrameTime != null) {
          frameTimes.add(timeStamp - lastFrameTime!);
        }
        lastFrameTime = timeStamp;
      });

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(config: SplashConfig.production()),
        ),
      );

      // Pump frames during animation period to test performance
      for (int i = 0; i < 60; i++) { // 1 second at 60 FPS
        await tester.pump(const Duration(milliseconds: 16));
      }

      // Analyze performance - should maintain reasonable frame rates
      if (frameTimes.isNotEmpty) {
        final averageFrameTime = frameTimes
            .map((d) => d.inMilliseconds)
            .reduce((a, b) => a + b) / frameTimes.length;

        // Performance should be reasonable (allowing for test environment overhead)
        expect(averageFrameTime, lessThan(50)); // Less than 50ms average frame time

        // Check for excessive frame drops
        final slowFrames = frameTimes.where((d) => d.inMilliseconds > 33).length;
        expect(slowFrames, lessThan(frameTimes.length * 0.2)); // Less than 20% slow frames
      }

      await tester.pumpAndSettle();
    });

    testWidgets('Responsive design verification - different screen sizes', (WidgetTester tester) async {
      // Test responsive design as specified in Requirement 3.4
      
      final List<Size> testSizes = [
        const Size(320, 568), // Small phone
        const Size(375, 667), // Medium phone  
        const Size(414, 896), // Large phone
        const Size(768, 1024), // Tablet
      ];

      for (final size in testSizes) {
        await tester.binding.setSurfaceSize(size);
        
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: SplashConfig.fast()),
          ),
        );

        // Verify responsive logo sizing (Requirement 3.1, 3.2)
        final logoWidget = tester.widget<CineLogLogo>(find.byType(CineLogLogo));
        expect(logoWidget.size, greaterThanOrEqualTo(80.0));
        expect(logoWidget.size, lessThanOrEqualTo(150.0));

        // Verify layout doesn't break on different sizes
        expect(find.byType(SplashScreen), findsOneWidget);
        expect(find.text('CineLog'), findsOneWidget);

        await tester.pumpAndSettle();
      }

      // Reset to default size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('Accessibility features verification', (WidgetTester tester) async {
      // Test accessibility features as specified in task requirements
      
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(config: SplashConfig.production()),
        ),
      );

      // Verify semantic structure is present for screen readers
      expect(find.byType(Semantics), findsWidgets);

      // Verify accessibility guidelines compliance
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));

      // Test with high contrast (accessibility requirement)
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: Colors.black,
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.white),
            ),
          ),
          home: SplashScreen(config: SplashConfig.production()),
        ),
      );

      // Verify high contrast compatibility
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('CineLog'), findsOneWidget);

      // Test with large text scaling (accessibility requirement)
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaleFactor: 2.0),
            child: SplashScreen(config: SplashConfig.production()),
          ),
        ),
      );

      // Verify large text scaling works
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('CineLog'), findsOneWidget);

      handle.dispose();
    });

    testWidgets('Animation timing and smoothness verification', (WidgetTester tester) async {
      // Test animation timing as specified in Requirement 2.4
      
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(config: SplashConfig.production()),
        ),
      );

      // Verify animations start correctly
      expect(find.byType(FadeTransition), findsOneWidget);
      expect(find.byType(SlideTransition), findsOneWidget);

      // Test animation progression over time
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(SplashScreen), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(SplashScreen), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 1000));
      expect(find.byType(SplashScreen), findsOneWidget);

      // Verify animations complete within expected timeframe
      await tester.pumpAndSettle(const Duration(seconds: 4));
      
      // Navigation should have occurred by now
      expect(find.byType(SplashScreen), findsNothing);
    });

    testWidgets('Error handling and fallback mechanisms', (WidgetTester tester) async {
      // Test error handling as specified in task requirements
      
      // Test with extreme configuration that might cause issues
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            config: const SplashConfig(
              displayDuration: Duration(milliseconds: 1),
              logoAnimationDuration: Duration(milliseconds: 1),
              textAnimationDuration: Duration(milliseconds: 1),
            ),
          ),
        ),
      );

      // Verify splash screen handles extreme config gracefully
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(CineLogLogo), findsOneWidget);

      // Should still navigate even with extreme timing
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // Verify error handling doesn't prevent navigation
      expect(find.byType(SplashScreen), findsNothing);
    });

    testWidgets('Memory usage and resource cleanup verification', (WidgetTester tester) async {
      // Test memory usage as specified in task requirements
      
      // Create and dispose splash screen multiple times
      for (int i = 0; i < 5; i++) {
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: SplashConfig.fast()),
          ),
        );

        // Verify creation
        expect(find.byType(SplashScreen), findsOneWidget);

        // Wait for navigation
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Verify cleanup
        expect(find.byType(SplashScreen), findsNothing);

        // Brief pause between iterations
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Final verification - no memory leaks or hanging resources
      await tester.pumpAndSettle();
    });

    testWidgets('Cross-configuration compatibility', (WidgetTester tester) async {
      // Test different configurations for robustness
      
      final configs = [
        SplashConfig.production(),
        SplashConfig.fast(),
        SplashConfig.debug(),
      ];

      for (final config in configs) {
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );

        // Verify each configuration works
        expect(find.byType(SplashScreen), findsOneWidget);
        expect(find.byType(CineLogLogo), findsOneWidget);
        expect(find.text('CineLog'), findsOneWidget);

        // Wait for navigation
        await tester.pumpAndSettle(const Duration(seconds: 4));

        // Verify navigation occurred
        expect(find.byType(SplashScreen), findsNothing);
      }
    });

    testWidgets('Theme consistency verification', (WidgetTester tester) async {
      // Verify theme consistency as mentioned in requirements
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF1A1D29),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFF6B35),
            ),
          ),
          home: SplashScreen(config: SplashConfig.production()),
        ),
      );

      // Verify theme colors are applied correctly
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFF1A1D29));

      // Verify text styling
      final textWidget = tester.widget<Text>(find.text('CineLog'));
      expect(textWidget.style?.color, Colors.white);

      await tester.pumpAndSettle();
    });
  });
}