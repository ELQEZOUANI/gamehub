// lib/screens/all_games_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../games/2048/level_selection_screen.dart';
import '../games/tic_tac_toe/mode_selection_screen.dart';
import '../games/rps/rps_screen.dart';

import '../games/memory/memory_screen.dart';
import '../games/quick_reaction/quick_reaction_screen.dart';
import 'package:gameapp/games/sketch_it/sketch_it_setup_screen.dart';
import '../games/simon_says/simon_says_screen.dart';

import '../games/word_guess/word_guess_screen.dart';
import '../services/game_prefs_service.dart';
import '../services/interstitial_ad_service.dart';

class AllGamesScreen extends StatefulWidget {
  const AllGamesScreen({super.key});

  @override
  State<AllGamesScreen> createState() => _AllGamesScreenState();
}

class _AllGamesScreenState extends State<AllGamesScreen>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  bool _openingGame = false;

  final List<Map<String, dynamic>> games = [
    {
      'title': '2048',
      'subtitle': 'Slide & Merge Numbers',
      'emoji': '🔢',
      'gradient':
          const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
      'screen': const LevelSelection2048Screen(),
      'isComingSoon': false,
    },
    {
      'title': 'Tic-Tac-Toe',
      'subtitle': 'Classic Strategy Game',
      'emoji': '✨',
      'gradient':
          const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)]),
      'screen': const ModeSelectionScreen(),
      'isComingSoon': false,
    },
    {
      'title': 'Rock Paper Scissors',
      'subtitle': 'Quick Hand Battle',
      'emoji': '✊',
      'gradient':
          const LinearGradient(colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)]),
      'screen': const RpsScreen(),
      'isComingSoon': false,
    },
    {
      'title': 'Quick Reaction',
      'subtitle': 'Test Your Reflexes',
      'emoji': '⚡️',
      'gradient':
          const LinearGradient(colors: [Color(0xFF42A5F5), Color(0xFF3498DB)]),
      'screen': const QuickReactionScreen(),
      'isComingSoon': false,
    },
    {
      'title': 'Sketch It!',
      'subtitle': 'Draw & Guess Fun',
      'emoji': '✏️',
      'gradient':
          const LinearGradient(colors: [Color(0xFF9C27B0), Color(0xFF673AB7)]),
      'screen': const SketchItSetupScreen(),
      'isComingSoon': false,
    },
    {
      'title': 'Memory Match',
      'subtitle': 'Find Matching Pairs',
      'emoji': '🧠',
      'gradient':
          const LinearGradient(colors: [Color(0xFFFFE66D), Color(0xFFFFA502)]),
      'screen': const MemoryScreen(),
      'isComingSoon': false,
    },
    {
      'title': 'Simon Says',
      'subtitle': 'Repeat the Pattern',
      'emoji': '🎨',
      'gradient':
          const LinearGradient(colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)]),
      'screen': const SimonSaysScreen(),
      'isComingSoon': false,
    },
    {
      'title': 'Word Guess',
      'subtitle': 'Mini Hangman Fun',
      'emoji': '🤔',
      'gradient':
          const LinearGradient(colors: [Color(0xFFf857a6), Color(0xFFff5858)]),
      'screen': const WordGuessScreen(),
      'isComingSoon': false,
    },
    // Coming Soon Games
    {
      'title': 'Snake',
      'subtitle': 'Classic Retro Game',
      'emoji': '🐍',
      'gradient':
          const LinearGradient(colors: [Color(0xFF06beb6), Color(0xFF48b1bf)]),
      'isComingSoon': true,
    },
    {
      'title': 'Puzzle Master',
      'subtitle': 'Solve Mind-Bending Puzzles',
      'emoji': '🧩',
      'gradient':
          const LinearGradient(colors: [Color(0xFFf093fb), Color(0xFFf5576c)]),
      'isComingSoon': true,
    },
    {
      'title': 'Trivia Quiz',
      'subtitle': 'Test Your Knowledge',
      'emoji': '❓',
      'gradient':
          const LinearGradient(colors: [Color(0xFF4facfe), Color(0xFF00f2fe)]),
      'isComingSoon': true,
    },
    {
      'title': 'Math Challenge',
      'subtitle': 'Quick Mental Math',
      'emoji': '➗',
      'gradient':
          const LinearGradient(colors: [Color(0xFFfa709a), Color(0xFFfee140)]),
      'isComingSoon': true,
    },
    {
      'title': 'Color Match',
      'subtitle': 'Match the Colors Fast',
      'emoji': '🎨',
      'gradient':
          const LinearGradient(colors: [Color(0xFF30cfd0), Color(0xFF330867)]),
      'isComingSoon': true,
    },
    {
      'title': 'Card Flip',
      'subtitle': 'Memory Card Game',
      'emoji': '🃏',
      'gradient':
          const LinearGradient(colors: [Color(0xFFa8edea), Color(0xFFfed6e3)]),
      'isComingSoon': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      games.length,
      (index) => AnimationController(
        duration: Duration(milliseconds: 600 + (index * 100)),
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutBack,
      );
    }).toList();

    // Start animations with delay
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) _controllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'All Games',
                      style: GoogleFonts.fredoka(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose your adventure!',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  physics: const BouncingScrollPhysics(),
                  itemCount: games.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: ScaleTransition(
                        scale: _animations[index],
                        child: GameCard3D(
                          title: games[index]['title'],
                          subtitle: games[index]['subtitle'],
                          emoji: games[index]['emoji'],
                          gradient: games[index]['gradient'],
                          isComingSoon: games[index]['isComingSoon'] ?? false,
                          onTap: () async {
                            if (_openingGame) return;
                            // Check if game is coming soon
                            if (games[index]['isComingSoon'] == true) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${games[index]['title']} is coming soon! Stay tuned! 🎮',
                                    style: GoogleFonts.poppins(
                                        color: Colors.white),
                                  ),
                                  backgroundColor: const Color(0xFFFF6B6B),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                              return;
                            }

                            _openingGame = true;
                            try {
                              final proceed = await InterstitialAdService
                                  .instance
                                  .showBeforeGame();
                              if (!mounted || !context.mounted || !proceed) {
                                return;
                              }
                              // Save the last played game
                              GamePrefsService.setLastPlayedGame(
                                  games[index]['title']);

                              // Navigate with full screen (hide tab view)
                              await Navigator.of(context, rootNavigator: true)
                                  .push(
                                PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      games[index]['screen'],
                                  transitionDuration:
                                      const Duration(milliseconds: 400),
                                  reverseTransitionDuration:
                                      const Duration(milliseconds: 300),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    // Morphing transition - current page transforms into new page
                                    const curve = Curves.easeInOutExpo;

                                    // Current page shrinks and fades out
                                    var exitScale = Tween(begin: 1.0, end: 0.8)
                                        .animate(CurvedAnimation(
                                            parent: secondaryAnimation,
                                            curve: curve));
                                    var exitFade = Tween(begin: 1.0, end: 0.0)
                                        .animate(CurvedAnimation(
                                            parent: secondaryAnimation,
                                            curve: curve));

                                    // New page grows from center with rotation
                                    var enterScale = Tween(begin: 0.3, end: 1.0)
                                        .animate(CurvedAnimation(
                                            parent: animation, curve: curve));
                                    var enterFade = Tween(begin: 0.0, end: 1.0)
                                        .animate(CurvedAnimation(
                                            parent: animation, curve: curve));
                                    var enterRotation =
                                        Tween(begin: 0.5, end: 0.0).animate(
                                            CurvedAnimation(
                                                parent: animation,
                                                curve: curve));

                                    return Stack(
                                      children: [
                                        // Exiting page
                                        if (secondaryAnimation.status !=
                                            AnimationStatus.dismissed)
                                          FadeTransition(
                                            opacity: exitFade,
                                            child: ScaleTransition(
                                              scale: exitScale,
                                              child:
                                                  Container(), // Previous page fades out
                                            ),
                                          ),
                                        // Entering page
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
                            } finally {
                              _openingGame = false;
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Add bottom padding to lift content above tab view
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class GameCard3D extends StatefulWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final Gradient gradient;
  final VoidCallback onTap;
  final bool isComingSoon;

  const GameCard3D({
    super.key,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.gradient,
    required this.onTap,
    this.isComingSoon = false,
  });

  @override
  State<GameCard3D> createState() => GameCard3DState();
}

class GameCard3DState extends State<GameCard3D>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.02,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          final palette = (widget.gradient as LinearGradient).colors;
          final accent = palette.first;
          final accentSecondary = palette.last;
          return Transform.scale(
            scale: _isPressed ? 0.98 : 1.0,
            child: Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(_rotationAnimation.value),
              alignment: Alignment.center,
              child: Container(
                constraints: const BoxConstraints(minHeight: 144),
                decoration: BoxDecoration(
                  color: const Color(0xFF10182D).withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(28),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.14)),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(
                        alpha: widget.isComingSoon ? 0.08 : 0.28,
                      ),
                      blurRadius: _isPressed ? 14 : 26,
                      spreadRadius: _isPressed ? 0 : 1,
                      offset: Offset(0, _isPressed ? 6 : 12),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                accent.withValues(alpha: 0.23),
                                accentSecondary.withValues(alpha: 0.07),
                                const Color(0xFF10182D).withValues(alpha: 0.72),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: -72,
                        right: -42,
                        child: Container(
                          width: 176,
                          height: 176,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.10),
                            ),
                            gradient: RadialGradient(
                              colors: [
                                accentSecondary.withValues(alpha: 0.28),
                                accent.withValues(alpha: 0.02),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 6,
                          height: 88,
                          decoration: BoxDecoration(
                            gradient: widget.gradient,
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 18, 18, 18),
                        child: Row(
                          children: [
                            Container(
                              width: 76,
                              height: 76,
                              decoration: BoxDecoration(
                                gradient: widget.gradient,
                                borderRadius: BorderRadius.circular(23),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.32),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: accent.withValues(alpha: 0.46),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  widget.emoji,
                                  style: TextStyle(
                                    fontSize: 36,
                                    color: widget.isComingSoon
                                        ? Colors.white.withValues(alpha: 0.60)
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          widget.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.fredoka(
                                            fontSize: 23,
                                            height: 1.05,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      if (widget.isComingSoon) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(
                                              alpha: 0.13,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color: Colors.white.withValues(
                                                alpha: 0.20,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            'SOON',
                                            style: GoogleFonts.poppins(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 7),
                                  Text(
                                    widget.subtitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      height: 1.25,
                                      color:
                                          Colors.white.withValues(alpha: 0.72),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.10),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.18),
                                ),
                              ),
                              child: Icon(
                                widget.isComingSoon
                                    ? Icons.lock_outline_rounded
                                    : Icons.play_arrow_rounded,
                                size: 25,
                                color: Colors.white.withValues(alpha: 0.92),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.isComingSoon)
                        Positioned.fill(
                          child: ColoredBox(
                            color: Colors.black.withValues(alpha: 0.18),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
