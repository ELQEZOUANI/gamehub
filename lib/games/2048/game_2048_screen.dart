// lib/games/2048/game_2048_screen.dart
import 'dart:math';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'widgets/tile_widget.dart';
import '../../services/stats_service.dart';
import '../../app_shell.dart';

class Game2048Screen extends StatefulWidget {
  final int gridSize;
  const Game2048Screen({super.key, this.gridSize = 4});
  @override
  State<Game2048Screen> createState() => _Game2048ScreenState();
}

class _Game2048ScreenState extends State<Game2048Screen> with TickerProviderStateMixin {
  late int _gridSize;
  late List<List<int>> _grid;
  final Random _random = Random();
  int _score = 0;
  int _bestScore = 0;
  bool _isGameWon = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Unified galaxy background animation
  late AnimationController _backgroundController;
  
  @override
  void initState() {
    super.initState();
    _gridSize = widget.gridSize;
    _grid = List.generate(_gridSize, (_) => List.generate(_gridSize, (_) => 0));
    
    // Initialize unified background animation
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();
    
    _loadGame();
  }
  
  @override
  void dispose() {
    _audioPlayer.dispose();
    _backgroundController.dispose();
    super.dispose();
  }
  
  Future<void> _saveGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('bestScore${_gridSize}x$_gridSize', _bestScore);
    String gameState = jsonEncode({'grid': _grid, 'score': _score});
    await prefs.setString('gameState${_gridSize}x$_gridSize', gameState);
  }

  Future<void> _loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    _bestScore = prefs.getInt('bestScore${_gridSize}x$_gridSize') ?? 0;
    String? gameStateString = prefs.getString('gameState${_gridSize}x$_gridSize');
    if (gameStateString != null) {
      try {
        var gameState = jsonDecode(gameStateString);
        _score = gameState['score'];
        _grid = (gameState['grid'] as List).map((row) => (row as List).map((item) => item as int).toList()).toList();
      } catch (e) {
        _startGameWithDefaultTiles();
      }
    } else {
      _startGameWithDefaultTiles();
    }
    setState(() {});
  }
  
  void _startGameWithDefaultTiles() {
    setState(() {
      _grid = List.generate(_gridSize, (_) => List.generate(_gridSize, (_) => 0));
      _score = 0;
      _isGameWon = false;
      
      // Add default tiles based on grid size
      if (_gridSize == 3) {
        // 3x3 - Add 3 tiles
        _grid[0][0] = 2;
        _grid[1][1] = 2;
        _grid[2][0] = 2;
      } else if (_gridSize == 4) {
        // 4x4 - Add 4 tiles  
        _grid[0][0] = 2;
        _grid[1][1] = 2;
        _grid[2][2] = 4;
        _grid[3][0] = 2;
      } else if (_gridSize == 5) {
        // 5x5 - Add 5 tiles
        _grid[0][0] = 2;
        _grid[1][1] = 4;
        _grid[2][2] = 2;
        _grid[3][1] = 2;
        _grid[4][3] = 4;
      }
      _saveGame();
    });
  }

  void _startGame({bool fromInit = false}) {
    if (!fromInit) {
      _startGameWithDefaultTiles();
    }
  }

  Future<void> _playSound(String soundFile) async {
    // This is a robust way to play sound
    try {
      await _audioPlayer.play(AssetSource('audio/$soundFile'));
      // Use debugPrint to see in the console if it's trying to play
      debugPrint("Playing sound: $soundFile");
    } catch (e) {
      debugPrint("Error playing sound '$soundFile': $e");
    }
  }
  
  void _addRandomTile() {
    List<Point<int>> emptyTiles = [];
    for (int i = 0; i < _gridSize; i++) {
      for (int j = 0; j < _gridSize; j++) {
        if (_grid[i][j] == 0) emptyTiles.add(Point(i, j));
      }
    }
    if (emptyTiles.isNotEmpty) {
      var pos = emptyTiles[_random.nextInt(emptyTiles.length)];
      _grid[pos.x][pos.y] = _random.nextInt(10) == 0 ? 4 : 2;
    }
  }
  
  void _handleSwipe(DragEndDetails details) {
    final Offset velocity = details.velocity.pixelsPerSecond;
    if (velocity.dx.abs() > velocity.dy.abs()) {
      if (velocity.dx > 0) {
        _moveRight();
      } else {
        _moveLeft();
      }
    } else {
      if (velocity.dy > 0) {
        _moveDown();
      } else {
        _moveUp();
      }
    }
  }

  List<int> _slideAndMergeRow(List<int> row) {
    List<int> newRow = row.where((val) => val != 0).toList();
    for (int i = 0; i < newRow.length - 1; i++) {
      if (newRow[i] == newRow[i + 1]) {
        newRow[i] *= 2;
        _playSound('merge.mp3');
        if (newRow[i] == 2048 && !_isGameWon) {
          _isGameWon = true;
          Future.delayed(const Duration(milliseconds: 500), () => _showGameEndDialog(title: 'You Win! 🎉', content: 'You have reached the 2048 tile!'));
        }
        _score += newRow[i];
        if (_score > _bestScore) {
          _bestScore = _score;
        }
        newRow.removeAt(i + 1);
      }
    }
    while (newRow.length < _gridSize) {
      newRow.add(0);
    }
    return newRow;
  }

  bool _isGameOver() {
    for (int i = 0; i < _gridSize; i++) {
      for (int j = 0; j < _gridSize; j++) {
        if (_grid[i][j] == 0) return false;
        if (j < _gridSize - 1 && _grid[i][j] == _grid[i][j + 1]) return false;
        if (i < _gridSize - 1 && _grid[i][j] == _grid[i + 1][j]) return false;
      }
    }
    return true;
  }

  void _checkGameOver() {
    if (_isGameOver()) {
      Future.delayed(const Duration(milliseconds: 500), () => _showGameEndDialog(title: 'Game Over!', content: 'No more possible moves.'));
    }
  }

  void _showGameEndDialog({required String title, required String content}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: title.contains("Win") 
                      ? const Color(0xFF4ECDC4).withValues(alpha: 0.3) 
                      : const Color(0xFFFF6B6B).withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.orbitron(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: title.contains("Win")
                            ? const Color(0xFF4ECDC4).withValues(alpha: 0.8)
                            : const Color(0xFFFF6B6B).withValues(alpha: 0.8),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  content,
                  style: GoogleFonts.orbitron(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.9),
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
                    _startGame();
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
  
  void _performMove(Function moveFn) async {
    if (_isGameWon) return;
    List<List<int>> originalGrid = _grid.map((row) => List<int>.from(row)).toList();
    moveFn();
    bool changed = false;
    for (int i = 0; i < _gridSize; i++) {
      if (originalGrid[i].join(',') != _grid[i].join(',')) {
        changed = true;
        break;
      }
    }
    if (changed) {
      _playSound('move.mp3');
      Vibration.vibrate(duration: 50, amplitude: 128);
      setState(() {
        _addRandomTile();
        _checkGameOver();
      });
      _saveGame();
      // Record game result in centralized stats
      await StatsService().recordGameResult(
        gameID: '${StatsService.game2048}_${_gridSize}x$_gridSize',
        score: _bestScore,
      );
    }
  }

  void _moveLeft() => _performMove(() { for (int i = 0; i < _gridSize; i++) {
    _grid[i] = _slideAndMergeRow(_grid[i]);
  } });
  void _moveRight() => _performMove(() { for (int i = 0; i < _gridSize; i++) {
    _grid[i] = _slideAndMergeRow(_grid[i].reversed.toList()).reversed.toList();
  } });
  void _moveUp() => _performMove(() { _grid = _transposeGrid(_grid); for (int i = 0; i < _gridSize; i++) {
    _grid[i] = _slideAndMergeRow(_grid[i]);
  } _grid = _transposeGrid(_grid); });
  void _moveDown() => _performMove(() { _grid = _transposeGrid(_grid); for (int i = 0; i < _gridSize; i++) {
    _grid[i] = _slideAndMergeRow(_grid[i].reversed.toList()).reversed.toList();
  } _grid = _transposeGrid(_grid); });

  List<List<int>> _transposeGrid(List<List<int>> grid) {
    List<List<int>> transposed = List.generate(_gridSize, (_) => List.generate(_gridSize, (_) => 0));
    for (int i = 0; i < _gridSize; i++) {
      for (int j = 0; j < _gridSize; j++) {
        transposed[j][i] = grid[i][j];
      }
    }
    return transposed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                        size: Size.infinite,
                      ),
                    ),
                    Positioned.fill(
                      child: CustomPaint(
                        painter: NebulaPainter(_backgroundController.value),
                        size: Size.infinite,
                      ),
                    ),
                    Positioned.fill(
                      child: CustomPaint(
                        painter: StarsPainter(_backgroundController.value),
                        size: Size.infinite,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          // Foreground content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '2048',
                      style: GoogleFonts.bebasNeue(
                          fontSize: 82,
                          color: Colors.white,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              color: const Color(0xFF667EEA).withValues(alpha: 0.8),
                              blurRadius: 10,
                            ),
                          ]),
                    ),
                    _buildScoreDisplay(),
                  ],
                ),
                const SizedBox(height: 30),
                // THIS IS THE FIX - WE PUT THE GESTUREDETECTOR BACK
                GestureDetector(
                  onVerticalDragEnd: _handleSwipe,
                  onHorizontalDragEnd: _handleSwipe,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _gridSize),
                      itemCount: _gridSize * _gridSize,
                      itemBuilder: (context, index) {
                        int row = index ~/ _gridSize;
                        int col = index % _gridSize;
                        int number = _grid.isNotEmpty ? _grid[row][col] : 0;
                        return TileWidget(number: number);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Cosmic New Game Button - Above tab view
                Container(
                  margin: const EdgeInsets.only(bottom: 100), // Space above tab view
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => _startGame(),
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: Text(
                      'New Game',
                      style: GoogleFonts.orbitron(
                        fontSize: 16, 
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: const Color(0xFF667EEA).withValues(alpha: 0.8),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            Text("SCORE", style: GoogleFonts.bebasNeue(fontSize: 20, color: Colors.white.withValues(alpha: 0.8))),
            const SizedBox(width: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: Text(
                _score.toString(),
                key: ValueKey<int>(_score),
                style: GoogleFonts.bebasNeue(
                  fontSize: 28, 
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: const Color(0xFF667EEA).withValues(alpha: 0.8),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Text("BEST", style: GoogleFonts.bebasNeue(fontSize: 20, color: Colors.white.withValues(alpha: 0.8))),
            const SizedBox(width: 8),
            Text(
              _bestScore.toString(),
              style: GoogleFonts.bebasNeue(
                fontSize: 28, 
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: const Color(0xFF667EEA).withValues(alpha: 0.8),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}