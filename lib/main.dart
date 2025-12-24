import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'onboarding_screen.dart';
import 'theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize ThemeService
  final themeService = ThemeService();
  await themeService.init();

  // Gemini init (existing)
  Gemini.init(apiKey: 'API--- Don/t use my API');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
              background: themeService.backgroundColor,
              surface: themeService.surfaceColor,
            ),
            useMaterial3: true,
          ),
          themeMode: themeService.isDark ? ThemeMode.dark : ThemeMode.light,
          home: const OnboardingScreen(),
        );
      },
    );
  }
}
