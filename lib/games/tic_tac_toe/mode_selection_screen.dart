// lib/games/tic_tac_toe/mode_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tic_tac_toe_screen.dart';
import 'logic/models.dart';
import '../../app_shell.dart';

class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen({super.key});

  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> with TickerProviderStateMixin {
  // State variable to track if the bot selection is expanded
  bool _isBotSelectionExpanded = false;

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
                  'Choose Game Mode',
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
                        // Player vs Player Button
                        _ModernModeButton(
                          title: 'X vs O (2 Players)',
                          icon: Icons.people,
                          onTap: () {
                            _navigateToGame(context, GameMode.playerVsPlayer);
                          },
                        ),
                        const SizedBox(height: 20),

                        // NEW: The expanding Player vs Bot card
                        _buildBotSelectionCard(),
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

  // This is the new expanding widget
  Widget _buildBotSelectionCard() {
    // We use AnimatedContainer to smoothly change the height
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha:0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withValues(alpha:0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // This is the main part of the button that is always visible
          InkWell(
            onTap: () {
              setState(() {
                _isBotSelectionExpanded = !_isBotSelectionExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.computer, color: Colors.white, size: 30),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "X vs Bot",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.orbitron(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: const Color(0xFF667EEA).withValues(alpha:0.8),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Arrow icon that changed direction
                  Icon(
                    _isBotSelectionExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          
          // This is the part that appears/disappears
          if (_isBotSelectionExpanded)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Divider(color: Colors.white.withValues(alpha:0.3)),
                _buildDifficultyButton(context, "Easy", BotDifficulty.easy),
                _buildDifficultyButton(context, "Medium", BotDifficulty.medium),
                _buildDifficultyButton(context, "Hard", BotDifficulty.hard),
              ],
            ),
        ],
      ),
    );
  }

  // A simple button for the difficulty levels
  Widget _buildDifficultyButton(BuildContext context, String title, BotDifficulty difficulty) {
    return Container(
      width: double.infinity,
      child: TextButton(
        onPressed: () {
          // NOTE: For now, all difficulties will start an "Easy" bot game.
          // We will add the Medium and Hard logic in the next steps.
          _navigateToGame(context, GameMode.playerVsBot, difficulty: difficulty);
        },
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.orbitron(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            shadows: [
              Shadow(
                color: const Color(0xFF667EEA).withValues(alpha:0.8),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToGame(BuildContext context, GameMode mode, {BotDifficulty? difficulty}) {
    // X vs O battle animation (hide tab view)
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => TicTacToeScreen(
          mode: mode,
          difficulty: difficulty,
        ),
        transitionDuration: const Duration(milliseconds: 450),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Flip card transition - like flipping X and O
          const curve = Curves.easeInOutCubic;
          
          // Current page flips out
          var exitRotation = Tween(begin: 0.0, end: 1.5708) // 90 degrees
              .animate(CurvedAnimation(parent: secondaryAnimation, curve: curve));
          var exitFade = Tween(begin: 1.0, end: 0.0)
              .animate(CurvedAnimation(parent: secondaryAnimation, curve: curve));
          
          // New page flips in
          var enterRotation = Tween(begin: -1.5708, end: 0.0) // -90 to 0 degrees
              .animate(CurvedAnimation(parent: animation, curve: curve));
          var enterFade = Tween(begin: 0.0, end: 1.0)
              .animate(CurvedAnimation(parent: animation, curve: curve));
          
          return Stack(
            children: [
              // Exiting page flips out
              if (secondaryAnimation.status != AnimationStatus.dismissed)
                FadeTransition(
                  opacity: exitFade,
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(exitRotation.value),
                    child: Container(), // Previous page
                  ),
                ),
              // Entering page flips in
              FadeTransition(
                opacity: enterFade,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(enterRotation.value),
                  child: child,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// A reusable button for "Player vs Player"
class _ModernModeButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ModernModeButton({ required this.title, required this.icon, required this.onTap });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 30),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha:0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha:0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667EEA).withValues(alpha:0.3),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(width: 16),
            Text(
              title,
              style: GoogleFonts.orbitron(
                fontSize: 20, 
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: const Color(0xFF667EEA).withValues(alpha:0.8),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}