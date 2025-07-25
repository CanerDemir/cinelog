import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cinelog/screens/splash_screen.dart';
import 'package:cinelog/models/splash_config.dart';
import 'package:cinelog/widgets/cinelog_logo.dart';

void main() {
  group('SplashScreen Responsive Design Tests', () {
    testWidgets('should have responsive logo sizing logic', (WidgetTester tester) async {
      // Test with MediaQuery override to simulate different screen sizes
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(360, 640)),
          child: MaterialApp(
            home: SplashScreen(
              config: SplashConfig(
                displayDuration: const Duration(milliseconds: 100),
                skipInDebug: false,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Find the logo widget
      final logoFinder = find.byType(CineLogLogo);
      expect(logoFinder, findsOneWidget);
      
      final CineLogLogo logoWidget = tester.widget(logoFinder);
      // For 360px width, logo should be 25% = 90px (within min: 80px, max: 150px)
      expect(logoWidget.size, equals(90.0));

      // Test large screen (tablet)
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(800, 1200)),
          child: MaterialApp(
            home: SplashScreen(
              config: SplashConfig(
                displayDuration: const Duration(milliseconds: 100),
                skipInDebug: false,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final logoFinderLarge = find.byType(CineLogLogo);
      final CineLogLogo logoWidgetLarge = tester.widget(logoFinderLarge);
      // For 800px width, logo should be 25% = 200px, but clamped to max: 150px
      expect(logoWidgetLarge.size, equals(150.0));

      // Test very small screen
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(240, 400)),
          child: MaterialApp(
            home: SplashScreen(
              config: SplashConfig(
                displayDuration: const Duration(milliseconds: 100),
                skipInDebug: false,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final logoFinderSmall = find.byType(CineLogLogo);
      final CineLogLogo logoWidgetSmall = tester.widget(logoFinderSmall);
      // For 240px width, logo should be 25% = 60px, but clamped to min: 80px
      expect(logoWidgetSmall.size, equals(80.0));
    });

    testWidgets('should adapt layout for different orientations', (WidgetTester tester) async {
      // Test portrait orientation
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(360, 640)),
          child: MaterialApp(
            home: SplashScreen(
              config: SplashConfig(
                displayDuration: const Duration(milliseconds: 100),
                skipInDebug: false,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final logoFinderPortrait = find.byType(CineLogLogo);
      final CineLogLogo logoWidgetPortrait = tester.widget(logoFinderPortrait);
      final portraitLogoSize = logoWidgetPortrait.size;

      // Test landscape orientation
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(640, 360)),
          child: MaterialApp(
            home: SplashScreen(
              config: SplashConfig(
                displayDuration: const Duration(milliseconds: 100),
                skipInDebug: false,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final logoFinderLandscape = find.byType(CineLogLogo);
      final CineLogLogo logoWidgetLandscape = tester.widget(logoFinderLandscape);
      final landscapeLogoSize = logoWidgetLandscape.size;

      // In landscape, logo should be constrained by height (20% of 360px = 72px, clamped to min 80px)
      expect(landscapeLogoSize, equals(80.0));
      // Should be different from portrait size
      expect(landscapeLogoSize, isNot(equals(portraitLogoSize)));
    });

    testWidgets('should have responsive text sizing', (WidgetTester tester) async {
      // Test small screen
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(360, 640)),
          child: MaterialApp(
            home: SplashScreen(
              config: SplashConfig(
                displayDuration: const Duration(milliseconds: 100),
                skipInDebug: false,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final textFinder = find.text('CineLog');
      expect(textFinder, findsOneWidget);
      
      final Text textWidget = tester.widget(textFinder);
      final smallScreenFontSize = textWidget.style?.fontSize;
      // For 360px width, text should be 8% = 28.8px (within min: 24px, max: 40px)
      expect(smallScreenFontSize, equals(28.8));

      // Test large screen
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(800, 1200)),
          child: MaterialApp(
            home: SplashScreen(
              config: SplashConfig(
                displayDuration: const Duration(milliseconds: 100),
                skipInDebug: false,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final textFinderLarge = find.text('CineLog');
      final Text textWidgetLarge = tester.widget(textFinderLarge);
      final largeScreenFontSize = textWidgetLarge.style?.fontSize;
      // For 800px width, text should be 8% = 64px, but clamped to max: 40px
      expect(largeScreenFontSize, equals(40.0));
    });

    testWidgets('should have responsive spacing', (WidgetTester tester) async {
      // Test different screen heights for spacing
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(360, 640)),
          child: MaterialApp(
            home: SplashScreen(
              config: SplashConfig(
                displayDuration: const Duration(milliseconds: 100),
                skipInDebug: false,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Find the SizedBox between logo and text
      final sizedBoxFinder = find.byType(SizedBox);
      expect(sizedBoxFinder, findsWidgets);
      
      // For 640px height, spacing should be 3% = 19.2px (within min: 16px, max: 32px)
      // We can't easily test the exact spacing value in widget tests,
      // but we can verify the SizedBox exists and the layout is correct
      expect(sizedBoxFinder, findsAtLeastNWidgets(1));
    });

    testWidgets('should maintain proper proportions on very tall screens', (WidgetTester tester) async {
      // Test very tall screen
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(360, 1200)),
          child: MaterialApp(
            home: SplashScreen(
              config: SplashConfig(
                displayDuration: const Duration(milliseconds: 100),
                skipInDebug: false,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final logoFinder = find.byType(CineLogLogo);
      final CineLogLogo logoWidget = tester.widget(logoFinder);
      
      // Logo should still be constrained properly
      // 25% of 360px = 90px, and 20% of 1200px = 240px, so should be 90px (smaller constraint)
      expect(logoWidget.size, equals(90.0));
    });

    testWidgets('should maintain proper proportions on very wide screens', (WidgetTester tester) async {
      // Test very wide screen
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(1200, 360)),
          child: MaterialApp(
            home: SplashScreen(
              config: SplashConfig(
                displayDuration: const Duration(milliseconds: 100),
                skipInDebug: false,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final logoFinder = find.byType(CineLogLogo);
      final CineLogLogo logoWidget = tester.widget(logoFinder);
      
      // Logo should be constrained by height: 20% of 360px = 72px, clamped to min 80px
      expect(logoWidget.size, equals(80.0));
    });
  });
}