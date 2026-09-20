import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/drawing_canvas.dart';
import 'word_list.dart';

class Player {
  final String name;
  int score = 0;
  Player(this.name);
}

class DrawingScreen extends StatefulWidget {
  final List<String> players;
  final int totalRounds;

  const DrawingScreen({
    super.key,
    required this.players,
    required this.totalRounds,
  });

  @override
  State<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  late List<Player> _gamePlayers;
  int _currentRound = 1;
  int _currentPlayerIndex = 0;
  
  // Drawing state
  List<DrawingPoint?> _points = [];
  Color _selectedColor = Colors.black;
  double _strokeWidth = 5.0;
  
  // Word logic
  String _wordToGuess = "";
  final Random _random = Random();
  Timer? _roundTimer;
  int _timeLeft = 60;

  @override
  void initState() {
    super.initState();
    _gamePlayers = widget.players.map((name) => Player(name)).toList();
    _startRound();
  }
  
  @override
  void dispose() {
    _roundTimer?.cancel();
    super.dispose();
  }

  void _startRound() {
    _timeLeft = 60;
    _points.clear();
    
    // Pick a new word
    final easyWords = WordList.words['Easy']!;
    _wordToGuess = easyWords[_random.nextInt(easyWords.length)];
    
    _roundTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _endRound();
      }
    });
    setState(() {});
  }

  void _endRound() {
    _roundTimer?.cancel();
    
    // Move to next player
    if (_currentPlayerIndex < _gamePlayers.length - 1) {
      _currentPlayerIndex++;
    } else {
      // End of round, move to next round or end game
      if (_currentRound < widget.totalRounds) {
        _currentRound++;
        _currentPlayerIndex = 0;
      } else {
        _endGame();
        return;
      }
    }
    _startRound();
  }
  
  void _endGame() {
    // TODO: Show final scores
    Navigator.of(context).pop();
  }
  
  void _handleGuess(String guess) {
    final guesser = _gamePlayers.firstWhere((p) => p.name != _gamePlayers[_currentPlayerIndex].name); // Simplified for 2 players
    
    if (guess.toLowerCase() == _wordToGuess.toLowerCase()) {
      setState(() {
        // Award points
        guesser.score += 10;
        _gamePlayers[_currentPlayerIndex].score += 5; // Drawer gets points
      });
      _endRound();
    }
  }

  @override
  Widget build(BuildContext context) {
    final drawer = _gamePlayers[_currentPlayerIndex];
    
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      appBar: AppBar(
        title: Text('Round $_currentRound / ${widget.totalRounds} - Time: $_timeLeft'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Info bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${drawer.name} is drawing: $_wordToGuess',
              style: GoogleFonts.orbitron(color: Colors.white, fontSize: 18),
            ),
          ),
          
          // Drawing canvas placeholder
          Expanded(
            flex: 3,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _points.add(DrawingPoint(
                    offset: details.localPosition,
                    paint: Paint()
                      ..color = _selectedColor
                      ..strokeWidth = _strokeWidth
                      ..strokeCap = StrokeCap.round,
                  ));
                });
              },
              onPanEnd: (details) {
                setState(() {
                  _points.add(null); // Indicates a break in the line
                });
              },
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: DrawingCanvas(points: _points),
              ),
            ),
          ),
          
          // Tools and guess area
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  _buildDrawingTools(),
                  const SizedBox(height: 16),
                  
                  // Guessing Field
                  TextField(
                    onSubmitted: _handleGuess,
                    decoration: InputDecoration(
                      hintText: 'Type your guess here...',
                      filled: true,
                      fillColor: Colors.white.withValues(alpha:0.9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  
                  // Scoreboard
                  _buildScoreboard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawingTools() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Color Palette
        ...[Colors.black, Colors.red, Colors.green, Colors.blue, Colors.yellow].map((color) => 
          _buildColorButton(color)
        ),
        // Eraser
        _buildEraserButton(),
        // Clear Button
        _buildClearButton(),
      ],
    );
  }

  Widget _buildColorButton(Color color) {
    bool isSelected = _selectedColor == color;
    return GestureDetector(
      onTap: () => setState(() => _selectedColor = color),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.3), blurRadius: 4)],
        ),
      ),
    );
  }
  
  Widget _buildEraserButton() {
    bool isSelected = _selectedColor == Colors.white;
    return GestureDetector(
      onTap: () => setState(() => _selectedColor = Colors.white),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.blueAccent, width: 3) : null,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.3), blurRadius: 4)],
        ),
        child: const Icon(Icons.cleaning_services_rounded, color: Colors.black, size: 20),
      ),
    );
  }

  Widget _buildClearButton() {
    return IconButton(
      icon: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent, size: 30),
      onPressed: () => setState(() => _points.clear()),
    );
  }

  Widget _buildScoreboard() {
    return Expanded(
      child: ListView.builder(
        itemCount: _gamePlayers.length,
        itemBuilder: (context, index) {
          final player = _gamePlayers[index];
          return ListTile(
            leading: Icon(
              index == _currentPlayerIndex ? Icons.edit : Icons.question_answer,
              color: Colors.white,
            ),
            title: Text(player.name, style: GoogleFonts.poppins(color: Colors.white)),
            trailing: Text(player.score.toString(), style: GoogleFonts.orbitron(color: Colors.white, fontSize: 18)),
          );
        },
      ),
    );
  }
}
