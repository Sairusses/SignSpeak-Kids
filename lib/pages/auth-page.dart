import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signspeak/home.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _confirmEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSigningUp = false;
  bool _isLoading = false;
  ThemeMode _themeMode = ThemeMode.light;

  Future<void> _toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  Future<void> _handleAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (_isSigningUp) {
      if (email != _confirmEmailController.text.trim()) {
        _showError("Emails don't match! 📧");
        return;
      }
      if (password != _confirmPasswordController.text.trim()) {
        _showError("Passwords don't match! 🔑");
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      if (_isSigningUp) {
        await Supabase.instance.client.auth.signUp(email: email, password: password);
        _showSuccess("Yay! Welcome to SignSpeak!");
      } else {
        await Supabase.instance.client.auth.signInWithPassword(email: email, password: password);
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Home(
              onThemeChanged: _toggleTheme,
              themeMode: _themeMode,
            ),
          ),
        );
      }
    } catch (e) {
      _showError("Oh no! Something went wrong.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.greenAccent[700], behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const PlayfulBackground(),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  Hero(
                    tag: 'logo',
                    child: Image.asset('assets/logo.png', height: 130),
                  ),
                  Text(
                    'SignSpeak',
                    style: GoogleFonts.fredoka(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 30),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOutBack,
                    child: Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildTextField(_emailController, "Your Email", Icons.mail_rounded, false),
                          if (_isSigningUp) ...[
                            const SizedBox(height: 15),
                            _buildTextField(_confirmEmailController, "Confirm Email", Icons.mail_outline, false),
                          ],
                          const SizedBox(height: 15),
                          _buildTextField(_passwordController, "Password", Icons.key_rounded, true),
                          if (_isSigningUp) ...[
                            const SizedBox(height: 15),
                            _buildTextField(_confirmPasswordController, "Confirm Password", Icons.lock_reset_rounded, true),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 65,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleAuth,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFB74D),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 8,
                        shadowColor: Colors.orangeAccent,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _isSigningUp ? "JOIN THE FUN!" : "GO INSIDE!",
                          key: ValueKey<bool>(_isSigningUp),
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => setState(() => _isSigningUp = !_isSigningUp),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _isSigningUp ? "Already a member? Sign In" : "New friend? Create an account",
                        key: ValueKey<bool>(_isSigningUp),
                        style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, bool isPassword) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.purpleAccent),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.purple[50]?.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class PlayfulBackground extends StatefulWidget {
  const PlayfulBackground({super.key});

  @override
  State<PlayfulBackground> createState() => _PlayfulBackgroundState();
}

class _PlayfulBackgroundState extends State<PlayfulBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE1F5FE), Color(0xFFF3E5F5)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              _buildBubble(100, -20 + (20 * _controller.value), -20, Colors.yellow[200]!),
              _buildBubble(150, null, -50 + (30 * _controller.value), Colors.pink[100]!, right: -30),
              _buildBubble(80, 200 - (40 * _controller.value), -40, Colors.green[100]!, left: -20),
              _buildBubble(120, null, 100 + (50 * _controller.value), Colors.blue[100]!, right: -40),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBubble(double size, double? top, double? bottom, Color color, {double? left, double? right}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withOpacity(0.4),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}