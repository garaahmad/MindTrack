import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'hugging_face_service.dart';
import 'journal_service.dart';
import 'theme_service.dart';

class JournalEntryScreen extends StatefulWidget {
  const JournalEntryScreen({Key? key}) : super(key: key);

  @override
  State<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends State<JournalEntryScreen> {
  final ThemeService _themeService = ThemeService();
  final TextEditingController _controller = TextEditingController();

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
      final hfService = HuggingFaceService();
      final result = await hfService.analyzeEntry(_controller.text);

      _moodTitle = result["mood"];
      _aiInsight = result["insight"];
      _sentimentScore = result["score"];
    } catch (e) {
      debugPrint("HF Error: $e");
      _moodTitle = "Connection Error";
      _aiInsight =
          "I'm having a little trouble connecting. Please check your settings.";
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
    final primaryColor = _themeService.primaryColor;
    final backgroundColor = _themeService.backgroundColor;
    final textColor = _themeService.textColor;
    final textColorSecondary = _themeService.textColorSecondary;
    final surfaceColor = _themeService.surfaceColor;
    final isDarkMode = _themeService.isDark;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Background Gradient decoration
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
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          size: 20,
                          color: textColor,
                        ),
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
                        icon: Icon(
                          Icons.more_horiz,
                          size: 24,
                          color: textColor,
                        ),
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
                        Row(
                          children: [
                            Icon(Icons.schedule, size: 14, color: primaryColor),
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
                            color: textColorSecondary,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Journal Input Area
                        ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 320),
                          child: Container(
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: textColor.withOpacity(0.05),
                              ),
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
                                      color: textColorSecondary.withOpacity(
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
                                    color: textColor,
                                  ),
                                ),
                                Positioned(
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
                      top: BorderSide(color: textColor.withOpacity(0.05)),
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
                          color: textColorSecondary,
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
                                ? SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: isDarkMode
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.psychology,
                                        color: isDarkMode
                                            ? Colors.black
                                            : Colors.white,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Analyze Entry',
                                        style: GoogleFonts.manrope(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: isDarkMode
                                              ? Colors.black
                                              : Colors.white,
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
    final themeService = ThemeService();
    final primaryColor = themeService.primaryColor;
    final backgroundColor = themeService.backgroundColor;
    final surfaceColor = themeService.surfaceColor;
    final textColor = themeService.textColor;
    final textColorSecondary = themeService.textColorSecondary;
    final isDarkMode = themeService.isDark;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: textColor.withOpacity(0.05)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: textColor.withOpacity(0.1),
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
            child: Icon(Icons.auto_awesome, color: primaryColor, size: 48),
          ),
          const SizedBox(height: 24),
          Text(
            'Mood Decoded',
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your mood today is',
            style: GoogleFonts.manrope(fontSize: 16, color: textColorSecondary),
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
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: textColor.withOpacity(0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb, color: primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'AI Insight',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor,
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
                    color: textColorSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
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
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: isDarkMode ? Colors.black : Colors.white,
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
