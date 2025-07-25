import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cinelog/widgets/cinelog_logo.dart';

// Simple test app to manually verify the splash screen transition
void main() {
  runApp(const TestSplashApp());
}

class TestSplashApp extends StatelessWidget {
  const TestSplashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Splash Transition Test',
      theme: ThemeData.dark(),
      home: const SplashScreen(
        displayDuration: Duration(seconds: 2), // Shorter for testing
      ),
    );
  }
}

// Mock home screen for testing
class MockHomeScreen extends StatelessWidget {
  const MockHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Home Screen'),
        backgroundColor: Colors.orange,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home,
              size: 64,
              color: Colors.orange,
            ),
            SizedBox(height: 16),
            Text(
              'Welcome to CineLog!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Transition completed successfully',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Test version of SplashScreen that uses MockHomeScreen
class SplashScreen extends StatefulWidget {
  final Duration displayDuration;
  final bool skipInDebug;
  
  const SplashScreen({
    super.key,
    this.displayDuration = const Duration(seconds: 3),
    this.skipInDebug = false,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> 
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late Animation<double> _logoFadeAnimation;
  late AnimationController _textAnimationController;
  late Animation<Offset> _textSlideAnimation;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    
    // Initialize logo fade-in animation controller
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Create fade animation with smooth curve
    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.easeInOut,
    ));
    
    // Initialize text slide-up animation controller
    _textAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // Create slide animation with upward movement
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textAnimationController,
      curve: Curves.easeOutCubic,
    ));
    
    // Start the logo animation immediately
    _logoAnimationController.forward();
    
    // Start text animation after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _textAnimationController.forward();
      }
    });
    
    // Set up navigation timer
    _navigationTimer = Timer(widget.displayDuration, () {
      if (mounted) {
        _navigateToHomeScreen();
      }
    });
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _textAnimationController.dispose();
    _navigationTimer?.cancel();
    super.dispose();
  }

  void _navigateToHomeScreen() {
    Navigator.of(context).pushReplacement(
      _createFadeTransition(),
    );
  }

  /// Creates a custom PageRouteBuilder with smooth fade transition
  PageRouteBuilder<void> _createFadeTransition() {
    return PageRouteBuilder<void>(
      pageBuilder: (context, animation, secondaryAnimation) => const MockHomeScreen(),
      transitionDuration: const Duration(milliseconds: 500),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Create smooth fade-in animation for the home screen
        final homeScreenFadeIn = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
        ));

        // Create smooth fade-out animation for the splash screen
        final splashScreenFadeOut = Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
        ));

        // Create a subtle scale effect for the splash screen during fade-out
        final splashScaleOut = Tween<double>(
          begin: 1.0,
          end: 0.95,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
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
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildResponsiveLogo(),
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Fade in the new screen (home screen) with a slight delay
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
            _buildResponsiveLogo(),
            const SizedBox(height: 24),
            SlideTransition(
              position: _textSlideAnimation,
              child: const Text(
                'CineLog',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveLogo() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        
        double logoSize = screenWidth * 0.25;
        logoSize = logoSize.clamp(80.0, 150.0);
        
        final maxHeightBasedSize = screenHeight * 0.2;
        if (logoSize > maxHeightBasedSize) {
          logoSize = maxHeightBasedSize;
        }
        
        return FadeTransition(
          opacity: _logoFadeAnimation,
          child: CineLogLogo(size: logoSize),
        );
      },
    );
  }
}