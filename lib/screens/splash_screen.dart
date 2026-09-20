import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_shell.dart';

class SplashScreen extends StatefulWidget {
  final Widget nextScreen;

  const SplashScreen({super.key, required this.nextScreen});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _controller.forward().whenComplete(() {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder<void>(
          pageBuilder: (_, __, ___) => widget.nextScreen,
          transitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (_, animation, __, child) => FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final progress = Curves.easeInOutCubic.transform(_controller.value);
          final pulse = 0.90 + math.sin(_controller.value * math.pi * 6) * 0.05;

          return Stack(
            fit: StackFit.expand,
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, -0.35),
                    radius: 1.35,
                    colors: [
                      Color(0xFF1B2752),
                      Color(0xFF10182F),
                      Color(0xFF070A16),
                    ],
                  ),
                ),
              ),
              CustomPaint(painter: GalaxyPainter(_controller.value)),
              CustomPaint(painter: NebulaPainter(_controller.value)),
              CustomPaint(painter: StarsPainter(_controller.value)),
              _FloatingGameSymbol(
                alignment: const Alignment(-0.82, -0.48),
                phase: 0,
                progress: _controller.value,
                icon: Icons.extension_rounded,
                color: const Color(0xFF4ECDC4),
              ),
              _FloatingGameSymbol(
                alignment: const Alignment(0.80, -0.23),
                phase: 1.8,
                progress: _controller.value,
                icon: Icons.bolt_rounded,
                color: const Color(0xFFFFE66D),
              ),
              _FloatingGameSymbol(
                alignment: const Alignment(-0.75, 0.43),
                phase: 3.5,
                progress: _controller.value,
                icon: Icons.casino_rounded,
                color: const Color(0xFFFF6B6B),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      const Spacer(flex: 3),
                      Transform.scale(
                        scale: pulse,
                        child: Container(
                          width: 128,
                          height: 128,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(34),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.48),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF667EEA).withValues(
                                  alpha: 0.68,
                                ),
                                blurRadius: 34,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: Image.asset(
                              'assets/appicon.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Opacity(
                        opacity: (progress * 2).clamp(0.0, 1.0),
                        child: Text(
                          'GAME HUB',
                          style: GoogleFonts.fredoka(
                            fontSize: 35,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: const Color(0xFF8B7CFF).withValues(
                                  alpha: 0.82,
                                ),
                                blurRadius: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'FUN CHALLENGES',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 3.2,
                          color: const Color(0xFF9FE9FF),
                        ),
                      ),
                      const Spacer(flex: 3),
                      Text(
                        progress < 0.98 ? 'PREPARING YOUR GAME ROOM' : 'READY!',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: Colors.white.withValues(alpha: 0.68),
                        ),
                      ),
                      const SizedBox(height: 13),
                      Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.20),
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: progress,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF4ECDC4),
                                    Color(0xFF667EEA),
                                    Color(0xFFB66DFF),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF4ECDC4).withValues(
                                      alpha: 0.75,
                                    ),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${(progress * 100).round()}%',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                      const SizedBox(height: 42),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FloatingGameSymbol extends StatelessWidget {
  final Alignment alignment;
  final double phase;
  final double progress;
  final IconData icon;
  final Color color;

  const _FloatingGameSymbol({
    required this.alignment,
    required this.phase,
    required this.progress,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final drift = math.sin(progress * math.pi * 4 + phase) * 10;
    final rotation = math.sin(progress * math.pi * 2 + phase) * 0.18;
    return Align(
      alignment: alignment,
      child: Transform.translate(
        offset: Offset(0, drift),
        child: Transform.rotate(
          angle: rotation,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: color.withValues(alpha: 0.38)),
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 18),
              ],
            ),
            child: Icon(icon, color: color, size: 26),
          ),
        ),
      ),
    );
  }
}
