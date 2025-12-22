import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'journal_service.dart';

class JournalEntryScreen extends StatefulWidget {
  const JournalEntryScreen({Key? key}) : super(key: key);

  @override
  State<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends State<JournalEntryScreen> {
  final TextEditingController _controller = TextEditingController(
    text:
        "I've been feeling incredibly productive today! The morning started with a great workout, and I managed to clear my inbox by noon. It feels like things are finally falling into place.\n\nI think the new routine is really working for me.",
  );

  bool _isAnalyzing = false;
  String _moodTitle = 'Decoding...';
  String _aiInsight = 'Analyzing your thoughts...';
  double _sentimentScore = 0.5;

  void _analyzeEntry() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final gemini = Gemini.instance;
      final prompt =
          """
Analyze the following journal entry and provide:
1. A short mood title (2-4 words) that captures the essence (e.g., "Productive & Calm").
2. A single concise sentence of AI insight/advice.

Format your response exactly like this:
MOOD: [Title]
INSIGHT: [Sentence]
SCORE: [Number between 0 and 10, where 0 is very sad/negative and 10 is very happy/positive]

Journal Entry:
${_controller.text}
""";

      final response = await gemini.text(prompt);
      final output = response?.output ?? "";

      if (output.contains('MOOD:') && output.contains('INSIGHT:')) {
        _moodTitle = output.split('MOOD:')[1].split('INSIGHT:')[0].trim();
        _aiInsight = output.split('INSIGHT:')[1].split('SCORE:')[0].trim();

        if (output.contains('SCORE:')) {
          String scoreStr = output.split('SCORE:')[1].trim();
          double? score = double.tryParse(scoreStr);
          if (score != null) {
            _sentimentScore = score / 10.0; // Normalize to 0.0 - 1.0
          }
        }
      } else {
        _moodTitle = "Mindful Reflection";
        _aiInsight = output.isNotEmpty
            ? output
            : "Thank you for sharing your thoughts.";
      }
    } catch (e) {
      debugPrint("Gemini Error: $e");
      _moodTitle = "Connection Error";
      _aiInsight = "Error details: ${e.toString().split('\n').first}";
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
        _showAnalysisResult();
      }
    }
  }

  void _showAnalysisResult() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AnalysisResultSheet(
        moodTitle: _moodTitle,
        aiInsight: _aiInsight,
        entryContent: _controller.text,
        sentimentScore: _sentimentScore,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF13EC5B);
    const backgroundLight = Color(0xFFF6F8F6);
    const backgroundDark = Color(0xFF102216);

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? backgroundDark : backgroundLight;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDarkMode
        ? const Color(0xFF94A3B8)
        : const Color(0xFF475569);
    final inputBgColor = isDarkMode
        ? const Color(0xFF1A2C20).withOpacity(0.6)
        : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Background Gradient Decoration
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withOpacity(0.05),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                        color: textColor,
                      ),
                      Expanded(
                        child: Text(
                          'New Entry',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.manrope(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.more_horiz, size: 24),
                        color: textColor,
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        // Date & Time Header
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule,
                              size: 14,
                              color: primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'DAILY CHECK-IN',
                              style: GoogleFonts.manrope(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('MMMM dd, yyyy').format(DateTime.now()),
                          style: GoogleFonts.manrope(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('hh:mm a').format(DateTime.now()),
                          style: GoogleFonts.manrope(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: secondaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Journal Input Area
                        ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 320),
                          child: Container(
                            decoration: BoxDecoration(
                              color: inputBgColor,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: isDarkMode
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                            ),
                            child: Stack(
                              children: [
                                TextField(
                                  controller: _controller,
                                  maxLines: null,
                                  decoration: InputDecoration(
                                    hintText:
                                        'How are you feeling today? Start writing here...',
                                    hintStyle: GoogleFonts.manrope(
                                      color: secondaryTextColor.withOpacity(
                                        0.5,
                                      ),
                                      fontSize: 18,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.all(20),
                                  ),
                                  style: GoogleFonts.manrope(
                                    fontSize: 18,
                                    height: 1.6,
                                    color: isDarkMode
                                        ? Colors.white.withOpacity(0.9)
                                        : const Color(0xFF1E293B),
                                  ),
                                ),
                                const Positioned(
                                  bottom: 20,
                                  right: 20,
                                  child: Icon(
                                    Icons.auto_awesome,
                                    color: primaryColor,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Bottom Action Area
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    border: Border(
                      top: BorderSide(
                        color: isDarkMode
                            ? Colors.white.withOpacity(0.05)
                            : Colors.black.withOpacity(0.05),
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isAnalyzing
                            ? 'Searching for patterns...'
                            : 'AI analysis ready',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: secondaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: _isAnalyzing ? null : _analyzeEntry,
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 56,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: _isAnalyzing
                                ? primaryColor.withOpacity(0.5)
                                : primaryColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: _isAnalyzing
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: backgroundDark,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.psychology,
                                        color: backgroundDark,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Analyze Entry',
                                        style: GoogleFonts.manrope(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: backgroundDark,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (_isAnalyzing)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
        ],
      ),
    );
  }
}

class AnalysisResultSheet extends StatelessWidget {
  final String moodTitle;
  final String aiInsight;
  final String entryContent;
  final double sentimentScore;

  const AnalysisResultSheet({
    Key? key,
    required this.moodTitle,
    required this.aiInsight,
    required this.entryContent,
    required this.sentimentScore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF13EC5B);
    const backgroundDark = Color(0xFF102216);
    const surfaceDark = Color(0xFF1C2B21);

    return Container(
      decoration: const BoxDecoration(
        color: backgroundDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: primaryColor,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Mood Decoded',
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your mood today is',
            style: GoogleFonts.manrope(
              fontSize: 16,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            moodTitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lightbulb, color: primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'AI Insight',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  aiInsight,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    height: 1.5,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              // Save to Journal Service
              final now = DateTime.now();
              JournalService().addEntry(
                JournalEntry(
                  date: DateFormat('MMM dd, yyyy').format(now),
                  time: DateFormat('hh:mm a').format(now),
                  content: entryContent,
                  mood: moodTitle,
                  insight: aiInsight,
                  sentimentScore: sentimentScore,
                  timestamp: now,
                ),
              );

              // Close sheet and the screen to return to History
              Navigator.pop(context); // Close sheet
              Navigator.pop(context); // Close JournalEntryScreen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: backgroundDark,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              'Grateful, Save Entry',
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
