import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cinelog/screens/splash_screen.dart';
import 'package:cinelog/models/splash_config.dart';

void main() {
  group('SplashScreen Basic Tests', () {
    testWidgets('should display splash screen with default config', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      // Verify splash screen is displayed
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('CineLog'), findsOneWidget);
    });

    testWidgets('should use custom config parameters', (WidgetTester tester) async {
      const customConfig = SplashConfig(
        displayDuration: Duration(milliseconds: 100),
        logoAnimationDuration: Duration(milliseconds: 50),
        textAnimationDuration: Duration(milliseconds: 50),
        skipInDebug: false,
        enableDebugLogging: false,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(config: customConfig),
        ),
      );

      // Verify splash screen is displayed
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('CineLog'), findsOneWidget);
      
      // Verify the config is being used
      final splashWidget = tester.widget<SplashScreen>(find.byType(SplashScreen));
      expect(splashWidget.config, equals(customConfig));
    });

    testWidgets('should handle skip splash configuration', (WidgetTester tester) async {
      final skipConfig = SplashConfig(
        skipInDebug: true,
        enableDebugLogging: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(config: skipConfig),
        ),
      );

      // Verify splash screen widget is created
      expect(find.byType(SplashScreen), findsOneWidget);
      
      // The widget should handle the skip case gracefully
      final splashWidget = tester.widget<SplashScreen>(find.byType(SplashScreen));
      expect(splashWidget.config.skipInDebug, true);
    });
  });
}