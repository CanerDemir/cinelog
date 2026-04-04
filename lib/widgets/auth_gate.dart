import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/splash_config.dart';
import '../providers/app_providers.dart';
import '../screens/auth_screen.dart';
import '../screens/home_screen.dart';
import '../screens/splash_screen.dart';
import '../services/auth_service.dart';
import '../theme/cinematic_tokens.dart';

/// Subscribes to [AuthService.authStateChanges] only after the Firebase Auth
/// plugin is ready. Subscribing in the first [build] (e.g. [StreamBuilder] in
/// [MaterialApp.home]) can trigger
/// `FirebaseAuthHostApi.registerAuthStateListener` channel errors on Windows
/// and some web/embedder setups.
///
/// Guest mode (Hive on device) does not require a Firebase user. Registered
/// users use Firebase; splash then home are shown without replacing the root
/// route so sign-in state keeps working.
class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  Stream<User?>? _authStream;
  Object? _subscriptionError;
  bool _showHome = false;

  static bool get _isWindows =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

  @override
  void initState() {
    super.initState();
    _attachAuthStreamWhenReady();
  }

  Future<void> _attachAuthStreamWhenReady() async {
    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;

    if (kIsWeb) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      if (!mounted) return;
    }

    if (_isWindows) {
      await Future<void>.delayed(const Duration(milliseconds: 150));
      if (!mounted) return;
    }

    try {
      FirebaseAuth.instance.currentUser;
      _authStream = AuthService.authStateChanges();
      if (mounted) setState(() {});
    } catch (e, st) {
      debugPrint('AuthGate: failed to attach auth stream: $e\n$st');
      if (mounted) {
        setState(() => _subscriptionError = e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_subscriptionError != null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    color: CinematicTokens.primaryContainer, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Could not start Firebase Auth.\n'
                  'Try: full restart (not hot reload), `flutter clean`, then run again.\n'
                  'On web, use Chrome; on desktop, ensure Firebase Auth is enabled in Console.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  '$_subscriptionError',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_authStream == null) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: CircularProgressIndicator(
              color: CinematicTokens.primaryContainer),
        ),
      );
    }

    final guestAsync = ref.watch(guestModeProvider);

    return StreamBuilder<User?>(
      stream: _authStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Auth error: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ),
          );
        }

        if (guestAsync.isLoading) {
          return const Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: CircularProgressIndicator(
                  color: CinematicTokens.primaryContainer),
            ),
          );
        }

        final guest = guestAsync.valueOrNull ?? false;
        final user = snapshot.data;
        final waiting = snapshot.connectionState == ConnectionState.waiting;

        if (!guest && waiting) {
          return const Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: CircularProgressIndicator(
                  color: CinematicTokens.primaryContainer),
            ),
          );
        }

        final authed = guest || user != null;

        if (!authed) {
          if (_showHome) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _showHome = false);
            });
          }
          return const AuthScreen();
        }

        if (!_showHome) {
          return SplashScreen(
            config: SplashConfig.production(),
            onNavigateToHome: () {
              if (mounted) setState(() => _showHome = true);
            },
          );
        }

        return const HomeScreen();
      },
    );
  }
}
