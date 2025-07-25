import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cinelog/screens/splash_screen.dart';
import 'package:cinelog/models/splash_config.dart';

void main() {
  group('SplashScreen Configuration', () {
    testWidgets('should use default configuration when none provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      // Verify splash screen is displayed
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('CineLog'), findsOneWidget);
    });

    testWidgets('should use custom configuration', (WidgetTester tester) async {
      const customConfig = SplashConfig(
        displayDuration: Duration(milliseconds: 100),
        logoAnimationDuration: Duration(milliseconds: 50),
        textAnimationDuration: Duration(milliseconds: 50),
        transitionDuration: Duration(milliseconds: 50),
        textAnimationDelay: Duration(milliseconds: 25),
        skipInDebug: false,
        enableDebugLogging: true,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(config: customConfig),
        ),
      );

      // Verify splash screen is displayed with custom config
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('CineLog'), findsOneWidget);
      
      // Verify the config is being used (we can't directly test internal state,
      // but we can verify the widget builds successfully with the config)
      final splashWidget = tester.widget<SplashScreen>(find.byType(SplashScreen));
      expect(splashWidget.config, equals(customConfig));
    });

    testWidgets('should skip splash screen when configured in debug mode', (WidgetTester tester) async {
      final skipConfig = SplashConfig.debug(skipSplash: true);

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(config: skipConfig),
        ),
      );

      // In debug mode with skipSplash = true, the splash should attempt to navigate immediately
      // We can verify the widget is created but may not be visible for long
      expect(find.byType(SplashScreen), findsOneWidget);
    });

    testWidgets('should use fast configuration', (WidgetTester tester) async {
      final fastConfig = SplashConfig.fast();

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(config: fastConfig),
        ),
      );

      // Verify splash screen is displayed
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('CineLog'), findsOneWidget);
      
      // Verify the fast config is being used
      final splashWidget = tester.widget<SplashScreen>(find.byType(SplashScreen));
      expect(splashWidget.config.displayDuration, const Duration(milliseconds: 1500));
      expect(splashWidget.config.logoAnimationDuration, const Duration(milliseconds: 400));
    });

    testWidgets('should use production configuration', (WidgetTester tester) async {
      final prodConfig = SplashConfig.production();

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(config: prodConfig),
        ),
      );

      // Verify splash screen is displayed
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('CineLog'), findsOneWidget);
      
      // Verify the production config is being used
      final splashWidget = tester.widget<SplashScreen>(find.byType(SplashScreen));
      expect(splashWidget.config.displayDuration, const Duration(seconds: 3));
      expect(splashWidget.config.skipInDebug, false);
      expect(splashWidget.config.enableDebugLogging, false);
    });
  });
}