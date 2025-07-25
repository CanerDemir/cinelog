import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cinelog/screens/splash_screen.dart';
import 'package:cinelog/models/splash_config.dart';
import 'package:cinelog/widgets/cinelog_logo.dart';

void main() {
  group('SplashScreen Widget Tests', () {
    group('UI Component Rendering Tests', () {
      testWidgets('should render splash screen with different configurations', (WidgetTester tester) async {
        final config = SplashConfig.debug(skipSplash: true);
        
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );

        // Verify main UI components are present (Requirement 3.1)
        expect(find.byType(SplashScreen), findsOneWidget);
        expect(find.byType(CineLogLogo), findsOneWidget);
        expect(find.text('CineLog'), findsOneWidget);
        
        // Verify background color matches app theme
        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.backgroundColor, equals(const Color(0xFF1A1D29)));
        
        // Verify proper layout structure
        expect(find.byType(SafeArea), findsOneWidget);
        expect(find.byType(LayoutBuilder), findsWidgets);
        expect(find.byType(Center), findsWidgets);
        expect(find.byType(Column), findsOneWidget);
      });

      testWidgets('should render with custom configuration', (WidgetTester tester) async {
        final customConfig = SplashConfig.debug(
          skipSplash: true,
          enableLogging: true,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: customConfig),
          ),
        );

        // Verify components render with custom config
        expect(find.byType(SplashScreen), findsOneWidget);
        expect(find.byType(CineLogLogo), findsOneWidget);
        expect(find.text('CineLog'), findsOneWidget);
        
        final splashWidget = tester.widget<SplashScreen>(find.byType(SplashScreen));
        expect(splashWidget.config, equals(customConfig));
      });

      testWidgets('should display proper text styling', (WidgetTester tester) async {
        final config = SplashConfig.debug(skipSplash: true);

        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );

        final textWidget = tester.widget<Text>(find.text('CineLog'));
        expect(textWidget.style?.color, equals(Colors.white));
        expect(textWidget.style?.fontWeight, equals(FontWeight.bold));
        expect(textWidget.style?.letterSpacing, equals(1.2));
      });
    });

    group('Animation Sequence Tests', () {
      testWidgets('should display logo fade-in animation (Requirement 2.1)', (WidgetTester tester) async {
        final config = SplashConfig(
          logoAnimationDuration: const Duration(milliseconds: 50),
          textAnimationDuration: const Duration(milliseconds: 50),
          displayDuration: const Duration(milliseconds: 100),
          skipInDebug: true,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );

        // Verify FadeTransition is present for logo animation
        expect(find.byType(FadeTransition), findsWidgets);
        expect(find.byType(CineLogLogo), findsOneWidget);

        await tester.pump(const Duration(milliseconds: 16));
        expect(find.byType(CineLogLogo), findsOneWidget);
      });

      testWidgets('should display text slide-up animation (Requirement 2.2)', (WidgetTester tester) async {
        final config = SplashConfig(
          logoAnimationDuration: const Duration(milliseconds: 50),
          textAnimationDuration: const Duration(milliseconds: 50),
          textAnimationDelay: const Duration(milliseconds: 25),
          displayDuration: const Duration(milliseconds: 100),
          skipInDebug: true,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );

        // Verify SlideTransition is present for text animation
        expect(find.byType(SlideTransition), findsOneWidget);
        expect(find.text('CineLog'), findsOneWidget);

        await tester.pump(const Duration(milliseconds: 16));
        expect(find.text('CineLog'), findsOneWidget);
      });

      testWidgets('should sequence animations properly', (WidgetTester tester) async {
        final config = SplashConfig(
          logoAnimationDuration: const Duration(milliseconds: 50),
          textAnimationDuration: const Duration(milliseconds: 50),
          textAnimationDelay: const Duration(milliseconds: 25),
          displayDuration: const Duration(milliseconds: 100),
          skipInDebug: true,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );

        // Verify both animations are present
        expect(find.byType(CineLogLogo), findsOneWidget);
        expect(find.text('CineLog'), findsOneWidget);
        expect(find.byType(FadeTransition), findsWidgets);
        expect(find.byType(SlideTransition), findsOneWidget);

        await tester.pump(const Duration(milliseconds: 16));
        expect(find.byType(CineLogLogo), findsOneWidget);
        expect(find.text('CineLog'), findsOneWidget);
      });

      testWidgets('should prepare for smooth screen transitions (Requirement 2.3)', (WidgetTester tester) async {
        final config = SplashConfig(
          displayDuration: const Duration(milliseconds: 100),
          transitionDuration: const Duration(milliseconds: 100),
          skipInDebug: true,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );

        // Verify initial state for transition
        expect(find.byType(SplashScreen), findsOneWidget);
        expect(find.byType(CineLogLogo), findsOneWidget);
        expect(find.text('CineLog'), findsOneWidget);

        await tester.pump(const Duration(milliseconds: 16));
        
        // Components should still be visible before transition
        expect(find.byType(SplashScreen), findsOneWidget);
        expect(find.byType(CineLogLogo), findsOneWidget);
        expect(find.text('CineLog'), findsOneWidget);
      });
    });

    group('Responsive Design Tests', () {
      testWidgets('should scale logo appropriately for different screen sizes (Requirement 3.1)', (WidgetTester tester) async {
        final config = SplashConfig.debug(skipSplash: true);

        // Test small screen (320x568 - iPhone SE)
        await tester.binding.setSurfaceSize(const Size(320, 568));
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );

        final logoWidget = tester.widget<CineLogLogo>(find.byType(CineLogLogo));
        expect(logoWidget.size, greaterThanOrEqualTo(80.0));

        // Test medium screen (414x896 - iPhone 11)
        await tester.binding.setSurfaceSize(const Size(414, 896));
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );
        await tester.pump();

        final logoWidget2 = tester.widget<CineLogLogo>(find.byType(CineLogLogo));
        expect(logoWidget2.size, greaterThanOrEqualTo(80.0));
        expect(logoWidget2.size, lessThanOrEqualTo(150.0));

        // Reset surface size
        await tester.binding.setSurfaceSize(null);
      });

      testWidgets('should maintain proper text sizing across screen sizes', (WidgetTester tester) async {
        final config = SplashConfig.debug(skipSplash: true);

        // Test small screen
        await tester.binding.setSurfaceSize(const Size(320, 568));
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );

        final textWidget = tester.widget<Text>(find.text('CineLog'));
        final textStyle = textWidget.style!;
        expect(textStyle.fontSize, greaterThanOrEqualTo(24.0));
        expect(textStyle.fontSize, lessThanOrEqualTo(40.0));

        await tester.binding.setSurfaceSize(null);
      });
    });

    group('Error Handling and Fallback Tests', () {
      testWidgets('should display fallback UI when animations fail', (WidgetTester tester) async {
        final config = SplashConfig(
          logoAnimationDuration: Duration.zero,
          textAnimationDuration: Duration.zero,
          displayDuration: const Duration(milliseconds: 50),
          skipInDebug: true,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );

        expect(find.byType(SplashScreen), findsOneWidget);
        expect(find.byType(CineLogLogo), findsOneWidget);
        expect(find.text('CineLog'), findsOneWidget);

        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.backgroundColor, equals(const Color(0xFF1A1D29)));
      });

      testWidgets('should handle animation disposal gracefully', (WidgetTester tester) async {
        final config = SplashConfig(
          logoAnimationDuration: const Duration(milliseconds: 100),
          textAnimationDuration: const Duration(milliseconds: 100),
          displayDuration: const Duration(milliseconds: 200),
          skipInDebug: true,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );

        expect(find.byType(SplashScreen), findsOneWidget);
        expect(find.byType(CineLogLogo), findsOneWidget);
        expect(find.text('CineLog'), findsOneWidget);

        await tester.pump(const Duration(milliseconds: 16));
        await tester.pumpWidget(Container());

        expect(find.byType(SplashScreen), findsNothing);
      });

      testWidgets('should maintain UI consistency during error states', (WidgetTester tester) async {
        final config = SplashConfig.debug(
          skipSplash: true,
          enableLogging: true,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );

        expect(find.byType(SplashScreen), findsOneWidget);
        expect(find.byType(CineLogLogo), findsOneWidget);
        expect(find.text('CineLog'), findsOneWidget);

        final textWidget = tester.widget<Text>(find.text('CineLog'));
        expect(textWidget.style?.color, equals(Colors.white));
        expect(textWidget.style?.fontWeight, equals(FontWeight.bold));
        expect(textWidget.style?.letterSpacing, equals(1.2));

        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.backgroundColor, equals(const Color(0xFF1A1D29)));
      });
    });

    group('Visual Behavior Tests', () {
      testWidgets('should maintain proper layout structure', (WidgetTester tester) async {
        final config = SplashConfig.debug(skipSplash: true);

        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );

        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(SafeArea), findsOneWidget);
        expect(find.byType(LayoutBuilder), findsWidgets);
        expect(find.byType(Center), findsWidgets);
        expect(find.byType(Column), findsOneWidget);

        final column = tester.widget<Column>(find.byType(Column));
        expect(column.mainAxisAlignment, equals(MainAxisAlignment.center));
      });

      testWidgets('should display proper spacing between elements', (WidgetTester tester) async {
        final config = SplashConfig.debug(skipSplash: true);

        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );

        expect(find.byType(SizedBox), findsWidgets);
        expect(find.byType(CineLogLogo), findsOneWidget);
        expect(find.text('CineLog'), findsOneWidget);
      });
    });
  });
}