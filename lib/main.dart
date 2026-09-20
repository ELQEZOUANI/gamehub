// lib/main.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_shell.dart';
import 'screens/onboarding_screen.dart';
import 'screens/splash_screen.dart';
import 'services/ad_setup_service.dart';

// "Minimalist Mint" Color Palette
const Color primaryColor = Color(0xFF00CBA9); // The fresh mint accent color
const Color backgroundColor = Color(0xFFF6F7F9); // Light, clean grey background
const Color textColor = Color(0xFF1E2022); // Dark text for readability

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Game Hub: Fun Challenges',

      // Ultimate Cosmic Galaxy Theme
      theme: ThemeData(
        primaryColor: const Color(0xFF667EEA),
        scaffoldBackgroundColor:
            Colors.transparent, // Let custom background show
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF667EEA),
          brightness: Brightness.dark,
        ),

        // Cosmic fonts with glow effects
        textTheme: GoogleFonts.orbitronTextTheme(
          Theme.of(context).textTheme.apply(
                bodyColor: Colors.white,
                displayColor: Colors.white,
              ),
        ).copyWith(
          // Override with Poppins for readability in body text
          bodyLarge: GoogleFonts.poppins(color: Colors.white),
          bodyMedium: GoogleFonts.poppins(color: Colors.white),
          bodySmall: GoogleFonts.poppins(color: Colors.white),
        ),

        // Transparent cosmic app bars
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          centerTitle: true,
          titleTextStyle: GoogleFonts.orbitron(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            shadows: [
              Shadow(
                color: const Color(0xFF667EEA).withValues(alpha: 0.8),
                blurRadius: 10,
              ),
            ],
          ),
        ),

        // Cosmic button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF667EEA),
            foregroundColor: Colors.white,
            elevation: 8,
            shadowColor: const Color(0xFF667EEA).withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),

        // Cosmic card theme
        cardTheme: CardThemeData(
          color: Colors.black.withValues(alpha: 0.3),
          elevation: 10,
          shadowColor: const Color(0xFF667EEA).withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
        ),
      ),
      home: const SplashScreen(nextScreen: OnboardingCheckScreen()),
    );
  }
}

class OnboardingCheckScreen extends StatefulWidget {
  const OnboardingCheckScreen({super.key});

  @override
  State<OnboardingCheckScreen> createState() => _OnboardingCheckScreenState();
}

class _OnboardingCheckScreenState extends State<OnboardingCheckScreen> {
  bool _isLoading = true;
  bool _hasCompletedOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userName = prefs.getString('user_name');
      final hasCompletedOnboarding = userName != null && userName.isNotEmpty;
      if (!mounted) return;
      setState(() {
        _hasCompletedOnboarding = hasCompletedOnboarding;
        _isLoading = false;
      });
      if (hasCompletedOnboarding) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AdSetupService.initializeAfterConsent();
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasCompletedOnboarding = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF667EEA),
                const Color(0xFF764BA2),
                const Color(0xFF2D3436),
              ],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ),
        ),
      );
    }

    return _hasCompletedOnboarding
        ? const AppShell()
        : const OnboardingScreen();
  }
}
