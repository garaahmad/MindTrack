import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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
    required this.id,
    required this.date,
    required this.time,
    required this.content,
    required this.mood,
    required this.insight,
    required this.sentimentScore,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date,
    'time': time,
    'content': content,
    'mood': mood,
    'insight': insight,
    'sentimentScore': sentimentScore,
    'timestamp': timestamp.toIso8601String(),
  };

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
    id: json['id'],
    date: json['date'],
    time: json['time'],
    content: json['content'],
    mood: json['mood'],
    insight: json['insight'],
    sentimentScore: json['sentimentScore'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}

class JournalService {
  static final JournalService _instance = JournalService._internal();
  factory JournalService() => _instance;

  JournalService._internal();

  List<JournalEntry> _localEntries = [];
  List<JournalEntry> get entries => List.unmodifiable(_localEntries);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final String? entriesJson = prefs.getString('journal_entries');
    if (entriesJson != null) {
      final List<dynamic> decoded = jsonDecode(entriesJson);
      _localEntries = decoded
          .map((item) => JournalEntry.fromJson(item))
          .toList();
    }
  }

  Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(
      _localEntries.map((e) => e.toJson()).toList(),
    );
    await prefs.setString('journal_entries', encoded);
  }

  Future<void> syncEntries() async {
    // No-op for now as we use local storage
  }

  Future<void> addEntry(JournalEntry entry) async {
    _localEntries.insert(0, entry);
    await _saveEntries();
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

      // Default to 0.5 (neutral) if no data, so drops to 0.1 are visible
      weeklyScores.add(score ?? 0.5);
    }
    return weeklyScores;
  }

  double getPercentageChange() {
    List<double> scores = getWeeklyScores();
    if (scores.length < 2) return 0;

    double today = scores.last;

    // Calculate average of previous 6 days
    double previousSum = 0;
    for (int i = 0; i < 6; i++) previousSum += scores[i];
    double previousAvg = previousSum / 6;

    if (previousAvg == 0) return today > 0 ? 100 : 0;
    double change = ((today - previousAvg) / previousAvg) * 100;

    return change.clamp(-100, 100);
  }
}
