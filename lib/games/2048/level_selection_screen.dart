// lib/games/2048/level_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'game_2048_screen.dart';
import '../../app_shell.dart';

class LevelSelection2048Screen extends StatefulWidget {
  const LevelSelection2048Screen({super.key});

  @override
  State<LevelSelection2048Screen> createState() => _LevelSelection2048ScreenState();
}

class _LevelSelection2048ScreenState extends State<LevelSelection2048Screen> with TickerProviderStateMixin {
  // Galaxy background animations
  late AnimationController _galaxyController;
  late AnimationController _starsController;
  late AnimationController _nebulaController;
  late Animation<double> _galaxyAnimation;
  late Animation<double> _starsAnimation;
  late Animation<double> _nebulaAnimation;

  @override
  void initState() {
    super.initState();
    
    // Galaxy animations
    _galaxyController = AnimationController(duration: const Duration(seconds: 30), vsync: this)..repeat();
    _starsController = AnimationController(duration: const Duration(seconds: 3), vsync: this)..repeat(reverse: true);
    _nebulaController = AnimationController(duration: const Duration(seconds: 15), vsync: this)..repeat(reverse: true);
    _galaxyAnimation = CurvedAnimation(parent: _galaxyController, curve: Curves.linear);
    _starsAnimation = CurvedAnimation(parent: _starsController, curve: Curves.easeInOut);
    _nebulaAnimation = CurvedAnimation(parent: _nebulaController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _galaxyController.dispose();
    _starsController.dispose();
    _nebulaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Galaxy Background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: Listenable.merge([_galaxyAnimation, _nebulaAnimation]),
              builder: (context, child) {
                return CustomPaint(
                  painter: NebulaPainter(_nebulaAnimation.value),
                  child: CustomPaint(
                    painter: GalaxyPainter(_galaxyAnimation.value),
                    child: AnimatedBuilder(
                      animation: _starsAnimation,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: StarsPainter(_starsAnimation.value),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          // Foreground content
          Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.white),
                title: Text(
                  'Choose Difficulty',
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    shadows: [
                      Shadow(
                        color: const Color(0xFF667EEA).withValues(alpha:0.8),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ModernLevelButton(
                title: 'Easy',
                subtitle: '3 x 3',
                onTap: () => _navigateToGame(context, 3),
              ),
              const SizedBox(height: 20),
              _ModernLevelButton(
                title: 'Classic',
                subtitle: '4 x 4',
                onTap: () => _navigateToGame(context, 4),
              ),
              const SizedBox(height: 20),
              _ModernLevelButton(
                title: 'Hard',
                subtitle: '5 x 5',
                onTap: () => _navigateToGame(context, 5),
              ),
                  ],
                ),
              ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToGame(BuildContext context, int gridSize) {
    // 2048 slide animation (hide tab view)
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
            Game2048Screen(gridSize: gridSize),
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Tile merge effect - like 2048 tiles merging
          const curve = Curves.easeInOutQuint;
          
          // Current page splits and fades
          var exitScale = Tween(begin: 1.0, end: 0.0)
              .animate(CurvedAnimation(parent: secondaryAnimation, curve: curve));
          var exitFade = Tween(begin: 1.0, end: 0.0)
              .animate(CurvedAnimation(parent: secondaryAnimation, curve: curve));
          
          // New page merges in from multiple points
          var enterScale = Tween(begin: 2.0, end: 1.0)
              .animate(CurvedAnimation(parent: animation, curve: curve));
          var enterFade = Tween(begin: 0.0, end: 1.0)
              .animate(CurvedAnimation(parent: animation, curve: curve));
          var enterRotation = Tween(begin: 0.2, end: 0.0)
              .animate(CurvedAnimation(parent: animation, curve: curve));
          
          return Stack(
            children: [
              // Exiting page shrinks away
              if (secondaryAnimation.status != AnimationStatus.dismissed)
                FadeTransition(
                  opacity: exitFade,
                  child: ScaleTransition(
                    scale: exitScale,
                    child: Container(), // Previous page
                  ),
                ),
              // Entering page merges in
              FadeTransition(
                opacity: enterFade,
                child: ScaleTransition(
                  scale: enterScale,
                  child: Transform.rotate(
                    angle: enterRotation.value,
                    child: child,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}


// A stylish button specifically for selecting levels
class _ModernLevelButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ModernLevelButton({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      tween: Tween(begin: 0.98, end: 1),
      builder: (context, value, child) => Transform.scale(scale: value, child: child),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667EEA).withValues(alpha:0.3),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 20),
            backgroundColor: Colors.white.withValues(alpha:0.15),
            side: BorderSide(color: Colors.white.withValues(alpha:0.3), width: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        child: Column(
          children: [
            Text(
              title,
              style: GoogleFonts.orbitron(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: const Color(0xFF667EEA).withValues(alpha:0.8),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.orbitron(
                fontSize: 14,
                color: Colors.white.withValues(alpha:0.8),
                shadows: [
                  Shadow(
                    color: const Color(0xFF667EEA).withValues(alpha:0.5),
                    blurRadius: 5,
                  ),
                ],
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}