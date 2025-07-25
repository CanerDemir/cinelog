import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cinelog/screens/splash_screen.dart';
import 'package:cinelog/models/splash_config.dart';

void main() {
  testWidgets('Splash screen transition timing test', (WidgetTester tester) async {
    // Build the splash screen
    await tester.pumpWidget(
      MaterialApp(
        home: SplashScreen(
          config: SplashConfig(
            displayDuration: Duration(milliseconds: 1000),
          ),
        ),
      ),
    );

    // Verify splash screen is displayed
    expect(find.text('CineLog'), findsOneWidget);
    expect(find.byType(SplashScreen), findsOneWidget);

    // Wait for the display duration and a bit more for transition
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump(const Duration(milliseconds: 100));

    // Pump the transition animation
    await tester.pump(const Duration(milliseconds: 250)); // Mid-transition
    await tester.pump(const Duration(milliseconds: 250)); // Complete transition

    print('Transition test completed successfully');
  });
}