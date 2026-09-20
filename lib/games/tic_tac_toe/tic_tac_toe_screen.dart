// lib/games/tic_tac_toe/tic_tac_toe_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'logic/models.dart';
import '../../services/stats_service.dart';
import '../../app_shell.dart';
import 'dart:async'; // Added for Timer

class TicTacToeScreen extends StatefulWidget {
  final GameMode mode;
  final BotDifficulty? difficulty;

  const TicTacToeScreen({
    super.key,
    required this.mode,
    this.difficulty,
  });

  @override
  State<TicTacToeScreen> createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> with TickerProviderStateMixin {
  late List<String> _board;
  late bool _isPlayerXTurn;
  String _winnerText = '';
  bool _gameInProgress = true;
  bool _isBotThinking = false; // To show bot thinking indicator
  Timer? _botMoveTimer; // To cancel bot move if game restarts
  final Random _random = Random();
  final AudioPlayer _audioPlayer = AudioPlayer();

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
    
    _startNewGame();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _galaxyController.dispose();
    _starsController.dispose();
    _nebulaController.dispose();
    _botMoveTimer?.cancel(); // Important: cancel timer on dispose
    super.dispose();
  }

  void _startNewGame() {
    setState(() {
      _board = List.filled(9, '');
      _isPlayerXTurn = true;
      _winnerText = '';
      _gameInProgress = true;
      _isBotThinking = false; // Reset thinking indicator
      _botMoveTimer?.cancel(); // Cancel any pending bot move
    });
  }

  Future<void> _playSound(String soundFile) async {
    try {
      await _audioPlayer.play(AssetSource('audio/$soundFile'));
    } catch (e) {
      debugPrint("Error playing sound '$soundFile': $e");
    }
  }

  void _handleTap(int index) async {
    if (!_gameInProgress || _board[index].isNotEmpty || _winnerText.isNotEmpty || _isBotThinking ||
        (widget.mode == GameMode.playerVsBot && !_isPlayerXTurn)) {
      return;
    }
    
    // Play sound on every valid tap
    _playSound('tictactoe_click.mp3');

    setState(() {
      _board[index] = _isPlayerXTurn ? 'X' : 'O';
      _isPlayerXTurn = !_isPlayerXTurn;
    });

    // Check for winner after player move
    bool gameEnded = await _checkWinner();
    
    // Only trigger bot move if game hasn't ended and it's bot mode
    if (!gameEnded && _gameInProgress && widget.mode == GameMode.playerVsBot && 
        !_isPlayerXTurn && _winnerText.isEmpty) {
      setState(() {
        _isBotThinking = true;
      });
      // Play sound on bot move as well
      _playSound('tictactoe_click.mp3');
      _botMoveTimer = Timer(const Duration(milliseconds: 600), _botMove);
    }
  }

  void _botMove() async {
    if (!_gameInProgress || _winnerText.isNotEmpty || !mounted) {
      setState(() {
        _isBotThinking = false;
      });
      return;
    }

    int? move;

    if (widget.difficulty == BotDifficulty.hard) {
      move = _findBestMoveHard();
    } 
    else if (widget.difficulty == BotDifficulty.medium) {
      move = _findBestMoveMedium();
    }
    
    move ??= _findRandomMove();
    
    if (move != null && move >= 0 && move < 9 && _board[move].isEmpty && 
        _winnerText.isEmpty && _gameInProgress) {
      final int botMove = move; // Safe cast since we checked move != null
      setState(() {
        _board[botMove] = 'O';
        _isPlayerXTurn = true; // Switch back to player
        _isBotThinking = false;
      });
      
      await _checkWinner();
    }
  }

  int? _findBestMoveMedium() {
    for (int i = 0; i < 9; i++) {
      if (_board[i].isEmpty) {
        _board[i] = 'O';
        if (_evaluateBoard() == 10) {
          _board[i] = '';
          return i;
        }
        _board[i] = '';
      }
    }

    for (int i = 0; i < 9; i++) {
      if (_board[i].isEmpty) {
        _board[i] = 'X';
        if (_evaluateBoard() == -10) {
          _board[i] = '';
          return i;
        }
        _board[i] = '';
      }
    }
    return null;
  }

  int? _findRandomMove() {
    List<int> emptySpots = [];
    for (int i = 0; i < _board.length; i++) {
      if (_board[i].isEmpty) {
        emptySpots.add(i);
      }
    }
    if (emptySpots.isNotEmpty) {
      return emptySpots[_random.nextInt(emptySpots.length)];
    }
    return null;
  }
  
  int? _findBestMoveHard() {
    int bestVal = -1000;
    int bestMove = -1;

    for (int i = 0; i < 9; i++) {
      if (_board[i].isEmpty) {
        _board[i] = 'O';
        int moveVal = _minimax(0, false);
        _board[i] = '';

        if (moveVal > bestVal) {
          bestMove = i;
          bestVal = moveVal;
        }
      }
    }
    return bestMove == -1 ? null : bestMove;
  }

  int _minimax(int depth, bool isMaximizing) {
    int score = _evaluateBoard();

    if (score == 10) return score - depth;
    if (score == -10) return score + depth;
    if (!_board.contains('')) return 0;

    if (isMaximizing) {
      int best = -1000;
      for (int i = 0; i < 9; i++) {
        if (_board[i].isEmpty) {
          _board[i] = 'O';
          best = max(best, _minimax(depth + 1, !isMaximizing));
          _board[i] = '';
        }
      }
      return best;
    } else {
      int best = 1000;
      for (int i = 0; i < 9; i++) {
        if (_board[i].isEmpty) {
          _board[i] = 'X';
          best = min(best, _minimax(depth + 1, !isMaximizing));
          _board[i] = '';
        }
      }
      return best;
    }
  }

  int _evaluateBoard() {
    const List<List<int>> lines = [ [0, 1, 2], [3, 4, 5], [6, 7, 8], [0, 3, 6], [1, 4, 7], [2, 5, 8], [0, 4, 8], [2, 4, 6] ];
    for (var line in lines) {
      String first = _board[line[0]];
      if (first.isNotEmpty && first == _board[line[1]] && first == _board[line[2]]) {
        if (first == 'O') return 10;
        if (first == 'X') return -10;
      }
    }
    return 0;
  }

  Future<bool> _checkWinner() async {
    if (_winnerText.isNotEmpty || !_gameInProgress) return true; // Already has a winner
    
    int score = _evaluateBoard();
    if (score == 10) {
      setState(() { 
        _winnerText = widget.mode == GameMode.playerVsBot ? 'Bot Wins! 🤖' : 'Player O Wins! 🎉';
        _gameInProgress = false;
      });
      // Record game result in centralized stats (O wins)
      await StatsService().recordGameResult(
        gameID: StatsService.gameTicTacToe,
        score: 1, // Win = 1 point
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _showEndDialog(_winnerText);
      });
      return true;
    } else if (score == -10) {
      setState(() { 
        _winnerText = widget.mode == GameMode.playerVsBot ? 'You Win! 🎉' : 'Player X Wins! 🎉';
        _gameInProgress = false;
      });
      // Record game result in centralized stats (X wins)
      await StatsService().recordGameResult(
        gameID: StatsService.gameTicTacToe,
        score: 1, // Win = 1 point
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _showEndDialog(_winnerText);
      });
      return true;
    } else if (!_board.contains('')) {
      setState(() { 
        _winnerText = 'It\'s a Draw! 🤝';
        _gameInProgress = false;
      });
      // Record game result in centralized stats (Draw)
      await StatsService().recordGameResult(
        gameID: StatsService.gameTicTacToe,
        score: 0, // Draw = 0 points
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _showEndDialog(_winnerText);
      });
      return true;
    }
    return false;
  }

  void _showEndDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
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
                  'Game Over',
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
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: GoogleFonts.orbitron(
                    fontSize: 18,
                    color: Colors.white.withValues(alpha:0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4ECDC4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _startNewGame();
                  },
                  child: Text(
                    'Play Again',
                    style: GoogleFonts.orbitron(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    String appBarTitle;
    if (widget.mode == GameMode.playerVsPlayer) {
      appBarTitle = 'Player vs Player';
    } else {
      appBarTitle = 'Player vs Bot (${widget.difficulty.toString().split('.').last})';
    }
    
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
                  appBarTitle,
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
                      children: [
                        Text(
                          _getTurnText(),
                          style: GoogleFonts.poppins(
                            fontSize: 28,
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
                        const SizedBox(height: 20),
                        Flexible(
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 1.0, // Ensure square cells
                            ),
                            itemCount: 9,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () => _handleTap(index),
                                child: Container(
                                  margin: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha:0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha:0.3),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF667EEA).withValues(alpha:0.2),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      _board[index],
                                      style: GoogleFonts.orbitron(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        color: _board[index] == 'X' 
                                            ? const Color(0xFF4ECDC4)
                                            : const Color(0xFFFF6B6B),
                                        shadows: [
                                          Shadow(
                                            color: _board[index] == 'X' 
                                                ? const Color(0xFF4ECDC4).withValues(alpha:0.8)
                                                : const Color(0xFFFF6B6B).withValues(alpha:0.8),
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 40),
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withValues(alpha:0.15),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(color: Colors.white.withValues(alpha:0.3)),
                              ),
                              shadowColor: const Color(0xFF667EEA).withValues(alpha:0.3),
                              elevation: 8,
                            ),
                            onPressed: _startNewGame,
                            icon: const Icon(Icons.refresh, color: Colors.white),
                            label: Text(
                              'New Game',
                              style: GoogleFonts.orbitron(
                                fontWeight: FontWeight.bold,
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
                        )
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

  String _getTurnText() {
    if (_winnerText.isNotEmpty) return _winnerText;
    if (_isBotThinking) return 'Bot is thinking... 🤖';
    if (widget.mode == GameMode.playerVsBot) {
      return _isPlayerXTurn ? 'Your Turn (X)' : 'Bot\'s Turn (O)';
    }
    return 'Player ${_isPlayerXTurn ? 'X' : 'O'}\'s Turn';
  }
}