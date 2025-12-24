import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { blueBlack, greenBlack, blueWhite, greenWhite }

class ThemeService {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  final ValueNotifier<AppThemeMode> themeNotifier = ValueNotifier(
    AppThemeMode.greenBlack,
  );

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('app_theme');
    if (savedTheme != null) {
      themeNotifier.value = AppThemeMode.values.firstWhere(
        (e) => e.toString() == savedTheme,
        orElse: () => AppThemeMode.greenBlack,
      );
    }
  }

  Future<void> setTheme(AppThemeMode mode) async {
    themeNotifier.value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_theme', mode.toString());
  }

  // Color getters based on current theme
  Color get primaryColor {
    switch (themeNotifier.value) {
      case AppThemeMode.blueBlack:
      case AppThemeMode.blueWhite:
        return const Color(0xFF3B82F6);
      case AppThemeMode.greenBlack:
      case AppThemeMode.greenWhite:
        return const Color(0xFF13EC5B);
    }
  }

  Color get backgroundColor {
    switch (themeNotifier.value) {
      case AppThemeMode.blueBlack:
        return const Color(0xFF0F172A);
      case AppThemeMode.greenBlack:
        return const Color(0xFF102216);
      case AppThemeMode.blueWhite:
      case AppThemeMode.greenWhite:
        return const Color(0xFFF9FAFB);
    }
  }

  Color get surfaceColor {
    switch (themeNotifier.value) {
      case AppThemeMode.blueBlack:
        return const Color(0xFF1E293B);
      case AppThemeMode.greenBlack:
        return const Color(0xFF1C2B21);
      case AppThemeMode.blueWhite:
      case AppThemeMode.greenWhite:
        return Colors.white;
    }
  }

  Color get textColor {
    switch (themeNotifier.value) {
      case AppThemeMode.blueBlack:
      case AppThemeMode.greenBlack:
        return Colors.white;
      case AppThemeMode.blueWhite:
      case AppThemeMode.greenWhite:
        return const Color(0xFF0F172A);
    }
  }

  Color get textColorSecondary {
    switch (themeNotifier.value) {
      case AppThemeMode.blueBlack:
      case AppThemeMode.greenBlack:
        return const Color(0xFF94A3B8);
      case AppThemeMode.blueWhite:
      case AppThemeMode.greenWhite:
        return const Color(0xFF64748B);
    }
  }

  bool get isDark {
    return themeNotifier.value == AppThemeMode.blueBlack ||
        themeNotifier.value == AppThemeMode.greenBlack;
  }
}
