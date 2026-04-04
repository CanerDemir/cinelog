import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';
import 'services/storage_service.dart';
import 'theme/cinematic_page_backdrop.dart';
import 'theme/cinematic_tokens.dart';
import 'widgets/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await StorageService.init();
  runApp(
    const ProviderScope(
      child: WatchlistApp(),
    ),
  );
}

class WatchlistApp extends StatelessWidget {
  const WatchlistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CineLog',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.transparent,
        textTheme: GoogleFonts.interTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
        colorScheme: ColorScheme.dark(
          primary: CinematicTokens.primary,
          onPrimary: Colors.white,
          primaryContainer: CinematicTokens.primaryContainer,
          onPrimaryContainer: CinematicTokens.onPrimaryFixed,
          secondary: CinematicTokens.secondary,
          onSecondary: CinematicTokens.surface,
          tertiary: CinematicTokens.tertiary,
          onTertiary: CinematicTokens.surface,
          surface: CinematicTokens.surface,
          onSurface: Colors.white,
          surfaceContainerLow: CinematicTokens.surfaceContainerLow,
          surfaceContainer: CinematicTokens.surfaceContainer,
          surfaceContainerHigh: CinematicTokens.surfaceContainerHigh,
          surfaceContainerHighest: CinematicTokens.surfaceBright,
          onSurfaceVariant: CinematicTokens.labelMuted,
          outlineVariant: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            minimumSize: const Size(48, 48),
            tapTargetSize: MaterialTapTargetSize.padded,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: CinematicTokens.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CinematicTokens.radiusXl),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: CinematicTokens.surfaceContainerHigh,
          hintStyle: const TextStyle(color: CinematicTokens.hint),
          prefixIconColor: CinematicTokens.hint,
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
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: CinematicTokens.primaryContainer,
            foregroundColor: CinematicTokens.onPrimaryFixed,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(CinematicTokens.radiusPill),
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: CinematicTokens.primaryContainer,
            foregroundColor: CinematicTokens.onPrimaryFixed,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(CinematicTokens.radiusPill),
            ),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: CinematicTokens.surfaceContainerHigh,
          labelStyle: const TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: CinematicTokens.pageBackground,
          selectedItemColor: CinematicTokens.primaryContainer,
          unselectedItemColor: CinematicTokens.hint,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
      ),
      themeMode: ThemeMode.dark,
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        return Stack(
          fit: StackFit.expand,
          children: [
            const CinematicPageBackdrop(),
            child,
          ],
        );
      },
    );
  }
}
