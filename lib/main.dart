import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';
import 'mood_history_screen.dart';
import 'theme_service.dart';
import 'journal_service.dart';
import 'habit_service.dart';
import 'notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeService = ThemeService();
  await themeService.init();

  final journalService = JournalService();
  await journalService.init();

  final habitService = HabitService();
  await habitService.init();

  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.scheduleDailyReminders();

  final prefs = await SharedPreferences.getInstance();
  final bool isOnboarded = prefs.getBool('is_onboarded') ?? false;
  final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;

  Widget home;
  if (!isOnboarded) {
    home = const OnboardingScreen();
  } else if (!isLoggedIn) {
    home = const LoginScreen();
  } else {
    home = const MoodHistoryScreen();
  }

  runApp(MyApp(home: home));
}

class MyApp extends StatelessWidget {
  final Widget home;
  const MyApp({super.key, required this.home});

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService();

    return ValueListenableBuilder<AppThemeMode>(
      valueListenable: themeService.themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'MindTrack',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: themeService.isDark
                ? Brightness.dark
                : Brightness.light,
            scaffoldBackgroundColor: themeService.backgroundColor,
            primaryColor: themeService.primaryColor,
            colorScheme: ColorScheme.fromSeed(
              seedColor: themeService.primaryColor,
              brightness: themeService.isDark
                  ? Brightness.dark
                  : Brightness.light,
              surface: themeService.surfaceColor,
            ),
            useMaterial3: true,
          ),
          themeMode: themeService.isDark ? ThemeMode.dark : ThemeMode.light,
          home: home,
        );
      },
    );
  }
}
