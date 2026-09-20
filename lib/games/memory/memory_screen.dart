import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/stats_service.dart';
import '../../utils/mission_tracker.dart';

class MemoryScreen extends StatefulWidget {
  const MemoryScreen({super.key});

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> with TickerProviderStateMixin {
  // Game state
  int currentLevel = 1;
  int currentScore = 0;
  int bestScore = 0;
  List<String> gameCards = [];
  List<bool> flippedCards = [];
  List<bool> matchedCards = [];
  List<int> selectedCards = [];
  
  // Timer
  Timer? gameTimer;
  int timeLeft = 60; // seconds per level
  
  // Game logic
  bool canFlip = true;
  Timer? flipBackTimer;
  int matches = 0;
  int totalPairs = 0;
  
  // Audio
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Unified galaxy background animation
  late AnimationController _backgroundController;
  
  // Card animations
  late AnimationController _flipController;
  late AnimationController _matchController;
  late AnimationController _levelCompleteController;

  late Animation<double> _matchAnimation;
  late Animation<double> _levelCompleteAnimation;

  // Card image assets for different levels (PNG 512x512)
  // Make sure these files exist under assets/memory/ and are declared in pubspec.yaml
  final List<String> allCardImages = [
    'assets/memory/m1.png',
    'assets/memory/m2.png',
    'assets/memory/m3.png',
    'assets/memory/m4.png',
    'assets/memory/m5.png',
    'assets/memory/m6.png',
    'assets/memory/m7.png',
    'assets/memory/m8.png',
    'assets/memory/m9.png',
    'assets/memory/m10.png',
    'assets/memory/m11.png',
    'assets/memory/m12.png',
    'assets/memory/m13.png',
    'assets/memory/m14.png',
    'assets/memory/m15.png',
    'assets/memory/m16.png',
    'assets/memory/m17.png',
    'assets/memory/m18.png',
    'assets/memory/m19.png',
    'assets/memory/m20.png',
    'assets/memory/m21.png',
    'assets/memory/m22.png',
    'assets/memory/m23.png',
    'assets/memory/m24.png',
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _initializeAnimations();
    
    // Load best score and start game
    _loadBestScore();
    _startLevel();
  }

  void _initializeAnimations() {
    // Unified background animation
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();
    
    // Card animations
    _flipController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _matchController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _levelCompleteController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    
    _matchAnimation = CurvedAnimation(parent: _matchController, curve: Curves.elasticOut);
    _levelCompleteAnimation = CurvedAnimation(parent: _levelCompleteController, curve: Curves.easeInOutBack);
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    flipBackTimer?.cancel();
    _audioPlayer.dispose();
    _backgroundController.dispose();
    _flipController.dispose();
    _matchController.dispose();
    _levelCompleteController.dispose();
    super.dispose();
  }

  Future<void> _loadBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      bestScore = prefs.getInt('memory_best_score') ?? 0;
    });
  }

  // Removed _saveBestScore - now handled by centralized StatsService

  void _startLevel() {
    // Calculate grid size based on level
    Map<String, int> gridSize = _getGridSize(currentLevel);
    int rows = gridSize['rows']!;
    int cols = gridSize['cols']!;
    totalPairs = (rows * cols) ~/ 2;
    
    // Reset game state
    matches = 0;
    selectedCards.clear();
    canFlip = true;
    
    // Set timer based on level difficulty
    timeLeft = _getTimeLimit(currentLevel);
    
    // Generate cards
    _generateCards(rows, cols);
    
    // Start timer
    _startTimer();
    
    setState(() {});
  }

  Map<String, int> _getGridSize(int level) {
    // Progressive difficulty
    switch (level) {
      case 1: return {'rows': 2, 'cols': 2}; // 4 cards, 2 pairs
      case 2: return {'rows': 2, 'cols': 3}; // 6 cards, 3 pairs
      case 3: return {'rows': 3, 'cols': 4}; // 12 cards, 6 pairs
      case 4: return {'rows': 4, 'cols': 4}; // 16 cards, 8 pairs
      case 5: return {'rows': 4, 'cols': 5}; // 20 cards, 10 pairs
      case 6: return {'rows': 5, 'cols': 6}; // 30 cards, 15 pairs
      default: 
        // For levels 7+, keep increasing
        int cards = 8 + (level * 2);
        int cols = (cards / 4).ceil();
        int rows = (cards / cols).ceil();
        return {'rows': rows, 'cols': cols};
    }
  }

  int _getTimeLimit(int level) {
    // More time for harder levels
    return 30 + (level * 15); // Level 1: 45s, Level 2: 60s, etc.
  }

  void _generateCards(int rows, int cols) {
    int totalCards = rows * cols;
    int pairs = totalCards ~/ 2;
    
    // Select random images for this level and build the deck
    List<String> pool;
    if (allCardImages.length < pairs) {
      // If provided assets are fewer than needed, cycle through safely
      pool = List<String>.generate(pairs, (i) => allCardImages[i % allCardImages.length]);
    } else {
      pool = List<String>.from(allCardImages);
    }
    pool.shuffle();
    final List<String> selectedImages = pool.take(pairs).toList();

    gameCards = [];
    for (final imagePath in selectedImages) {
      gameCards.add(imagePath);
      gameCards.add(imagePath);
    }
    gameCards.shuffle();
    
    // Initialize card states
    flippedCards = List.filled(totalCards, false);
    matchedCards = List.filled(totalCards, false);
  }

  void _startTimer() {
    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        _gameOver();
      }
    });
  }

  void _flipCard(int index) {
    if (!canFlip || flippedCards[index] || matchedCards[index]) return;
    
    _playSound('tictactoe_click.mp3');
    
    setState(() {
      flippedCards[index] = true;
      selectedCards.add(index);
    });
    
    if (selectedCards.length == 2) {
      canFlip = false;
      _checkForMatch();
    }
  }

  void _checkForMatch() {
    int first = selectedCards[0];
    int second = selectedCards[1];
    
    if (gameCards[first] == gameCards[second]) {
      // Match found!
      _playSound('merge.mp3');
      setState(() {
        matchedCards[first] = true;
        matchedCards[second] = true;
        currentScore += 10; // +10 points for match
        matches++;
      });
      
      // Trigger match animation
      _matchController.forward().then((_) {
        _matchController.reset();
      });
      
      selectedCards.clear();
      canFlip = true;
      
      // Check if level complete
      if (matches == totalPairs) {
        _levelComplete();
      }
      
    } else {
      // No match
      setState(() {
        currentScore = max(0, currentScore - 2); // -2 points for wrong match
      });
      
      // Flip cards back after delay
      flipBackTimer = Timer(const Duration(milliseconds: 1000), () {
        setState(() {
          flippedCards[first] = false;
          flippedCards[second] = false;
          selectedCards.clear();
          canFlip = true;
        });
      });
    }
  }

  void _levelComplete() async {
    gameTimer?.cancel();
    
    // Bonus points for time remaining
    int timeBonus = timeLeft * 2;
    setState(() {
      currentScore += timeBonus;
    });
    
    await StatsService().recordGameResult(
      gameID: StatsService.gameMemoryMatch,
      score: currentScore,
    );
    
    // Track mission progress
    try {
      await MissionTracker.trackGameCompletion(
        gameTitle: 'Memory Match',
        finalScore: currentScore,
      );
    } catch (e) {
      debugPrint('Mission tracking error: $e');
    }
    
    _levelCompleteController.forward();
    
    // Show level complete dialog
    _showLevelCompleteDialog(timeBonus);
  }

  void _gameOver() async {
    gameTimer?.cancel();
    
    await StatsService().recordGameResult(
      gameID: StatsService.gameMemoryMatch,
      score: currentScore,
    );
    
    // Track mission progress
    try {
      await MissionTracker.trackGameCompletion(
        gameTitle: 'Memory Match',
        finalScore: currentScore,
      );
    } catch (e) {
      debugPrint('Mission tracking error: $e');
    }
    
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _buildGameOverDialog(),
      );
    }
  }

  void _showLevelCompleteDialog(int timeBonus) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildLevelCompleteDialog(timeBonus),
    );
  }

  Future<void> _playSound(String soundFile) async {
    try {
      await _audioPlayer.play(AssetSource('audio/$soundFile'));
    } catch (e) {
      debugPrint("Error playing sound: $e");
    }
  }

  void _nextLevel() {
    Navigator.of(context).pop(); // Close dialog
    setState(() {
      currentLevel++;
    });
    _levelCompleteController.reset();
    _startLevel();
  }

  void _restartGame() {
    Navigator.of(context).pop(); // Close dialog
    setState(() {
      currentLevel = 1;
      currentScore = 0;
    });
    _levelCompleteController.reset();
    _startLevel();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, int> gridSize = _getGridSize(currentLevel);
    int cols = gridSize['cols']!;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Simple animated gradient background
          AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              final t = _backgroundController.value;
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(-1 + t * 0.4, -1 + t * 0.3),
                    end: Alignment(1 - t * 0.4, 1 - t * 0.3),
                    colors: [
                      const Color(0xFF0F1419),
                      const Color(0xFF16213E).withValues(alpha: 0.9),
                      const Color(0xFF1A1A2E).withValues(alpha: 0.8),
                    ],
                  ),
                ),
              );
            },
          ),
          
          // Game Content
          Column(
            children: [
              // Cosmic AppBar
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.white),
                title: Text(
                  'Memory Match',
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
              
              // Game Stats
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard('Level', currentLevel.toString(), const Color(0xFF4ECDC4)),
                    _buildStatCard('Score', currentScore.toString(), const Color(0xFFFFE66D)),
                    _buildStatCard('Time', '$timeLeft s', timeLeft <= 10 ? const Color(0xFFFF6B6B) : const Color(0xFF95E1D3)),
                    _buildStatCard('Best', bestScore.toString(), const Color(0xFFB8860B)),
                  ],
                ),
              ),
              
              // Game Grid
              Expanded(
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
                    padding: const EdgeInsets.all(20),
                    child: AnimatedBuilder(
                      animation: _levelCompleteAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + (_levelCompleteAnimation.value * 0.1),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: cols,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 1,
                            ),
                            itemCount: gameCards.length,
                            itemBuilder: (context, index) {
                              return _buildMemoryCard(index);
                            },
                          ),
                        );
                      },
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

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha:0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha:0.3),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.orbitron(
              fontSize: 10,
              color: Colors.white.withValues(alpha:0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.orbitron(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: color.withValues(alpha:0.8),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoryCard(int index) {
    bool isFlipped = flippedCards[index];
    bool isMatched = matchedCards[index];
    
    return GestureDetector(
      onTap: () => _flipCard(index),
      child: AnimatedBuilder(
        animation: _matchAnimation,
        builder: (context, child) {
          double scale = isMatched ? 1.0 + (_matchAnimation.value * 0.2) : 1.0;
          
          return Transform.scale(
            scale: scale,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: isMatched 
                        ? const Color(0xFF4ECDC4).withValues(alpha:0.5)
                        : Colors.white.withValues(alpha:0.2),
                    blurRadius: isMatched ? 15 : 8,
                    spreadRadius: isMatched ? 2 : 1,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return RotationTransition(
                      turns: animation,
                      child: child,
                    );
                  },
                  child: isFlipped || isMatched
                      ? Container(
                          key: ValueKey('front_$index'),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: const [
                                Color(0xFF667EEA),
                                Color(0xFF764BA2),
                              ],
                            ),
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final double size = constraints.biggest.shortestSide * 0.6; // 60% of card
                              return Center(
                                child: Image.asset(
                                  gameCards[index],
                                  width: size,
                                  height: size,
                                  fit: BoxFit.contain,
                                ),
                              );
                            },
                          ),
                        )
                      : Container(
                          key: ValueKey('back_$index'),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withValues(alpha:0.2),
                                Colors.white.withValues(alpha:0.1),
                              ],
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha:0.3),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.help_outline,
                              color: Colors.white.withValues(alpha:0.6),
                              size: 32,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLevelCompleteDialog(int timeBonus) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha:0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha:0.3)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667EEA).withValues(alpha:0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '🎉 Level Complete! 🎉',
              style: GoogleFonts.orbitron(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: const Color(0xFF4ECDC4).withValues(alpha:0.8),
                    blurRadius: 10,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'Level $currentLevel Complete!',
              style: GoogleFonts.orbitron(
                fontSize: 18,
                color: Colors.white.withValues(alpha:0.9),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Score: $currentScore',
              style: GoogleFonts.orbitron(
                fontSize: 16,
                color: Colors.white.withValues(alpha:0.8),
              ),
            ),
            if (timeBonus > 0) ...[
              Text(
                'Time Bonus: +$timeBonus',
                style: GoogleFonts.orbitron(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha:0.2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.white.withValues(alpha:0.3)),
                      ),
                    ),
                    onPressed: _restartGame,
                    child: Text(
                      'Restart',
                      style: GoogleFonts.orbitron(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4ECDC4),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _nextLevel,
                    child: Text(
                      'Next Level',
                      style: GoogleFonts.orbitron(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOverDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha:0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha:0.3)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6B6B).withValues(alpha:0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '⏰ Time\'s Up! ⏰',
              style: GoogleFonts.orbitron(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: const Color(0xFFFF6B6B).withValues(alpha:0.8),
                    blurRadius: 10,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'Final Score: $currentScore',
              style: GoogleFonts.orbitron(
                fontSize: 18,
                color: Colors.white.withValues(alpha:0.9),
              ),
            ),
            Text(
              'Level Reached: $currentLevel',
              style: GoogleFonts.orbitron(
                fontSize: 16,
                color: Colors.white.withValues(alpha:0.8),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4ECDC4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _restartGame,
              child: Text(
                'Play Again',
                style: GoogleFonts.orbitron(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}