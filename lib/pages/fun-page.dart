import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'alphabets-quiz.dart';
import 'awareness-page.dart';
import 'category-quiz-page.dart';

class FunPage extends StatelessWidget {
  const FunPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Bubbly Background Layer
          _buildAnimatedBackground(),

          // 2. Main Content Layer
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    _buildKidButton(
                      context,
                      navigateTo: const AlphabetQuizMenuPage(),
                      title: "Alphabets Quiz",
                      subtitle: "Learn your ABCs!",
                      icon: Icons.abc_rounded,
                      primaryColor: const Color(0xFF4EA8DE),
                      shadowColor: const Color(0xFF5390D9),
                    ),
                    const SizedBox(height: 25),
                    _buildKidButton(
                      context,
                      navigateTo: CategoryQuizPage(),
                      title: "Category Quizzes",
                      subtitle: "Greetings, Feelings & More!",
                      icon: Icons.extension_rounded,
                      primaryColor: const Color(0xFFFF9F1C),
                      shadowColor: const Color(0xFFE76F51),
                    ),
                    const SizedBox(height: 25),
                    _buildKidButton(
                      context,
                      navigateTo: const AwarenessPage(),
                      title: "Learn More",
                      subtitle: "Discover Sign Language",
                      icon: Icons.lightbulb_rounded,
                      primaryColor: const Color(0xFF72EFDD),
                      shadowColor: const Color(0xFF48BFE3),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildAnimatedBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF0F7FF), Color(0xFFE0E7FF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          _buildBubble(top: -50, left: -50, size: 200, color: Colors.blue.withOpacity(0.1)),
          _buildBubble(bottom: 100, right: -30, size: 150, color: Colors.pink.withOpacity(0.1)),
          _buildBubble(top: 250, left: -20, size: 80, color: Colors.yellow.withOpacity(0.15)),
          _buildBubble(bottom: -20, left: 40, size: 120, color: Colors.green.withOpacity(0.1)),
        ],
      ),
    );
  }

  Widget _buildBubble({double? top, double? bottom, double? left, double? right, required double size, required Color color}) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  // Improved UI Button with a "Chunky" Kid-Friendly Look
  Widget _buildKidButton(
      BuildContext context, {
        required Widget navigateTo,
        required String title,
        required String subtitle,
        required IconData icon,
        required Color primaryColor,
        required Color shadowColor,
      }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => navigateTo));
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: [
            // This second shadow creates the "3D" chunky effect
            BoxShadow(
              color: shadowColor,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 40),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.fredoka(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.fredoka(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }
}