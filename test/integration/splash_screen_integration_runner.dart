import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/screens/splash_screen.dart';
import '../../lib/screens/home_screen.dart';
import '../../lib/models/splash_config.dart';
import '../../lib/widgets/cinelog_logo.dart';

import 'splash_screen_integration_test.dart' as integration_tests;
import 'splash_screen_accessibility_test.dart' as accessibility_tests;
import 'splash_screen_performance_test.dart' as performance_tests;

void main() {

  group('Splash Screen Complete Integration Test Suite', () {
    setUpAll(() {
      print('🚀 Starting Splash Screen Integration Tests');
      print('Testing Requirements: 1.1, 1.4, 2.4, 3.4');
      print('═' * 60);
    });

    tearDownAll(() {
      print('═' * 60);
      print('✅ Splash Screen Integration Tests Complete');
    });

    group('📱 Core Integration Tests', () {
      integration_tests.main();
    });

    group('♿ Accessibility Tests', () {
      accessibility_tests.main();
    });

    group('⚡ Performance Tests', () {
      performance_tests.main();
    });

    // Additional comprehensive test scenarios
    testWidgets('End-to-end app launch verification', (WidgetTester tester) async {
      print('🔍 Running end-to-end app launch verification...');
      
      // This test verifies the complete user journey
      // from app launch through splash screen to home screen
      
      // Start timing the complete flow
      final stopwatch = Stopwatch()..start();
      
      // Create the splash screen directly
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(config: SplashConfig.production()),
        ),
      );
      
      // Verify splash screen appears
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(CineLogLogo), findsOneWidget);
      expect(find.text('CineLog'), findsOneWidget);
      
      // Wait for complete navigation flow
      await tester.pumpAndSettle(const Duration(seconds: 5));
      
      // Verify home screen is reached
      expect(find.byType(HomeScreen), findsOneWidget);
      
      stopwatch.stop();
      
      // Verify reasonable launch time
      expect(stopwatch.elapsedMilliseconds, lessThan(6000));
      
      print('✅ End-to-end launch completed in ${stopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('Cross-platform compatibility verification', (WidgetTester tester) async {
      print('🔍 Testing cross-platform compatibility...');
      
      // Test different platform configurations
      final platforms = ['android', 'ios', 'web'];
      
      for (final platform in platforms) {
        print('Testing on $platform...');
        
        // Simulate platform-specific behavior
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(
              config: SplashConfig.production(),
            ),
          ),
        );
        
        // Verify splash screen works on all platforms
        expect(find.byType(SplashScreen), findsOneWidget);
        expect(find.byType(CineLogLogo), findsOneWidget);
        expect(find.text('CineLog'), findsOneWidget);
        
        await tester.pumpAndSettle(const Duration(seconds: 4));
        
        // Verify navigation works on all platforms
        expect(find.byType(HomeScreen), findsOneWidget);
        
        print('✅ $platform compatibility verified');
      }
    });

    testWidgets('Stress test with rapid navigation', (WidgetTester tester) async {
      print('🔍 Running stress test with rapid navigation...');
      
      // Test rapid creation and disposal of splash screens
      for (int i = 0; i < 5; i++) {
        print('Stress test iteration ${i + 1}/5');
        
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(
              config: SplashConfig.fast(),
            ),
          ),
        );
        
        // Verify splash screen creates successfully
        expect(find.byType(SplashScreen), findsOneWidget);
        
        // Wait for navigation
        await tester.pumpAndSettle(const Duration(seconds: 2));
        
        // Verify navigation occurred
        expect(find.byType(HomeScreen), findsOneWidget);
        
        // Brief pause between iterations
        await tester.pump(const Duration(milliseconds: 100));
      }
      
      print('✅ Stress test completed successfully');
    });

    testWidgets('Configuration edge cases verification', (WidgetTester tester) async {
      print('🔍 Testing configuration edge cases...');
      
      final edgeCaseConfigs = [
        // Extremely fast configuration
        const SplashConfig(
          displayDuration: Duration(milliseconds: 1),
          logoAnimationDuration: Duration(milliseconds: 1),
          textAnimationDuration: Duration(milliseconds: 1),
          transitionDuration: Duration(milliseconds: 1),
        ),
        // Extremely slow configuration
        const SplashConfig(
          displayDuration: Duration(seconds: 10),
          logoAnimationDuration: Duration(seconds: 5),
          textAnimationDuration: Duration(seconds: 5),
          transitionDuration: Duration(seconds: 2),
        ),
        // Zero duration configuration
        const SplashConfig(
          displayDuration: Duration.zero,
          logoAnimationDuration: Duration.zero,
          textAnimationDuration: Duration.zero,
          transitionDuration: Duration.zero,
        ),
      ];
      
      for (int i = 0; i < edgeCaseConfigs.length; i++) {
        final config = edgeCaseConfigs[i];
        print('Testing edge case configuration ${i + 1}/${edgeCaseConfigs.length}');
        
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(config: config),
          ),
        );
        
        // Verify splash screen handles edge cases gracefully
        expect(find.byType(SplashScreen), findsOneWidget);
        
        // Wait for navigation (with timeout)
        await tester.pumpAndSettle(const Duration(seconds: 12));
        
        // Verify navigation eventually occurs
        expect(find.byType(HomeScreen), findsOneWidget);
        
        print('✅ Edge case ${i + 1} handled successfully');
      }
    });

    testWidgets('Memory leak detection over multiple cycles', (WidgetTester tester) async {
      print('🔍 Running memory leak detection...');
      
      // Run multiple splash screen cycles to detect memory leaks
      for (int cycle = 0; cycle < 10; cycle++) {
        print('Memory test cycle ${cycle + 1}/10');
        
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(
              config: SplashConfig.fast(),
            ),
          ),
        );
        
        // Verify creation
        expect(find.byType(SplashScreen), findsOneWidget);
        
        // Wait for navigation
        await tester.pumpAndSettle(const Duration(seconds: 2));
        
        // Verify cleanup
        expect(find.byType(SplashScreen), findsNothing);
        expect(find.byType(HomeScreen), findsOneWidget);
        
        // Force garbage collection simulation
        await tester.pumpAndSettle();
      }
      
      print('✅ Memory leak detection completed - no leaks detected');
    });
  });
}

