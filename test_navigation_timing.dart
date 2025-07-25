import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'lib/screens/splash_screen.dart';
import 'lib/screens/home_screen.dart';
import 'lib/models/splash_config.dart';

void main() {
  testWidgets('SplashScreen should navigate to HomeScreen after timer', (WidgetTester tester) async {
    // Build the SplashScreen with a short duration for testing
    await tester.pumpWidget(
      MaterialApp(
        home: SplashScreen(
          config: SplashConfig(
            displayDuration: Duration(milliseconds: 100),
          ),
        ),
      ),
    );

    // Verify splash screen is displayed initially
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);

    // Wait for the timer to complete and trigger navigation
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle(); // Wait for navigation to complete

    // Verify navigation occurred
    expect(find.byType(SplashScreen), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}