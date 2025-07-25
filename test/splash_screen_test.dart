import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cinelog/screens/splash_screen.dart';
import 'package:cinelog/widgets/cinelog_logo.dart';

void main() {
  group('SplashScreen Logo Animation Tests', () {
    testWidgets('should initialize animation controller and fade animation', (WidgetTester tester) async {
      // Build the SplashScreen widget
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      // Verify the splash screen is rendered
      expect(find.byType(SplashScreen), findsOneWidget);
      
      // Verify the FadeTransition widget is present
      expect(find.byType(FadeTransition), findsOneWidget);
      
      // Verify the CineLogLogo is wrapped in FadeTransition
      expect(find.byType(CineLogLogo), findsOneWidget);
      
      // Verify the app name text is present
      expect(find.text('CineLog'), findsOneWidget);
    });

    testWidgets('should start logo fade-in animation on init', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      // Get the FadeTransition widget
      final fadeTransition = tester.widget<FadeTransition>(find.byType(FadeTransition));
      
      // Initially, the animation should be at the beginning (opacity near 0)
      expect(fadeTransition.opacity.value, lessThan(0.1));
      
      // Pump the animation forward
      await tester.pump(const Duration(milliseconds: 100));
      
      // Animation should be progressing (opacity increasing)
      expect(fadeTransition.opacity.value, greaterThan(0.0));
      
      // Complete the animation
      await tester.pump(const Duration(milliseconds: 800));
      
      // Animation should be complete (opacity near 1.0)
      expect(fadeTransition.opacity.value, greaterThan(0.9));
    });

    testWidgets('should use correct animation duration and curve', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      // Get the FadeTransition widget
      final fadeTransition = tester.widget<FadeTransition>(find.byType(FadeTransition));
      
      // Verify the animation uses CurvedAnimation
      expect(fadeTransition.opacity, isA<CurvedAnimation>());
      
      final curvedAnimation = fadeTransition.opacity as CurvedAnimation;
      
      // Verify the curve is easeInOut
      expect(curvedAnimation.curve, equals(Curves.easeInOut));
    });

    testWidgets('should render logo with responsive sizing', (WidgetTester tester) async {
      // Set a specific screen size for testing
      tester.binding.window.physicalSizeTestValue = const Size(400, 800);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      // Verify CineLogLogo is present
      expect(find.byType(CineLogLogo), findsOneWidget);
      
      // Get the logo widget and verify it has appropriate size
      final logoWidget = tester.widget<CineLogLogo>(find.byType(CineLogLogo));
      
      // Logo size should be 25% of screen width (400 * 0.25 = 100)
      // Clamped between 80 and 150
      expect(logoWidget.size, equals(100.0));
      
      // Reset the window size
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });
  });
}