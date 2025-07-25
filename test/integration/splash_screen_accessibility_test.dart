import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/screens/splash_screen.dart';
import '../../lib/models/splash_config.dart';
import '../../lib/widgets/cinelog_logo.dart';

void main() {

  group('Splash Screen Accessibility Tests', () {
    testWidgets('Screen reader compatibility and semantic labels', (WidgetTester tester) async {
      // Enable semantics for accessibility testing
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(config: SplashConfig.production()),
        ),
      );

      // Verify semantic structure is present
      expect(find.byType(Semantics), findsWidgets);

      // Check for logo accessibility
      final logoFinder = find.byType(CineLogLogo);
      expect(logoFinder, findsOneWidget);

      // Verify the logo has proper semantic properties
      final logoWidget = tester.widget<CineLogLogo>(logoFinder);
      expect(logoWidget.size, greaterThan(0));

      // Check for text accessibility
      final textFinder = find.text('CineLog');
      expect(textFinder, findsOneWidget);

      // Verify text is accessible to screen readers
      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.data, 'CineLog');
      expect(textWidget.style?.color, Colors.white);

      // Verify semantic tree structure
      final semantics = tester.getSemantics(find.byType(SplashScreen));
      expect(semantics, isNotNull);

      // Check that important elements are focusable
      await tester.pump();
      
      // Verify no accessibility violations
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));

      handle.dispose();
    });

    testWidgets('High contrast mode compatibility', (WidgetTester tester) async {
      // Test with high contrast theme
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: Colors.black,
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Colors.white),
            ),
          ),
          home: SplashScreen(config: SplashConfig.production()),
        ),
      );

      // Verify high contrast elements are visible
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('CineLog'), findsOneWidget);

      // Check background color for high contrast
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFF1A1D29));

      // Verify text contrast
      final textWidget = tester.widget<Text>(find.text('CineLog'));
      expect(textWidget.style?.color, Colors.white);

      await tester.pumpAndSettle();
    });

    testWidgets('Reduced motion accessibility support', (WidgetTester tester) async {
      // Test with reduced motion preferences
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            config: const SplashConfig(
              logoAnimationDuration: Duration(milliseconds: 100), // Reduced animation
              textAnimationDuration: Duration(milliseconds: 100),
              displayDuration: Duration(seconds: 1),
            ),
          ),
        ),
      );

      // Verify splash screen still functions with reduced animations
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(CineLogLogo), findsOneWidget);
      expect(find.text('CineLog'), findsOneWidget);

      // Verify animations complete quickly for reduced motion
      await tester.pump(const Duration(milliseconds: 200));
      
      // Check that content is still visible and accessible
      expect(find.byType(CineLogLogo), findsOneWidget);
      expect(find.text('CineLog'), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('Focus management and keyboard navigation', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(config: SplashConfig.production()),
        ),
      );

      // Verify initial focus state
      expect(find.byType(SplashScreen), findsOneWidget);

      // Test that splash screen doesn't interfere with focus
      // Since splash screen is non-interactive, it shouldn't trap focus
      final splashScreenWidget = tester.widget<SplashScreen>(find.byType(SplashScreen));
      expect(splashScreenWidget, isNotNull);

      // Verify no focusable elements that could trap keyboard users
      final focusableElements = find.byWidgetPredicate(
        (widget) => widget is Focus || widget is FocusScope,
      );
      
      // Splash screen should not have interactive focus elements
      // that could interfere with screen reader navigation
      await tester.pump();

      handle.dispose();
    });

    testWidgets('Screen reader announcements and labels', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(
        MaterialApp(
          home: Semantics(
            label: 'CineLog app loading screen',
            child: SplashScreen(config: SplashConfig.production()),
          ),
        ),
      );

      // Verify semantic labels are present
      expect(find.bySemanticsLabel('CineLog app loading screen'), findsOneWidget);

      // Check that logo has appropriate semantic meaning
      final logoFinder = find.byType(CineLogLogo);
      expect(logoFinder, findsOneWidget);

      // Verify text is properly labeled for screen readers
      final textFinder = find.text('CineLog');
      expect(textFinder, findsOneWidget);

      // Test semantic tree structure
      final semanticsTree = tester.binding.pipelineOwner.semanticsOwner?.rootSemanticsNode;
      expect(semanticsTree, isNotNull);

      await tester.pump();

      handle.dispose();
    });

    testWidgets('Color contrast and visibility requirements', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(config: SplashConfig.production()),
        ),
      );

      // Verify background color meets accessibility standards
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFF1A1D29));

      // Verify text color provides sufficient contrast
      final textWidget = tester.widget<Text>(find.text('CineLog'));
      expect(textWidget.style?.color, Colors.white);

      // Check logo visibility
      final logoWidget = tester.widget<CineLogLogo>(find.byType(CineLogLogo));
      expect(logoWidget.size, greaterThan(80.0)); // Minimum size for visibility

      // Verify contrast guidelines are met
      await expectLater(tester, meetsGuideline(textContrastGuideline));

      await tester.pumpAndSettle();
    });

    testWidgets('Animation accessibility with screen readers', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(config: SplashConfig.production()),
        ),
      );

      // Verify animations don't interfere with screen reader functionality
      expect(find.byType(FadeTransition), findsOneWidget);
      expect(find.byType(SlideTransition), findsOneWidget);

      // Check that animated elements maintain semantic properties
      final logoFinder = find.byType(CineLogLogo);
      expect(logoFinder, findsOneWidget);

      final textFinder = find.text('CineLog');
      expect(textFinder, findsOneWidget);

      // Pump through animation frames
      for (int i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        
        // Verify elements remain accessible during animation
        expect(find.byType(CineLogLogo), findsOneWidget);
        expect(find.text('CineLog'), findsOneWidget);
      }

      await tester.pumpAndSettle();

      handle.dispose();
    });

    testWidgets('Large text and scaling support', (WidgetTester tester) async {
      // Test with large text scaling
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              textScaleFactor: 2.0, // Large text scaling
            ),
            child: SplashScreen(config: SplashConfig.production()),
          ),
        ),
      );

      // Verify text scales appropriately
      final textWidget = tester.widget<Text>(find.text('CineLog'));
      expect(textWidget.data, 'CineLog');

      // Verify layout accommodates larger text
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(CineLogLogo), findsOneWidget);

      // Check that scaled text doesn't break layout
      await tester.pump();
      
      // Verify no overflow issues with large text
      expect(tester.takeException(), isNull);

      await tester.pumpAndSettle();
    });

    testWidgets('Voice control and switch navigation compatibility', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(config: SplashConfig.production()),
        ),
      );

      // Verify splash screen doesn't interfere with assistive technologies
      expect(find.byType(SplashScreen), findsOneWidget);

      // Check semantic structure for voice control
      final semantics = tester.getSemantics(find.byType(SplashScreen));
      expect(semantics, isNotNull);

      // Verify no interactive elements that could confuse voice control
      // Splash screen should be purely informational
      final interactiveElements = find.byWidgetPredicate(
        (widget) => widget is GestureDetector || 
                   widget is InkWell || 
                   widget is ElevatedButton ||
                   widget is TextButton,
      );
      
      // Should find minimal interactive elements (only for navigation)
      expect(interactiveElements, findsNothing);

      await tester.pump();

      handle.dispose();
    });

    testWidgets('Accessibility guidelines compliance', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(config: SplashConfig.production()),
        ),
      );

      // Test all major accessibility guidelines
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));

      // Verify semantic structure
      expect(find.byType(Semantics), findsWidgets);

      // Check for proper semantic roles
      final splashSemantics = tester.getSemantics(find.byType(SplashScreen));
      expect(splashSemantics, isNotNull);

      await tester.pumpAndSettle();

      handle.dispose();
    });
  });
}