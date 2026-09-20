import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/stats_service.dart';
import '../services/stats_notifier.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin, StatsListenerMixin {
  String _userName = 'Player';
  String _avatarEmoji = '🙂';
  late AnimationController _avatarController;
  late Animation<double> _avatarAnimation;
  late AnimationController _statsController;
  late Animation<double> _statsAnimation;
  late AnimationController _floatingController;
  late AnimationController _pulseController;
  late Animation<double> _floatingAnimation;
  late Animation<double> _pulseAnimation;
  late AnimationController _heroController;
  late Animation<double> _heroAnimation;

  @override
  void initState() {
    super.initState();
    _avatarController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _statsController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _avatarAnimation = CurvedAnimation(
      parent: _avatarController,
      curve: Curves.elasticOut,
    );
    _statsAnimation = CurvedAnimation(
      parent: _statsController,
      curve: Curves.easeOutBack,
    );
    _floatingAnimation = CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    );
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
    _heroAnimation = CurvedAnimation(
      parent: _heroController,
      curve: Curves.easeOutBack,
    );
    
    _avatarController.forward();
    _statsController.forward();
    _heroController.forward();
    _floatingController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
    _load();
  }

  @override
  void dispose() {
    _avatarController.dispose();
    _statsController.dispose();
    _floatingController.dispose();
    _pulseController.dispose();
    _heroController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    // Initialize the stats service
    await statsNotifier.initialize();
    
    // Load user name and avatar
    final userName = await statsNotifier.getUserName();
    final avatarEmoji = await statsNotifier.getUserAvatarEmoji();
    
    setState(() {
      _userName = userName;
      _avatarEmoji = avatarEmoji;
    });
  }

  Future<void> _pickAvatarEmoji() async {
    final faces = [
      '😀','😃','😄','😁','😆','😅','😂','🙂','😊','😇','😉','😎','😍','🤩','😘','😗','😚','😙','🤗','🤠','🥳','🤓','🤖','👽'
    ];
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF1F1F1F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Choose your avatar',
                  style: GoogleFonts.fredoka(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: faces.length,
                  itemBuilder: (_, i) {
                    return InkWell(
                      onTap: () => Navigator.pop(context, faces[i]),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                        ),
                        child: Center(
                          child: Text(
                            faces[i],
                            style: const TextStyle(fontSize: 26),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      }
    );

    if (selected != null && selected != _avatarEmoji) {
      await statsNotifier.setUserAvatarEmoji(selected);
      setState(() => _avatarEmoji = selected);
    }
  }

  Future<void> _editName() async {
    final TextEditingController nameController = TextEditingController(text: _userName);
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D3436),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Edit Your Name',
          style: GoogleFonts.fredoka(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: TextField(
          controller: nameController,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: 'Enter your name',
            hintStyle: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.6),
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white,
                width: 2,
              ),
            ),
          ),
          textCapitalization: TextCapitalization.words,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty && newName.length >= 2 && newName.length <= 20) {
                Navigator.pop(context, newName);
              }
            },
            child: Text(
              'Save',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (result != null && result != _userName) {
      await statsNotifier.setUserName(result);
      setState(() {
        _userName = result;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Name updated to: $result'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated Gradient Background
          AnimatedBuilder(
            animation: _floatingAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(
                      -1 + _floatingAnimation.value * 0.2,
                      -1 + _floatingAnimation.value * 0.3,
                    ),
                    end: Alignment(
                      1 - _floatingAnimation.value * 0.2,
                      1 - _floatingAnimation.value * 0.3,
                    ),
                    colors: [
                      Colors.black.withValues(alpha: 0.95),
                      Colors.black.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              );
            },
          ),
          
          // Subtle animated shapes in background
          AnimatedBuilder(
            animation: _floatingAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  // Floating shape 1
                  Positioned(
                    top: 50 + _floatingAnimation.value * 25,
                    left: -60,
                    child: Transform.rotate(
                      angle: _floatingAnimation.value * 0.2,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.12),
                              Colors.white.withValues(alpha: 0.03),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Floating shape 2
                  Positioned(
                    bottom: 100 - _floatingAnimation.value * 20,
                    right: -70,
                    child: Transform.rotate(
                      angle: -_floatingAnimation.value * 0.15,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.1),
                              Colors.white.withValues(alpha: 0.02),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Floating shape 3 (center)
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.3 + _floatingAnimation.value * 15,
                    right: MediaQuery.of(context).size.width * 0.2,
                    child: Transform.rotate(
                      angle: _floatingAnimation.value * 0.1,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.08),
                              Colors.white.withValues(alpha: 0.01),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          
          // Profile Content
          SafeArea(
            child: _buildBody(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StatsBuilder(
      builder: (context, statsNotifier) {

        final totalGames = statsNotifier.totalGamesPlayed;
        
        // Calculate total wins from different games
        final tttStats = statsNotifier.getStats(gameID: StatsService.gameTicTacToe);
        final rpsStats = statsNotifier.getStats(gameID: StatsService.gameRockPaperScissors);
        
        final totalWins = (tttStats?.bestScore ?? 0) + (rpsStats?.bestScore ?? 0);
        final winRate = totalGames > 0 ? (totalWins / totalGames * 100) : 0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Profile Header with floating animation
          AnimatedBuilder(
            animation: _floatingAnimation,
            builder: (context, child) {
              return Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(_floatingAnimation.value * 0.02)
                  ..translate(0.0, _floatingAnimation.value * 10 - 5),
                alignment: Alignment.center,
                child: ScaleTransition(
                  scale: _avatarAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.2),
                          Colors.white.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + _pulseAnimation.value * 0.05,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFFF6B6B),
                                    const Color(0xFFFFE66D),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFF6B6B).withValues(alpha: 0.4),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: _pickAvatarEmoji,
                                  child: Center(
                                    child: Text(
                                      _avatarEmoji,
                                      style: const TextStyle(fontSize: 46),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4ECDC4),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(
                            Icons.star,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  ScaleTransition(
                    scale: _heroAnimation,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _userName,
                          style: GoogleFonts.fredoka(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: _editName,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Win Rate: ${winRate.toStringAsFixed(1)}%',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
      const SizedBox(height: 24),

          // Stats Overview with floating animation
          AnimatedBuilder(
            animation: _floatingAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, -_floatingAnimation.value * 8 + 4),
                child: ScaleTransition(
                  scale: _statsAnimation,
                  child: Row(
                    children: [
                      Expanded(
                        child: _QuickStat(
                          icon: Icons.sports_esports,
                          value: totalGames.toString(),
                          label: 'Total Games',
                          color: const Color(0xFF4ECDC4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickStat(
                          icon: Icons.emoji_events,
                          value: totalWins.toString(),
                          label: 'Total Wins',
                          color: const Color(0xFFFFE66D),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickStat(
                    icon: Icons.local_fire_department,
                    value: '0',
                    label: 'Streak',
                    color: const Color(0xFFFF6B6B),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Game Stats - 2048
          FutureBuilder<List<int>>(
            future: Future.wait([
              statsNotifier.getBest2048(3),
              statsNotifier.getBest2048(4),
              statsNotifier.getBest2048(5),
            ]),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final scores = snapshot.data!;
                return StatCard3D(
                  title: '2048',
                  icon: '🔢',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ),
                  items: [
                    _Kv('Best Score (3x3)', scores[0]),
                    _Kv('Best Score (4x4)', scores[1]),
                    _Kv('Best Score (5x5)', scores[2]),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(height: 16),

          // Game Stats - Tic-Tac-Toe
          StatCard3D(
            title: 'Tic-Tac-Toe',
            icon: '❌⭕',
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
            ),
            items: [
              _Kv('Best Score', statsNotifier.getBestScore(gameID: StatsService.gameTicTacToe)),
              _Kv('Games Played', statsNotifier.getGamesPlayed(gameID: StatsService.gameTicTacToe)),
              _Kv('Win Rate', (statsNotifier.getAverageScore(gameID: StatsService.gameTicTacToe) * 100).round()),
            ],
          ),
          const SizedBox(height: 16),

          // Game Stats - Rock Paper Scissors
          StatCard3D(
            title: 'Rock Paper Scissors',
            icon: '✊✋✌️',
            gradient: const LinearGradient(
              colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
            ),
            items: [
              _Kv('Best Score', statsNotifier.getBestScore(gameID: StatsService.gameRockPaperScissors)),
              _Kv('Games Played', statsNotifier.getGamesPlayed(gameID: StatsService.gameRockPaperScissors)),
              _Kv('Win Rate', (statsNotifier.getAverageScore(gameID: StatsService.gameRockPaperScissors) * 100).round()),
            ],
          ),
          const SizedBox(height: 16),

          // Game Stats - Quick Reaction
          StatCard3D(
            title: 'Quick Reaction',
            icon: '⚡️',
            gradient: const LinearGradient(
              colors: [Color(0xFF42A5F5), Color(0xFF3498DB)],
            ),
            items: [
              _Kv('Best Score', statsNotifier.getBestScore(gameID: StatsService.gameQuickReaction)),
              _Kv('Games Played', statsNotifier.getGamesPlayed(gameID: StatsService.gameQuickReaction)),
              _Kv('Avg Score', statsNotifier.getAverageScore(gameID: StatsService.gameQuickReaction).round()),
            ],
          ),
          const SizedBox(height: 16),

          // Game Stats - Memory Match
          StatCard3D(
            title: 'Memory Match',
            icon: '🧠',
            gradient: const LinearGradient(
              colors: [Color(0xFFFFE66D), Color(0xFFFFA502)],
            ),
            items: [
              _Kv('Best Score', statsNotifier.getBestScore(gameID: StatsService.gameMemoryMatch)),
              _Kv('Games Played', statsNotifier.getGamesPlayed(gameID: StatsService.gameMemoryMatch)),
              _Kv('Avg Score', statsNotifier.getAverageScore(gameID: StatsService.gameMemoryMatch).round()),
            ],
          ),
          const SizedBox(height: 16),

          // Game Stats - Simon Says
          StatCard3D(
            title: 'Simon Says',
            icon: '🎨',
            gradient: const LinearGradient(
              colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
            ),
            items: [
              _Kv('Best Level', statsNotifier.getBestScore(gameID: StatsService.gameSimonSays)),
              _Kv('Games Played', statsNotifier.getGamesPlayed(gameID: StatsService.gameSimonSays)),
              _Kv('Avg Level', statsNotifier.getAverageScore(gameID: StatsService.gameSimonSays).round()),
            ],
          ),
          const SizedBox(height: 16),


          const SizedBox(height: 16),

          // Game Stats - Word Guess
          StatCard3D(
            title: 'Word Guess',
            icon: '🤔',
            gradient: const LinearGradient(
              colors: [Color(0xFFf857a6), Color(0xFFff5858)],
            ),
            items: [
              _Kv('Best Score', statsNotifier.getBestScore(gameID: StatsService.gameWordGuess)),
              _Kv('Games Played', statsNotifier.getGamesPlayed(gameID: StatsService.gameWordGuess)),
              _Kv('Avg Score', statsNotifier.getAverageScore(gameID: StatsService.gameWordGuess).round()),
            ],
          ),
          const SizedBox(height: 16),

          // Game Stats - Sketch It!
          StatCard3D(
            title: 'Sketch It!',
            icon: '✏️',
            gradient: const LinearGradient(
              colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
            ),
            items: [
              _Kv('Games Played', statsNotifier.getGamesPlayed(gameID: StatsService.gameSketchIt)),
              _Kv('Creative Score', statsNotifier.getGamesPlayed(gameID: StatsService.gameSketchIt) * 10),
              _Kv('Fun Factor', statsNotifier.hasStats(gameID: StatsService.gameSketchIt) ? 100 : 50),
            ],
          ),
          const SizedBox(height: 24),

          // Reset Button
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.red.shade400,
                  Colors.red.shade600,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: const Color(0xFF2D3436),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: Text(
                        'Reset All Stats?',
                        style: GoogleFonts.fredoka(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      content: Text(
                        'This will permanently delete all your game statistics.',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.poppins(color: Colors.white),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            await statsNotifier.resetAllStats();
                            await _load();
                          },
        child: Text(
                            'Reset',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.restart_alt, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Reset Stats',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Add bottom padding to lift content above tab view
          const SizedBox(height: 100),
        ],
      ),
    );
      },
    );
  }
}

class _QuickStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _QuickStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: int.tryParse(value) ?? 0),
            duration: const Duration(milliseconds: 800),
            builder: (_, v, __) => Text(
              '$v',
              style: GoogleFonts.fredoka(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class StatCard3D extends StatelessWidget {
  final String title;
  final String icon;
  final Gradient gradient;
  final List<_Kv> items;

  const StatCard3D({
    super.key,
    required this.title,
    required this.icon,
    required this.gradient,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (gradient as LinearGradient).colors.first.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.fredoka(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: items
                  .map((e) => Expanded(
                        child: Column(
                          children: [
                            Text(
                              e.key,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TweenAnimationBuilder<int>(
                              tween: IntTween(begin: 0, end: e.value),
                              duration: const Duration(milliseconds: 600),
                              builder: (_, v, __) => Text(
                                '$v',
                                style: GoogleFonts.fredoka(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Kv {
  final String key;
  final int value;
  _Kv(this.key, this.value);
}

