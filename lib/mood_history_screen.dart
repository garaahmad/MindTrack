import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'journal_entry_screen.dart';
import 'settings_screen.dart';
import 'ai_chat_screen.dart';
import 'all_entries_screen.dart';
import 'explore_screen.dart';
import 'journal_service.dart';
import 'dart:ui';
import 'package:intl/intl.dart';

class MoodHistoryScreen extends StatefulWidget {
  const MoodHistoryScreen({Key? key}) : super(key: key);

  @override
  State<MoodHistoryScreen> createState() => _MoodHistoryScreenState();
}

class _MoodHistoryScreenState extends State<MoodHistoryScreen> {
  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    await JournalService().syncEntries();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF13EC5B);
    const backgroundDark = Color(0xFF102216);
    const surfaceDark = Color(0xFF1C271F);
    const textColorSecondary = Color(0xFF9DB9A6);

    return Scaffold(
      backgroundColor: backgroundDark,
      body: Stack(
        children: [
          SafeArea(
            child: RefreshIndicator(
              color: primaryColor,
              backgroundColor: surfaceDark,
              onRefresh: () async {
                await JournalService().syncEntries();
                if (mounted) setState(() {});
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
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
                                color: Colors.white,
                              ),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
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
                        textColorSecondary,
                      ),
                      const SizedBox(height: 24),

                      const SizedBox(height: 24),

                      // Mood Calendar
                      _buildCalendar(
                        context,
                        primaryColor,
                        textColorSecondary,
                        surfaceDark,
                      ),
                      const SizedBox(height: 24),

                      // Recent Entries
                      _buildRecentEntries(
                        context,
                        primaryColor,
                        textColorSecondary,
                        surfaceDark,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom Navigation
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomNav(
              context,
              primaryColor,
              surfaceDark,
              textColorSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodGraph(
    BuildContext context,
    Color primaryColor,
    Color textColorSecondary,
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
                  'Elevated',
                  style: GoogleFonts.manrope(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Builder(
              builder: (context) {
                final percentage = JournalService().getPercentageChange();
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
              colors: [const Color(0xFF1C271F), Colors.transparent],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              CustomPaint(
                painter: WaveGraphPainter(
                  primaryColor,
                  JournalService().getWeeklyScores(),
                ),
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
    Color textColorSecondary,
    Color surfaceDark,
  ) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final startWeekday =
        firstDayOfMonth.weekday % 7; // Sunday = 0, Monday = 1...

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
                color: Colors.white,
              ),
            ),
            Row(
              children: [
                const Icon(
                  Icons.arrow_back_ios,
                  size: 12,
                  color: Colors.white70,
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('MMMM yyyy').format(now),
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Colors.white70,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surfaceDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                    .map(
                      (day) => Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: textColorSecondary,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 8,
                ),
                itemCount: daysInMonth + startWeekday,
                itemBuilder: (context, index) {
                  if (index < startWeekday) return const SizedBox();

                  final dayNum = index - startWeekday + 1;
                  final date = DateTime(now.year, now.month, dayNum);
                  final isToday = dayNum == now.day;

                  // Get mood for this specific day
                  final moodScore = JournalService().getMoodForDay(date);

                  Color? boxColor;
                  Color? textColor;

                  if (moodScore != null) {
                    if (moodScore >= 0.6) {
                      boxColor = const Color(0xFF13EC5B); // Green
                      textColor = Colors.black;
                    } else if (moodScore <= 0.4) {
                      boxColor = Colors.redAccent; // Red
                      textColor = Colors.white;
                    } else {
                      boxColor = Colors.white.withOpacity(0.1); // Neutral
                      textColor = Colors.white;
                    }
                  } else {
                    boxColor = Colors.white.withOpacity(0.05);
                    textColor = Colors.white.withOpacity(0.6);
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: boxColor,
                      borderRadius: BorderRadius.circular(8),
                      border: isToday
                          ? Border.all(color: Colors.white, width: 2)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '$dayNum',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: isToday
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                    ),
                  );
                },
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
    Color textColorSecondary,
    Color surfaceDark,
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
                color: Colors.white,
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
                  surfaceDark,
                  textColorSecondary,
                ),
              );
            })
            .toList(),
        if (JournalService().entries.where((entry) {
          final now = DateTime.now();
          return entry.timestamp.year == now.year &&
              entry.timestamp.month == now.month &&
              entry.timestamp.day == now.day;
        }).isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'No entries today. Start writing!',
                style: GoogleFonts.manrope(color: textColorSecondary),
              ),
            ),
          ),
        Center(
          child: Text(
            'No entries yet. Start journaling!',
            style: GoogleFonts.manrope(color: textColorSecondary),
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
    Color surfaceDark,
    Color textColorSecondary,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
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
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Container(width: 1, height: 40, color: Colors.white.withOpacity(0.1)),
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
                        color: Colors.white,
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
    Color surfaceDark,
    Color textColorSecondary,
  ) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: surfaceDark.withOpacity(0.95),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ExploreScreen(),
                    ),
                  );
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
                Colors.white,
                isSelected: true,
                primaryColor: primaryColor,
              ),
              const SizedBox(width: 48), // Space for FAB
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AIChatScreen(),
                    ),
                  );
                },
                child: _buildNavItem(
                  Icons.chat_bubble,
                  'AI Chat',
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
                  );
                },
                child: _buildNavItem(
                  Icons.settings,
                  'Settings',
                  textColorSecondary,
                ),
              ),
            ],
          ),
          Positioned(
            top: -24,
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

    // Normalize coordinates
    double stepWidth = size.width / (scores.length - 1);

    // Starting point
    path.moveTo(0, size.height * (1.0 - scores[0]));

    for (int i = 0; i < scores.length - 1; i++) {
      double x1 = i * stepWidth;
      double y1 = size.height * (1.0 - scores[i]);
      double x2 = (i + 1) * stepWidth;
      double y2 = size.height * (1.0 - scores[i + 1]);

      // Control points for smooth curve
      double controlPointX1 = x1 + (x2 - x1) / 2;
      double controlPointX2 = x1 + (x2 - x1) / 2;

      path.cubicTo(controlPointX1, y1, controlPointX2, y2, x2, y2);
    }

    canvas.drawPath(path, paint);

    // Area under the curve
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

    // Current day point
    final lastX = size.width;
    final lastY = size.height * (1.0 - scores.last);

    final pointPaint = Paint()..color = primaryColor;
    canvas.drawCircle(Offset(lastX, lastY), 4, pointPaint);
  }

  @override
  bool shouldRepaint(covariant WaveGraphPainter oldDelegate) =>
      oldDelegate.scores != scores;
}
