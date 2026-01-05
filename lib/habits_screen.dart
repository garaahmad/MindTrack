import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'habit_service.dart';
import 'theme_service.dart';
import 'dart:ui';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({Key? key}) : super(key: key);

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  final ThemeService _themeService = ThemeService();
  final HabitService _habitService = HabitService();
  final TextEditingController _habitController = TextEditingController();

  void _showAddHabitDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: _themeService.surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add New Habit',
                style: GoogleFonts.manrope(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _themeService.textColor,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _habitController,
                autofocus: true,
                style: GoogleFonts.manrope(color: _themeService.textColor),
                decoration: InputDecoration(
                  hintText: 'What habit do you want to start?',
                  hintStyle: GoogleFonts.manrope(
                    color: _themeService.textColorSecondary.withOpacity(0.5),
                  ),
                  filled: true,
                  fillColor: _themeService.backgroundColor.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: _themeService.primaryColor),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (_habitController.text.isNotEmpty) {
                      setState(() {
                        _habitService.addHabit(_habitController.text);
                        _habitController.clear();
                      });
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _themeService.primaryColor,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Add Habit',
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

        final habits = _habitService.habits;
        final completedCount = habits.where((h) => h.isCompleted).length;
        final progress = habits.isEmpty ? 0.0 : completedCount / habits.length;

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            backgroundColor: backgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: textColor),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Daily Habits',
              style: GoogleFonts.manrope(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                onPressed: _showAddHabitDialog,
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, color: Colors.black, size: 20),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              // Progress Card
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: textColor.withOpacity(0.05)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Daily Progress',
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  color: textColorSecondary,
                                ),
                              ),
                              Text(
                                '${(progress * 100).toInt()}% Done',
                                style: GoogleFonts.manrope(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                          CircularProgressIndicator(
                            value: progress,
                            backgroundColor: primaryColor.withOpacity(0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              primaryColor,
                            ),
                            strokeWidth: 8,
                            strokeCap: StrokeCap.round,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: primaryColor.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: habits.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.checklist_rtl_rounded,
                              size: 80,
                              color: textColorSecondary.withOpacity(0.2),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No habits added yet\nClick + to start your journey',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.manrope(
                                color: textColorSecondary,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        physics: const BouncingScrollPhysics(),
                        itemCount: habits.length,
                        itemBuilder: (context, index) {
                          final habit = habits[index];
                          return _buildHabitItem(
                            habit,
                            primaryColor,
                            surfaceColor,
                            textColor,
                            textColorSecondary,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHabitItem(
    Habit habit,
    Color primaryColor,
    Color surfaceColor,
    Color textColor,
    Color textColorSecondary,
  ) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: habit.isCompleted
              ? primaryColor.withOpacity(0.5)
              : textColor.withOpacity(0.05),
          width: 1.5,
        ),
      ),
      color: surfaceColor,
      child: InkWell(
        onTap: () {
          setState(() {
            _habitService.toggleHabit(habit.id);
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: habit.isCompleted ? primaryColor : Colors.transparent,
                  border: Border.all(
                    color: habit.isCompleted
                        ? primaryColor
                        : textColorSecondary.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: habit.isCompleted
                    ? const Icon(Icons.check, size: 22, color: Colors.black)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.title,
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: habit.isCompleted
                            ? textColor.withOpacity(0.5)
                            : textColor,
                        decoration: habit.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    Text(
                      'Completed ${habit.totalCompletions} times',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: textColorSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent.withOpacity(0.6),
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _habitService.deleteHabit(habit.id);
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
