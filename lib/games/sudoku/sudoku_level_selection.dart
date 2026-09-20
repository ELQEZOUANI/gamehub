import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'sudoku_screen.dart';
import '../../services/sudoku_progress_service.dart';
import '../../app_shell.dart';

class SudokuLevelSelection extends StatefulWidget {
  const SudokuLevelSelection({super.key});

  @override
  State<SudokuLevelSelection> createState() => _SudokuLevelSelectionState();
}

class _SudokuLevelSelectionState extends State<SudokuLevelSelection>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;
  int _highestCompletedLevel = 0;

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
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // Galaxy animations
    _galaxyController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();
    
    _starsController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _nebulaController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat(reverse: true);

    _galaxyAnimation = CurvedAnimation(parent: _galaxyController, curve: Curves.linear);
    _starsAnimation = CurvedAnimation(parent: _starsController, curve: Curves.easeInOut);
    _nebulaAnimation = CurvedAnimation(parent: _nebulaController, curve: Curves.easeInOut);
    
    // Create staggered animations for each level
    _animations = List.generate(50, (index) {
      return CurvedAnimation(
        parent: _controller,
        curve: Interval(
          index * 0.02, // Stagger by 20ms each
          0.5 + (index * 0.01),
          curve: Curves.easeOutBack,
        ),
      );
    });
    
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final progress = await SudokuProgressService.getHighestCompletedLevel();
    setState(() {
      _highestCompletedLevel = progress;
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _galaxyController.dispose();
    _starsController.dispose();
    _nebulaController.dispose();
    super.dispose();
  }

  // Calculate difficulty based on level
  SudokuDifficulty _getDifficulty(int level) {
    if (level <= 10) return SudokuDifficulty.easy;
    if (level <= 25) return SudokuDifficulty.medium;
    if (level <= 40) return SudokuDifficulty.hard;
    return SudokuDifficulty.expert;
  }

  void _showTestingOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D3436),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Testing Options',
          style: GoogleFonts.orbitron(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Developer options for testing',
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await SudokuProgressService.completeLevel(50);
                Navigator.pop(context);
                await _loadProgress();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4ECDC4),
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Unlock All Levels',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                await SudokuProgressService.resetProgress();
                Navigator.pop(context);
                await _loadProgress();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE74C3C),
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Reset Progress',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Get difficulty name and color
  Map<String, dynamic> _getDifficultyInfo(int level) {
    final difficulty = _getDifficulty(level);
    switch (difficulty) {
      case SudokuDifficulty.easy:
        return {
          'name': 'Easy',
          'color': const Color(0xFF4ECDC4),
          'gradient': const LinearGradient(
            colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
          ),
        };
      case SudokuDifficulty.medium:
        return {
          'name': 'Medium',
          'color': const Color(0xFFFFE66D),
          'gradient': const LinearGradient(
            colors: [Color(0xFFFFE66D), Color(0xFFFFA502)],
          ),
        };
      case SudokuDifficulty.hard:
        return {
          'name': 'Hard',
          'color': const Color(0xFFFF6B6B),
          'gradient': const LinearGradient(
            colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
          ),
        };
      case SudokuDifficulty.expert:
        return {
          'name': 'Expert',
          'color': const Color(0xFF9C27B0),
          'gradient': const LinearGradient(
            colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
          ),
        };
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
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha:0.1),
                ],
              ),
            ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        const Spacer(),
                        Text(
                          'Sudoku Levels',
                          style: GoogleFonts.orbitron(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: const Color(0xFF667EEA).withValues(alpha:0.8),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(width: 48), // Balance the back button
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose your challenge level',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha:0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha:0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.emoji_events,
                            color: const Color(0xFFFFE66D),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Progress: $_highestCompletedLevel/50',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _showTestingOptions(),
                            child: Icon(
                              Icons.settings,
                              color: Colors.white.withValues(alpha:0.7),
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Difficulty Legend
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _DifficultyLegend(
                      color: const Color(0xFF4ECDC4),
                      label: 'Easy (1-10)',
                    ),
                    _DifficultyLegend(
                      color: const Color(0xFFFFE66D),
                      label: 'Medium (11-25)',
                    ),
                    _DifficultyLegend(
                      color: const Color(0xFFFF6B6B),
                      label: 'Hard (26-40)',
                    ),
                    _DifficultyLegend(
                      color: const Color(0xFF9C27B0),
                      label: 'Expert (41-50)',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Levels Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      childAspectRatio: 1,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    itemCount: 50,
                    itemBuilder: (context, index) {
                      final level = index + 1;
                      final diffInfo = _getDifficultyInfo(level);
                      final isUnlocked = level <= _highestCompletedLevel + 1;
                      final isCompleted = level <= _highestCompletedLevel;
                      
                      return ScaleTransition(
                        scale: _animations[index],
                        child: _LevelButton(
                          level: level,
                          difficulty: _getDifficulty(level),
                          color: diffInfo['color'],
                          gradient: diffInfo['gradient'],
                          isUnlocked: isUnlocked,
                          isCompleted: isCompleted,
                          onTap: isUnlocked ? () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SudokuScreen(
                                  level: level,
                                  difficulty: _getDifficulty(level),
                                ),
                              ),
                            );
                            
                            // Refresh progress if level was completed
                            if (result == true) {
                              await _loadProgress();
                            }
                          } : null,
                        ),
                      );
                    },
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
}

class _DifficultyLegend extends StatelessWidget {
  final Color color;
  final String label;

  const _DifficultyLegend({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha:0.5),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _LevelButton extends StatefulWidget {
  final int level;
  final SudokuDifficulty difficulty;
  final Color color;
  final Gradient gradient;
  final bool isUnlocked;
  final bool isCompleted;
  final VoidCallback? onTap;

  const _LevelButton({
    required this.level,
    required this.difficulty,
    required this.color,
    required this.gradient,
    required this.isUnlocked,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  State<_LevelButton> createState() => _LevelButtonState();
}

class _LevelButtonState extends State<_LevelButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _hoverAnimation = CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isUnlocked ? (_) {
        setState(() => _isPressed = true);
        _hoverController.forward();
      } : null,
      onTapUp: widget.isUnlocked ? (_) {
        setState(() => _isPressed = false);
        _hoverController.reverse();
        widget.onTap?.call();
      } : null,
      onTapCancel: widget.isUnlocked ? () {
        setState(() => _isPressed = false);
        _hoverController.reverse();
      } : null,
      child: AnimatedBuilder(
        animation: _hoverAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isUnlocked ? 1.0 - (_hoverAnimation.value * 0.05) : 1.0,
            child: Container(
              decoration: BoxDecoration(
                gradient: widget.isUnlocked ? widget.gradient : null,
                color: !widget.isUnlocked ? Colors.grey.shade600 : null,
                borderRadius: BorderRadius.circular(16),
                boxShadow: widget.isUnlocked ? [
                  BoxShadow(
                    color: widget.color.withValues(alpha:_isPressed ? 0.6 : 0.4),
                    blurRadius: _isPressed ? 8 : 15,
                    spreadRadius: _isPressed ? 1 : 3,
                    offset: Offset(0, _isPressed ? 2 : 6),
                  ),
                  if (!_isPressed)
                    BoxShadow(
                      color: Colors.white.withValues(alpha:0.2),
                      blurRadius: 5,
                      spreadRadius: 1,
                      offset: const Offset(0, -2),
                    ),
                ] : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.3),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Locked overlay
                  if (!widget.isUnlocked)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha:0.6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.lock,
                            color: Colors.white70,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  
                  // Level number
                  if (widget.isUnlocked)
                    Center(
                      child: Text(
                        '${widget.level}',
                        style: GoogleFonts.orbitron(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha:0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  // Completed checkmark
                  if (widget.isCompleted)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 8,
                        ),
                      ),
                    ),
                  
                  // Difficulty indicator (small dot) - only for unlocked levels
                  if (widget.isUnlocked && !widget.isCompleted)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha:0.8),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  
                  // Stars for expert difficulty
                  if (widget.isUnlocked && widget.difficulty == SudokuDifficulty.expert)
                    Positioned(
                      bottom: 4,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) => 
                          Icon(
                            Icons.star,
                            color: Colors.white.withValues(alpha:0.9),
                            size: 8,
                          ),
                        ),
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

enum SudokuDifficulty { easy, medium, hard, expert }
