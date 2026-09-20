import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_shell.dart';
import '../services/ad_setup_service.dart';
import '../services/stats_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentPage = 0;
  final List<OnboardingPage> _pages = [
    const OnboardingPage(
      title: "Welcome to Game Hub",
      subtitle: "Your Ultimate Gaming Destination",
      description:
          "Discover a world of exciting games, challenges, and endless fun. Get ready to embark on an amazing gaming journey!",
      icon: "🎮",
      gradient: [Color(0xFF667eea), Color(0xFF764ba2)],
    ),
    const OnboardingPage(
      title: "Multiple Games",
      subtitle: "Endless Entertainment",
      description:
          "From classic puzzles to brain teasers, from quick reactions to strategic challenges. There's something for everyone!",
      icon: "🎯",
      gradient: [Color(0xFFf093fb), Color(0xFFf5576c)],
    ),
    const OnboardingPage(
      title: "Track Progress",
      subtitle: "Monitor Your Achievements",
      description:
          "Keep track of your best scores, unlock new levels, and challenge yourself to beat your own records!",
      icon: "🏆",
      gradient: [Color(0xFF4facfe), Color(0xFF00f2fe)],
    ),
    const OnboardingPage(
      title: "Daily Challenges",
      subtitle: "Fresh Content Every Day",
      description:
          "New challenges await you every day. Stay engaged with rotating games and special events!",
      icon: "🌟",
      gradient: [Color(0xFF43e97b), Color(0xFF38f9d7)],
    ),
    const OnboardingPage(
      title: "Ready to Start?",
      subtitle: "Let's Begin Your Journey",
      description:
          "Enter your name below and start exploring the amazing world of games we've prepared for you!",
      icon: "🚀",
      gradient: [Color(0xFFfa709a), Color(0xFFfee140)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _showNameInputDialog() {
    final TextEditingController nameController = TextEditingController();
    final screenSize = MediaQuery.of(context).size;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          content: Container(
            width: screenSize.width * 0.8,
            height: screenSize.height * 0.35,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF667eea),
                  Color(0xFF764ba2),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Header Icon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.cyan, Colors.blue],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_add,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Title
                  Text(
                    "What's Your Name?",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // Description
                  Text(
                    "Enter your name to personalize your gaming experience",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Name Input Field
                  Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: TextFormField(
                      controller: nameController,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: "Enter your name",
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Start Button
                  Container(
                    width: double.infinity,
                    height: 45,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.cyan, Colors.blue],
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyan.withValues(alpha: 0.4),
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => _saveName(nameController.text),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        "Start Gaming!",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _saveName(String name) async {
    if (name.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your name"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Save name to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await StatsService().setUserName(name.trim());
    await prefs.setBool('hasCompletedOnboarding', true);
    if (!mounted) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          content: Container(
            width: MediaQuery.of(context).size.width * 0.7,
            height: MediaQuery.of(context).size.height * 0.3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF667eea),
                  Color(0xFF764ba2),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Preparing Your Gaming Experience...",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    // Wait for 6 seconds then navigate
    Future.delayed(const Duration(seconds: 6), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AppShell()),
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AdSetupService.initializeAfterConsent();
      });
    });
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
              Color(0xFF0f0c29),
              Color(0xFF302b63),
              Color(0xFF24243e),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Page View
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: page.gradient,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      page.gradient[0].withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                page.icon,
                                style: const TextStyle(fontSize: 60),
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Title
                          Text(
                            page.title,
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 16),

                          // Subtitle
                          Text(
                            page.subtitle,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Colors.white.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 24),

                          // Description
                          Text(
                            page.description,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white.withValues(alpha: 0.7),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom Section
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    // Page Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Start Button or Swipe Instructions
                    if (_currentPage == _pages.length - 1)
                      // Start Button on last page
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFfa709a), Color(0xFFfee140)],
                          ),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFfa709a)
                                  .withValues(alpha: 0.5),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _showNameInputDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.rocket_launch,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "Start Gaming!",
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      // Swipe Instructions for other pages
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.keyboard_arrow_left,
                            color: Colors.cyan,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Swipe to Next Page",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.keyboard_arrow_right,
                            color: Colors.cyan,
                            size: 18,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final String icon;
  final List<Color> gradient;

  const OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.gradient,
  });
}
