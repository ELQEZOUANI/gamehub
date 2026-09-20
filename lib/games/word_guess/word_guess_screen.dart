import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'word_list.dart';
import '../../app_shell.dart';
import '../../services/stats_service.dart';

class WordGuessScreen extends StatefulWidget {
  const WordGuessScreen({super.key});

  @override
  State<WordGuessScreen> createState() => _WordGuessScreenState();
}

class _WordGuessScreenState extends State<WordGuessScreen> with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  String _word = '';
  String _category = '';
  final Set<String> _guessedLetters = {};
  int _lives = 6;
  bool _isGameOver = false;
  bool _didWin = false;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(vsync: this, duration: const Duration(seconds: 50))..repeat();
    _startNewGame();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startNewGame() {
    final random = Random();
    final categories = WordList.categories.keys.toList();
    _category = categories[random.nextInt(categories.length)];
    final words = WordList.categories[_category]!;
    _word = words[random.nextInt(words.length)];

    setState(() {
      _guessedLetters.clear();
      _lives = 6;
      _isGameOver = false;
      _didWin = false;
    });
  }

  void _guessLetter(String letter) {
    if (_isGameOver || _guessedLetters.contains(letter)) return;

    setState(() {
      _guessedLetters.add(letter);
      if (!_word.contains(letter)) {
        _lives--;
        _playSound('move.mp3');
      } else {
        _playSound('merge.mp3');
      }

      _checkGameState();
    });
  }
  
  void _checkGameState() async {
    bool wordGuessed = _word.split('').every((letter) => _guessedLetters.contains(letter));
    if (wordGuessed) {
      _isGameOver = true;
      _didWin = true;
      // Update stats: simple score as remaining lives * word length
      final score = _lives * _word.length;
      await StatsService().recordGameResult(
        gameID: StatsService.gameWordGuess,
        score: score,
      );
    } else if (_lives <= 0) {
      _isGameOver = true;
      _didWin = false;
      // Record a game played even if loss (score = 0)
      await StatsService().recordGameResult(
        gameID: StatsService.gameWordGuess,
        score: 0,
      );
    }
  }

  Future<void> _playSound(String sound) async {
    try {
      await _audioPlayer.play(AssetSource('audio/$sound'));
    } catch (e) { /* ... */ }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Word Guess', style: GoogleFonts.orbitron(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          AnimatedGalaxyBackground(controller: _backgroundController),
          Center(
            child: _isGameOver ? _buildGameOverMenu() : _buildGameInterface(),
          ),
        ],
      ),
    );
  }

  Widget _buildGameInterface() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Category: $_category', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 18)),
            const SizedBox(height: 20),
            Text('Lives: $_lives ❤️', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            _buildWordDisplay(),
            const SizedBox(height: 40),
            _buildKeyboard(),
          ],
        ),
      ),
    );
  }

  Widget _buildWordDisplay() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: _word.split('').map((letter) {
        return Container(
          width: 40,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white30),
          ),
          child: Center(
            child: Text(
              _guessedLetters.contains(letter) ? letter : '',
              style: GoogleFonts.orbitron(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKeyboard() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('').map((letter) {
        final bool isGuessed = _guessedLetters.contains(letter);
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isGuessed ? Colors.white30 : Colors.deepPurple.withValues(alpha:0.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.all(12),
          ),
          onPressed: isGuessed ? null : () => _guessLetter(letter),
          child: Text(letter, style: GoogleFonts.orbitron(fontSize: 18, color: Colors.white)),
        );
      }).toList(),
    );
  }

  Widget _buildGameOverMenu() {
    return Container(
       padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha:0.6),
          borderRadius: BorderRadius.circular(20),
        ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _didWin ? 'You Win! 🎉' : 'Game Over! 💀',
            style: GoogleFonts.orbitron(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text('The word was:', style: GoogleFonts.poppins(color: Colors.white70)),
          Text(_word, style: GoogleFonts.orbitron(fontSize: 24, color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: Text('Play Again', style: GoogleFonts.orbitron(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _didWin ? Colors.green : Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
            onPressed: _startNewGame,
          )
        ],
      ),
    );
  }
}
