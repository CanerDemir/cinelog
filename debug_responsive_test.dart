import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cinelog/screens/splash_screen.dart';
import 'package:cinelog/models/splash_config.dart';
import 'package:cinelog/widgets/cinelog_logo.dart';

void main() {
  testWidgets('Debug responsive logo sizing', (WidgetTester tester) async {
    // Test small screen (mobile) - 360x640
    await tester.binding.setSurfaceSize(const Size(360, 640));
    await tester.pumpWidget(
      MaterialApp(
        home: SplashScreen(
          config: SplashConfig(
            displayDuration: const Duration(milliseconds: 100),
            skipInDebug: false,
          ),
        ),
      ),
    );
    await tester.pump();

    // Find the logo widget
    final logoFinder = find.byType(CineLogLogo);
    expect(logoFinder, findsOneWidget);
    
    final CineLogLogo logoWidget = tester.widget(logoFinder);
    print('Screen size: 360x640');
    print('Expected logo size: 90.0 (25% of 360px)');
    print('Actual logo size: ${logoWidget.size}');
    
    // Calculate what the size should be
    double expectedSize = 360 * 0.25; // 90.0
    expectedSize = expectedSize.clamp(80.0, 150.0); // Still 90.0
    double maxHeightBasedSize = 640 * 0.2; // 128.0
    if (maxHeightBasedSize < expectedSize) {
      expectedSize = maxHeightBasedSize.clamp(80.0, 150.0);
    }
    print('Calculated expected size: $expectedSize');
  });
}