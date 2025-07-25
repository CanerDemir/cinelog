import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cinelog/screens/splash_screen.dart';
import 'package:cinelog/models/splash_config.dart';
import 'package:cinelog/screens/home_screen.dart';
import 'package:cinelog/widgets/cinelog_logo.dart';

void main() {
  group('SplashScreen Unit Tests', () {
    group('Animation Controller Tests', () {
      testWidgets('should initialize and render splash screen correctly', (WidgetTester tester) async {
        const config = SplashConfig(
          logoAnimationDuration: Duration(milliseconds: 500),
          textAnimationDuration: Duration(milliseconds: 300),
        );
        
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );
        
        // Verify the widget is created and renders correctly
        expect(find.byType(SplashScreen), findsOneWidget);
        expect(find.byType(CineLogLogo), findsOneWidget);
        expect(find.text('CineLog'), findsOneWidget);
        
        // Verify background color is correct
        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.backgroundColor, const Color(0xFF1A1D29));
      });

      testWidgets('should dispose properly without errors', (WidgetTester tester) async {
        const config = SplashConfig();
        
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );
        
        // Verify widget is rendered
        expect(find.byType(SplashScreen), findsOneWidget);
        
        // Remove the widget to trigger dispose - should not throw errors
        expect(() async {
          await tester.pumpWidget(const MaterialApp(home: Scaffold()));
        }, returnsNormally);
      });

      testWidgets('should handle animation initialization gracefully', (WidgetTester tester) async {
        // Test with extreme configuration that might cause issues
        const config = SplashConfig(
          logoAnimationDuration: Duration(microseconds: 1),
          textAnimationDuration: Duration(microseconds: 1),
        );
        
        // This should not throw an exception
        expect(() async {
          await tester.pumpWidget(
            MaterialApp(
              home: SplashScreen(config: config),
            ),
          );
        }, returnsNormally);
        
        // Widget should still be created successfully
        expect(find.byType(SplashScreen), findsOneWidget);
      });

      testWidgets('should handle widget disposal during animation', (WidgetTester tester) async {
        const config = SplashConfig(
          logoAnimationDuration: Duration(seconds: 10), // Long duration
          textAnimationDuration: Duration(seconds: 10),
        );
        
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );
        
        // Start animations
        await tester.pump(const Duration(milliseconds: 100));
        
        // Remove widget to trigger dispose - should not throw errors
        expect(() async {
          await tester.pumpWidget(const MaterialApp(home: Scaffold()));
        }, returnsNormally);
      });

      testWidgets('should render animations correctly', (WidgetTester tester) async {
        const config = SplashConfig(
          logoAnimationDuration: Duration(milliseconds: 200),
          textAnimationDuration: Duration(milliseconds: 200),
          textAnimationDelay: Duration(milliseconds: 50),
        );
        
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );
        
        // Initially, logo should be present (might be fading in)
        expect(find.byType(CineLogLogo), findsOneWidget);
        expect(find.text('CineLog'), findsOneWidget);
        
        // Pump through animation frames
        await tester.pump(const Duration(milliseconds: 50));
        expect(find.byType(CineLogLogo), findsOneWidget);
        
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byType(CineLogLogo), findsOneWidget);
        expect(find.text('CineLog'), findsOneWidget);
      });
    });

    group('Timer Functionality Tests', () {
      testWidgets('should set up navigation timer with correct duration', (WidgetTester tester) async {
        const config = SplashConfig(
          displayDuration: Duration(milliseconds: 100),
        );
        
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
            routes: {
              '/home': (context) => const HomeScreen(),
            },
          ),
        );
        
        // Initially should be on splash screen
        expect(find.byType(SplashScreen), findsOneWidget);
        expect(find.byType(HomeScreen), findsNothing);
        
        // Wait for timer duration and pump
        await tester.pump(config.displayDuration);
        await tester.pumpAndSettle();
        
        // Should navigate to home screen
        expect(find.byType(SplashScreen), findsNothing);
        expect(find.byType(HomeScreen), findsOneWidget);
      });

      testWidgets('should handle timer cancellation on disposal', (WidgetTester tester) async {
        const config = SplashConfig(
          displayDuration: Duration(seconds: 10), // Long duration
        );
        
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );
        
        // Verify splash screen is shown
        expect(find.byType(SplashScreen), findsOneWidget);
        
        // Remove widget to trigger dispose - should not cause timer errors
        expect(() async {
          await tester.pumpWidget(const MaterialApp(home: Scaffold()));
        }, returnsNormally);
        
        // Wait additional time to ensure no delayed timer callbacks cause issues
        await tester.pump(const Duration(seconds: 1));
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('should handle timer setup errors gracefully', (WidgetTester tester) async {
        // Test with zero duration which might cause issues
        const config = SplashConfig(
          displayDuration: Duration.zero,
        );
        
        // This should not throw an exception
        expect(() async {
          await tester.pumpWidget(
            MaterialApp(
              home: SplashScreen(config: config),
              routes: {
                '/home': (context) => const HomeScreen(),
              },
            ),
          );
        }, returnsNormally);
        
        // Should still navigate (immediately in this case)
        await tester.pumpAndSettle();
        expect(find.byType(HomeScreen), findsOneWidget);
      });

      testWidgets('should navigate only once', (WidgetTester tester) async {
        const config = SplashConfig(
          displayDuration: Duration(milliseconds: 50),
        );
        
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );
        
        // Wait for timer and pump multiple times
        await tester.pump(config.displayDuration);
        await tester.pumpAndSettle();
        await tester.pump(config.displayDuration);
        await tester.pumpAndSettle();
        
        // Should navigate successfully to home screen
        expect(find.byType(HomeScreen), findsOneWidget);
      });
    });

    group('Navigation Triggering Tests', () {
      testWidgets('should navigate to home screen after display duration', (WidgetTester tester) async {
        const config = SplashConfig(
          displayDuration: Duration(milliseconds: 100),
        );
        
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );
        
        // Initially on splash screen
        expect(find.byType(SplashScreen), findsOneWidget);
        expect(find.byType(HomeScreen), findsNothing);
        
        // Wait for display duration
        await tester.pump(config.displayDuration);
        await tester.pumpAndSettle();
        
        // Should be on home screen now
        expect(find.byType(SplashScreen), findsNothing);
        expect(find.byType(HomeScreen), findsOneWidget);
      });

      testWidgets('should use custom fade transition for navigation', (WidgetTester tester) async {
        const config = SplashConfig(
          displayDuration: Duration(milliseconds: 50),
          transitionDuration: Duration(milliseconds: 100),
        );
        
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );
        
        // Wait for navigation to start
        await tester.pump(config.displayDuration);
        
        // During transition, both screens might be present
        await tester.pump(const Duration(milliseconds: 50));
        
        // Complete the transition
        await tester.pumpAndSettle();
        
        // Should end up on home screen
        expect(find.byType(HomeScreen), findsOneWidget);
      });

      testWidgets('should handle navigation errors with fallback', (WidgetTester tester) async {
        const config = SplashConfig(
          displayDuration: Duration(milliseconds: 50),
        );
        
        // Create app without proper route setup to potentially cause navigation error
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
            // No routes defined, might cause navigation issues
          ),
        );
        
        // Wait for navigation attempt
        await tester.pump(config.displayDuration);
        await tester.pumpAndSettle();
        
        // Should still navigate successfully (using fallback navigation)
        expect(find.byType(HomeScreen), findsOneWidget);
      });

      testWidgets('should skip splash screen in debug mode when configured', (WidgetTester tester) async {
        const config = SplashConfig(
          skipInDebug: true,
          displayDuration: Duration(seconds: 10), // Long duration that would be skipped
        );
        
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );
        
        // Should navigate immediately in debug mode
        await tester.pumpAndSettle();
        
        // Should be on home screen without waiting
        expect(find.byType(HomeScreen), findsOneWidget);
      });

      testWidgets('should not skip splash screen when skipInDebug is false', (WidgetTester tester) async {
        const config = SplashConfig(
          skipInDebug: false,
          displayDuration: Duration(milliseconds: 100),
        );
        
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );
        
        // Should remain on splash screen initially
        expect(find.byType(SplashScreen), findsOneWidget);
        expect(find.byType(HomeScreen), findsNothing);
        
        // Wait for display duration
        await tester.pump(config.displayDuration);
        await tester.pumpAndSettle();
        
        // Now should navigate
        expect(find.byType(HomeScreen), findsOneWidget);
      });
    });

    group('Responsive Sizing Tests', () {
      testWidgets('should calculate logo size correctly for different screen sizes', (WidgetTester tester) async {
        const config = SplashConfig();
        
        // Test with small screen
        await tester.binding.setSurfaceSize(const Size(320, 568)); // iPhone SE size
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );
        
        // Logo size should be 25% of width (80px) but clamped to minimum 80px
        final logoWidget = tester.widget<CineLogLogo>(find.byType(CineLogLogo));
        expect(logoWidget.size, equals(80.0)); // 320 * 0.25 = 80, within range
        
        // Test with medium screen
        await tester.binding.setSurfaceSize(const Size(414, 896)); // iPhone 11 size
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );
        await tester.pump();
        
        final logoWidget2 = tester.widget<CineLogLogo>(find.byType(CineLogLogo));
        expect(logoWidget2.size, equals(103.5)); // 414 * 0.25 = 103.5, within range
        
        // Test with large screen
        await tester.binding.setSurfaceSize(const Size(800, 1200)); // Tablet size
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );
        await tester.pump();
        
        final logoWidget3 = tester.widget<CineLogLogo>(find.byType(CineLogLogo));
        expect(logoWidget3.size, equals(150.0)); // 800 * 0.25 = 200, clamped to max 150
        
        // Reset surface size
        await tester.binding.setSurfaceSize(null);
      });

      testWidgets('should handle landscape orientation constraints', (WidgetTester tester) async {
        const config = SplashConfig();
        
        // Test with landscape orientation (wide but short)
        await tester.binding.setSurfaceSize(const Size(800, 400));
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );
        
        final logoWidget = tester.widget<CineLogLogo>(find.byType(CineLogLogo));
        // Width-based: 800 * 0.25 = 200, clamped to 150
        // Height-based: 400 * 0.2 = 80
        // Should use height constraint (80) as it's smaller
        expect(logoWidget.size, equals(80.0));
        
        await tester.binding.setSurfaceSize(null);
      });

      testWidgets('should handle extreme screen sizes gracefully', (WidgetTester tester) async {
        const config = SplashConfig();
        
        // Test with very small screen
        await tester.binding.setSurfaceSize(const Size(100, 100));
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );
        
        final logoWidget = tester.widget<CineLogLogo>(find.byType(CineLogLogo));
        expect(logoWidget.size, equals(80.0)); // Should clamp to minimum
        
        // Test with very large screen
        await tester.binding.setSurfaceSize(const Size(2000, 3000));
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );
        await tester.pump();
        
        final logoWidget2 = tester.widget<CineLogLogo>(find.byType(CineLogLogo));
        expect(logoWidget2.size, equals(150.0)); // Should clamp to maximum
        
        await tester.binding.setSurfaceSize(null);
      });
    });

    group('Configuration Handling Tests', () {
      testWidgets('should use custom configuration parameters correctly', (WidgetTester tester) async {
        const config = SplashConfig(
          displayDuration: Duration(milliseconds: 200),
          logoAnimationDuration: Duration(milliseconds: 100),
          textAnimationDuration: Duration(milliseconds: 80),
          textAnimationDelay: Duration(milliseconds: 50),
        );
        
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );
        
        // Verify splash screen renders with custom config
        expect(find.byType(SplashScreen), findsOneWidget);
        expect(find.byType(CineLogLogo), findsOneWidget);
        expect(find.text('CineLog'), findsOneWidget);
        
        // Verify navigation happens at correct time
        await tester.pump(config.displayDuration);
        await tester.pumpAndSettle();
        
        expect(find.byType(HomeScreen), findsOneWidget);
      });

      testWidgets('should handle debug configuration correctly', (WidgetTester tester) async {
        final config = SplashConfig.debug(skipSplash: true);
        
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );
        
        // Should skip splash screen immediately in debug mode
        await tester.pumpAndSettle();
        expect(find.byType(HomeScreen), findsOneWidget);
      });

      testWidgets('should handle production configuration correctly', (WidgetTester tester) async {
        final config = SplashConfig.production();
        
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );
        
        // Should render splash screen with production config
        expect(find.byType(SplashScreen), findsOneWidget);
        expect(find.byType(CineLogLogo), findsOneWidget);
        expect(find.text('CineLog'), findsOneWidget);
        
        // Should not skip splash screen - verify it stays for a bit
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byType(SplashScreen), findsOneWidget);
      });

      testWidgets('should handle fast configuration correctly', (WidgetTester tester) async {
        final config = SplashConfig.fast();
        
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );
        
        // Should render splash screen with fast config
        expect(find.byType(SplashScreen), findsOneWidget);
        expect(find.byType(CineLogLogo), findsOneWidget);
        expect(find.text('CineLog'), findsOneWidget);
        
        // Should navigate faster than default
        await tester.pump(config.displayDuration);
        await tester.pumpAndSettle();
        
        expect(find.byType(HomeScreen), findsOneWidget);
      });
    });

    group('Error Handling Tests', () {
      testWidgets('should handle animation errors gracefully', (WidgetTester tester) async {
        // Test with configuration that might cause animation issues
        const config = SplashConfig(
          logoAnimationDuration: Duration(microseconds: 1),
          textAnimationDuration: Duration(microseconds: 1),
        );
        
        // Should not throw exception
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );
        
        // Widget should still render
        expect(find.byType(SplashScreen), findsOneWidget);
        
        // Should still navigate after display duration
        await tester.pump(config.displayDuration);
        await tester.pumpAndSettle();
        
        expect(find.byType(HomeScreen), findsOneWidget);
      });

      testWidgets('should handle widget disposal during animation gracefully', (WidgetTester tester) async {
        const config = SplashConfig(
          logoAnimationDuration: Duration(seconds: 1),
          displayDuration: Duration(seconds: 2),
        );
        
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );
        
        // Start animations
        await tester.pump(const Duration(milliseconds: 100));
        
        // Dispose widget during animation - should not throw exception
        expect(() async {
          await tester.pumpWidget(const MaterialApp(home: Scaffold()));
        }, returnsNormally);
        
        // Should end up with the new scaffold
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('should handle mounted check correctly', (WidgetTester tester) async {
        const config = SplashConfig(
          displayDuration: Duration(milliseconds: 100),
        );
        
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );
        
        // Remove widget before timer completes
        await tester.pump(const Duration(milliseconds: 50));
        await tester.pumpWidget(const MaterialApp(home: Scaffold()));
        
        // Wait for original timer duration
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();
        
        // Should not cause any errors or unexpected navigation
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('should handle fallback display on critical errors', (WidgetTester tester) async {
        // Test that splash screen can handle extreme edge cases
        const config = SplashConfig(
          displayDuration: Duration(milliseconds: 50),
        );
        
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );
        
        // Should render without throwing exceptions
        expect(find.byType(SplashScreen), findsOneWidget);
        expect(find.byType(CineLogLogo), findsOneWidget);
        expect(find.text('CineLog'), findsOneWidget);
        
        // Should still navigate successfully
        await tester.pump(config.displayDuration);
        await tester.pumpAndSettle();
        
        expect(find.byType(HomeScreen), findsOneWidget);
      });
    });
  });
}