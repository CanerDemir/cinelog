import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/cinelog_logo.dart';
import '../models/splash_config.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  final SplashConfig config;
  
  const SplashScreen({
    super.key,
    this.config = const SplashConfig(),
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
  
  // Error handling state
  bool _animationError = false;
  bool _navigationError = false;

  @override
  void initState() {
    super.initState();
    
    try {
      // Log configuration if debug logging is enabled
      widget.config.debugLog('Initializing splash screen with config: ${widget.config}');
      
      // Check if splash screen should be skipped in debug mode
      if (widget.config.shouldSkipSplash()) {
        widget.config.debugLog('Skipping splash screen in debug mode');
        _initializeFallbackAnimations();
        
        // Navigate immediately to home screen
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _navigateToHomeScreen();
          }
        });
        return;
      }
      
      // Initialize animations with error handling
      _initializeAnimations();
      
    } catch (error, stackTrace) {
      // Log the error and initialize fallback
      widget.config.debugLog('Error during splash screen initialization: $error');
      debugPrint('SplashScreen initialization error: $error\n$stackTrace');
      
      _animationError = true;
      _initializeFallbackAnimations();
    }
    
    // Always set up navigation timer as a safety net
    _setupNavigationTimer();
  }

  /// Initialize animations with comprehensive error handling
  void _initializeAnimations() {
    try {
      // Initialize logo fade-in animation controller with configurable duration
      _logoAnimationController = AnimationController(
        duration: widget.config.logoAnimationDuration,
        vsync: this,
      );
      
      // Create fade animation with smooth curve
      _logoFadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _logoAnimationController,
        curve: Curves.easeInOut, // Smooth curve for professional feel
      ));
      
      widget.config.debugLog('Logo animation controller initialized successfully');
      
    } catch (error) {
      widget.config.debugLog('Error initializing logo animation: $error');
      _animationError = true;
      _initializeFallbackLogoAnimation();
    }
    
    try {
      // Initialize text slide-up animation controller with configurable duration
      _textAnimationController = AnimationController(
        duration: widget.config.textAnimationDuration,
        vsync: this,
      );
      
      // Create slide animation with upward movement
      _textSlideAnimation = Tween<Offset>(
        begin: const Offset(0.0, 0.5), // Start slightly below
        end: Offset.zero, // End at normal position
      ).animate(CurvedAnimation(
        parent: _textAnimationController,
        curve: Curves.easeOutCubic, // Smooth deceleration curve
      ));
      
      widget.config.debugLog('Text animation controller initialized successfully');
      
    } catch (error) {
      widget.config.debugLog('Error initializing text animation: $error');
      _animationError = true;
      _initializeFallbackTextAnimation();
    }
    
    // Start animations with error handling
    _startAnimations();
  }

  /// Initialize fallback animations that always work
  void _initializeFallbackAnimations() {
    try {
      // Create minimal controllers that won't fail
      _logoAnimationController = AnimationController(
        duration: const Duration(milliseconds: 1),
        vsync: this,
      );
      _textAnimationController = AnimationController(
        duration: const Duration(milliseconds: 1),
        vsync: this,
      );
      
      // Static animations (no movement/fade)
      _logoFadeAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(_logoAnimationController);
      _textSlideAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(_textAnimationController);
      
      widget.config.debugLog('Fallback animations initialized');
      
    } catch (error) {
      widget.config.debugLog('Critical error: Even fallback animations failed: $error');
      // This should never happen, but if it does, we'll handle it in the build method
    }
  }

  /// Initialize fallback logo animation only
  void _initializeFallbackLogoAnimation() {
    try {
      _logoAnimationController = AnimationController(
        duration: const Duration(milliseconds: 1),
        vsync: this,
      );
      _logoFadeAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(_logoAnimationController);
      widget.config.debugLog('Fallback logo animation initialized');
    } catch (error) {
      widget.config.debugLog('Critical error in fallback logo animation: $error');
    }
  }

  /// Initialize fallback text animation only
  void _initializeFallbackTextAnimation() {
    try {
      _textAnimationController = AnimationController(
        duration: const Duration(milliseconds: 1),
        vsync: this,
      );
      _textSlideAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(_textAnimationController);
      widget.config.debugLog('Fallback text animation initialized');
    } catch (error) {
      widget.config.debugLog('Critical error in fallback text animation: $error');
    }
  }

  /// Start animations with error handling
  void _startAnimations() {
    if (_animationError) {
      widget.config.debugLog('Skipping animation start due to initialization errors');
      return;
    }
    
    try {
      // Start the logo animation immediately
      widget.config.debugLog('Starting logo animation');
      _logoAnimationController.forward();
      
      // Start text animation after configurable delay
      Future.delayed(widget.config.textAnimationDelay, () {
        if (mounted && !_animationError) {
          try {
            widget.config.debugLog('Starting text animation');
            _textAnimationController.forward();
          } catch (error) {
            widget.config.debugLog('Error starting text animation: $error');
            // Animation error doesn't prevent navigation
          }
        }
      });
      
    } catch (error) {
      widget.config.debugLog('Error starting animations: $error');
      // Don't set _animationError here as animations are already initialized
    }
  }

  /// Set up navigation timer with error handling
  void _setupNavigationTimer() {
    try {
      // Set up navigation timer to automatically transition to home screen
      widget.config.debugLog('Setting navigation timer for ${widget.config.displayDuration}');
      _navigationTimer = Timer(widget.config.displayDuration, () {
        if (mounted) {
          widget.config.debugLog('Navigation timer triggered, transitioning to home screen');
          _navigateToHomeScreen();
        }
      });
    } catch (error) {
      widget.config.debugLog('Error setting up navigation timer: $error');
      // If timer setup fails, set up immediate navigation as fallback
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.config.debugLog('Using immediate navigation fallback');
          _navigateToHomeScreen();
        }
      });
    }
  }

  /// Cancel all timers and animations safely
  void _cancelAllTimersAndAnimations() {
    try {
      _navigationTimer?.cancel();
      _navigationTimer = null;
    } catch (error) {
      widget.config.debugLog('Error canceling navigation timer: $error');
    }

    try {
      if (_logoAnimationController.isAnimating) {
        _logoAnimationController.stop();
      }
    } catch (error) {
      widget.config.debugLog('Error stopping logo animation: $error');
    }

    try {
      if (_textAnimationController.isAnimating) {
        _textAnimationController.stop();
      }
    } catch (error) {
      widget.config.debugLog('Error stopping text animation: $error');
    }
  }

  @override
  void dispose() {
    // Cancel all timers and stop animations before disposing
    _cancelAllTimersAndAnimations();
    
    try {
      _logoAnimationController.dispose();
    } catch (error) {
      widget.config.debugLog('Error disposing logo animation controller: $error');
    }
    
    try {
      _textAnimationController.dispose();
    } catch (error) {
      widget.config.debugLog('Error disposing text animation controller: $error');
    }
    
    super.dispose();
  }

  void _navigateToHomeScreen() {
    try {
      // Navigate to home screen using custom fade transition
      Navigator.of(context).pushReplacement(
        _createFadeTransition(),
      );
      widget.config.debugLog('Navigation to home screen successful');
    } catch (error) {
      widget.config.debugLog('Error during navigation: $error');
      _navigationError = true;
      
      // Fallback navigation without custom transition
      try {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        widget.config.debugLog('Fallback navigation successful');
      } catch (fallbackError) {
        widget.config.debugLog('Critical error: Fallback navigation also failed: $fallbackError');
        // Last resort: try to pop and push
        try {
          Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
        } catch (lastResortError) {
          widget.config.debugLog('Critical error: All navigation methods failed: $lastResortError');
        }
      }
    }
  }

  /// Creates a custom PageRouteBuilder with smooth fade transition
  PageRouteBuilder<void> _createFadeTransition() {
    return PageRouteBuilder<void>(
      pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
      transitionDuration: widget.config.transitionDuration,
      reverseTransitionDuration: Duration(milliseconds: (widget.config.transitionDuration.inMilliseconds * 0.6).round()),
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
                  color: const Color(0xFF1A1D29), // Match splash background
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CineLogLogo(size: 120), // Fixed size for transition
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
      backgroundColor: const Color(0xFF1A1D29), // Dark background matching app theme
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            try {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Responsive logo with sizing logic
                    _buildResponsiveLogo(),
                    _buildResponsiveSpacing(),
                    // App name text with slide-up animation and responsive sizing
                    _buildAnimatedText(),
                  ],
                ),
              );
            } catch (error) {
              widget.config.debugLog('Critical error in build method: $error');
              // Ultimate fallback: static display without any animations
              return _buildFallbackDisplay();
            }
          },
        ),
      ),
    );
  }

  /// Build animated text with error handling
  Widget _buildAnimatedText() {
    try {
      // If animations failed completely, show static text
      if (_animationError) {
        return _buildResponsiveText();
      }
      
      // Try to use slide animation
      return SlideTransition(
        position: _textSlideAnimation,
        child: _buildResponsiveText(),
      );
    } catch (error) {
      widget.config.debugLog('Error building animated text: $error');
      // Fallback to static text
      return _buildResponsiveText();
    }
  }

  /// Ultimate fallback display for critical errors
  Widget _buildFallbackDisplay() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Simple static logo with default size
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Center(
              child: Text(
                'CineLog',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Simple static text
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
    );
  }

  Widget _buildResponsiveLogo() {
    return LayoutBuilder(
      builder: (context, constraints) {
        try {
          // Get screen dimensions for responsive sizing from MediaQuery
          final screenWidth = MediaQuery.of(context).size.width;
          final screenHeight = MediaQuery.of(context).size.height;
          
          // Calculate responsive logo size based on requirements:
          // - Logo size: 25% of screen width (min: 80px, max: 150px)
          double logoSize = screenWidth * 0.25;
          
          // Apply minimum and maximum constraints for width-based sizing
          logoSize = logoSize.clamp(80.0, 150.0);
          
          // Additional check for very tall/narrow screens or landscape orientation
          // Ensure logo doesn't exceed 20% of screen height to maintain proportions
          final maxHeightBasedSize = screenHeight * 0.2;
          if (maxHeightBasedSize < logoSize) {
            logoSize = maxHeightBasedSize.clamp(80.0, 150.0);
          }
          
          // If animations failed, show static logo
          if (_animationError) {
            widget.config.debugLog('Using static logo due to animation error');
            return CineLogLogo(size: logoSize);
          }
          
          // Wrap CineLogLogo with FadeTransition for smooth fade-in effect
          return FadeTransition(
            opacity: _logoFadeAnimation,
            child: CineLogLogo(size: logoSize),
          );
          
        } catch (error) {
          widget.config.debugLog('Error building responsive logo: $error');
          // Fallback to simple static logo with default size
          return const CineLogLogo(size: 100);
        }
      },
    );
  }

  Widget _buildResponsiveSpacing() {
    return LayoutBuilder(
      builder: (context, constraints) {
        try {
          final screenHeight = MediaQuery.of(context).size.height;
          // Responsive spacing: 3% of screen height (min: 16px, max: 32px)
          double spacing = screenHeight * 0.03;
          spacing = spacing.clamp(16.0, 32.0);
          return SizedBox(height: spacing);
        } catch (error) {
          widget.config.debugLog('Error building responsive spacing: $error');
          // Fallback to fixed spacing
          return const SizedBox(height: 24);
        }
      },
    );
  }

  Widget _buildResponsiveText() {
    return LayoutBuilder(
      builder: (context, constraints) {
        try {
          final screenWidth = MediaQuery.of(context).size.width;
          // Responsive text size based on screen width
          double fontSize = screenWidth * 0.08;
          fontSize = fontSize.clamp(24.0, 40.0);
          
          // If animations failed, show static text
          if (_animationError) {
            widget.config.debugLog('Using static text due to animation error');
            return Text(
              'CineLog',
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            );
          }
          
          return Text(
            'CineLog',
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          );
        } catch (error) {
          widget.config.debugLog('Error building responsive text: $error');
          // Fallback to simple static text with default styling
          return const Text(
            'CineLog',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          );
        }
      },
    );
  }
}