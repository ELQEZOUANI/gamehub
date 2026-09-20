// lib/games/rps/rps_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/stats_service.dart';
import '../../app_shell.dart';

enum Rps { rock, paper, scissors }

class RpsScreen extends StatefulWidget {
  const RpsScreen({super.key});

  @override
  State<RpsScreen> createState() => _RpsScreenState();
}

class _RpsScreenState extends State<RpsScreen> with TickerProviderStateMixin {
  final Random _random = Random();
  Rps? _player;
  Rps? _bot;
  String? _result;

  // Galaxy background animations
  late AnimationController _galaxyController;
  late AnimationController _starsController;
  late AnimationController _nebulaController;
  late Animation<double> _galaxyAnimation;
  late Animation<double> _starsAnimation;
  late Animation<double> _nebulaAnimation;

  // Battle animations
  late AnimationController _battleController;
  late Animation<double> _battleAnimation;

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
    
    // Battle animation
    _battleController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _battleAnimation = CurvedAnimation(parent: _battleController, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _galaxyController.dispose();
    _starsController.dispose();
    _nebulaController.dispose();
    _battleController.dispose();
    super.dispose();
  }

  void _play(Rps choice) async {
    // Reset animation
    _battleController.reset();
    
    final bot = Rps.values[_random.nextInt(3)];
    final result = _judge(choice, bot);
    
    setState(() {
      _player = choice;
      _bot = bot;
      _result = result;
    });
    
    // Trigger battle animation
    _battleController.forward();
    
    // Record game result with score based on outcome
    int score = 0;
    switch (result) {
      case 'Win':
        score = 1; // Win = 1 point
        break;
      case 'Lose':
        score = 0; // Loss = 0 points
        break;
      default:
        score = 0; // Draw = 0 points (could be 0.5 if needed)
    }
    
    await StatsService().recordGameResult(
      gameID: StatsService.gameRockPaperScissors,
      score: score,
    );
  }

  String _judge(Rps p, Rps b) {
    if (p == b) return 'Draw';
    if ((p == Rps.rock && b == Rps.scissors) ||
        (p == Rps.paper && b == Rps.rock) ||
        (p == Rps.scissors && b == Rps.paper)) {
      return 'Win';
    }
    return 'Lose';
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
              // Cosmic AppBar
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.white),
                title: Text(
                  'Rock • Paper • Scissors',
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    shadows: [
                      Shadow(
                        color: const Color(0xFF667EEA).withValues(alpha:0.8),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Game Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Battle Status
                      AnimatedBuilder(
                        animation: _battleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 + (_battleAnimation.value * 0.1),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha:0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha:0.3),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF667EEA).withValues(alpha:0.3),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Text(
                                _result == null ? 'Choose Your Weapon!' : _getResultText(),
                                style: GoogleFonts.orbitron(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: const Color(0xFF667EEA).withValues(alpha:0.8),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Battle Arena
                      if (_player != null && _bot != null)
                        AnimatedBuilder(
                          animation: _battleAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 1.0 + (_battleAnimation.value * 0.2),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha:0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha:0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _CosmicMovePreview(label: 'You', move: _player!, isWinner: _result == 'Win'),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha:0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        'VS',
                                        style: GoogleFonts.orbitron(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    _CosmicMovePreview(label: 'Bot', move: _bot!, isWinner: _result == 'Lose'),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      
                      const SizedBox(height: 50),
                      
                      // Cosmic Move Buttons
                      Row(
                        children: [
                          Expanded(
                            child: _CosmicMoveButton(
                              icon: '✊',
                              label: 'Rock',
                              color: const Color(0xFFFF6B6B),
                              onTap: () => _play(Rps.rock),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _CosmicMoveButton(
                              icon: '✋',
                              label: 'Paper',
                              color: const Color(0xFF4ECDC4),
                              onTap: () => _play(Rps.paper),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _CosmicMoveButton(
                              icon: '✌️',
                              label: 'Scissors',
                              color: const Color(0xFFFFE66D),
                              onTap: () => _play(Rps.scissors),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getResultText() {
    switch (_result) {
      case 'Win':
        return '🎉 Victory! You Win! 🎉';
      case 'Lose':
        return '💫 Bot Wins! Try Again! 💫';
      case 'Draw':
        return '🤝 It\'s a Draw! 🤝';
      default:
        return 'Choose Your Weapon!';
    }
  }
}

// Cosmic Move Button
class _CosmicMoveButton extends StatefulWidget {
  final String icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CosmicMoveButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_CosmicMoveButton> createState() => _CosmicMoveButtonState();
}

class _CosmicMoveButtonState extends State<_CosmicMoveButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
        _controller.forward();
      },
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha:0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.color.withValues(alpha:0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha:0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    widget.icon,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.label,
                    style: GoogleFonts.orbitron(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 14,
                      shadows: [
                        Shadow(
                          color: widget.color.withValues(alpha:0.8),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Cosmic Move Preview
class _CosmicMovePreview extends StatelessWidget {
  final String label;
  final Rps move;
  final bool isWinner;

  const _CosmicMovePreview({
    required this.label,
    required this.move,
    required this.isWinner,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.orbitron(
            color: Colors.white.withValues(alpha:0.8),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isWinner 
                ? const Color(0xFF4ECDC4).withValues(alpha:0.2)
                : Colors.white.withValues(alpha:0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: isWinner 
                  ? const Color(0xFF4ECDC4)
                  : Colors.white.withValues(alpha:0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isWinner 
                    ? const Color(0xFF4ECDC4).withValues(alpha:0.4)
                    : Colors.white.withValues(alpha:0.2),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Text(
            _getIcon(move),
            style: const TextStyle(fontSize: 36),
          ),
        ),
      ],
    );
  }

  String _getIcon(Rps move) {
    switch (move) {
      case Rps.rock:
        return '✊';
      case Rps.paper:
        return '✋';
      case Rps.scissors:
        return '✌️';
    }
  }
}