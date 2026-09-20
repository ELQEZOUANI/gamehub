import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'drawing_screen.dart';
import '../../app_shell.dart';

class SketchItSetupScreen extends StatefulWidget {
  const SketchItSetupScreen({super.key});

  @override
  State<SketchItSetupScreen> createState() => _SketchItSetupScreenState();
}

class _SketchItSetupScreenState extends State<SketchItSetupScreen> with TickerProviderStateMixin {
  final _player1Controller = TextEditingController(text: 'Player 1');
  final _player2Controller = TextEditingController(text: 'Player 2');
  final _playerControllers = <TextEditingController>[];
  
  double _rounds = 3;
  
  late AnimationController _backgroundController;

  @override
  void initState() {
    super.initState();
    _playerControllers.addAll([_player1Controller, _player2Controller]);
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
  }

  @override
  void dispose() {
    for (var controller in _playerControllers) {
      controller.dispose();
    }
    _backgroundController.dispose();
    super.dispose();
  }

  void _addPlayer() {
    if (_playerControllers.length < 6) { // Max 6 players
      setState(() {
        _playerControllers.add(TextEditingController(text: 'Player ${_playerControllers.length + 1}'));
      });
    }
  }
  
  void _removePlayer(int index) {
    if (_playerControllers.length > 2) {
      setState(() {
        _playerControllers.removeAt(index).dispose();
      });
    }
  }

  void _startGame() {
    final players = _playerControllers.map((c) => c.text.trim()).where((name) => name.isNotEmpty).toList();
    if (players.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need at least 2 players to start!')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DrawingScreen(
          players: players,
          totalRounds: _rounds.toInt(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Sketch It! - Setup', style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold)),
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
                    Positioned.fill(child: CustomPaint(painter: GalaxyPainter(_backgroundController.value))),
                    Positioned.fill(child: CustomPaint(painter: NebulaPainter(_backgroundController.value))),
                    Positioned.fill(child: CustomPaint(painter: StarsPainter(_backgroundController.value))),
                  ],
                );
              },
            ),
          ),
          
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSectionTitle('Players'),
                  ..._buildPlayerFields(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_playerControllers.length < 6)
                        TextButton.icon(
                          icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                          label: Text('Add Player', style: GoogleFonts.orbitron(color: Colors.white)),
                          onPressed: _addPlayer,
                        ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  _buildSectionTitle('Rounds'),
                  Text('${_rounds.toInt()}', style: GoogleFonts.orbitron(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold)),
                  Slider(
                    value: _rounds,
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: _rounds.toInt().toString(),
                    onChanged: (value) => setState(() => _rounds = value),
                    activeColor: const Color(0xFF4ECDC4),
                    inactiveColor: Colors.white.withValues(alpha:0.3),
                  ),
                  const SizedBox(height: 40),

                  ElevatedButton(
                    onPressed: _startGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4ECDC4),
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                      textStyle: GoogleFonts.orbitron(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    child: const Text('Start Game'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.orbitron(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white.withValues(alpha:0.9),
        shadows: [Shadow(color: Colors.white.withValues(alpha:0.3), blurRadius: 8)],
      ),
    );
  }

  List<Widget> _buildPlayerFields() {
    return List.generate(_playerControllers.length, (index) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _playerControllers[index],
                style: GoogleFonts.poppins(color: Colors.white),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person, color: Color(0xFF4ECDC4)),
                  labelText: 'Player ${index + 1}',
                  labelStyle: GoogleFonts.orbitron(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha:0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            if (_playerControllers.length > 2)
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                onPressed: () => _removePlayer(index),
              ),
          ],
        ),
      );
    });
  }
}
