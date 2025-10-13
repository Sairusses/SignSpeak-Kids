import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Ensure these imports point to your actual files
import 'package:signspeak/pages/auth-page.dart';
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
          _buildAnimatedBackground(),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 40), // Added extra space before logout
                    _buildLogoutButton(context),
                    const SizedBox(height: 20), // Bottom padding for scrolling
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // FIXED: Renamed and removed 'Positioned' wrapper
  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity, // Ensures it stretches full width
      child: ElevatedButton(
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            barrierDismissible: true,
            builder: (context) {
              bool allowLogout = false;

              return Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFF3C4), Color(0xFFFFE0F0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header
                          Row(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFFFA69E), Color(0xFFFFD6A5)],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orange.withOpacity(0.25),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text('👋', style: TextStyle(fontSize: 32)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'See you soon!',
                                      style: GoogleFonts.fredoka(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Do you want to log out now?',
                                      style: GoogleFonts.fredoka(
                                        fontSize: 14,
                                        color: Colors.deepPurple.withOpacity(0.85),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Switch Row
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle_outline, color: Colors.green),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'I\'m ready to log out',
                                          style: GoogleFonts.fredoka(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      Switch(
                                        value: allowLogout,
                                        activeColor: Colors.green,
                                        activeTrackColor: Colors.greenAccent.withOpacity(0.4),
                                        onChanged: (v) {
                                          setState(() {
                                            allowLogout = v;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          // Actions
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  icon: const Icon(Icons.close, color: Colors.deepPurple),
                                  label: Text('Cancel', style: GoogleFonts.fredoka(color: Colors.deepPurple)),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    side: BorderSide(color: Colors.deepPurple.withOpacity(0.12)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: allowLogout
                                      ? () => Navigator.of(context).pop(true)
                                      : null,
                                  icon: const Icon(Icons.logout, color: Colors.white),
                                  label: Text('Log Out', style: GoogleFonts.fredoka(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: allowLogout ? Colors.redAccent : Colors.redAccent.withOpacity(0.5),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    elevation: allowLogout ? 8 : 0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );

          if (confirmed == true) {
            await Supabase.instance.client.auth.signOut();
            if (context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const AuthPage()),
                    (Route<dynamic> route) => false,
              );
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 8,
          shadowColor: Colors.red.withOpacity(0.6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, color: Colors.white),
            const SizedBox(width: 12),
            Text('Log Out', style: GoogleFonts.fredoka(fontSize: 18, color: Colors.white)),
          ],
        ),
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