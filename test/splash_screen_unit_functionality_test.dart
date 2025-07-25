import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cinelog/screens/splash_screen.dart';
import 'package:cinelog/models/splash_config.dart';
import 'package:cinelog/widgets/cinelog_logo.dart';

void main() {
  group('SplashScreen Unit Functionality Tests', () {
    group('Animation Controller Initialization and Disposal', () {
      testWidgets('should initialize splash screen without errors', (WidgetTester tester) async {
        const config = SplashConfig(
          logoAnimationDuration: Duration(milliseconds: 100),
          textAnimationDuration: Duration(milliseconds: 100),
          displayDuration: Duration(milliseconds: 200),
        );
        
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );
        
        // Verify the widget is created successfully
        expect(find.byType(SplashScreen), findsOneWidget);
        expect(find.byType(CineLogLogo), findsOneWidget);
        expect(find.text('CineLog'), findsOneWidget);
      });

      testWidgets('should dispose properly without throwing errors', (WidgetTester tester) async {
        const config = SplashConfig(
          logoAnimationDuration: Duration(milliseconds: 100),
          textAnimationDuration: Duration(milliseconds: 100),
          displayDuration: Duration(milliseconds: 200),
        );
        
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );
        
        // Verify widget is rendered
        expect(find.byType(SplashScreen), findsOneWidget);
        
        // Remove the widget to trigger dispose - should not throw errors
        await tester.pumpWidget(const MaterialApp(home: Scaffold()));
        
        // Should complete without errors
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('should handle extreme animation durations gracefully', (WidgetTester tester) async {
        const config = SplashConfig(
          logoAnimationDuration: Duration(microseconds: 1),
          textAnimationDuration: Duration(microseconds: 1),
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
      });

      testWidgets('should render animations correctly over time', (WidgetTester tester) async {
        const config = SplashConfig(
          logoAnimationDuration: Duration(milliseconds: 200),
          textAnimationDuration: Duration(milliseconds: 200),
          textAnimationDelay: Duration(milliseconds: 100),
          displayDuration: Duration(seconds: 2),
        );
        
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );
        
        // Initially, both logo and text should be present
        expect(find.byType(CineLogLogo), findsOneWidget);
        expect(find.text('CineLog'), findsOneWidget);
        
        // Pump through animation frames
        await tester.pump(const Duration(milliseconds: 50));
        expect(find.byType(CineLogLogo), findsOneWidget);
        
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byType(CineLogLogo), findsOneWidget);
        expect(find.text('CineLog'), findsOneWidget);
        
        await tester.pump(const Duration(milliseconds: 200));
        expect(find.byType(CineLogLogo), findsOneWidget);
        expect(find.text('CineLog'), findsOneWidget);
      });
    });

    group('Timer Functionality', () {
      testWidgets('should handle timer setup without errors', (WidgetTester tester) async {
        const config = SplashConfig(
          displayDuration: Duration(milliseconds: 100),
        );
        
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );
        
        // Initially should be on splash screen
        expect(find.byType(SplashScreen), findsOneWidget);
        
        // Pump some time but not the full duration
        await tester.pump(const Duration(milliseconds: 50));
        expect(find.byType(SplashScreen), findsOneWidget);
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
        await tester.pumpWidget(const MaterialApp(home: Scaffold()));
        
        // Wait additional time to ensure no delayed timer callbacks cause issues
        await tester.pump(const Duration(seconds: 1));
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('should handle zero duration gracefully', (WidgetTester tester) async {
        const config = SplashConfig(
          displayDuration: Duration.zero,
        );
        
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );
        
        // Should render without throwing exceptions
        expect(find.byType(SplashScreen), findsOneWidget);
      });
    });

    group('Responsive Sizing Calculations', () {
      testWidgets('should calculate logo size within constraints for normal screen', (WidgetTester tester) async {
        const config = SplashConfig();
        
        // Test with normal screen size
        await tester.binding.setSurfaceSize(const Size(400, 800));
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );
        
        // Logo should be present and sized appropriately
        expect(find.byType(CineLogLogo), findsOneWidget);
        
        final logoWidget = tester.widget<CineLogLogo>(find.byType(CineLogLogo));
        // 400 * 0.25 = 100, which is within the 80-150 range
        expect(logoWidget.size, equals(100.0));
        
        await tester.binding.setSurfaceSize(null);
      });

      testWidgets('should handle minimum logo size constraint', (WidgetTester tester) async {
        const config = SplashConfig();
        
        // Test with small screen that would result in logo size below minimum
        await tester.binding.setSurfaceSize(const Size(200, 400));
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );
        
        expect(find.byType(CineLogLogo), findsOneWidget);
        
        final logoWidget = tester.widget<CineLogLogo>(find.byType(CineLogLogo));
        // 200 * 0.25 = 50, should clamp to minimum 80
        expect(logoWidget.size, equals(80.0));
        
        await tester.binding.setSurfaceSize(null);
      });

      testWidgets('should handle maximum logo size constraint', (WidgetTester tester) async {
        const config = SplashConfig();
        
        // Test with large screen that would result in logo size above maximum
        await tester.binding.setSurfaceSize(const Size(800, 1200));
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );
        
        expect(find.byType(CineLogLogo), findsOneWidget);
        
        final logoWidget = tester.widget<CineLogLogo>(find.byType(CineLogLogo));
        // 800 * 0.25 = 200, should clamp to maximum 150
        expect(logoWidget.size, equals(150.0));
        
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
        
        expect(find.byType(CineLogLogo), findsOneWidget);
        
        final logoWidget = tester.widget<CineLogLogo>(find.byType(CineLogLogo));
        // Width-based: 800 * 0.25 = 200, clamped to 150
        // Height-based: 400 * 0.2 = 80
        // Should use height constraint (80) as it's smaller
        expect(logoWidget.size, equals(80.0));
        
        await tester.binding.setSurfaceSize(null);
      });
    });

    group('Configuration Handling', () {
      testWidgets('should use custom configuration parameters', (WidgetTester tester) async {
        const config = SplashConfig(
          displayDuration: Duration(milliseconds: 300),
          logoAnimationDuration: Duration(milliseconds: 150),
          textAnimationDuration: Duration(milliseconds: 100),
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
        
        // Verify it stays rendered for a bit (not immediately navigating)
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byType(SplashScreen), findsOneWidget);
      });

      testWidgets('should handle debug configuration', (WidgetTester tester) async {
        final config = SplashConfig.debug(skipSplash: false, enableLogging: true);
        
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );
        
        // Should render splash screen with debug config
        expect(find.byType(SplashScreen), findsOneWidget);
        expect(find.byType(CineLogLogo), findsOneWidget);
        expect(find.text('CineLog'), findsOneWidget);
      });

      testWidgets('should handle production configuration', (WidgetTester tester) async {
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

      testWidgets('should handle fast configuration', (WidgetTester tester) async {
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
      });
    });

    group('Error Handling', () {
      testWidgets('should handle animation errors gracefully', (WidgetTester tester) async {
        // Test with configuration that might cause animation issues
        const config = SplashConfig(
          logoAnimationDuration: Duration(microseconds: 1),
          textAnimationDuration: Duration(microseconds: 1),
          displayDuration: Duration(milliseconds: 100),
        );
        
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );
        
        // Widget should still render
        expect(find.byType(SplashScreen), findsOneWidget);
        expect(find.byType(CineLogLogo), findsOneWidget);
        expect(find.text('CineLog'), findsOneWidget);
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
        await tester.pumpWidget(const MaterialApp(home: Scaffold()));
        
        // Should end up with the new scaffold
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('should handle mounted check correctly', (WidgetTester tester) async {
        const config = SplashConfig(
          displayDuration: Duration(milliseconds: 200),
        );
        
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );
        
        // Remove widget before timer completes
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpWidget(const MaterialApp(home: Scaffold()));
        
        // Wait for original timer duration
        await tester.pump(const Duration(milliseconds: 200));
        
        // Should not cause any errors or unexpected navigation
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('should render fallback display correctly', (WidgetTester tester) async {
        const config = SplashConfig(
          displayDuration: Duration(milliseconds: 100),
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
        
        // Verify background color is correct
        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.backgroundColor, const Color(0xFF1A1D29));
      });
    });

    group('Skip Splash Logic', () {
      testWidgets('should handle skip splash configuration', (WidgetTester tester) async {
        const config = SplashConfig(
          skipInDebug: false, // Don't skip in this test
          displayDuration: Duration(milliseconds: 100),
        );
        
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );
        
        // Should render splash screen normally
        expect(find.byType(SplashScreen), findsOneWidget);
        expect(find.byType(CineLogLogo), findsOneWidget);
        expect(find.text('CineLog'), findsOneWidget);
      });
    });
  });
}