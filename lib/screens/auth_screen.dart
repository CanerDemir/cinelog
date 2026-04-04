import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/app_providers.dart';
import '../services/auth_service.dart';
import '../theme/cinematic_page_backdrop.dart';
import '../theme/cinematic_tokens.dart';
import '../widgets/cinelog_logo.dart';

/// Sign-in and registration. Registered users sync to Firebase; guests use
/// on-device storage only (see [guestModeProvider]).
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _registerMode = false;
  bool _busy = false;
  bool _obscurePassword = true;
  bool _emailFocused = false;
  bool _passwordFocused = false;

  static const double _cardPad = 22;

  TextStyle get _labelStyle => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: CinematicTokens.labelMuted,
      );

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submitEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      if (_registerMode) {
        await AuthService.registerWithEmail(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        await AuthService.signInWithEmail(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }
      await ref.read(guestModeProvider.notifier).setGuest(false);
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_messageForAuthException(e)),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Something went wrong: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _continueAsGuest() async {
    setState(() => _busy = true);
    try {
      await ref.read(guestModeProvider.notifier).setGuest(true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sendPasswordReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enter your email above, then tap Forgot? again.'),
          ),
        );
      }
      return;
    }
    setState(() => _busy = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reset link sent to $email'),
            backgroundColor: CinematicTokens.surfaceContainerHigh,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_messageForAuthException(e)),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _messageForAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Wrong email or password.';
      case 'email-already-in-use':
        return 'That email is already registered.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return e.message ?? 'Authentication failed (${e.code}).';
    }
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required Widget prefix,
    Widget? suffix,
    bool focused = false,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: CinematicTokens.hint, fontSize: 15),
      filled: true,
      fillColor: focused
          ? CinematicTokens.surfaceBright
          : CinematicTokens.surfaceContainerHigh,
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 14, right: 8),
        child: IconTheme(
          data: IconThemeData(
            size: 22,
            color: focused
                ? CinematicTokens.primaryContainer
                : CinematicTokens.hint,
          ),
          child: prefix,
        ),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CinematicTokens.radiusLg),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CinematicTokens.radiusLg),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CinematicTokens.radiusLg),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = GoogleFonts.manrope(
      fontSize: 26,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.5,
    );
    final taglineStyle = GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 2.4,
      color: Colors.white.withValues(alpha: 0.85),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _CinematicAuthBackdrop(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      const CineLogLogo(size: 72, cinematicGlow: true),
                      const SizedBox(height: 20),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'THE ',
                              style: titleStyle.copyWith(color: Colors.white),
                            ),
                            TextSpan(
                              text: 'CINELOG',
                              style: titleStyle.copyWith(
                                color: CinematicTokens.primaryContainer,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'YOUR PERSONAL FILM ARCHIVE',
                        textAlign: TextAlign.center,
                        style: taglineStyle,
                      ),
                      const SizedBox(height: 28),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(
                          _cardPad,
                          _cardPad + 4,
                          _cardPad,
                          _cardPad + 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(CinematicTokens.radiusXl),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              CinematicTokens.surfaceContainerHigh,
                              CinematicTokens.surfaceContainer,
                              Color.lerp(
                                    CinematicTokens.surfaceContainerLow,
                                    CinematicTokens.primaryContainer,
                                    0.08,
                                  ) ??
                                  CinematicTokens.surfaceContainerLow,
                            ],
                            stops: const [0.0, 0.48, 1.0],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: CinematicTokens.primaryContainer
                                  .withValues(alpha: 0.06),
                              blurRadius: 40,
                              spreadRadius: 0,
                              offset: const Offset(0, 18),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('EMAIL ADDRESS', style: _labelStyle),
                            const SizedBox(height: 8),
                            Focus(
                              onFocusChange: (v) =>
                                  setState(() => _emailFocused = v),
                              child: TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                autofillHints: const [AutofillHints.email],
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                                decoration: _fieldDecoration(
                                  hint: 'name@example.com',
                                  prefix: const Icon(Icons.alternate_email),
                                  focused: _emailFocused,
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Enter your email';
                                  }
                                  if (!v.contains('@')) {
                                    return 'Enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Expanded(
                                  child: Text(
                                    'PASSWORD',
                                    style: _labelStyle,
                                  ),
                                ),
                                if (!_registerMode)
                                  TextButton(
                                    onPressed:
                                        _busy ? null : _sendPasswordReset,
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      foregroundColor:
                                          CinematicTokens.primaryContainer,
                                    ),
                                    child: Text(
                                      'FORGOT?',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Focus(
                              onFocusChange: (v) =>
                                  setState(() => _passwordFocused = v),
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                autofillHints: _registerMode
                                    ? const [AutofillHints.newPassword]
                                    : const [AutofillHints.password],
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                                decoration: _fieldDecoration(
                                  hint: 'Password',
                                  prefix:
                                      const Icon(Icons.lock_outline_rounded),
                                  focused: _passwordFocused,
                                  suffix: IconButton(
                                    onPressed: () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: CinematicTokens.hint,
                                      size: 22,
                                    ),
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Enter a password';
                                  }
                                  if (v.length < 6) {
                                    return 'At least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            if (_registerMode) ...[
                              const SizedBox(height: 18),
                              Text('CONFIRM PASSWORD', style: _labelStyle),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _confirmController,
                                obscureText: true,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                                decoration: _fieldDecoration(
                                  hint: 'Repeat password',
                                  prefix:
                                      const Icon(Icons.lock_outline_rounded),
                                ),
                                validator: (v) {
                                  if (v != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                            ],
                            const SizedBox(height: 26),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  CinematicTokens.radiusPill,
                                ),
                                gradient: const LinearGradient(
                                  colors: [
                                    CinematicTokens.primary,
                                    CinematicTokens.primaryContainer,
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                boxShadow: CinematicTokens.primaryAmbientGlow(),
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: FilledButton(
                                  onPressed: _busy ? null : _submitEmailAuth,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    foregroundColor:
                                        CinematicTokens.onPrimaryFixed,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        CinematicTokens.radiusPill,
                                      ),
                                    ),
                                  ),
                                  child: _busy
                                      ? SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color:
                                                CinematicTokens.onPrimaryFixed,
                                          ),
                                        )
                                      : Text(
                                          _registerMode
                                              ? 'Create account'
                                              : 'Sign In',
                                          style: GoogleFonts.manrope(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      TextButton(
                        onPressed: _busy
                            ? null
                            : () {
                                setState(() {
                                  _registerMode = !_registerMode;
                                  _confirmController.clear();
                                });
                              },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                        child: Text.rich(
                          TextSpan(
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white38,
                            ),
                            children: [
                              TextSpan(
                                text: _registerMode
                                    ? 'Already use CineLog? '
                                    : 'New to CineLog? ',
                              ),
                              TextSpan(
                                text: _registerMode
                                    ? ' Sign in'
                                    : ' Register Now',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: CinematicTokens.primaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: _busy ? null : _continueAsGuest,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'CONTINUE AS GUEST',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.6,
                                color: Colors.white38,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 18,
                              color: Colors.white38,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'Guest mode keeps your list on this device only. '
                          'Sign in with email to sync across devices.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            height: 1.35,
                            color: Colors.white.withValues(alpha: 0.42),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CinematicAuthBackdrop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                CinematicTokens.pageBackground,
                Color(0xFF0C0C0C),
                CinematicTokens.surfaceDim,
              ],
              stops: [0.0, 0.55, 1.0],
            ),
          ),
        ),
        // Same narrow header accent as app-wide backdrop.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: CinematicHeaderAccentLayer.height,
          child: const CinematicHeaderAccentLayer(),
        ),
        // Subtle bottom glow framing the footer.
        Positioned(
          left: -100,
          right: -100,
          bottom: -140,
          height: 320,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, 1),
                radius: 1.2,
                colors: [
                  CinematicTokens.primaryContainer.withValues(alpha: 0.09),
                  CinematicTokens.primary.withValues(alpha: 0.04),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
