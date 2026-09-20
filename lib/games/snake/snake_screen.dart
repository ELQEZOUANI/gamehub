import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../services/stats_service.dart';

enum Direction { up, down, left, right }

class SnakeScreen extends StatefulWidget {
  const SnakeScreen({super.key});

  @override
  State<SnakeScreen> createState() => _SnakeScreenState();
}

class _SnakeScreenState extends State<SnakeScreen>
    with TickerProviderStateMixin {
  static const int gridSize = 20;
  List<Point<int>> snake = [const Point(10, 10)];
  Point<int> food = const Point(15, 15);
  Direction direction = Direction.right;
  bool isGameRunning = false;
  bool isGameOver = false;
  int score = 0;
  int bestScore = 0;
  Timer? gameTimer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  late AnimationController _scoreController;
  late Animation<double> _scoreAnimation;
  late AnimationController _foodController;
  late Animation<double> _foodAnimation;

  @override
  void initState() {
    super.initState();
    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _foodController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
    
    _scoreAnimation = CurvedAnimation(
      parent: _scoreController,
      curve: Curves.elasticOut,
    );
    _foodAnimation = CurvedAnimation(
      parent: _foodController,
      curve: Curves.easeInOut,
    );
    
    _loadBestScore();
    _generateFood();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    _audioPlayer.dispose();
    _scoreController.dispose();
    _foodController.dispose();
    super.dispose();
  }

  Future<void> _loadBestScore() async {
    final statsService = StatsService();
    await statsService.initialize();
    bestScore = statsService.getBestScore(gameID: 'snake_game');
    setState(() {});
  }

  Future<void> _saveBestScore() async {
    await StatsService().recordGameResult(
      gameID: 'snake_game',
      score: score,
    );
    if (score > bestScore) {
      bestScore = score;
    }
  }

  Future<void> _playSound(String soundFile) async {
    try {
      await _audioPlayer.play(AssetSource('audio/$soundFile'));
    } catch (e) {
      debugPrint("Error playing sound '$soundFile': $e");
    }
  }

  void _generateFood() {
    final random = Random();
    Point<int> newFood;
    do {
      newFood = Point(random.nextInt(gridSize), random.nextInt(gridSize));
    } while (snake.contains(newFood));
    food = newFood;
  }

  void _startGame() {
    setState(() {
      snake = [const Point(10, 10)];
      direction = Direction.right;
      isGameRunning = true;
      isGameOver = false;
      score = 0;
    });
    _generateFood();
    
    gameTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      _moveSnake();
    });
  }

  void _pauseGame() {
    setState(() {
      isGameRunning = !isGameRunning;
    });
    
    if (isGameRunning) {
      gameTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
        _moveSnake();
      });
    } else {
      gameTimer?.cancel();
    }
  }

  void _moveSnake() {
    if (!isGameRunning || isGameOver) return;

    setState(() {
      Point<int> head = snake.first;
      Point<int> newHead;

      switch (direction) {
        case Direction.up:
          newHead = Point(head.x, head.y - 1);
          break;
        case Direction.down:
          newHead = Point(head.x, head.y + 1);
          break;
        case Direction.left:
          newHead = Point(head.x - 1, head.y);
          break;
        case Direction.right:
          newHead = Point(head.x + 1, head.y);
          break;
      }

      // Check wall collision
      if (newHead.x < 0 || newHead.x >= gridSize || 
          newHead.y < 0 || newHead.y >= gridSize) {
        _gameOver();
        return;
      }

      // Check self collision
      if (snake.contains(newHead)) {
        _gameOver();
        return;
      }

      snake.insert(0, newHead);

      // Check food collision
      if (newHead == food) {
        score += 10;
        _scoreController.forward().then((_) => _scoreController.reset());
        _playSound('merge.mp3');
        _generateFood();
      } else {
        snake.removeLast();
      }
    });
  }

  void _gameOver() {
    setState(() {
      isGameRunning = false;
      isGameOver = true;
    });
    gameTimer?.cancel();
    _saveBestScore();
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF2D3436),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Game Over! 🐍',
              style: GoogleFonts.fredoka(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Score: $score',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (score == bestScore)
                  Text(
                    '🎉 New Best Score!',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFFFE66D),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _startGame();
                },
                child: Text(
                  'Play Again',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF4ECDC4),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    });
  }

  void _changeDirection(Direction newDirection) {
    // Prevent reverse direction
    if ((direction == Direction.up && newDirection == Direction.down) ||
        (direction == Direction.down && newDirection == Direction.up) ||
        (direction == Direction.left && newDirection == Direction.right) ||
        (direction == Direction.right && newDirection == Direction.left)) {
      return;
    }
    direction = newDirection;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF4ECDC4),
              const Color(0xFF44A08D),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Spacer(),
                    Column(
                      children: [
                        Text(
                          'Snake',
                          style: GoogleFonts.fredoka(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Row(
                          children: [
                            ScaleTransition(
                              scale: _scoreAnimation,
                              child: Text(
                                'Score: $score',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Text(
                              'Best: $bestScore',
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: isGameOver ? null : _pauseGame,
                      icon: Icon(
                        isGameRunning ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Game Grid
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridSize,
                    ),
                    itemCount: gridSize * gridSize,
                    itemBuilder: (context, index) {
                      final x = index % gridSize;
                      final y = index ~/ gridSize;
                      final point = Point(x, y);

                      Widget child = Container();

                      if (snake.contains(point)) {
                        final isHead = snake.first == point;
                        child = Container(
                          margin: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: isHead ? Colors.white : Colors.white.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(isHead ? 6 : 4),
                            boxShadow: isHead ? [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.5),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ] : null,
                          ),
                        );
                      } else if (point == food) {
                        child = ScaleTransition(
                          scale: _foodAnimation,
                          child: Container(
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B6B),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF6B6B).withValues(alpha: 0.5),
                                  blurRadius: 6,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return child;
                    },
                  ),
                ),
              ),

              // Controls
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    if (!isGameRunning && !isGameOver)
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFFFE66D),
                              const Color(0xFFFFA502),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFE66D).withValues(alpha: 0.3),
                              blurRadius: 15,
                              spreadRadius: 2,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _startGame,
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.play_arrow, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Start Game',
                                    style: GoogleFonts.fredoka(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 20),
                    
                    // Direction Controls
                    Column(
                      children: [
                        _DirectionButton(
                          icon: Icons.keyboard_arrow_up,
                          onPressed: () => _changeDirection(Direction.up),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _DirectionButton(
                              icon: Icons.keyboard_arrow_left,
                              onPressed: () => _changeDirection(Direction.left),
                            ),
                            const SizedBox(width: 60),
                            _DirectionButton(
                              icon: Icons.keyboard_arrow_right,
                              onPressed: () => _changeDirection(Direction.right),
                            ),
                          ],
                        ),
                        _DirectionButton(
                          icon: Icons.keyboard_arrow_down,
                          onPressed: () => _changeDirection(Direction.down),
                        ),
                      ],
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

class _DirectionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _DirectionButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
