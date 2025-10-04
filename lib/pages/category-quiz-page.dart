import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';

// -----------------------------------------------------------------------------
// 1. SHARED WIDGETS & CONSTANTS
// -----------------------------------------------------------------------------

// A playful background painter to make things "Bubbly"
class BubblyBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = Random(42); // Fixed seed for consistent bubbles

    // Base background color
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = const Color(0xFFE0F7FA) // Light Cyan
    );

    for (int i = 0; i < 15; i++) {
      paint.color = Colors.primaries[random.nextInt(Colors.primaries.length)]
          .withOpacity(0.15);
      double radius = random.nextDouble() * 80 + 20;
      double dx = random.nextDouble() * size.width;
      double dy = random.nextDouble() * size.height;
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BubblyScaffold extends StatelessWidget {
  final Widget child;
  final Widget? bottomNavigationBar;

  const BubblyScaffold(
      {super.key, required this.child, this.bottomNavigationBar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent, // Important for the painter
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: BubblyBackgroundPainter()),
          ),
          SafeArea(child: child),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

// -----------------------------------------------------------------------------
// 2. DATA CONFIGURATION
// -----------------------------------------------------------------------------

final List<Map<String, dynamic>> categoriesData = [
  {"name": "greetings", "icon": Icons.waving_hand_outlined, "color": Colors.orange},
  {"name": "questions", "icon": Icons.question_answer_outlined, "color": Colors.blue},
  {"name": "common_phrases", "icon": Icons.chat_bubble_outline, "color": Colors.purple},
  {"name": "actions", "icon": Icons.run_circle_outlined, "color": Colors.red},
  {"name": "objects", "icon": Icons.category_outlined, "color": Colors.teal},
  {"name": "feelings", "icon": Icons.favorite_border, "color": Colors.pink},
  {"name": "time", "icon": Icons.access_time, "color": Colors.indigo},
  {"name": "people", "icon": Icons.people_outline, "color": Colors.green},
  {"name": "places", "icon": Icons.place_outlined, "color": Colors.brown},
  {"name": "numbers", "icon": Icons.pin_outlined, "color": Colors.amber},
  {"name": "colors", "icon": Icons.palette_outlined, "color": Colors.cyan},
  {"name": "directions", "icon": Icons.directions_outlined, "color": Colors.deepOrange},
];

// -----------------------------------------------------------------------------
// 3. PAGE 1: CATEGORY SELECTION
// -----------------------------------------------------------------------------

class CategoryQuizPage extends StatelessWidget {
  const CategoryQuizPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BubblyScaffold(
      child: Column(
        children: [
          // Custom Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.orange),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Pick a Category!',
                  style: GoogleFonts.fredoka(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4A4A4A),
                  ),
                ),
              ],
            ),
          ),

          // Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: categoriesData.length,
              itemBuilder: (context, index) {
                final cat = categoriesData[index];
                return _CategoryCard(
                  name: cat['name'],
                  icon: cat['icon'],
                  color: cat['color'],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryIntroPage(
                          categoryName: cat['name'],
                          categoryColor: cat['color'],
                          categoryIcon: cat['icon'],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.name,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Formatting category name (e.g., "common_phrases" -> "Common Phrases")
    final displayLabel = name.split('_').map((word) {
      if (word.isEmpty) return "";
      return "${word[0].toUpperCase()}${word.substring(1)}";
    }).join(' ');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
          border: Border.all(color: color.withOpacity(0.2), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              displayLabel,
              textAlign: TextAlign.center,
              style: GoogleFonts.fredoka(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 4. PAGE 2: HIGH SCORE & INTRO
// -----------------------------------------------------------------------------

class CategoryIntroPage extends StatefulWidget {
  final String categoryName;
  final Color categoryColor;
  final IconData categoryIcon;

  const CategoryIntroPage({
    super.key,
    required this.categoryName,
    required this.categoryColor,
    required this.categoryIcon,
  });

  @override
  State<CategoryIntroPage> createState() => _CategoryIntroPageState();
}

class _CategoryIntroPageState extends State<CategoryIntroPage> {
  int highScore = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHighScore();
  }

  Future<void> _fetchHighScore() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user != null) {
      try {
        final response = await supabase
            .from('categories_quiz')
            .select('score')
            .eq('user_id', user.id)
            .eq('category', widget.categoryName)
            .order('score', ascending: false)
            .limit(1);

        if (response.isNotEmpty) {
          setState(() {
            highScore = response[0]['score'] as int;
          });
        }
      } catch (e) {
        debugPrint('Error fetching high score: $e');
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BubblyScaffold(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Big Hero Icon
            Hero(
              tag: widget.categoryName,
              child: Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.categoryColor.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: Icon(
                  widget.categoryIcon,
                  size: 80,
                  color: widget.categoryColor,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Title
            Text(
              widget.categoryName.replaceAll('_', ' ').toUpperCase(),
              style: GoogleFonts.fredoka(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: widget.categoryColor,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),

            // High Score Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: widget.categoryColor, width: 2),
              ),
              child: Column(
                children: [
                  Text(
                    "YOUR BEST SCORE",
                    style: GoogleFonts.fredoka(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 5),
                  isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : Text(
                    "$highScore",
                    style: GoogleFonts.bubblegumSans( // Or Fredoka
                      fontSize: 48,
                      color: widget.categoryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Play Button
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizGamePage(
                      categoryName: widget.categoryName,
                      color: widget.categoryColor,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.categoryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 8,
              ),
              child: Text(
                "START QUIZ",
                style: GoogleFonts.fredoka(fontSize: 24, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Go Back", style: GoogleFonts.fredoka(color: Colors.grey[700])),
            )
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 5. PAGE 3: THE GAME
// -----------------------------------------------------------------------------

class QuizGamePage extends StatefulWidget {
  final String categoryName;
  final Color color;

  const QuizGamePage({
    super.key,
    required this.categoryName,
    required this.color,
  });

  @override
  State<QuizGamePage> createState() => _QuizGamePageState();
}

class _QuizGamePageState extends State<QuizGamePage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  bool _hasAnswered = false;

  // Current question options
  List<String> _currentOptions = [];

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    try {
      final response = await supabase
          .from('sign_gifs')
          .select('text, gif_url')
          .eq('category', widget.categoryName);

      List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(response);

      // Shuffle questions so it's not the same order every time
      data.shuffle();

      // Limit to 10 questions max per round if there are many
      if(data.length > 10) {
        data = data.sublist(0, 10);
      }

      setState(() {
        _questions = data;
        _isLoading = false;
      });

      if (_questions.isNotEmpty) {
        _generateOptionsForCurrent();
      }
    } catch (e) {
      debugPrint("Error loading quiz: $e");
      // Handle error state appropriately in production
    }
  }

  void _generateOptionsForCurrent() {
    if (_questions.isEmpty) return;

    final correctAnswer = _questions[_currentIndex]['text'];

    // Get all possible answers from the full list to create distractors
    // Note: In a real app, you might want to fetch distinct texts from DB
    // Here we use the texts present in the current loaded batch + duplicates logic handling
    final allAnswers = _questions.map((e) => e['text'] as String).toSet().toList();

    // Remove correct answer from pool
    allAnswers.remove(correctAnswer);

    // Shuffle remaining and pick 3
    allAnswers.shuffle();
    List<String> distractors = allAnswers.take(3).toList();

    // Combine and shuffle again
    List<String> options = [correctAnswer, ...distractors];
    options.shuffle();

    setState(() {
      _currentOptions = options;
      _hasAnswered = false;
    });
  }

  void _handleAnswer(String selectedAnswer) {
    if (_hasAnswered) return;

    bool isCorrect = selectedAnswer == _questions[_currentIndex]['text'];
    setState(() {
      _hasAnswered = true;
      if (isCorrect) _score++;
    });

    // Wait a moment then go to next
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (_currentIndex < _questions.length - 1) {
        setState(() {
          _currentIndex++;
        });
        _generateOptionsForCurrent();
      } else {
        _finishQuiz();
      }
    });
  }

  Future<void> _finishQuiz() async {
    // Show loading dialog or something? For now just submit and pop.

    final user = supabase.auth.currentUser;
    if (user != null) {
      await supabase.from('categories_quiz').insert({
        'user_id': user.id,
        'category': widget.categoryName,
        'score': _score,
        'total_questions': _questions.length,
      });
    }

    if (!mounted) return;

    // Show results dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFFFFF8E1),
        title: Center(
          child: Text(
            _score == _questions.length ? "PERFECT! 🎉" : "Great Job!",
            style: GoogleFonts.fredoka(
                fontSize: 28,
                color: widget.color,
                fontWeight: FontWeight.bold
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("You scored", style: GoogleFonts.fredoka(fontSize: 18)),
            Text(
              "$_score / ${_questions.length}",
              style: GoogleFonts.fredoka(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.color,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Back to Intro Page
              },
              child: Text("Close", style: GoogleFonts.fredoka(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return BubblyScaffold(
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return BubblyScaffold(
        child: Center(
          child: Text(
            "No questions found for this category yet!",
            style: GoogleFonts.fredoka(fontSize: 20),
          ),
        ),
      );
    }

    final question = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;

    return BubblyScaffold(
      child: Column(
        children: [
          // Header / Progress
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Question ${_currentIndex + 1}/${_questions.length}",
                      style: GoogleFonts.fredoka(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: widget.color),
                      ),
                      child: Text(
                        "Score: $_score",
                        style: GoogleFonts.fredoka(
                            color: widget.color, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white,
                  color: widget.color,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(10),
                ),
              ],
            ),
          ),

          // The Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // GIF Container
                  Container(
                    height: 300,
                    width: MediaQuery.of(context).size.width * .8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        )
                      ],
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        question['gif_url'],
                        fit: BoxFit.cover,
                        loadingBuilder: (ctx, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                            ),
                          );
                        },
                        errorBuilder: (ctx, _, __) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Options
                  ..._currentOptions.map((option) {
                    bool isSelected = _hasAnswered && option == question['text'];
                    bool isWrong = _hasAnswered && option != question['text'] && option == _currentOptions.firstWhere((e) => e == option); // Simplified logic needed?

                    // Color Logic:
                    // If not answered: White
                    // If answered AND this is the correct answer: Green
                    // If answered AND this was selected BUT wrong: Red

                    Color btnColor = Colors.white;
                    Color textColor = Colors.black87;

                    if (_hasAnswered) {
                      if (option == question['text']) {
                        btnColor = Colors.greenAccent.shade100;
                        textColor = Colors.green.shade800;
                      } else if (!isSelected) { // Logic to highlight selected wrong answer is tricky with simple map, sticking to simple feedback
                        btnColor = Colors.white.withOpacity(0.5);
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () => _handleAnswer(option),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: btnColor,
                            foregroundColor: widget.color,
                            elevation: _hasAnswered ? 0 : 4,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: BorderSide(
                                    color: _hasAnswered && option == question['text']
                                        ? Colors.green
                                        : Colors.transparent,
                                    width: 2
                                )
                            ),
                          ),
                          child: Text(
                            option.toUpperCase(),
                            style: GoogleFonts.fredoka(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}