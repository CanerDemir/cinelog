import 'package:flutter/material.dart';

void main() {
  runApp(const TransitionDemoApp());
}

class TransitionDemoApp extends StatelessWidget {
  const TransitionDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Splash Transition Demo',
      theme: ThemeData.dark(),
      home: const DemoSplashScreen(),
    );
  }
}

class DemoSplashScreen extends StatefulWidget {
  const DemoSplashScreen({super.key});

  @override
  State<DemoSplashScreen> createState() => _DemoSplashScreenState();
}

class _DemoSplashScreenState extends State<DemoSplashScreen> {
  void _navigateToHomeScreen() {
    Navigator.of(context).pushReplacement(
      _createFadeTransition(),
    );
  }

  PageRouteBuilder<void> _createFadeTransition() {
    return PageRouteBuilder<void>(
      pageBuilder: (context, animation, secondaryAnimation) => const DemoHomeScreen(),
      transitionDuration: const Duration(milliseconds: 500),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Optimized fade-in animation for the home screen with better timing
        final homeScreenFadeIn = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
        ));

        // Optimized fade-out animation for the splash screen with smoother curve
        final splashScreenFadeOut = Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
        ));

        // More subtle scale effect for natural feel
        final splashScaleOut = Tween<double>(
          begin: 1.0,
          end: 0.98,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
        ));

        return Stack(
          children: [
            // Fade out and slightly scale the splash screen content
            FadeTransition(
              opacity: splashScreenFadeOut,
              child: ScaleTransition(
                scale: splashScaleOut,
                child: Container(
                  color: const Color(0xFF1A1D29),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.movie, size: 100, color: Colors.orange),
                        SizedBox(height: 24),
                        Text(
                          'CineLog',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Fade in the new screen (home screen) with optimized timing
            FadeTransition(
              opacity: homeScreenFadeIn,
              child: child,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D29),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.movie, size: 100, color: Colors.orange),
            const SizedBox(height: 24),
            const Text(
              'CineLog',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: _navigateToHomeScreen,
              child: const Text('Test Smooth Transition'),
            ),
          ],
        ),
      ),
    );
  }
}

class DemoHomeScreen extends StatelessWidget {
  const DemoHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Transition Complete!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'The smooth fade transition with subtle scale effect\ncreates a natural, polished user experience.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const DemoSplashScreen()),
                );
              },
              child: const Text('Test Again'),
            ),
          ],
        ),
      ),
    );
  }
}