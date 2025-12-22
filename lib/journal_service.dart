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
    // Add some dummy data for testing
    _localEntries = [
      JournalEntry(
        date: 'Dec 22, 2025',
        time: '10:00 AM',
        content: 'Had a great start to the day with some meditation.',
        mood: 'Calm & Focused',
        insight: 'Meditation is key to your morning routine.',
        sentimentScore: 0.8,
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      JournalEntry(
        date: 'Dec 21, 2025',
        time: '08:30 PM',
        content: 'Feeling a bit tired but satisfied with the work done.',
        mood: 'Productive but Tired',
        insight: 'Rest is just as important as work.',
        sentimentScore: 0.6,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
      JournalEntry(
        date: 'Dec 20, 2025',
        time: '02:15 PM',
        content: 'Great session with the team today!',
        mood: 'Energetic',
        insight: 'Collaboration brings out the best in you.',
        sentimentScore: 0.9,
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  List<JournalEntry> _localEntries = [];
  List<JournalEntry> get entries => List.unmodifiable(_localEntries);

  Future<void> syncEntries() async {
    // No-op for local test mode
    return;
  }

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

  double getAverageMoodScore() {
    if (_localEntries.isEmpty) return 0.5;
    double sum = 0;
    for (var entry in _localEntries) {
      sum += entry.sentimentScore;
    }
    return sum / _localEntries.length;
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
      weeklyScores.add(
        score ?? (weeklyScores.isEmpty ? 0.5 : weeklyScores.last),
      );
    }
    return weeklyScores;
  }

  double getPercentageChange() {
    List<double> weeklyScores = getWeeklyScores();
    if (weeklyScores.length < 2) return 0;

    double current = weeklyScores.last;
    double previous = weeklyScores[weeklyScores.length - 2];

    if (previous == 0) return current > 0 ? 100 : 0;
    return ((current - previous) / previous) * 100;
  }
}
