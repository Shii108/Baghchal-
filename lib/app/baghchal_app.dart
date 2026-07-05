import 'package:baghchal_app/models/ai_difficulty.dart';
import 'package:baghchal_app/screens/baghchal_screen.dart';
import 'package:baghchal_app/theme/app_theme.dart';
import 'package:flutter/material.dart';

// ─── Main App ─────────────────────────────────────────────
class BaghchalApp extends StatefulWidget {
  const BaghchalApp({super.key});

  @override
  State<BaghchalApp> createState() => _BaghchalAppState();
}

class _BaghchalAppState extends State<BaghchalApp> {
  AppTheme _currentTheme = AppTheme.green;
  AIDifficulty _difficulty = AIDifficulty.medium;

  void _changeTheme() {
    final values = AppTheme.values;
    final currentIndex = values.indexOf(_currentTheme);
    final nextIndex = (currentIndex + 1) % values.length;
    setState(() => _currentTheme = values[nextIndex]);
  }

  void _changeDifficulty() {
    final values = AIDifficulty.values;
    final currentIndex = values.indexOf(_difficulty);
    final nextIndex = (currentIndex + 1) % values.length;
    setState(() => _difficulty = values[nextIndex]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baghchal',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0f1f13),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1a2e1f),
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFFf7f0dc),
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
      ),
      home: BaghchalScreen(
        key: ValueKey(_currentTheme),
        theme: _currentTheme,
        onThemeChange: _changeTheme,
        difficulty: _difficulty,
        onDifficultyChange: _changeDifficulty,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

