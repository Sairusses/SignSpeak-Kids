import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BubblyBackground extends StatelessWidget {
  final Widget child;
  const BubblyBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE0F7FA), Color(0xFFF1F8E9)],
            ),
          ),
        ),
        _buildPositionedBubble(-50, -50, 200, const Color(0xFFFFE082).withOpacity(0.3)),
        _buildPositionedBubble(100, -30, 80, const Color(0xFF80DEEA).withOpacity(0.4)),
        _buildPositionedBubble(null, 20, 120, const Color(0xFFF48FB1).withOpacity(0.2), bottom: 40),
        _buildPositionedBubble(null, null, 150, const Color(0xFFC5E1A5).withOpacity(0.3), bottom: -30, right: -20),
        child,
      ],
    );
  }

  Widget _buildPositionedBubble(double? top, double? left, double size, Color color, {double? bottom, double? right}) {
    return Positioned(
      top: top, left: left, bottom: bottom, right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

class AlphabetQuizMenuPage extends StatefulWidget {
  const AlphabetQuizMenuPage({super.key});

  @override
  State<AlphabetQuizMenuPage> createState() => _AlphabetQuizMenuPageState();
}

class _AlphabetQuizMenuPageState extends State<AlphabetQuizMenuPage> {
  final TextEditingController _nameController = TextEditingController();
  List<Map<String, dynamic>> _highScores = [];
  final user = Supabase.instance.client.auth.currentUser;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final displayName = user?.userMetadata?['display_name'] ?? "";
    _nameController.text = displayName;
    _fetchHighScores();
  }

  Future<void> _fetchHighScores() async {
    try {
      final List<Map<String, dynamic>> data = await Supabase.instance.client
          .from('alphabet_quiz')
          .select('uid, display_name, score')
          .order('score', ascending: false);

      final Map<String, Map<String, dynamic>> bestScores = {};
      for (final row in data) {
        final uid = row['uid'].toString();
        if (!bestScores.containsKey(uid)) {
          bestScores[uid] = row;
        }
      }

      if (mounted) {
        setState(() {
          _highScores = bestScores.values.take(5).toList();
          _loading = false;
        });
        print("highscore $_highScores");
      }
    } catch (e, stack) {
      print("Error fetching scores: $e");
      print(stack);
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BubblyBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                _buildCustomAppBar(context),
                const SizedBox(height: 20),
                _buildLeaderboard(),
                const SizedBox(height: 25),
                _buildNameInput(),
                const SizedBox(height: 20),
                _buildPlayButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Row(
      children: [
        _buildChunkyIconButton(Icons.arrow_back_rounded, Colors.orange, () => Navigator.pop(context)),
        const SizedBox(width: 15),
        Text(
          "HALL OF FAME",
          style: GoogleFonts.fredoka(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF2D3436)),
        ),
      ],
    );
  }

  Widget _buildLeaderboard() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFF4ECDC4), width: 5),
          boxShadow: const [BoxShadow(color: Color(0xFF4ECDC4), offset: Offset(0, 8))],
        ),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: _highScores.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final score = _highScores[index];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: index == 0 ? const Color(0xFFFFF9C4) : Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.black12),
              ),
              child: Row(
                children: [
                  Text("${index + 1}.", style: GoogleFonts.fredoka(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(score['display_name'] ?? 'Guest', style: GoogleFonts.fredoka(fontSize: 18))),
                  Text("${score['score']} pts", style: GoogleFonts.fredoka(fontSize: 18, color: Colors.redAccent, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNameInput() {
    return TextField(
      controller: _nameController,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: "What's your name?",
        prefixIcon: const Icon(Icons.face_rounded, color: Colors.orange),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Colors.orange, width: 3)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Colors.orange, width: 3)),
      ),
      style: GoogleFonts.fredoka(fontSize: 18),
    );
  }

  Widget _buildPlayButton() {
    return GestureDetector(
      onTap: () {
        if (_nameController.text.trim().isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AlphabetsQuiz(playerName: _nameController.text.trim())),
          ).then((_) => _fetchHighScores()); // Refresh leaderboard when back
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFFF6B6B),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Color(0xFFD32F2F), offset: Offset(0, 8))],
        ),
        child: Center(
          child: Text("START QUIZ!", style: GoogleFonts.fredoka(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildChunkyIconButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [BoxShadow(color: color.withOpacity(0.5), offset: const Offset(0, 4))],
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}

class AlphabetsQuiz extends StatefulWidget {
  final String playerName;
  const AlphabetsQuiz({super.key, required this.playerName});

  @override
  State<AlphabetsQuiz> createState() => _AlphabetsQuizState();
}

class _AlphabetsQuizState extends State<AlphabetsQuiz> with SingleTickerProviderStateMixin {
  final uid = Supabase.instance.client.auth.currentUser?.id;
  late List<String> _remainingLetters;
  final List<String> _allLetters = List.generate(26, (i) => String.fromCharCode(65 + i));

  String? _currentLetter;
  List<String> _currentOptions = [];
  int _score = 0;
  int _questionCount = 0;
  final int _totalQuestions = 26;
  List<Map<String, String>> _mistakesLog = []; // NEW: Tracking mistakes

  bool _isTransitioning = false;
  bool? _isCorrect;
  String _selectedLetter = "";

  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _remainingLetters = List.from(_allLetters)..shuffle();
    _bounceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
    _bounceAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut));
    _loadNextQuestion();
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _loadNextQuestion() {
    if (_questionCount >= _totalQuestions) {
      _finishGame();
      return;
    }
    setState(() {
      _isTransitioning = false;
      _isCorrect = null;
      _selectedLetter = "";
      _currentLetter = _remainingLetters.removeLast();
      _questionCount++;
      List<String> choices = [_currentLetter!];
      while (choices.length < 4) {
        String random = _allLetters[Random().nextInt(26)];
        if (!choices.contains(random)) choices.add(random);
      }
      choices.shuffle();
      _currentOptions = choices;
    });
  }

  void _handleAnswer(String letter) {
    if (_isCorrect != null) return;
    bool correct = (letter == _currentLetter);

    setState(() {
      _selectedLetter = letter;
      _isCorrect = correct;
      if (correct) {
        _score++;
      } else {
        // Track the mistake for Supabase
        _mistakesLog.add({
          "expected": _currentLetter!,
          "picked": letter,
        });
      }
      _isTransitioning = true;
    });
    Future.delayed(const Duration(milliseconds: 1500), () => _loadNextQuestion());
  }

  Future<void> _finishGame() async {
    try {
      await Supabase.instance.client.from('alphabet_quiz').insert({
        'display_name': widget.playerName,
        'score': _score,
        'mistakes': _mistakesLog,
        'uid': uid,
      });
    } catch (e) {
      debugPrint("Supabase Save Error: $e");
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        backgroundColor: const Color(0xFFE3FDF5),
        title: Center(child: Text("GREAT JOB! 🎉", style: GoogleFonts.fredoka(fontSize: 32, fontWeight: FontWeight.bold))),
        content: Text("You got $_score / $_totalQuestions stars!", textAlign: TextAlign.center, style: GoogleFonts.fredoka(fontSize: 22)),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10)),
              onPressed: () { Navigator.pop(context); Navigator.pop(context); },
              child: Text("OK!", style: GoogleFonts.fredoka(color: Colors.white, fontSize: 20)),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BubblyBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildProgressBar(),
              const SizedBox(height: 20),
              Expanded(
                child: _isTransitioning ? _buildBouncyLoader(_isCorrect!) : _buildFlashcard(),
              ),
              const SizedBox(height: 20),
              _buildOptionsGrid(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: const Icon(Icons.close_rounded, size: 35), onPressed: () => Navigator.pop(context)),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Colors.orange, size: 35),
              const SizedBox(width: 8),
              Text("$_score", style: GoogleFonts.fredoka(fontSize: 28, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Stack(
        children: [
          Container(height: 15, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(10))),
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            height: 15,
            width: (MediaQuery.of(context).size.width - 80) * (_questionCount / _totalQuestions),
            decoration: BoxDecoration(color: const Color(0xFF4ECDC4), borderRadius: BorderRadius.circular(10)),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF4ECDC4), width: 8),
        boxShadow: const [BoxShadow(color: Color(0xFFB2DFDB), offset: Offset(0, 15))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Image.asset(
          "assets/alphabet/${_currentLetter!.toLowerCase()}.jpeg",
          fit: BoxFit.contain,
          errorBuilder: (c, e, s) => const Icon(Icons.abc, size: 100, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildOptionsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 20, mainAxisSpacing: 20, childAspectRatio: 1.5,
        ),
        itemCount: 4,
        itemBuilder: (context, index) {
          final letter = _currentOptions[index];
          Color btnColor = Colors.white;
          if (_isCorrect != null) {
            if (letter == _currentLetter) btnColor = const Color(0xFF00E676);
            else if (letter == _selectedLetter) btnColor = const Color(0xFFFF1744);
          }

          return GestureDetector(
            onTap: () => _handleAnswer(letter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: btnColor,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [BoxShadow(color: btnColor == Colors.white ? Colors.black12 : btnColor.withOpacity(0.5), offset: const Offset(0, 8))],
                border: Border.all(color: Colors.black.withOpacity(0.05), width: 2),
              ),
              child: Center(
                child: Text(letter, style: GoogleFonts.fredoka(fontSize: 48, fontWeight: FontWeight.bold)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBouncyLoader(bool isCorrect) {
    return FadeTransition(
      opacity: _bounceAnimation,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCorrect ? Icons.celebration : Icons.sentiment_dissatisfied_rounded,
              color: isCorrect ? Colors.greenAccent : Colors.redAccent,
              size: 100,
            ),
            const SizedBox(height: 10),
            Text(
              isCorrect ? "AWESOME!" : "NEXT TIME!",
              style: GoogleFonts.fredoka(fontSize: 32, color: isCorrect ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}