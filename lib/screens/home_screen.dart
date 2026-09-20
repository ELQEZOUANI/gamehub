import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../games/2048/level_selection_screen.dart';
import '../games/tic_tac_toe/mode_selection_screen.dart';
import '../games/rps/rps_screen.dart';
import '../games/memory/memory_screen.dart';
import '../games/quick_reaction/quick_reaction_screen.dart';
import '../games/sketch_it/sketch_it_setup_screen.dart';
import '../games/simon_says/simon_says_screen.dart';

import '../games/word_guess/word_guess_screen.dart';
import '../services/game_prefs_service.dart';
import '../services/interstitial_ad_service.dart';
import '../services/mission_service.dart';
import '../models/mission.dart';
import '../models/mission_type.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _heroController;
  late AnimationController _floatController;
  late AnimationController _missionController;
  late AnimationController _glowController;
  late Animation<double> _heroAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _missionStagger;
  late Animation<double> _glowAnimation;

  Future<Map<String, dynamic>>? _homeData;
  final MissionService _missionService = MissionService();
  List<Mission> _missions = [];
  bool _openingGame = false;

  // This map should ideally be managed in a central place
  final Map<String, Widget> _gameScreens = {
    '2048': const LevelSelection2048Screen(),
    'Tic-Tac-Toe': const ModeSelectionScreen(),
    'Rock Paper Scissors': const RpsScreen(),
    'Quick Reaction': const QuickReactionScreen(),
    'Sketch It!': const SketchItSetupScreen(),
    'Memory Match': const MemoryScreen(),
    'Simon Says': const SimonSaysScreen(),

    'Word Guess': const WordGuessScreen(),
  };



  @override
  void initState() {
    super.initState();
    _heroController = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this);
    _floatController = AnimationController(duration: const Duration(seconds: 3), vsync: this)..repeat(reverse: true);
    _missionController = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this);
    _glowController = AnimationController(duration: const Duration(seconds: 2), vsync: this)..repeat(reverse: true);
    
    _heroAnimation = CurvedAnimation(parent: _heroController, curve: Curves.easeOutBack);
    _floatAnimation = CurvedAnimation(parent: _floatController, curve: Curves.easeInOut);
    _missionStagger = CurvedAnimation(parent: _missionController, curve: Curves.elasticOut);
    _glowAnimation = CurvedAnimation(parent: _glowController, curve: Curves.easeInOut);
    
    _heroController.forward();
    _initializeMissions();
    _loadHomeData();
  }

  void _loadHomeData() {
    _homeData = _fetchHomeData();
  }

  Future<void> _initializeMissions() async {
    await _missionService.initialize();
    if (!mounted) return;
    setState(() {
      _missions = _missionService.dailyMissions;
    });
    // Start mission animations after loading
    _missionController.forward();
  }

  Future<Map<String, dynamic>> _fetchHomeData() async {
    final lastPlayed = await GamePrefsService.getLastPlayedGame();
    return {
      'lastPlayed': lastPlayed,
    };
  }

  @override
  void dispose() {
    _heroController.dispose();
    _floatController.dispose();
    _missionController.dispose();
    _glowController.dispose();
    super.dispose();
  }
  
  Future<void> _navigateToGame(Widget screen, [String? gameTitle]) async {
    if (_openingGame) return;
    _openingGame = true;
    try {
      final proceed = await InterstitialAdService.instance.showBeforeGame();
      if (!mounted || !proceed) return;
      await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(builder: (context) => screen),
      ).then((_) async {
        if (!mounted) return;
        // Track mission events after returning from a game
        if (gameTitle != null) {
          final isNewGame = await _missionService.isGameNewToday(gameTitle);
        
          // For now, we'll track with a default score of 1 and let individual games
          // call trackEvent with actual scores when they finish
          await _missionService.trackEvent(
            gameID: gameTitle,
            score: 1, // Default score - games should call trackEvent with real scores
            wasNewGame: isNewGame,
          );
        }
      
        // Refresh home data and missions when returning from a game
        await _initializeMissions();
        if (!mounted) return;
        setState(() {
          _loadHomeData();
        });
      });
    } finally {
      _openingGame = false;
    }
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
              Colors.transparent,
              Colors.black.withValues(alpha: 0.1),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _loadHomeData();
              });
            },
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _homeData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
                    }

                    final data = snapshot.data ?? {};
                    final lastPlayed = data['lastPlayed'];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        _buildUserProfile(),
                        const SizedBox(height: 25),
                        _buildHeader(),
                        const SizedBox(height: 30),

                        _buildQuickActions(lastPlayed),
                        const SizedBox(height: 35),
                        
                        // Compact Daily Missions at bottom
                        _buildCompactDailyMissions(),
                        const SizedBox(height: 100), // Added padding for tab view
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return ScaleTransition(
      scale: _heroAnimation,
      child: Column(
        children: [
          Text(
            'Game Hub: Fun Challenges',
            textAlign: TextAlign.center,
            style: GoogleFonts.fredoka(
              fontWeight: FontWeight.w700,
              fontSize: 34,
              height: 1.1,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '🎮 Play, Compete, Have Fun! 🚀',
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }


  
  Widget _buildQuickActions(String? lastPlayed) {
    return Row(
      children: [
        if (lastPlayed != null && _gameScreens.containsKey(lastPlayed))
          Expanded(
            child: _Quick3DAction(
              icon: Icons.replay,
              title: 'Play',
              subtitle: lastPlayed,
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              onTap: () => _navigateToGame(_gameScreens[lastPlayed]!, lastPlayed),
            ),
          ),
        if (lastPlayed != null) const SizedBox(width: 12),
        Expanded(
          child: _Quick3DAction(
            icon: Icons.shuffle,
            title: 'Quick Play',
            subtitle: 'Random Game',
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
            ),
            onTap: () {
              final randomGameKey = (_gameScreens.keys.toList()..shuffle()).first;
              _navigateToGame(_gameScreens[randomGameKey]!, randomGameKey);
            },
          ),
        ),
      ],
    );
  }



  Widget _buildCompactDailyMissions() {
    if (_missions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.1),
              Colors.white.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Daily Missions loading...',
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.emoji_events, color: Colors.amber, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Daily Missions',
                  style: GoogleFonts.fredoka(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_missions.where((m) => m.isCompleted).length}/${_missions.length}',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Missions list - compact
          ...List.generate(_missions.length, (index) {
            final mission = _missions[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  // Status indicator
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: mission.isCompleted 
                          ? Colors.green
                          : Colors.white.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: mission.isCompleted 
                        ? const Icon(Icons.check, size: 10, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  // Mission text
                  Expanded(
                    child: Text(
                      mission.description,
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                        decoration: mission.isCompleted 
                            ? TextDecoration.lineThrough 
                            : TextDecoration.none,
                      ),
                    ),
                  ),
                  // Progress
                  Text(
                    '${mission.progress}/${mission.goal}',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // Helper function to get mission type display text
  String _getMissionTypeText(MissionType type) {
    switch (type) {
      case MissionType.playGamesInARow:
        return 'STREAK';
      case MissionType.beatPersonalBest:
        return 'HIGH SCORE';
      case MissionType.tryNewGame:
        return 'EXPLORE';
    }
  }

  Widget _buildUserProfile() {
    return ScaleTransition(
      scale: _heroAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.25),
              Colors.white.withValues(alpha: 0.15),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            // User Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Level 5',
      style: GoogleFonts.fredoka(
                      fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Experience Progress Bar
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.7, // 70% progress
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '1,250 / 1,800 XP',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Quick3DAction extends StatefulWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Gradient gradient;
  final VoidCallback onTap;
  
  const _Quick3DAction({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_Quick3DAction> createState() => _Quick3DActionState();
}

class _Quick3DActionState extends State<_Quick3DAction> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
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
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              height: 120,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: widget.gradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: widget.gradient.colors.first.withValues(alpha: 0.4),
                    blurRadius: _isPressed ? 8 : 15,
                    spreadRadius: _isPressed ? 1 : 3,
                    offset: Offset(0, _isPressed ? 3 : 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(widget.icon, color: Colors.white, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    widget.title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  if (widget.subtitle != null)
                    Text(
                      widget.subtitle!,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
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
