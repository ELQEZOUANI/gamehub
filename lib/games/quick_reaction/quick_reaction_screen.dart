import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app_shell.dart'; // For galaxy background
import '../../utils/mission_tracker.dart';

// --- Enums and Models ---

enum CueType { color, word, shape }
enum ShapeType { circle, square, triangle }

class Cue {
  final CueType type;
  final String text;
  final Color color;
  final ShapeType? shape;

  Cue({required this.type, required this.text, required this.color, this.shape});
}

class QuickReactionScreen extends StatefulWidget {
  const QuickReactionScreen({super.key});

  @override
  State<QuickReactionScreen> createState() => _QuickReactionScreenState();
}

class _QuickReactionScreenState extends State<QuickReactionScreen> with TickerProviderStateMixin {
  // Game State
  bool _isPlaying = false;
  int _score = 0;
  int _highScore = 0;
  int _level = 1;
  Cue? _currentCue;
  
  // Timer
  Timer? _reactionTimer;
  late AnimationController _timerController;

  // Game Logic
  final Random _random = Random();
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Unified background animation
  late AnimationController _backgroundController;

  // Cue options
  static const Map<String, Color> colorOptions = {
    'RED': Colors.red,
    'BLUE': Colors.blue,
    'GREEN': Colors.green,
    'YELLOW': Colors.yellow,
  };

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();

    _timerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    
    _loadHighScore();
  }

  @override
  void dispose() {
    _reactionTimer?.cancel();
    _timerController.dispose();
    _backgroundController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highScore = prefs.getInt('quick_reaction_highscore') ?? 0;
    });
  }

  Future<void> _saveHighScore() async {
    if (_score > _highScore) {
      _highScore = _score;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('quick_reaction_highscore', _highScore);
    }
  }

  void _startGame() {
    setState(() {
      _score = 0;
      _level = 1;
      _isPlaying = true;
    });
    _nextCue();
  }

  void _nextCue() {
    // Generate new cue
    _currentCue = _generateCue();

    // Reset and start timer
    double durationSeconds = max(0.8, 2.0 - (_level * 0.1));
    _timerController.duration = Duration(milliseconds: (durationSeconds * 1000).toInt());
    _timerController.reset();
    _timerController.forward();
    
    _reactionTimer?.cancel();
    _reactionTimer = Timer(_timerController.duration!, () {
      // Time's up
      _gameOver("Time's up!");
    });
    
    setState(() {});
  }

  Cue _generateCue() {
    // Simple logic for now, gets complex with levels
    final cueTypes = [CueType.color, CueType.word];
    if (_level >= 3) {
      cueTypes.add(CueType.shape);
    }
    
    final type = cueTypes[_random.nextInt(cueTypes.length)];
    final colorNames = colorOptions.keys.toList();
    final String correctText = colorNames[_random.nextInt(colorNames.length)];
    final Color correctColor = colorOptions[correctText]!;

    switch (type) {
      case CueType.word:
        // Stroop effect: text might not match color
        final String displayedText = colorNames[_random.nextInt(colorNames.length)];
        return Cue(type: type, text: displayedText, color: correctColor);
      case CueType.shape:
        final shape = ShapeType.values[_random.nextInt(ShapeType.values.length)];
        return Cue(type: type, text: correctText, color: correctColor, shape: shape);
      case CueType.color:
        return Cue(type: type, text: correctText, color: correctColor);
    }
  }

  void _handleReaction(String colorName) {
    if (!_isPlaying) return;

    _reactionTimer?.cancel();
    bool isCorrect = false;

    // Check correctness based on cue type
    switch (_currentCue!.type) {
      case CueType.word:
        isCorrect = (_currentCue!.text == colorName);
        break;
      case CueType.color:
      case CueType.shape:
        isCorrect = (colorOptions[colorName] == _currentCue!.color);
        break;
    }
    
    if (isCorrect) {
      _playSound('merge.mp3');
      // Add points + speed bonus
      double timeBonus = _timerController.value; // value is 0.0 to 1.0 (remaining time)
      setState(() {
        _score += 10 + (timeBonus * 5).toInt();
        _level++;
      });
      _nextCue();
    } else {
      _gameOver('Wrong!');
    }
  }
  
  void _gameOver(String reason) async {
    _playSound('tictactoe_click.mp3'); // A simple fail sound
    _reactionTimer?.cancel();
    _saveHighScore();
    
    // Track mission progress
    try {
      await MissionTracker.trackGameCompletion(
        gameTitle: 'Quick Reaction',
        finalScore: _score,
      );
    } catch (e) {
      // Silently handle mission tracking errors
      debugPrint('Mission tracking error: $e');
    }
    
    setState(() {
      _isPlaying = false;
    });

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _buildGameOverDialog(reason),
      );
    }
  }
  
  Future<void> _playSound(String soundFile) async {
    try {
      await _audioPlayer.play(AssetSource('audio/$soundFile'));
    } catch (e) {
      debugPrint("Error playing sound: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Quick Reaction',
          style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Galaxy Background
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _backgroundController,
              builder: (context, child) {
                return Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: GalaxyPainter(_backgroundController.value),
                      ),
                    ),
                    Positioned.fill(
                      child: CustomPaint(
                        painter: NebulaPainter(_backgroundController.value),
                      ),
                    ),
                    Positioned.fill(
                      child: CustomPaint(
                        painter: StarsPainter(_backgroundController.value),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          
          // Game UI
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Score and Timer
                _buildStatsBar(),
                if (_isPlaying)
                  AnimatedBuilder(
                    animation: _timerController,
                    builder: (context, child) {
                      return LinearProgressIndicator(
                        value: 1.0 - _timerController.value,
                        backgroundColor: Colors.white.withValues(alpha:0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.redAccent),
                      );
                    },
                  ),

                // Cue Display
                Expanded(
                  flex: 3,
                  child: _buildCueArea(),
                ),

                // Reaction Buttons
                Expanded(
                  flex: 2,
                  child: _buildButtonGrid(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat('Score', _score.toString()),
          _buildStat('High Score', _highScore.toString()),
          _buildStat('Level', _level.toString()),
        ],
      ),
    );
  }
  
  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(label.toUpperCase(), style: GoogleFonts.orbitron(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.orbitron(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildCueArea() {
    if (!_isPlaying) {
      return Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4ECDC4),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            textStyle: GoogleFonts.orbitron(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          onPressed: _startGame,
          child: const Text('Start Game'),
        ),
      );
    }

    if (_currentCue == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      alignment: Alignment.center,
      child: _buildCueWidget(_currentCue!),
    );
  }
  
  Widget _buildCueWidget(Cue cue) {
    switch(cue.type) {
      case CueType.word:
        return Text(
          cue.text,
          style: GoogleFonts.orbitron(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            color: cue.color,
            shadows: [Shadow(color: cue.color.withValues(alpha:0.7), blurRadius: 15)]
          ),
        );
      case CueType.shape:
        return CustomPaint(
          size: const Size(120, 120),
          painter: ShapePainter(shape: cue.shape!, color: cue.color),
        );
      case CueType.color:
        return Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: cue.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: cue.color.withValues(alpha:0.8), blurRadius: 25, spreadRadius: 5)
            ]
          ),
        );
    }
  }

  Widget _buildButtonGrid() {
    if (!_isPlaying) return const SizedBox.shrink();
    
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 2.5,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      physics: const NeverScrollableScrollPhysics(),
      children: colorOptions.entries.map((entry) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: entry.value,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () => _handleReaction(entry.key),
          child: Text(
            entry.key,
            style: GoogleFonts.orbitron(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildGameOverDialog(String reason) {
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
            Text('Game Over', style: GoogleFonts.orbitron(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Text(reason, style: GoogleFonts.orbitron(fontSize: 18, color: Colors.white70)),
            const SizedBox(height: 16),
            Text('Score: $_score', style: GoogleFonts.orbitron(fontSize: 22, color: Colors.white)),
            Text('High Score: $_highScore', style: GoogleFonts.orbitron(fontSize: 16, color: Colors.white70)),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4ECDC4),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                if (mounted) {
                  Navigator.of(context).pop();
                  _startGame();
                }
              },
              child: Text('Play Again', style: GoogleFonts.orbitron(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for shapes
class ShapePainter extends CustomPainter {
  final ShapeType shape;
  final Color color;
  ShapePainter({required this.shape, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
      
    final shadowPaint = Paint()
      ..color = color.withValues(alpha:0.8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
      
    final path = Path();
    switch(shape) {
      case ShapeType.circle:
        path.addOval(Rect.fromLTWH(0, 0, size.width, size.height));
        break;
      case ShapeType.square:
        path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
        break;
      case ShapeType.triangle:
        path.moveTo(size.width / 2, 0);
        path.lineTo(size.width, size.height);
        path.lineTo(0, size.height);
        path.close();
        break;
    }
    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
