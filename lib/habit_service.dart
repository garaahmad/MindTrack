import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Habit {
  final String id;
  final String title;
  final bool isCompleted; // Completion for today
  final int totalCompletions;
  final DateTime lastCompletionDate;

  Habit({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.totalCompletions = 0,
    required this.lastCompletionDate,
  });

  Habit copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    int? totalCompletions,
    DateTime? lastCompletionDate,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      totalCompletions: totalCompletions ?? this.totalCompletions,
      lastCompletionDate: lastCompletionDate ?? this.lastCompletionDate,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'isCompleted': isCompleted,
    'totalCompletions': totalCompletions,
    'lastCompletionDate': lastCompletionDate.toIso8601String(),
  };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
    id: json['id'],
    title: json['title'],
    isCompleted: json['isCompleted'] ?? false,
    totalCompletions: json['totalCompletions'] ?? 0,
    lastCompletionDate: DateTime.parse(json['lastCompletionDate']),
  );
}

class HabitService {
  static final HabitService _instance = HabitService._internal();
  factory HabitService() => _instance;

  HabitService._internal();

  List<Habit> _habits = [];
  List<Habit> get habits => List.unmodifiable(_habits);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final String? habitsJson = prefs.getString('user_habits');
    if (habitsJson != null) {
      final List<dynamic> decoded = jsonDecode(habitsJson);
      _habits = decoded.map((item) => Habit.fromJson(item)).toList();
      _checkDayReset();
    }
  }

  void _checkDayReset() {
    final now = DateTime.now();
    bool changed = false;
    for (int i = 0; i < _habits.length; i++) {
      final lastDate = _habits[i].lastCompletionDate;
      if (lastDate.year != now.year ||
          lastDate.month != now.month ||
          lastDate.day != now.day) {
        if (_habits[i].isCompleted) {
          _habits[i] = _habits[i].copyWith(isCompleted: false);
          changed = true;
        }
      }
    }
    if (changed) _saveHabits();
  }

  Future<void> _saveHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_habits.map((h) => h.toJson()).toList());
    await prefs.setString('user_habits', encoded);
  }

  Future<void> toggleHabit(String id) async {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index != -1) {
      final habit = _habits[index];
      final now = DateTime.now();
      bool newStatus = !habit.isCompleted;

      _habits[index] = habit.copyWith(
        isCompleted: newStatus,
        totalCompletions: newStatus
            ? habit.totalCompletions + 1
            : (habit.totalCompletions > 0 ? habit.totalCompletions - 1 : 0),
        lastCompletionDate: now,
      );
      await _saveHabits();
    }
  }

  Future<void> addHabit(String title) async {
    _habits.add(
      Habit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        lastCompletionDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
    );
    await _saveHabits();
  }

  Future<void> deleteHabit(String id) async {
    _habits.removeWhere((h) => h.id == id);
    await _saveHabits();
  }

  double getDailyCompletionRate() {
    if (_habits.isEmpty) return 0.0;
    final completed = _habits.where((h) => h.isCompleted).length;
    return completed / _habits.length;
  }
}
