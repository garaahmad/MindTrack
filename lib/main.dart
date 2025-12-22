import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase disabled for local testing
  Gemini.init(apiKey: 'AIzaSyDdmXKgnTM1XYmTadSAs4lDYzvN9sBgg8Y');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MindTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF6F8F6),
        primaryColor: const Color(0xFF13EC5B),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF102216),
        primaryColor: const Color(0xFF13EC5B),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.dark,
      home: const OnboardingScreen(),
    );
  }
}
