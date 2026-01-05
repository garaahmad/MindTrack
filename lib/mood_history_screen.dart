import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'journal_entry_screen.dart';
import 'settings_screen.dart';
import 'habits_screen.dart';
import 'all_entries_screen.dart';
import 'explore_screen.dart';
import 'journal_service.dart';
import 'theme_service.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'habit_service.dart';

class MoodHistoryScreen extends StatefulWidget {
  const MoodHistoryScreen({Key? key}) : super(key: key);

  @override
  State<MoodHistoryScreen> createState() => _MoodHistoryScreenState();
}

class _MoodHistoryScreenState extends State<MoodHistoryScreen> {
  final ThemeService _themeService = ThemeService();

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    await JournalService().syncEntries();
    if (mounted) setState(() {});
  }

  List<double> _getCombinedScores() {
    final journalService = JournalService();
    final habitService = HabitService();
    final moodScores = journalService.getWeeklyScores();
    final habitRate = habitService.getDailyCompletionRate();
    final hasHabits = habitService.habits.isNotEmpty;
    final hasEntryToday = journalService.getMoodForDay(DateTime.now()) != null;

    List<double> combined = List.from(moodScores);

    if (combined.isNotEmpty) {
      double todayBase;
      if (!hasEntryToday) {
        // If no entry, start at neutral 0.5
        todayBase = 0.5;
        // If they have habits and completed some, increase it
        if (hasHabits) {
          todayBase += (habitRate * 0.4); // can go up to 0.9
        }
      } else {
        // Has entry, blend mood with habit progress
        double moodScore = moodScores.last;
        if (hasHabits) {
          todayBase = (moodScore + (0.5 + (habitRate * 0.5))) / 2;
        } else {
          todayBase = moodScore;
        }
      }
      combined[combined.length - 1] = todayBase;
    }

    return combined;
  }

  String _getMoodStatus(double score) {
    if (score >= 0.7) return 'Positive';
    if (score >= 0.55) return 'Elevated';
    if (score >= 0.45) return 'Steady';
    if (score >= 0.3) return 'Lowered';
    return 'Challenging';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeMode>(
      valueListenable: _themeService.themeNotifier,
      builder: (context, _, __) {
        final primaryColor = _themeService.primaryColor;
        final backgroundColor = _themeService.backgroundColor;
        final surfaceColor = _themeService.surfaceColor;
        final textColor = _themeService.textColor;
        final textColorSecondary = _themeService.textColorSecondary;

        return Scaffold(
          backgroundColor: backgroundColor,
          extendBody: true,
          body: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              color: primaryColor,
              backgroundColor: surfaceColor,
              onRefresh: () async {
                await JournalService().syncEntries();
                if (mounted) setState(() {});
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 120),
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(width: 48),
                            Text(
                              'Mood History',
                              style: GoogleFonts.manrope(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.filter_list,
                                color: textColorSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Average Mood & Graph
                      _buildMoodGraph(
                        context,
                        primaryColor,
                        textColor,
                        textColorSecondary,
                        surfaceColor,
                      ),
                      const SizedBox(height: 24),

                      // Mood Calendar
                      _buildCalendar(
                        context,
                        primaryColor,
                        textColor,
                        textColorSecondary,
                        surfaceColor,
                      ),
                      const SizedBox(height: 24),

                      // Recent Entries
                      _buildRecentEntries(
                        context,
                        primaryColor,
                        textColor,
                        textColorSecondary,
                        surfaceColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          bottomNavigationBar: _buildBottomNav(
            context,
            primaryColor,
            surfaceColor,
            textColor,
            textColorSecondary,
          ),
        );
      },
    );
  }

  Widget _buildMoodGraph(
    BuildContext context,
    Color primaryColor,
    Color textColor,
    Color textColorSecondary,
    Color surfaceColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Average Mood',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    color: textColorSecondary,
                  ),
                ),
                Text(
                  _getMoodStatus(_getCombinedScores().last),
                  style: GoogleFonts.manrope(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            Builder(
              builder: (context) {
                final scores = _getCombinedScores();
                if (scores.length < 2) return const SizedBox();

                final double today = scores.last;
                double previousSum = 0;
                for (int i = 0; i < scores.length - 1; i++)
                  previousSum += scores[i];
                double previousAvg = previousSum / (scores.length - 1);

                double percentage = 0;
                if (previousAvg != 0) {
                  percentage = ((today - previousAvg) / previousAvg) * 100;
                }

                final bool isPositive = percentage >= 0;
                final color = isPositive ? primaryColor : Colors.redAccent;

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isPositive ? Icons.trending_up : Icons.trending_down,
                        size: 14,
                        color: color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${isPositive ? "+" : ""}${percentage.toStringAsFixed(0)}%',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [surfaceColor, surfaceColor.withOpacity(0)],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: textColor.withOpacity(0.05)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              CustomPaint(
                painter: WaveGraphPainter(textColor, _getCombinedScores()),
                size: const Size(double.infinity, 180),
              ),
              Positioned(
                bottom: 8,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                        .map(
                          (day) => Text(
                            day,
                            style: GoogleFonts.manrope(
                              fontSize: 10,
                              color: textColorSecondary,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCalendar(
    BuildContext context,
    Color primaryColor,
    Color textColor,
    Color textColorSecondary,
    Color surfaceColor,
  ) {
    final now = DateTime.now();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mood Calendar',
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            Row(
              children: [
                Icon(
                  Icons.arrow_back_ios,
                  size: 12,
                  color: textColor.withOpacity(0.7),
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('MMMM yyyy').format(now),
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: textColor.withOpacity(0.7),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: textColor.withOpacity(0.05)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  final day = now.subtract(Duration(days: 6 - index));
                  final isToday = day.day == now.day && day.month == now.month;
                  final moodScore = JournalService().getMoodForDay(day);

                  Color? boxColor;
                  Color? dayTextColor;

                  if (moodScore != null) {
                    if (moodScore >= 0.6) {
                      boxColor = primaryColor;
                      dayTextColor = Colors.black;
                    } else if (moodScore <= 0.4) {
                      boxColor = Colors.redAccent;
                      dayTextColor = Colors.white;
                    } else {
                      boxColor = textColor.withOpacity(0.1);
                      dayTextColor = textColor;
                    }
                  } else {
                    boxColor = textColor.withOpacity(0.05);
                    dayTextColor = textColor.withOpacity(0.6);
                  }

                  return Expanded(
                    child: Column(
                      children: [
                        Text(
                          DateFormat('E').format(day)[0],
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: textColorSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 40,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: boxColor,
                            borderRadius: BorderRadius.circular(8),
                            border: isToday
                                ? Border.all(color: primaryColor, width: 2)
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              '${day.day}',
                              style: GoogleFonts.manrope(
                                fontSize: 14,
                                fontWeight: isToday
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: dayTextColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentEntries(
    BuildContext context,
    Color primaryColor,
    Color textColor,
    Color textColorSecondary,
    Color surfaceColor,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's Entries",
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AllEntriesScreen(),
                  ),
                );
              },
              child: Text(
                'View All',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...JournalService().entries
            .where((entry) {
              final now = DateTime.now();
              return entry.timestamp.year == now.year &&
                  entry.timestamp.month == now.month &&
                  entry.timestamp.day == now.day;
            })
            .take(5)
            .map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildEntryItem(
                  entry.mood,
                  entry.content,
                  DateFormat('MMM').format(entry.timestamp),
                  DateFormat('dd').format(entry.timestamp),
                  Icons.auto_awesome,
                  primaryColor,
                  surfaceColor,
                  textColor,
                  textColorSecondary,
                ),
              );
            })
            .toList(),
        if (JournalService().entries.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'No entries yet. Start journaling!',
                style: GoogleFonts.manrope(color: textColorSecondary),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEntryItem(
    String title,
    String subtitle,
    String month,
    String day,
    IconData moodIcon,
    Color moodColor,
    Color surfaceColor,
    Color textColor,
    Color textColorSecondary,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                month.toUpperCase(),
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: textColorSecondary,
                ),
              ),
              Text(
                day,
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Container(width: 1, height: 40, color: textColor.withOpacity(0.1)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Icon(moodIcon, size: 18, color: moodColor),
                  ],
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    color: textColorSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(
    BuildContext context,
    Color primaryColor,
    Color surfaceColor,
    Color textColor,
    Color textColorSecondary,
  ) {
    return Container(
      height: 100, // Increased to accommodate safe area and FAB
      color: Colors.transparent, // Make it transparent to see FAB overlapping
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80 + MediaQuery.of(context).padding.bottom,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom,
              ),
              decoration: BoxDecoration(
                color: surfaceColor.withOpacity(0.95),
                border: Border(
                  top: BorderSide(color: textColor.withOpacity(0.05)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ExploreScreen(),
                        ),
                      ).then((_) {
                        if (mounted) setState(() {});
                      });
                    },
                    child: _buildNavItem(
                      Icons.explore,
                      'Explore',
                      textColorSecondary,
                    ),
                  ),
                  _buildNavItem(
                    Icons.bar_chart,
                    'History',
                    textColor,
                    isSelected: true,
                    primaryColor: primaryColor,
                  ),
                  const SizedBox(width: 48), // Space for FAB
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HabitsScreen(),
                        ),
                      ).then((_) {
                        if (mounted) setState(() {});
                      });
                    },
                    child: _buildNavItem(
                      Icons.check_circle_outline,
                      'Habits',
                      textColorSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      ).then((_) {
                        if (mounted) setState(() {});
                      });
                    },
                    child: _buildNavItem(
                      Icons.settings,
                      'Settings',
                      textColorSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // FAB
          Positioned(
            bottom:
                40 +
                MediaQuery.of(
                  context,
                ).padding.bottom, // Adjusted based on bar height
            left: MediaQuery.of(context).size.width / 2 - 28,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const JournalEntryScreen(),
                  ),
                ).then((_) {
                  setState(() {});
                });
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.black,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    Color color, {
    bool isSelected = false,
    Color? primaryColor,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}

class WaveGraphPainter extends CustomPainter {
  final Color primaryColor;
  final List<double> scores;

  WaveGraphPainter(this.primaryColor, this.scores);

  @override
  void paint(Canvas canvas, Size size) {
    if (scores.isEmpty) return;

    final paint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path();
    double stepWidth = size.width / (scores.length - 1);
    path.moveTo(0, size.height * (1.0 - scores[0]));

    for (int i = 0; i < scores.length - 1; i++) {
      double x1 = i * stepWidth;
      double y1 = size.height * (1.0 - scores[i]);
      double x2 = (i + 1) * stepWidth;
      double y2 = size.height * (1.0 - scores[i + 1]);
      path.cubicTo(x1 + (x2 - x1) / 2, y1, x1 + (x2 - x1) / 2, y2, x2, y2);
    }

    canvas.drawPath(path, paint);

    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [primaryColor.withOpacity(0.2), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    final lastX = size.width;
    final lastY = size.height * (1.0 - scores.last);
    canvas.drawCircle(Offset(lastX, lastY), 4, Paint()..color = primaryColor);
  }

  @override
  bool shouldRepaint(covariant WaveGraphPainter oldDelegate) =>
      oldDelegate.scores != scores;
}
