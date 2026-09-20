import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'sudoku_level_selection.dart';
import '../../app_shell.dart'; // Reuse Galaxy/Nebula/Stars painters
import '../../services/sudoku_progress_service.dart';

class SudokuScreen extends StatefulWidget {
  final int level;
  final SudokuDifficulty difficulty;

  const SudokuScreen({
    super.key,
    required this.level,
    required this.difficulty,
  });

  // Fallback constructor for backward compatibility
  const SudokuScreen.defaultLevel({
    super.key,
  }) : level = 1, difficulty = SudokuDifficulty.easy;

  @override
  State<SudokuScreen> createState() => _SudokuScreenState();
}

class _SudokuScreenState extends State<SudokuScreen>
    with TickerProviderStateMixin {
  // Game state variables
  List<List<int>> grid = [];
  List<List<int>> solution = [];
  List<List<bool>> isFixed = [];
  List<List<bool>> isError = [];
  
  int? selectedRow;
  int? selectedCol;
  int mistakes = 0;
  int maxMistakes = 3;
  int hintsUsed = 0;
  int maxHints = 3;

  // Animation controllers
  late AnimationController _winController;
  late AnimationController _errorController;
  late Animation<double> _winAnimation;
  late Animation<double> _errorAnimation;
  // Background animation
  late AnimationController _bgController;
  late Animation<double> _bgAnimation;

  // Audio player
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _winController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _errorController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Initialize animations
    _winAnimation = CurvedAnimation(
      parent: _winController,
      curve: Curves.elasticOut,
    );
    _errorAnimation = CurvedAnimation(
      parent: _errorController,
      curve: Curves.easeInOut,
    );

    // Ensure grid is visible immediately; play win animation from 0 when needed
    _winController.value = 1.0;

    // Background animation
    _bgController = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    )..repeat();
    _bgAnimation = CurvedAnimation(parent: _bgController, curve: Curves.linear);

    // Generate initial puzzle
    _generatePuzzle();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _winController.dispose();
    _errorController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  Future<void> _playSound(String soundFile) async {
    try {
      await _audioPlayer.play(AssetSource('audio/$soundFile'));
    } catch (e) {
      debugPrint("Error playing sound '$soundFile': $e");
    }
  }

  // Get number of cells to remove based on difficulty and level
  int _getCellsToRemove() {
    int baseCells;
    switch (widget.difficulty) {
      case SudokuDifficulty.easy:
        baseCells = 35 + (widget.level ~/ 3); // 35-38 cells removed
        break;
      case SudokuDifficulty.medium:
        baseCells = 40 + (widget.level ~/ 2); // 40-52 cells removed
        break;
      case SudokuDifficulty.hard:
        baseCells = 50 + widget.level; // 50-90 cells removed
        break;
      case SudokuDifficulty.expert:
        baseCells = 55 + (widget.level * 2); // 55-155 cells removed
        break;
    }
    return baseCells.clamp(30, 65); // Ensure reasonable bounds
  }

  void _generatePuzzle() {
    // Initialize grids
    grid = List.generate(9, (_) => List.filled(9, 0));
    solution = List.generate(9, (_) => List.filled(9, 0));
    isFixed = List.generate(9, (_) => List.filled(9, false));
    isError = List.generate(9, (_) => List.filled(9, false));
    
    // Use a predefined valid Sudoku puzzle for testing
    _generateSimplePuzzle();
    
    // Debug: Print first row to verify generation
    debugPrint('Generated Sudoku - First row: ${grid[0]}');
    debugPrint('Fixed cells count: ${isFixed.expand((row) => row).where((cell) => cell).length}');
    
    // Reset game state
    mistakes = 0;
    hintsUsed = 0;
    maxHints = widget.difficulty == SudokuDifficulty.expert ? 1 : 3;
    
    setState(() {});
  }

  void _generateSimplePuzzle() {
    // A valid complete Sudoku solution
    List<List<int>> completeSolution = [
      [5, 3, 4, 6, 7, 8, 9, 1, 2],
      [6, 7, 2, 1, 9, 5, 3, 4, 8],
      [1, 9, 8, 3, 4, 2, 5, 6, 7],
      [8, 5, 9, 7, 6, 1, 4, 2, 3],
      [4, 2, 6, 8, 5, 3, 7, 9, 1],
      [7, 1, 3, 9, 2, 4, 8, 5, 6],
      [9, 6, 1, 5, 3, 7, 2, 8, 4],
      [2, 8, 7, 4, 1, 9, 6, 3, 5],
      [3, 4, 5, 2, 8, 6, 1, 7, 9]
    ];

    // Copy to solution grid
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        solution[i][j] = completeSolution[i][j];
        grid[i][j] = completeSolution[i][j];
      }
    }

    // Remove cells based on difficulty
    final random = Random(widget.level * 42);
    int cellsToRemove = _getCellsToRemove();
    
    List<Point<int>> cells = [];
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        cells.add(Point(i, j));
      }
    }
    cells.shuffle(random);
    
    for (int i = 0; i < cellsToRemove && i < cells.length; i++) {
      final cell = cells[i];
      grid[cell.x][cell.y] = 0;
    }

    // Mark remaining cells as fixed
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        isFixed[i][j] = grid[i][j] != 0;
      }
    }
  }



  void _placeNumber(int number) {
    if (selectedRow == null || selectedCol == null) return;
    if (isFixed[selectedRow!][selectedCol!]) return;

    setState(() {
      isError[selectedRow!][selectedCol!] = false;
      
      if (number == solution[selectedRow!][selectedCol!]) {
        // Correct number
        grid[selectedRow!][selectedCol!] = number;
        _playSound('tictactoe_click.mp3');
        
        if (_checkWin()) {
          _playSound('merge.mp3');
          _winController.forward(from: 0.0);
          _showWinDialog();
        }
      } else {
        // Wrong number
        grid[selectedRow!][selectedCol!] = number;
        isError[selectedRow!][selectedCol!] = true;
        mistakes++;
      }
    });

    _errorController.forward().then((_) {
      _errorController.reverse();
    });

    if (mistakes >= maxMistakes) {
      _showGameOverDialog();
    }
  }

  void _useHint() {
    if (hintsUsed >= maxHints) return;
    if (selectedRow == null || selectedCol == null) return;
    if (isFixed[selectedRow!][selectedCol!]) return;

    setState(() {
      grid[selectedRow!][selectedCol!] = solution[selectedRow!][selectedCol!];
      isError[selectedRow!][selectedCol!] = false;
      hintsUsed++;
    });

    _playSound('merge.mp3');

    if (_checkWin()) {
      _winController.forward(from: 0.0);
      _showWinDialog();
    }
  }

  bool _checkWin() {
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (grid[i][j] == 0 || grid[i][j] != solution[i][j]) {
          return false;
        }
      }
    }
    return true;
  }

  void _clearCell() {
    if (selectedRow == null || selectedCol == null) return;
    if (isFixed[selectedRow!][selectedCol!]) return;

    setState(() {
      grid[selectedRow!][selectedCol!] = 0;
      isError[selectedRow!][selectedCol!] = false;
    });
  }

  void _showWinDialog() async {
    // Mark level as completed
    await SudokuProgressService.completeLevel(widget.level);
    
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
              'Level ${widget.level} Complete! 🎉',
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Congratulations!',
                  style: GoogleFonts.poppins(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mistakes: $mistakes/$maxMistakes',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Hints used: $hintsUsed/$maxHints',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.level < 50)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '🔓 Level ${widget.level + 1} Unlocked!',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF4ECDC4),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            actions: [
              if (widget.level < 50)
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SudokuScreen(
                          level: widget.level + 1,
                          difficulty: _getNextDifficulty(),
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Next Level',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF4ECDC4),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, true); // Return true to indicate completion
                },
                child: Text(
                  'Level Select',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF667EEA),
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

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D3436),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Game Over! 💀',
          style: GoogleFonts.orbitron(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Too many mistakes! Try again.',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _generatePuzzle();
            },
            child: Text(
              'Try Again',
              style: GoogleFonts.poppins(
                color: const Color(0xFFFF6B6B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  SudokuDifficulty _getNextDifficulty() {
    final nextLevel = widget.level + 1;
    if (nextLevel <= 10) return SudokuDifficulty.easy;
    if (nextLevel <= 25) return SudokuDifficulty.medium;
    if (nextLevel <= 40) return SudokuDifficulty.hard;
    return SudokuDifficulty.expert;
  }

  String _getDifficultyName() {
    switch (widget.difficulty) {
      case SudokuDifficulty.easy:
        return 'Easy';
      case SudokuDifficulty.medium:
        return 'Medium';
      case SudokuDifficulty.hard:
        return 'Hard';
      case SudokuDifficulty.expert:
        return 'Expert';
    }
  }

  Color _getDifficultyColor() {
    switch (widget.difficulty) {
      case SudokuDifficulty.easy:
        // Pastel mint
        return const Color(0xFF81E6D9); // teal 200
      case SudokuDifficulty.medium:
        // Pastel sunshine
        return const Color(0xFFFFF59D); // yellow 200
      case SudokuDifficulty.hard:
        // Pastel coral
        return const Color(0xFFFF8A80); // red accent 100
      case SudokuDifficulty.expert:
        // Pastel lavender
        return const Color(0xFFD1C4E9); // purple 100
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Galaxy Background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgAnimation,
              builder: (context, _) {
                return CustomPaint(
                  painter: NebulaPainter(_bgAnimation.value),
                  child: CustomPaint(
                    painter: GalaxyPainter(_bgAnimation.value),
                    child: CustomPaint(
                      painter: StarsPainter(_bgAnimation.value),
                    ),
                  ),
                );
              },
            ),
          ),
          // Foreground content
          Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha:0.06),
              _getDifficultyColor().withValues(alpha:0.18),
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
                          'Level ${widget.level}',
                          style: GoogleFonts.orbitron(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _getDifficultyName().toUpperCase(),
                          style: GoogleFonts.poppins(
                            color: _getDifficultyColor().withValues(alpha:0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        _generatePuzzle();
                        // Keep value at 1 to avoid hiding grid; win animation will set from 0 when needed
                      },
                      icon: const Icon(Icons.refresh, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Stats Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatItem(
                      icon: Icons.error_outline,
                      label: 'Mistakes',
                      value: '$mistakes/$maxMistakes',
                      color: const Color(0xFFFF8A80),
                    ),
                    _StatItem(
                      icon: Icons.lightbulb_outline,
                      label: 'Hints',
                      value: '$hintsUsed/$maxHints',
                      color: const Color(0xFFFFF59D),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Sudoku Grid
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AnimatedBuilder(
                    animation: _errorAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(
                          _errorAnimation.value * 10 * 
                          ((_errorAnimation.value * 4).floor() % 2 == 0 ? 1 : -1),
                          0,
                        ),
                        child: ScaleTransition(
                          scale: _winAnimation,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha:0.14),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha:0.25),
                                width: 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  // Painted grid lines (premium look)
                                  Positioned.fill(
                                    child: CustomPaint(
                                      painter: _SudokuGridPainter(
                                        thinLineColor: const Color(0xFFE5E7EB), // gray-200
                                        thickLineColor: const Color(0xFF9CA3AF), // gray-400
                                        thinWidth: 1,
                                        thickWidth: 2,
                                      ),
                                    ),
                                  ),
                                  // Cells and numbers
                                  _buildGrid(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Number Pad
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      16 + MediaQuery.of(context).padding.bottom,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha:0.10),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha:0.25),
                        width: 1,
                      ),
                    ),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        childAspectRatio: 1.05,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: 11, // 1-9 + Clear + Hint
                      itemBuilder: (context, index) {
                        if (index == 9) {
                          return _ControlButton(
                            text: '✖',
                            onPressed: _clearCell,
                            color: const Color(0xFFFF6B6B),
                          );
                        } else if (index == 10) {
                          return _ControlButton(
                            text: '💡',
                            onPressed: hintsUsed < maxHints ? _useHint : null,
                            color: const Color(0xFFFFE66D),
                          );
                        }
                        
                        final number = index + 1;
                        return _ControlButton(
                          text: number.toString(),
                          onPressed: () => _placeNumber(number),
                          color: _getDifficultyColor(),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    final selectedValue = (selectedRow != null && selectedCol != null)
        ? grid[selectedRow!][selectedCol!]
        : 0;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 9,
        childAspectRatio: 1,
      ),
      itemCount: 81,
      itemBuilder: (context, index) {
        final row = index ~/ 9;
        final col = index % 9;
        final number = grid[row][col];
        final isSelected = selectedRow == row && selectedCol == col;
        final isInSameRowCol = selectedRow == row || selectedCol == col;
        final isInSameBox = selectedRow != null && selectedCol != null &&
            (selectedRow! ~/ 3) == (row ~/ 3) &&
            (selectedCol! ~/ 3) == (col ~/ 3);
        final isSameNumber = selectedValue != 0 && number == selectedValue && !(isSelected);

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedRow = row;
              selectedCol = col;
            });
          },
          child: Container(
            margin: EdgeInsets.all(
              (row % 3 == 2 && row != 8) || (col % 3 == 2 && col != 8) ? 2 : 1,
            ),
            decoration: BoxDecoration(
              color: isError[row][col]
                  ? const Color(0xFFFFCDD2) // light red
                  : isSelected
                      ? const Color(0xFFB3E5FC) // light cyan
                      : isSameNumber
                          ? const Color(0xFFE0F2F1) // light teal
                          : isInSameRowCol || isInSameBox
                              ? const Color(0xFFF3F4F6) // gray-100
                              : Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isSelected ? const Color(0xFF0288D1) : const Color(0xFFCFD8DC),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Center(
              child: Text(
                number == 0 ? '' : number.toString(),
                style: GoogleFonts.orbitron(
                  fontSize: 24, // Bigger for readability
                  letterSpacing: 1.2,
                  fontWeight: isFixed[row][col] ? FontWeight.w800 : FontWeight.w700,
                  color: isError[row][col]
                      ? const Color(0xFFB71C1C)
                      : isFixed[row][col]
                          ? const Color(0xFF111827) // near-black
                          : const Color(0xFF1F2937), // slate-700
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha:0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha:0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color color;

  const _ControlButton({
    required this.text,
    required this.onPressed,
    required this.color,
  });

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null ? (_) => _controller.forward() : null,
      onTapUp: widget.onPressed != null ? (_) {
        _controller.reverse();
        widget.onPressed?.call();
      } : null,
      onTapCancel: widget.onPressed != null ? () => _controller.reverse() : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: widget.onPressed != null
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.color,
                      widget.color.withValues(alpha:0.7),
                    ],
                  )
                : LinearGradient(
                    colors: [Colors.grey.shade600, Colors.grey.shade700],
                  ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: widget.onPressed != null
                ? [
                    BoxShadow(
                      color: widget.color.withValues(alpha:0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              widget.text,
              style: GoogleFonts.orbitron(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: widget.onPressed != null ? Colors.white : Colors.white54,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Painter for premium Sudoku grid lines
class _SudokuGridPainter extends CustomPainter {
  final Color thinLineColor;
  final Color thickLineColor;
  final double thinWidth;
  final double thickWidth;

  _SudokuGridPainter({
    required this.thinLineColor,
    required this.thickLineColor,
    this.thinWidth = 1,
    this.thickWidth = 2.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final thin = Paint()
      ..color = thinLineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = thinWidth;
    final thick = Paint()
      ..color = thickLineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickWidth;

    final cellW = size.width / 9;
    final cellH = size.height / 9;

    // Vertical lines
    for (int i = 0; i <= 9; i++) {
      final x = i * cellW;
      final paint = (i % 3 == 0) ? thick : thin;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    // Horizontal lines
    for (int i = 0; i <= 9; i++) {
      final y = i * cellH;
      final paint = (i % 3 == 0) ? thick : thin;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}