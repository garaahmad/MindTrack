import 'dart:math';

class JournalEntry {
  final String id;
  final String date;
  final String time;
  final String content;
  final String mood;
  final String insight;
  final double sentimentScore;
  final DateTime timestamp;

  JournalEntry({
    this.id = '',
    required this.date,
    required this.time,
    required this.content,
    required this.mood,
    required this.insight,
    required this.sentimentScore,
    required this.timestamp,
  });
}

class JournalService {
  static final JournalService _instance = JournalService._internal();
  factory JournalService() => _instance;

  JournalService._internal() {
    // Better dummy data for testing
    _localEntries = [
      JournalEntry(
        date: 'Dec 22, 2025',
        time: '10:00 AM',
        content: 'Productive day, feels good.',
        mood: 'Accomplished',
        insight: 'Keep this momentum.',
        sentimentScore: 0.8,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
      JournalEntry(
        date: 'Dec 21, 2025',
        time: '08:30 PM',
        content: 'A bit slow today.',
        mood: 'Reflective',
        insight: 'It is okay to rest.',
        sentimentScore: 0.5,
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  List<JournalEntry> _localEntries = [];
  List<JournalEntry> get entries => List.unmodifiable(_localEntries);

  Future<void> syncEntries() async => null;

  Future<void> addEntry(JournalEntry entry) async {
    _localEntries.insert(0, entry);
  }

  double? getMoodForDay(DateTime day) {
    var dayEntries = _localEntries.where(
      (e) =>
          e.timestamp.year == day.year &&
          e.timestamp.month == day.month &&
          e.timestamp.day == day.day,
    );

    if (dayEntries.isEmpty) return null;

    double daySum = 0;
    for (var e in dayEntries) daySum += e.sentimentScore;
    return daySum / dayEntries.length;
  }

  List<double> getWeeklyScores() {
    List<double> weeklyScores = [];
    DateTime now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      DateTime day = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i));
      double? score = getMoodForDay(day);

      // If no score, use 0.5 as middle ground baseline
      weeklyScores.add(score ?? 0.5);
    }
    return weeklyScores;
  }

  double getPercentageChange() {
    List<double> scores = getWeeklyScores();
    if (scores.length < 2) return 0;

    double today = scores.last;
    double baseline = 0.5; // Use 0.5 as the "neutral" baseline for comparison

    // Find average of the previous 6 days
    double previousSum = 0;
    for (int i = 0; i < 6; i++) previousSum += scores[i];
    double previousAvg = previousSum / 6;

    // Calculate change from the weekly average
    if (previousAvg == 0) return 0;
    double change = ((today - previousAvg) / previousAvg) * 100;

    // Clamp to avoid crazy numbers from small denominators
    return change.clamp(-100, 100);
  }
}
