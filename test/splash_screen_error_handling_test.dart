import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cinelog/screens/splash_screen.dart';
import 'package:cinelog/models/splash_config.dart';
import 'package:cinelog/widgets/cinelog_logo.dart';

void main() {
  group('SplashScreen Error Handling Tests', () {
    testWidgets('should display splash screen elements without errors', (WidgetTester tester) async {
      // Create a config with very short durations to avoid navigation
      const config = SplashConfig(
        displayDuration: Duration(seconds: 10), // Long enough to avoid navigation during test
        logoAnimationDuration: Duration(milliseconds: 50),
        textAnimationDuration: Duration(milliseconds: 50),
        enableDebugLogging: true,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(config: config),
        ),
      );

      // Verify splash screen is displayed even with potential animation errors
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('CineLog'), findsOneWidget);
      expect(find.byType(CineLogLogo), findsOneWidget);

      // Pump a few frames to let animations start
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('should handle skip splash configuration without errors', (WidgetTester tester) async {
      const config = SplashConfig(
        skipInDebug: true,
        displayDuration: Duration(seconds: 10),
        enableDebugLogging: true,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(config: config),
        ),
      );

      // Verify splash screen widget is created
      expect(find.byType(SplashScreen), findsOneWidget);

      // Pump a frame to initialize
      await tester.pump();
    });

    testWidgets('should properly dispose resources without errors', (WidgetTester tester) async {
      const config = SplashConfig(
        displayDuration: Duration(seconds: 10),
        enableDebugLogging: true,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(config: config),
        ),
      );

      // Verify splash screen is displayed
      expect(find.byType(SplashScreen), findsOneWidget);

      // Navigate away to trigger dispose
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Text('New Screen')),
        ),
      );

      // Verify no errors during disposal
      expect(find.text('New Screen'), findsOneWidget);
    });

    testWidgets('should handle MediaQuery errors gracefully', (WidgetTester tester) async {
      const config = SplashConfig(
        displayDuration: Duration(seconds: 10),
        enableDebugLogging: true,
      );

      // Test with minimal screen size that might cause calculation issues
      tester.binding.window.physicalSizeTestValue = const Size(100, 100);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(config: config),
        ),
      );

      // Verify splash screen still renders with fallback values
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('CineLog'), findsOneWidget);

      // Reset window size
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      
      // Pump a frame to render
      await tester.pump();
    });

    testWidgets('should handle animation controller initialization', (WidgetTester tester) async {
      const config = SplashConfig(
        displayDuration: Duration(seconds: 10),
        logoAnimationDuration: Duration(milliseconds: 100),
        textAnimationDuration: Duration(milliseconds: 100),
        enableDebugLogging: true,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(config: config),
        ),
      );

      // Verify splash screen is displayed
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('CineLog'), findsOneWidget);

      // Pump a few frames to let animations initialize
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('should display fallback UI elements correctly', (WidgetTester tester) async {
      const config = SplashConfig(
        displayDuration: Duration(seconds: 10),
        enableDebugLogging: true,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(config: config),
        ),
      );

      // Verify basic elements are present
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('CineLog'), findsOneWidget);
      expect(find.byType(CineLogLogo), findsOneWidget);

      // Verify the scaffold and background
      expect(find.byType(Scaffold), findsOneWidget);
      
      // Pump a frame to render
      await tester.pump();
    });
  });
}