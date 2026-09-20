// lib/app_shell.dart

import 'dart:math' as math;
import 'dart:math';
import 'package:flutter/material.dart';
import 'screens/all_games_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> 
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  
  late AnimationController _backgroundController; // Unified controller for all background animations
  late AnimationController _tabController;
  
  late Animation<double> _tabAnimation;
  
  Key _profileRebuildKey = UniqueKey();

  final List<TabData> _tabs = [
    TabData(
      icon: Icons.rocket_launch_rounded,
      label: 'Home',
      color: const Color(0xFF667EEA),
      gradient: const LinearGradient(
        colors: [Color(0xFF667EEA), Color(0xFF764BA2), Color(0xFF9C27B0)],
      ),
      particles: const Color(0xFF9C27B0),
    ),
    TabData(
      icon: Icons.games_rounded,
      label: 'Games',
      color: const Color(0xFF4ECDC4),
      gradient: const LinearGradient(
        colors: [Color(0xFF4ECDC4), Color(0xFF44A08D), Color(0xFF00BCD4)],
      ),
      particles: const Color(0xFF00BCD4),
    ),
    TabData(
      icon: Icons.person_rounded,
      label: 'Profile',
      color: const Color(0xFFFF6B6B),
      gradient: const LinearGradient(
        colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53), Color(0xFFE91E63)],
      ),
      particles: const Color(0xFFE91E63),
    ),
    TabData(
      icon: Icons.settings_rounded,
      label: 'Settings',
      color: const Color(0xFFFFE66D),
      gradient: const LinearGradient(
        colors: [Color(0xFFFFE66D), Color(0xFFFFA502), Color(0xFFFF9800)],
      ),
      particles: const Color(0xFFFF9800),
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    );
    
    _tabController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Initialize animations
    _tabAnimation = CurvedAnimation(
      parent: _tabController,
      curve: Curves.elasticOut,
    );
    
    // Start animations
    _backgroundController.repeat();
    _tabController.forward();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        // Force ProfileScreen to rebuild and reload when selected
        if (index == 2) {
          _profileRebuildKey = UniqueKey();
        }
        _selectedIndex = index;
      });
      
      // Simple bounce animation for tab selection
      _tabController.reset();
      _tabController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Deep Space Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 2.0,
                  colors: [
                    Color(0xFF0A0A0A), // Deep black
                    Color(0xFF1A1A2E), // Dark purple
                    Color(0xFF16213E), // Dark blue
                    Color(0xFF0F1419), // Almost black
                  ],
                ),
              ),
            ),
          ),
          
          // Deep Space Background, animated with a single controller
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
                        painter: PlanetsPainter(_backgroundController.value),
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
          
          // Main Content with proper navigation
          IndexedStack(
            index: _selectedIndex,
            children: [
              const HomeScreen(),
              const AllGamesScreen(),
              ProfileScreen(key: _profileRebuildKey),
              const SettingsScreen(),
            ].map((widget) {
              return Navigator(
                onGenerateRoute: (settings) {
                  return MaterialPageRoute(
                    builder: (context) => widget,
                    settings: settings,
                  );
                },
              );
            }).toList(),
          ),
        ],
      ),
      
      // Cosmic Floating Navigation
      floatingActionButton: _buildCosmicNavigation(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildCosmicNavigation() {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      child: AnimatedBuilder(
        animation: _tabAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: 0.8 + (_tabAnimation.value * 0.2), // Scale from 0.8 to 1.0
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer Glow Ring
                Container(
                  width: 280,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(
                        color: _tabs[_selectedIndex].color.withValues(alpha: 0.6),
                        blurRadius: 40,
                        spreadRadius: 15,
                      ),
                    ],
                  ),
                ),
                
                // Main Navigation Container
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.black.withValues(alpha: 0.4),
                        Colors.black.withValues(alpha: 0.2),
                        Colors.black.withValues(alpha: 0.4),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(35),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 25,
                        spreadRadius: 5,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: _tabs.asMap().entries.map((entry) {
                      final index = entry.key;
                      final tab = entry.value;
                      final isSelected = index == _selectedIndex;
                      
                      return _buildCosmicTab(tab, index, isSelected);
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCosmicTab(TabData tab, int index, bool isSelected) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Particle Effect
          if (isSelected)
            AnimatedBuilder(
              animation: _tabAnimation, // Use tab animation for particles
              builder: (context, child) {
                return CustomPaint(
                  painter: ParticlePainter(
                    _tabAnimation.value,
                    tab.particles,
                  ),
                  size: const Size(60, 60),
                );
              },
            ),
          
          // Tab Container
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: EdgeInsets.symmetric(
              horizontal: isSelected ? 20 : 16,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              gradient: isSelected ? tab.gradient : null,
              color: isSelected ? null : Colors.transparent,
              borderRadius: BorderRadius.circular(30),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: tab.color.withValues(alpha: 0.5),
                  blurRadius: 20,
                  spreadRadius: 3,
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.2),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, -2),
                ),
              ] : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon with glow
                Container(
                  decoration: isSelected ? BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.8),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ) : null,
                  child: Icon(
                    tab.icon,
                    color: Colors.white,
                    size: isSelected ? 26 : 22,
                  ),
                ),
                
                // Label with animation
                if (isSelected) ...[
                  const SizedBox(width: 10),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 400),
                    opacity: isSelected ? 1.0 : 0.0,
                    child: Text(
                      tab.label,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        shadows: [
                          Shadow(
                            color: Colors.white.withValues(alpha: 0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TabData {
  final IconData icon;
  final String label;
  final Color color;
  final Gradient gradient;
  final Color particles;

  TabData({
    required this.icon,
    required this.label,
    required this.color,
    required this.gradient,
    required this.particles,
  });
}

// Galaxy Spiral Painter
class GalaxyPainter extends CustomPainter {
  final double animation;

  GalaxyPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw galaxy spiral arms
    for (int arm = 0; arm < 4; arm++) {
      final armAngle = (arm * math.pi / 2) + (animation * 2 * math.pi * 0.1);
      
      for (double t = 0; t < 6; t += 0.1) {
        final angle = armAngle + t;
        final radius = t * 30 + 50;
        final x = center.dx + radius * math.cos(angle);
        final y = center.dy + radius * math.sin(angle);
        
        if (x >= 0 && x <= size.width && y >= 0 && y <= size.height) {
          final opacity = (1 - t / 6) * 0.3;
          paint.color = Color.lerp(
            const Color(0xFF667EEA),
            const Color(0xFF764BA2),
            t / 6,
          )!.withValues(alpha: opacity);
          
          canvas.drawCircle(Offset(x, y), (6 - t) * 0.5, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(GalaxyPainter oldDelegate) => oldDelegate.animation != animation;
}

// Nebula Clouds Painter
class NebulaPainter extends CustomPainter {
  final double animation;

  NebulaPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    
    // Draw colorful nebula clouds
    final colors = [
      const Color(0xFF9C27B0).withValues(alpha: 0.1),
      const Color(0xFF673AB7).withValues(alpha: 0.1),
      const Color(0xFF3F51B5).withValues(alpha: 0.1),
      const Color(0xFF2196F3).withValues(alpha: 0.1),
    ];
    
    for (int i = 0; i < colors.length; i++) {
      final offset = animation * 2 * math.pi + i * math.pi / 2;
      final x = size.width / 2 + math.sin(offset) * size.width * 0.3;
      final y = size.height / 2 + math.cos(offset) * size.height * 0.2;
      
      paint.color = colors[i];
      canvas.drawCircle(Offset(x, y), 80 + math.sin(animation * 2 * math.pi + i) * 20, paint);
    }
  }

  @override
  bool shouldRepaint(NebulaPainter oldDelegate) => oldDelegate.animation != animation;
}

// Floating Planets Painter
class PlanetsPainter extends CustomPainter {
  final double animation;

  PlanetsPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    
    // Draw planets
    final planets = [
      {'color': const Color(0xFFFF6B6B), 'size': 15.0, 'speed': 1.0},
      {'color': const Color(0xFF4ECDC4), 'size': 12.0, 'speed': 1.5},
      {'color': const Color(0xFFFFE66D), 'size': 18.0, 'speed': 0.8},
      {'color': const Color(0xFF667EEA), 'size': 10.0, 'speed': 2.0},
    ];
    
    for (int i = 0; i < planets.length; i++) {
      final planet = planets[i];
      final speed = planet['speed'] as double;
      final planetSize = planet['size'] as double;
      final color = planet['color'] as Color;
      
      final angle = animation * 2 * math.pi * speed + i * math.pi / 2;
      final radius = 100 + i * 50;
      final x = size.width / 2 + radius * math.cos(angle);
      final y = size.height / 2 + radius * math.sin(angle);
      
      // Planet shadow
      paint.color = Colors.black.withValues(alpha: 0.3);
      canvas.drawCircle(Offset(x + 2, y + 2), planetSize, paint);
      
      // Planet body
      paint.color = color;
      canvas.drawCircle(Offset(x, y), planetSize, paint);
      
      // Planet highlight
      paint.color = Colors.white.withValues(alpha: 0.4);
      canvas.drawCircle(Offset(x - planetSize * 0.3, y - planetSize * 0.3), planetSize * 0.3, paint);
    }
  }

  @override
  bool shouldRepaint(PlanetsPainter oldDelegate) => oldDelegate.animation != animation;
}

// Enhanced Stars Painter
class StarsPainter extends CustomPainter {
  final double animation;
  final Random random = Random(42);

  StarsPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    
    // Draw twinkling stars
    for (int i = 0; i < 150; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      
      final twinkle = (math.sin(animation * 2 * math.pi + i * 0.1) + 1) / 2;
      final starSize = random.nextDouble() * 2 + 0.5;
      
      paint.color = Colors.white.withValues(alpha: twinkle * 0.9);
      
      // Main star
      canvas.drawCircle(Offset(x, y), starSize, paint);
      
      // Cross sparkle for bigger stars
      if (starSize > 1.5) {
        paint.strokeWidth = 0.5;
        canvas.drawLine(
          Offset(x - starSize * 2, y),
          Offset(x + starSize * 2, y),
          paint,
        );
        canvas.drawLine(
          Offset(x, y - starSize * 2),
          Offset(x, y + starSize * 2),
          paint,
        );
      }
    }
    
    // Draw shooting stars
    for (int i = 0; i < 3; i++) {
      final progress = (animation + i * 0.3) % 1.0;
      if (progress > 0.1 && progress < 0.9) {
        const startX = -100.0;
        final endX = size.width + 100;
        final currentX = startX + (endX - startX) * progress;
        final y = (i + 1) * size.height / 4;
        
        final gradient = LinearGradient(
          colors: [
            Colors.transparent,
            Colors.white.withValues(alpha: 0.9),
            const Color(0xFF667EEA).withValues(alpha: 0.8),
            Colors.transparent,
          ],
        );
        
        final rect = Rect.fromLTWH(currentX - 60, y - 1.5, 120, 3);
        paint.shader = gradient.createShader(rect);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(1.5)),
          paint,
        );
        paint.shader = null;
      }
    }
  }

  @override
  bool shouldRepaint(StarsPainter oldDelegate) => oldDelegate.animation != animation;
}

// Particle Effect Painter
class ParticlePainter extends CustomPainter {
  final double animation;
  final Color color;

  ParticlePainter(this.animation, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final center = Offset(size.width / 2, size.height / 2);
    
    for (int i = 0; i < 12; i++) {
      final angle = (i / 12) * 2 * math.pi + animation * 2 * math.pi;
      final radius = 25 + math.sin(animation * 4 * math.pi + i) * 5;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      
      final opacity = (math.sin(animation * 3 * math.pi + i) + 1) / 2 * 0.6;
      paint.color = color.withValues(alpha: opacity);
      
      canvas.drawCircle(Offset(x, y), 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => 
    oldDelegate.animation != animation || oldDelegate.color != color;
}

class AnimatedGalaxyBackground extends StatelessWidget {
  final AnimationController controller;

  const AnimatedGalaxyBackground({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          painter: NebulaPainter(controller.value),
          child: CustomPaint(
            painter: GalaxyPainter(controller.value),
            child: CustomPaint(
              painter: StarsPainter(controller.value),
            ),
          ),
        );
      },
    );
  }
}