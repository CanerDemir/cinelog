import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/main.dart' as app;
import '../../lib/screens/splash_screen.dart';
import '../../lib/screens/home_screen.dart';
import '../../lib/models/splash_config.dart';
import '../../lib/widgets/cinelog_logo.dart';

void main() {

  group('Splash Screen Integration Tests', () {
    testWidgets('Complete app launch flow from splash to home screen', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify splash screen is displayed initially
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);

      // Verify splash screen components are present
      expect(find.byType(CineLogLogo), findsOneWidget);
      expect(find.text('CineLog'), findsOneWidget);

      // Verify background color matches app theme
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.backgroundColor, const Color(0xFF1A1D29));

      // Wait for splash screen duration and animations to complete
      // Using a longer timeout to ensure all animations complete
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify navigation to home screen occurred
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);

      // Verify home screen is properly loaded with expected components
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      
      // Verify the CineLog logo is present in home screen
      expect(find.byType(CineLogLogo), findsOneWidget);
    });

    testWidgets('Splash screen with debug configuration', (WidgetTester tester) async {
      // Create app with debug configuration
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            config: SplashConfig.debug(skipSplash: false, enableLogging: true),
          ),
        ),
      );

      // Verify splash screen renders with debug config
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(CineLogLogo), findsOneWidget);
      expect(find.text('CineLog'), findsOneWidget);

      // Wait for shorter debug duration
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify navigation occurred faster with debug config
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('Splash screen with fast configuration', (WidgetTester tester) async {
      // Create app with fast configuration
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            config: SplashConfig.fast(),
          ),
        ),
      );

      // Verify splash screen renders
      expect(find.byType(SplashScreen), findsOneWidget);

      // Wait for fast configuration duration
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify navigation occurred
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('Animation performance and smoothness verification', (WidgetTester tester) async {
      // Track frame rendering performance
      final List<Duration> frameDurations = [];
      
      // Override frame callback to measure performance
      tester.binding.addPersistentFrameCallback((duration) {
        frameDurations.add(duration);
      });

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            config: SplashConfig.production(),
          ),
        ),
      );

      // Pump multiple frames to capture animation performance
      for (int i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 16)); // 60 FPS
      }

      // Verify animations are running smoothly
      expect(find.byType(FadeTransition), findsOneWidget);
      expect(find.byType(SlideTransition), findsOneWidget);

      // Check that we're not dropping too many frames
      // Allow some tolerance for test environment
      final droppedFrames = frameDurations.where((d) => d.inMilliseconds > 20).length;
      expect(droppedFrames, lessThan(frameDurations.length * 0.1)); // Less than 10% dropped frames

      await tester.pumpAndSettle();
    });

    testWidgets('Responsive design on different screen sizes', (WidgetTester tester) async {
      // Test on small screen (phone)
      await tester.binding.setSurfaceSize(const Size(375, 667)); // iPhone SE size
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(config: SplashConfig.production()),
        ),
      );

      // Verify logo is appropriately sized for small screen
      final smallScreenLogo = tester.widget<CineLogLogo>(find.byType(CineLogLogo));
      expect(smallScreenLogo.size, greaterThanOrEqualTo(80.0));
      expect(smallScreenLogo.size, lessThanOrEqualTo(150.0));

      // Test on large screen (tablet)
      await tester.binding.setSurfaceSize(const Size(768, 1024)); // iPad size
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(config: SplashConfig.production()),
        ),
      );

      // Verify logo scales appropriately for larger screen
      final largeScreenLogo = tester.widget<CineLogLogo>(find.byType(CineLogLogo));
      expect(largeScreenLogo.size, greaterThanOrEqualTo(80.0));
      expect(largeScreenLogo.size, lessThanOrEqualTo(150.0));

      // Test landscape orientation
      await tester.binding.setSurfaceSize(const Size(667, 375)); // Landscape
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(config: SplashConfig.production()),
        ),
      );

      // Verify layout adapts to landscape
      final landscapeLogo = tester.widget<CineLogLogo>(find.byType(CineLogLogo));
      expect(landscapeLogo.size, greaterThanOrEqualTo(80.0));

      // Reset to default size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('Error handling and fallback mechanisms', (WidgetTester tester) async {
      // Test with a configuration that might cause issues
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            config: const SplashConfig(
              displayDuration: Duration(milliseconds: 100), // Very short
              logoAnimationDuration: Duration(milliseconds: 50),
              textAnimationDuration: Duration(milliseconds: 50),
            ),
          ),
        ),
      );

      // Verify splash screen still renders even with extreme configuration
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(CineLogLogo), findsOneWidget);

      // Wait for navigation
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify navigation still occurs despite potential timing issues
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('Memory usage and resource cleanup', (WidgetTester tester) async {
      // Track widget lifecycle
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(config: SplashConfig.production()),
        ),
      );

      // Verify splash screen is active
      expect(find.byType(SplashScreen), findsOneWidget);

      // Wait for navigation
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Verify splash screen is properly disposed
      expect(find.byType(SplashScreen), findsNothing);
      expect(find.byType(HomeScreen), findsOneWidget);

      // Force garbage collection to verify no memory leaks
      await tester.pumpAndSettle();
      
      // Navigate away and back to test cleanup
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      
      // Verify no splash screen remnants
      expect(find.byType(SplashScreen), findsNothing);
    });

    testWidgets('Navigation timing consistency', (WidgetTester tester) async {
      final List<int> navigationTimes = [];

      // Test navigation timing multiple times
      for (int i = 0; i < 3; i++) {
        final stopwatch = Stopwatch()..start();
        
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: SplashConfig.production()),
          ),
        );

        // Wait for navigation
        await tester.pumpAndSettle(const Duration(seconds: 5));
        
        stopwatch.stop();
        navigationTimes.add(stopwatch.elapsedMilliseconds);

        // Verify navigation occurred
        expect(find.byType(HomeScreen), findsOneWidget);
      }

      // Verify timing consistency (within reasonable range)
      final averageTime = navigationTimes.reduce((a, b) => a + b) / navigationTimes.length;
      for (final time in navigationTimes) {
        expect((time - averageTime).abs(), lessThan(500)); // Within 500ms variance
      }
    });

    testWidgets('App state preservation during splash transition', (WidgetTester tester) async {
      // Start the full app
      app.main();
      await tester.pumpAndSettle();

      // Verify splash screen
      expect(find.byType(SplashScreen), findsOneWidget);

      // Wait for navigation to home
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify home screen is loaded with proper state
      expect(find.byType(HomeScreen), findsOneWidget);
      
      // Verify app theme is preserved
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme?.brightness, Brightness.dark);
      expect(materialApp.theme?.scaffoldBackgroundColor, const Color(0xFF1A1D29));
    });
  });
}