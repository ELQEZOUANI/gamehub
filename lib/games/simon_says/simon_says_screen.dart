
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import '../../app_shell.dart'; // For galaxy background painters
import '../../services/game_prefs_service.dart';
import '../../services/stats_service.dart';

enum GameState { waiting, sequence, playing, gameOver }

class SimonSaysScreen extends StatefulWidget {
  const SimonSaysScreen({super.key});

  @override
  State<SimonSaysScreen> createState() => _SimonSaysScreenState();
}

class _SimonSaysScreenState extends State<SimonSaysScreen> with TickerProviderStateMixin {
  // Game Logic
  GameState _gameState = GameState.waiting;
  int _score = 0;
  int _bestScore = 0;
  final List<int> _sequence = [];
  int _playerIndex = 0;
  final Random _random = Random();
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Button Animation
  int _highlightedButton = -1; // -1 means none

  // Galaxy Background Animations
  late AnimationController _backgroundController;

  final List<Color> _buttonColors = [
    Colors.red.shade600,
    Colors.blue.shade600,
    Colors.yellow.shade600,
    Colors.green.shade600,
  ];

  final List<Color> _buttonHighlightColors = [
    Colors.red.shade300,
    Colors.blue.shade300,
    Colors.yellow.shade300,
    Colors.green.shade300,
  ];

  @override
  void initState() {
    super.initState();
    _loadBestScore();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 45),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
  
  Future<void> _playSound(int index) async {
    try {
      // Simple pitch variation for different buttons
      await _audioPlayer.play(AssetSource('audio/move.mp3'), volume: 0.8);
      await _audioPlayer.setPlaybackRate(1.0 + (index * 0.2));
    } catch (e) {
      debugPrint("Error playing sound: $e");
    }
  }

  void _startGame() {
    setState(() {
      _score = 0;
      _sequence.clear();
      _gameState = GameState.sequence;
    });
    _addNewStep();
  }

  void _addNewStep() {
    _sequence.add(_random.nextInt(4));
    _playSequence();
  }

  Future<void> _playSequence() async {
    await Future.delayed(const Duration(milliseconds: 700));
    for (int i = 0; i < _sequence.length; i++) {
      setState(() {
        _highlightedButton = _sequence[i];
      });
      _playSound(_sequence[i]);
      await Future.delayed(const Duration(milliseconds: 400));
      setState(() {
        _highlightedButton = -1;
      });
      await Future.delayed(const Duration(milliseconds: 200));
    }
    setState(() {
      _gameState = GameState.playing;
      _playerIndex = 0;
    });
  }

  void _handlePlayerTap(int index) {
    if (_gameState != GameState.playing) return;

    _playSound(index);
    _flashButton(index);

    if (_sequence[_playerIndex] == index) {
      _playerIndex++;
      if (_playerIndex >= _sequence.length) {
        // Round complete
        setState(() {
          _score++;
          _gameState = GameState.sequence;
        });
        _addNewStep();
      }
    } else {
      // Game Over
      _gameOver();
    }
  }

  void _flashButton(int index) async {
     setState(() => _highlightedButton = index);
     await Future.delayed(const Duration(milliseconds: 200));
     if(mounted) setState(() => _highlightedButton = -1);
  }

  void _gameOver() async {
    Vibration.vibrate(duration: 400);
    _updateBestScore();
    // Record game result in centralized stats
    await StatsService().recordGameResult(
      gameID: StatsService.gameSimonSays,
      score: _score,
    );
    setState(() {
      _gameState = GameState.gameOver;
    });
  }

  Future<void> _loadBestScore() async {
    _bestScore = await GamePrefsService.getBestScoreSimonSays();
    setState(() {});
  }

  Future<void> _updateBestScore() async {
    await GamePrefsService.setBestScoreSimonSays(_score);
    _loadBestScore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Simon Says',
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
             Text(
              'Best: $_bestScore',
              style: GoogleFonts.orbitron(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          AnimatedGalaxyBackground(controller: _backgroundController),
          Center(
            child: _buildGameUI(),
          ),
        ],
      ),
    );
  }

  Widget _buildGameUI() {
    switch (_gameState) {
      case GameState.waiting:
        return _buildStartMenu("Start Game");
      case GameState.gameOver:
        return _buildStartMenu("Game Over! Score: $_score\nPlay Again?");
      case GameState.sequence:
      case GameState.playing:
        return _buildGameGrid();
    }
  }

  Widget _buildStartMenu(String text) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
         Text(
          'Score: $_score',
          style: GoogleFonts.orbitron(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (_gameState != GameState.waiting)
          Text(
            'Best: $_bestScore',
            style: GoogleFonts.orbitron(
              color: Colors.white70,
              fontSize: 22,
            ),
          ),
        const SizedBox(height: 80),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple.withValues(alpha: 0.5),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Colors.white, width: 2),
            ),
          ),
          onPressed: _startGame,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.orbitron(fontSize: 20, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildGameGrid() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Score: $_score',
          style: GoogleFonts.orbitron(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            shadows: [const Shadow(blurRadius: 10, color: Colors.cyanAccent)],
          ),
        ),
        const SizedBox(height: 10),
         Text(
          'Best: $_bestScore',
          style: GoogleFonts.orbitron(
            color: Colors.white70,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: 300,
          height: 300,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
            ),
            itemCount: 4,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _handlePlayerTap(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: _highlightedButton == index
                        ? _buttonHighlightColors[index]
                        : _buttonColors[index],
                    borderRadius: BorderRadius.circular(16),
                     boxShadow: [
                      BoxShadow(
                        color: _highlightedButton == index
                          ? _buttonHighlightColors[index].withValues(alpha: 0.8)
                          : Colors.transparent,
                        blurRadius: 15,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
         const SizedBox(height: 40),
         if (_gameState == GameState.sequence)
          const CircularProgressIndicator(color: Colors.white),
      ],
    );
  }
}
