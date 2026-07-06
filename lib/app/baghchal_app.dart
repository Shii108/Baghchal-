import 'package:baghchal_app/models/ai_difficulty.dart';
import 'package:baghchal_app/screens/baghchal_screen.dart';
import 'package:baghchal_app/screens/home_screen.dart';
import 'package:baghchal_app/screens/login_screen.dart';
import 'package:baghchal_app/screens/signup_screen.dart';
import 'package:baghchal_app/screens/play_with_friend_screen.dart';
import 'package:baghchal_app/services/api_service.dart';
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
      home: FutureBuilder<String?>(
        future: ApiService.getToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // If token exists, go to home, otherwise go to login
          final isLoggedIn = snapshot.data != null;
          return isLoggedIn ? const HomeScreen() : const LoginScreen();
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/play-with-friend': (context) => const PlayWithFriendScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

