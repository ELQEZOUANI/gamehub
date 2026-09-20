import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  static final Uri _appStoreUrl = Uri.parse(
    'https://apps.apple.com/app/id6814179629',
  );

  late AnimationController _heroController;
  late AnimationController _floatController;
  late Animation<double> _heroAnimation;
  late Animation<double> _floatAnimation;
  late List<Animation<double>> _staggeredAnimations;

  @override
  void initState() {
    super.initState();
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _heroAnimation = CurvedAnimation(
      parent: _heroController,
      curve: Curves.easeOutBack,
    );

    _floatAnimation = CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    );

    _staggeredAnimations = List.generate(
      3,
      (index) => CurvedAnimation(
        parent: _heroController,
        curve: Interval(
          index * 0.2,
          0.5 + index * 0.2,
          curve: Curves.easeOutBack,
        ),
      ),
    );

    _heroController.forward();
  }

  @override
  void dispose() {
    _heroController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _shareApp() async {
    final renderBox = context.findRenderObject() as RenderBox?;
    try {
      await SharePlus.instance.share(
        ShareParams(
          title: 'Game Hub: Fun Challenges',
          subject: 'Try Game Hub: Fun Challenges',
          text: 'Try Game Hub: Fun Challenges! 🎮\n$_appStoreUrl',
          sharePositionOrigin: renderBox == null
              ? null
              : renderBox.localToGlobal(Offset.zero) & renderBox.size,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not open sharing. Please try again.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: const Color(0xFFFF6B6B),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openPrivacyPolicy() async {
    final policyUrl = Uri(
      scheme: 'https',
      host: 'gamehub1x.blogspot.com',
      path: '/2026/09/blog-post.html',
    );
    final opened = await launchUrl(
      policyUrl,
      mode: LaunchMode.externalApplication,
    );
    if (!mounted || opened) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Could not open the Privacy Policy. Please try again.',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: const Color(0xFFFF6B6B),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _openAppStore() async {
    final opened = await launchUrl(
      _appStoreUrl,
      mode: LaunchMode.externalApplication,
    );
    if (!mounted || opened) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Could not open the App Store. Please try again.',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: const Color(0xFFFF6B6B),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _rateApp() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.star,
                color: Color(0xFFFF6B6B),
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                'Rate Game Hub',
                style: GoogleFonts.fredoka(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          content: Text(
            'Enjoying Game Hub? Your rating and feedback help us improve and reach more gamers. Rate us on the App Store!',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Maybe Later',
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _openAppStore();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Rate Now',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated Gradient Background
          AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(
                      -1 + _floatAnimation.value * 0.3,
                      -1 + _floatAnimation.value * 0.2,
                    ),
                    end: Alignment(
                      1 - _floatAnimation.value * 0.3,
                      1 - _floatAnimation.value * 0.2,
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
            animation: _floatAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    top: 100 + _floatAnimation.value * 20,
                    right: -50,
                    child: Transform.rotate(
                      angle: _floatAnimation.value * 0.1,
                      child: Container(
                        width: 150,
                        height: 150,
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
                  Positioned(
                    bottom: 150 - _floatAnimation.value * 15,
                    left: -80,
                    child: Transform.rotate(
                      angle: -_floatAnimation.value * 0.15,
                      child: Container(
                        width: 200,
                        height: 200,
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

          // Settings Content
          SafeArea(
            child: Column(
              children: [
                // Header with scale animation
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: ScaleTransition(
                    scale: _heroAnimation,
                    child: Column(
                      children: [
                        Text(
                          'Settings',
                          style: GoogleFonts.fredoka(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '⚙️ Support & Feedback 💬',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Action Buttons
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Share App Button with floating animation
                      AnimatedBuilder(
                        animation: _floatAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _floatAnimation.value * 8 - 4),
                            child: ScaleTransition(
                              scale: _staggeredAnimations[0],
                              child: _ActionButton(
                                icon: Icons.share,
                                title: 'Share App',
                                subtitle: 'Tell your friends about Game Hub',
                                color: const Color(0xFF4ECDC4),
                                onTap: _shareApp,
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      // Privacy Policy Button with floating animation
                      AnimatedBuilder(
                        animation: _floatAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, -_floatAnimation.value * 6 + 3),
                            child: ScaleTransition(
                              scale: _staggeredAnimations[1],
                              child: _ActionButton(
                                icon: Icons.privacy_tip_outlined,
                                title: 'Privacy Policy',
                                subtitle: 'Learn how we protect your data',
                                color: const Color(0xFFFFE66D),
                                onTap: _openPrivacyPolicy,
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      // Rate Us Button with floating animation
                      AnimatedBuilder(
                        animation: _floatAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _floatAnimation.value * 7 - 3.5),
                            child: ScaleTransition(
                              scale: _staggeredAnimations[2],
                              child: _ActionButton(
                                icon: Icons.star_outline,
                                title: 'Rate Us',
                                subtitle: 'Help us improve with your feedback',
                                color: const Color(0xFFFF6B6B),
                                onTap: _rateApp,
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withValues(alpha: 0.8),
                        color,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.fredoka(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withValues(alpha: 0.4),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
